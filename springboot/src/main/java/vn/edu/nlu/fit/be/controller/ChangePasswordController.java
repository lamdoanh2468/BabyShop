package vn.edu.nlu.fit.be.controller;

import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import vn.edu.nlu.fit.be.model.Account;
import vn.edu.nlu.fit.be.service.AccountService;

@Controller
public class ChangePasswordController {

    private final AccountService accountService;

    public ChangePasswordController(AccountService accountService) {
        this.accountService = accountService;
    }

    @GetMapping("/change-password")
    public String form(HttpSession session) {
        if (session.getAttribute("USER") == null) return "redirect:/login";
        return "change_password";
    }

    @PostMapping("/change-password")
    public String change(@RequestParam String oldPassword,
                         @RequestParam String newPassword,
                         @RequestParam String confirmPassword,
                         HttpSession session, Model model) {
        Account acc = (Account) session.getAttribute("USER");
        if (acc == null) return "redirect:/login";

        if (!newPassword.equals(confirmPassword)) {
            model.addAttribute("error", "Mật khẩu xác nhận không khớp");
            return "change_password";
        }

        boolean ok = accountService.changePassword(acc.getAccountId(), oldPassword, newPassword);
        if (ok) {
            model.addAttribute("success", "Đổi mật khẩu thành công");
        } else {
            model.addAttribute("error", "Mật khẩu hiện tại không đúng");
        }
        return "change_password";
    }
}
