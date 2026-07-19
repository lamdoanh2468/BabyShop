package vn.edu.nlu.fit.be.controller;

import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import vn.edu.nlu.fit.be.model.Account;
import vn.edu.nlu.fit.be.service.ProfileService;

@Controller
public class ProfileController {

    private final ProfileService profileService;

    public ProfileController(ProfileService profileService) {
        this.profileService = profileService;
    }

    @GetMapping("/profile")
    public String profile(HttpSession session, Model model) {
        Account user = (Account) session.getAttribute("USER");
        if (user == null) return "redirect:/login";

        model.addAttribute("profile", profileService.findById(user.getProfileId()));
        return "profile";
    }

    @PostMapping("/profile")
    public String updateProfile(@RequestParam(required = false) String fullName,
                                @RequestParam(required = false) String phone,
                                @RequestParam(required = false) String address,
                                @RequestParam(required = false) String gender,
                                @RequestParam(required = false) String birthDate,
                                HttpSession session) {
        Account user = (Account) session.getAttribute("USER");
        if (user == null) return "redirect:/login";

        profileService.updateProfile(user.getProfileId(), fullName, phone, address, gender, birthDate);
        return "redirect:/profile";
    }
}
