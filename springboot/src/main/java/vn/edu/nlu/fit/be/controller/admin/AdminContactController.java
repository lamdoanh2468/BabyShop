package vn.edu.nlu.fit.be.controller.admin;

import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import vn.edu.nlu.fit.be.repository.ContactRepository;

@Controller
public class AdminContactController {

    private final ContactRepository contactRepo;

    public AdminContactController(ContactRepository contactRepo) {
        this.contactRepo = contactRepo;
    }

    @GetMapping("/admin/contacts")
    public String contacts(@RequestParam(required = false) String action,
                           @RequestParam(required = false) Integer id, Model model) {
        // Xoá (giữ hành vi GET như bản cũ; redirect để refresh không xoá lại)
        if ("delete".equals(action) && id != null) {
            contactRepo.deleteById(id);
            return "redirect:/admin/contacts";
        }
        if ("view".equals(action) && id != null) {
            model.addAttribute("selectedContact", contactRepo.findById(id).orElse(null));
        }
        model.addAttribute("contactList", contactRepo.findAll(Sort.by(Sort.Direction.DESC, "contactId")));
        return "admin/contacts";
    }
}
