package vn.edu.nlu.fit.be.controller;

import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import vn.edu.nlu.fit.be.model.Account;
import vn.edu.nlu.fit.be.service.ContactService;

import java.util.Map;

@Controller
public class ContactController {

    private final ContactService contactService;

    public ContactController(ContactService contactService) {
        this.contactService = contactService;
    }

    @GetMapping("/contact")
    public String contactPage() {
        return "contact";
    }

    // Gửi liên hệ (AJAX) — trả JSON {status, message} như bản cũ
    @PostMapping("/contact")
    @ResponseBody
    public ResponseEntity<Map<String, String>> submit(@RequestParam(name = "name", required = false) String fullName,
                                                       @RequestParam(required = false) String phone,
                                                       @RequestParam(required = false) String email,
                                                       @RequestParam(required = false) String address,
                                                       @RequestParam(required = false) String message,
                                                       HttpSession session) {
        Account acc = (Account) session.getAttribute("USER");
        if (acc == null) {
            return ResponseEntity.ok(Map.of("status", "error", "message", "Bạn cần đăng nhập để gửi liên hệ."));
        }
        if (isBlank(fullName) || isBlank(phone) || isBlank(email) || isBlank(message)) {
            return ResponseEntity.ok(Map.of("status", "error", "message", "Vui lòng nhập đầy đủ thông tin"));
        }
        try {
            contactService.createContact(acc.getAccountId(), fullName, phone, email,
                    address == null ? "" : address, message);
            return ResponseEntity.ok(Map.of("status", "success",
                    "message", "Liên hệ của bạn đã được gửi. Chúng tôi sẽ liên lạc với bạn sớm nhất"));
        } catch (Exception e) {
            return ResponseEntity.ok(Map.of("status", "error", "message", "Lỗi máy chủ, vui lòng thử lại sau."));
        }
    }

    private static boolean isBlank(String s) {
        return s == null || s.isBlank();
    }
}
