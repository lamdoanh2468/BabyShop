package vn.edu.nlu.fit.be.controller;

import jakarta.servlet.http.HttpSession;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import vn.edu.nlu.fit.be.model.Account;
import vn.edu.nlu.fit.be.model.Certificate;
import vn.edu.nlu.fit.be.service.CertificateService;

import java.util.Optional;

@Controller
public class SecurityKeyController {

    private final CertificateService certificateService;

    public SecurityKeyController(CertificateService certificateService) {
        this.certificateService = certificateService;
    }

    @GetMapping("/security-key")
    public String page(HttpSession session, Model model) {
        Account acc = (Account) session.getAttribute("USER");
        if (acc == null) return "redirect:/login";
        Optional<Certificate> cert = certificateService.getActiveCertByAccountId(acc.getAccountId());
        model.addAttribute("hasCert", cert.isPresent());
        model.addAttribute("cert", cert.orElse(null));
        model.addAttribute("hasPendingKey", certificateService.hasPendingPrivateKey(acc.getAccountId()));
        return "security_key";
    }

    // Cấp chứng thư + cặp khoá mới
    @PostMapping("/security-key/create")
    public String create(HttpSession session, org.springframework.web.servlet.mvc.support.RedirectAttributes ra) {
        Account acc = (Account) session.getAttribute("USER");
        if (acc == null) return "redirect:/login";
        try {
            certificateService.createNewCertAccount(acc.getAccountId());
            ra.addFlashAttribute("msg", "Đã cấp chứng thư mới. Tải private key và lưu an toàn (chỉ tải được 1 lần).");
        } catch (Exception e) {
            ra.addFlashAttribute("err", "Không thể cấp chứng thư: " + e.getMessage());
        }
        return "redirect:/security-key";
    }

    // Thu hồi cert hiện tại (báo mất khoá)
    @PostMapping("/security-key/revoke")
    public String revoke(@RequestParam(required = false) String reason, HttpSession session,
                         org.springframework.web.servlet.mvc.support.RedirectAttributes ra) {
        Account acc = (Account) session.getAttribute("USER");
        if (acc == null) return "redirect:/login";
        certificateService.revokeActiveCertByLostKey(acc.getAccountId(),
                reason == null || reason.isBlank() ? "Người dùng báo mất khoá" : reason);
        ra.addFlashAttribute("msg", "Đã thu hồi chứng thư. Hãy cấp chứng thư mới để ký đơn.");
        return "redirect:/security-key";
    }

    // Tải private key (đúng 1 lần, sau đó file bị xoá)
    @GetMapping("/security-key/download-private-key")
    public ResponseEntity<byte[]> downloadPrivateKey(HttpSession session) throws Exception {
        Account acc = (Account) session.getAttribute("USER");
        if (acc == null) return ResponseEntity.status(401).build();
        byte[] key = certificateService.consumePrivateKey(acc.getAccountId());
        if (key == null) {
            return ResponseEntity.status(404).body("Private key không còn (đã tải hoặc chưa cấp).".getBytes());
        }
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION,
                        "attachment; filename=\"account_" + acc.getAccountId() + "_private.key\"")
                .contentType(MediaType.APPLICATION_OCTET_STREAM)
                .body(key);
    }
}
