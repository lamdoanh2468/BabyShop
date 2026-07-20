package vn.edu.nlu.fit.be.controller.admin;

import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import vn.edu.nlu.fit.be.model.Account;
import vn.edu.nlu.fit.be.model.Profile;
import vn.edu.nlu.fit.be.repository.ProfileRepository;
import vn.edu.nlu.fit.be.service.AccountService;

@Controller
public class AdminSettingController {

    private final AccountService accountService;
    private final ProfileRepository profileRepo;

    public AdminSettingController(AccountService accountService, ProfileRepository profileRepo) {
        this.accountService = accountService;
        this.profileRepo = profileRepo;
    }

    @GetMapping("/admin/settings")
    public String settings(HttpSession session, Model model) {
        Account acc = (Account) session.getAttribute("USER");
        model.addAttribute("admin", acc);
        Profile p = (acc == null) ? null : profileRepo.findById(acc.getProfileId()).orElse(null);
        model.addAttribute("profileFullName", p != null ? p.getFullName() : "");
        return "admin/settings";
    }

    @PostMapping("/admin/settings")
    public String update(@RequestParam(required = false) String action,
                         @RequestParam(required = false) String fullName,
                         @RequestParam(required = false) String email,
                         @RequestParam(required = false) String password,
                         HttpSession session) {
        Account acc = (Account) session.getAttribute("USER");
        if (acc == null) return "redirect:/login";

        if (!"update".equals(action) && action != null) {
            // giữ nhánh khác an toàn (vd action lạ) -> quay lại settings
            return "redirect:/admin/settings";
        }

        Account updated = accountService.updateAdminSelf(acc.getAccountId(), fullName, email, password);
        if (updated != null) {
            session.setAttribute("USER", updated); // refresh session để header/hiển thị đúng
        }
        return "redirect:/admin/settings";
    }
}
