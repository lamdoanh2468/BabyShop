package vn.edu.nlu.fit.be.controller.admin;

import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import vn.edu.nlu.fit.be.model.Account;
import vn.edu.nlu.fit.be.model.AccountStatus;
import vn.edu.nlu.fit.be.model.Profile;
import vn.edu.nlu.fit.be.repository.ProfileRepository;
import vn.edu.nlu.fit.be.service.AccountService;

@Controller
public class AdminAccountController {

    private final AccountService accountService;
    private final ProfileRepository profileRepo;

    public AdminAccountController(AccountService accountService, ProfileRepository profileRepo) {
        this.accountService = accountService;
        this.profileRepo = profileRepo;
    }

    /* ===== LIST + SEARCH + FORM ADD ===== */
    @GetMapping("/admin/accounts")
    public String list(@RequestParam(required = false) String action,
                       @RequestParam(required = false) String search, Model model) {
        if ("add".equals(action)) {
            return "admin/account_form";
        }
        model.addAttribute("accounts",
                (search != null && !search.isBlank()) ? accountService.search(search) : accountService.getAll());
        return "admin/accounts";
    }

    /* ===== ADD ACCOUNT ===== */
    @PostMapping("/admin/accounts")
    public String add(@RequestParam String username, @RequestParam String email,
                      @RequestParam String password, @RequestParam(defaultValue = "0") int role) {
        accountService.adminAdd(username, email, password, role);
        return "redirect:/admin/accounts";
    }

    /* ===== KHOÁ/MỞ TÀI KHOẢN ===== */
    @PostMapping("/admin/accounts/updateStatus")
    public String updateStatus(@RequestParam int id, @RequestParam String status) {
        accountService.updateStatus(id, AccountStatus.from(status));
        return "redirect:/admin/accounts";
    }

    /* ===== XOÁ (chặn tự xoá chính mình) ===== */
    @PostMapping("/admin/accounts/delete")
    public String delete(@RequestParam int id, HttpSession session) {
        Account current = (Account) session.getAttribute("USER");
        if (current != null && current.getAccountId() == id) {
            return "redirect:/admin/accounts?error=self-delete";
        }
        accountService.deleteById(id);
        return "redirect:/admin/accounts";
    }

    /* ===== AJAX: xem profile của 1 account (JSON) ===== */
    @GetMapping("/admin/accounts/profile")
    @ResponseBody
    public Profile profile(@RequestParam int accountId) {
        Account acc = accountService.getById(accountId);
        if (acc == null) return null;
        return profileRepo.findById(acc.getProfileId()).orElse(null);
    }
}
