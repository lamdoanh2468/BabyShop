package vn.edu.nlu.fit.be.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import vn.edu.nlu.fit.be.dto.SignedOrderReq;
import vn.edu.nlu.fit.be.model.Account;
import vn.edu.nlu.fit.be.service.SignVerifyService;

import java.util.Map;

@Controller
public class SignUploadController {

    private final SignVerifyService signVerifyService;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public SignUploadController(SignVerifyService signVerifyService) {
        this.signVerifyService = signVerifyService;
    }

    // Upload file chữ ký (.json) -> verify. Trả JSON {success, status, message}.
    @PostMapping("/upload-signature")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> upload(@RequestParam("signedOrderFile") MultipartFile file,
                                                      HttpSession session) {
        Account acc = (Account) session.getAttribute("USER");
        if (acc == null) {
            return ResponseEntity.status(401).body(Map.of("success", false, "message", "Chưa đăng nhập"));
        }
        try {
            SignedOrderReq req = objectMapper.readValue(file.getBytes(), SignedOrderReq.class);
            SignVerifyService.Result r = signVerifyService.verify(req, acc.getAccountId());
            return ResponseEntity.ok(Map.of(
                    "success", r.success(), "status", r.status(), "message", r.message()));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "success", false, "message", "File chữ ký không hợp lệ: " + e.getMessage()));
        }
    }
}
