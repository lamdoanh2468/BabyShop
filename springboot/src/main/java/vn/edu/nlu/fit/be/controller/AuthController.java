package vn.edu.nlu.fit.be.controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import vn.edu.nlu.fit.be.model.Account;
import vn.edu.nlu.fit.be.service.AccountService;
import vn.edu.nlu.fit.be.service.EmailService;
import vn.edu.nlu.fit.be.service.OtpService;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@Controller
public class AuthController {

    private static final long OTP_TTL_MS = 60_000; // 60 giây, như bản cũ

    private final AccountService accountService;
    private final OtpService otpService;
    private final EmailService emailService;
    private final String googleClientId;
    private final String googleRedirectUri;

    public AuthController(AccountService accountService, OtpService otpService, EmailService emailService,
                          @Value("${google.client-id:}") String googleClientId,
                          @Value("${google.redirect-uri:}") String googleRedirectUri) {
        this.accountService = accountService;
        this.otpService = otpService;
        this.emailService = emailService;
        this.googleClientId = googleClientId;
        this.googleRedirectUri = googleRedirectUri;
    }

    /* ===================== LOGIN ===================== */

    @GetMapping("/login")
    public String loginForm(@RequestParam(name = "returnUrl", required = false) String returnUrl,
                            @RequestParam(name = "error", required = false) String error, Model model) {
        model.addAttribute("returnUrl", returnUrl);
        model.addAttribute("googleAuthUrl", buildGoogleAuthUrl());
        if ("blocked".equals(error)) model.addAttribute("error", "Tài khoản của bạn đã bị khoá.");
        else if ("google_not_configured".equals(error)) model.addAttribute("error", "Đăng nhập Google chưa được cấu hình.");
        else if ("google".equals(error)) model.addAttribute("error", "Đăng nhập Google thất bại, vui lòng thử lại.");
        return "login";
    }

    // URL Google authorize (null nếu chưa cấu hình client-id)
    private String buildGoogleAuthUrl() {
        if (googleClientId == null || googleClientId.isBlank()) return null;
        return "https://accounts.google.com/o/oauth2/v2/auth?response_type=code&access_type=online"
                + "&scope=" + URLEncoder.encode("email profile", StandardCharsets.UTF_8)
                + "&client_id=" + URLEncoder.encode(googleClientId, StandardCharsets.UTF_8)
                + "&redirect_uri=" + URLEncoder.encode(googleRedirectUri, StandardCharsets.UTF_8);
    }

    @PostMapping("/login")
    public String login(@RequestParam String username,
                        @RequestParam String password,
                        @RequestParam(name = "returnUrl", required = false) String returnUrl,
                        HttpServletRequest request,
                        Model model) {
        Account acc;
        try {
            acc = accountService.login(username, password);
        } catch (IllegalStateException e) {
            model.addAttribute("error", e.getMessage());
            model.addAttribute("returnUrl", returnUrl);
            return "login";
        }

        if (acc == null) {
            model.addAttribute("error", "Sai tên đăng nhập hoặc mật khẩu!");
            model.addAttribute("returnUrl", returnUrl);
            return "login";
        }

        HttpSession session = request.getSession(true);
        session.setAttribute("USER", acc);
        session.setMaxInactiveInterval(30 * 60); // 30 phút

        // Admin -> trang quản trị (nhóm admin migrate sau)
        if (acc.getRole() != null && acc.getRole() == 1) {
            return "redirect:/admin/overview";
        }

        if (returnUrl != null && !returnUrl.isBlank()) {
            return "redirect:" + returnUrl;
        }
        return "redirect:/";
    }

    /* ===================== REGISTER ===================== */

    @GetMapping("/register")
    public String registerForm() {
        return "register";
    }

    @PostMapping("/register")
    public String register(@RequestParam String username,
                           @RequestParam String email,
                           @RequestParam String password,
                           @RequestParam String confirmPassword,
                           HttpSession session,
                           Model model) {
        if (!password.equals(confirmPassword)) {
            model.addAttribute("error", "Mật khẩu không khớp!");
            return "register";
        }
        if (accountService.existsByEmail(email)) {
            model.addAttribute("error", "Email đã được sử dụng!");
            return "register";
        }

        String otp = otpService.generateOTP();
        emailService.sendOTP(email, otp);

        session.setAttribute("OTP", otp);
        session.setAttribute("OTP_TIME", System.currentTimeMillis());
        session.setAttribute("REGISTER_USERNAME", username);
        session.setAttribute("REGISTER_EMAIL", email);
        session.setAttribute("REGISTER_PASS", password);

        return "redirect:/verify-otp";
    }

    /* ===================== VERIFY OTP ===================== */

    @GetMapping("/verify-otp")
    public String verifyOtpForm(HttpSession session) {
        // Truy cập trực tiếp khi chưa đăng ký -> về trang đăng ký
        if (session.getAttribute("REGISTER_EMAIL") == null) {
            return "redirect:/register";
        }
        return "verify-otp";
    }

    @PostMapping("/verify-otp")
    public String verifyOtp(@RequestParam("otp") String inputOtp, HttpSession session, Model model) {
        String sessionOtp = (String) session.getAttribute("OTP");
        Long otpTime = (Long) session.getAttribute("OTP_TIME");

        if (sessionOtp == null || otpTime == null) {
            model.addAttribute("error", "OTP không hợp lệ!");
            return "verify-otp";
        }
        if (System.currentTimeMillis() - otpTime > OTP_TTL_MS) {
            model.addAttribute("error", "OTP đã hết hạn!");
            return "verify-otp";
        }
        if (!sessionOtp.equals(inputOtp)) {
            model.addAttribute("error", "OTP không đúng!");
            return "verify-otp";
        }

        String username = (String) session.getAttribute("REGISTER_USERNAME");
        String email = (String) session.getAttribute("REGISTER_EMAIL");
        String pass = (String) session.getAttribute("REGISTER_PASS");

        accountService.register(username, email, pass);

        session.invalidate();
        return "redirect:/login";
    }

    @GetMapping("/resend-otp")
    public String resendOtp(HttpSession session, Model model) {
        String email = (String) session.getAttribute("REGISTER_EMAIL");
        if (email == null) {
            model.addAttribute("error", "Phiên làm việc đã hết hạn, vui lòng đăng ký lại!");
            return "register";
        }
        String otp = otpService.generateOTP();
        emailService.sendOTP(email, otp);
        session.setAttribute("OTP", otp);
        session.setAttribute("OTP_TIME", System.currentTimeMillis());
        model.addAttribute("message", "Đã gửi lại mã OTP!");
        return "verify-otp";
    }

    /* ===================== LOGOUT ===================== */

    @GetMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/";
    }
}
