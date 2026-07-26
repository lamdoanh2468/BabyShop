package vn.edu.nlu.fit.be.controller;

import jakarta.servlet.http.HttpSession;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import vn.edu.nlu.fit.be.model.Account;
import vn.edu.nlu.fit.be.model.Certificate;
import vn.edu.nlu.fit.be.service.CertificateService;
import vn.edu.nlu.fit.be.service.OrderSigningService;

import java.util.LinkedHashMap;
import java.util.Map;

@Controller
public class OrderSignController {

    private final OrderSigningService orderSigningService;
    private final CertificateService certificateService;

    public OrderSignController(OrderSigningService orderSigningService, CertificateService certificateService) {
        this.orderSigningService = orderSigningService;
        this.certificateService = certificateService;
    }

    // Tải file JSON dữ liệu đơn để ký bằng tool (chứa orderHash + certificateId).
    @GetMapping("/order-sign/order-json")
    public ResponseEntity<Map<String, Object>> orderJson(@RequestParam int orderId, HttpSession session) {
        Account acc = (Account) session.getAttribute("USER");
        if (acc == null) return ResponseEntity.status(401).build();

        Map<String, Object> sign = orderSigningService.getLatestSign(orderId);
        if (sign == null) return ResponseEntity.notFound().build();
        if (((Number) sign.get("account_id")).intValue() != acc.getAccountId()) {
            return ResponseEntity.status(403).build();
        }
        Certificate cert = certificateService.getActiveCertByAccountId(acc.getAccountId()).orElse(null);

        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("orderId", orderId);
        payload.put("accountId", acc.getAccountId());
        payload.put("certificateId", cert == null ? 0 : cert.getCertificateId());
        payload.put("orderHash", sign.get("order_hash"));
        payload.put("hashAlgorithm", sign.get("hash_algorithm"));
        payload.put("signatureAlgorithm", "SHA256withRSA");

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"order_to_sign_" + orderId + ".json\"")
                .contentType(MediaType.APPLICATION_JSON)
                .body(payload);
    }
}
