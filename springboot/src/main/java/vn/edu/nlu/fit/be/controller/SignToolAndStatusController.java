package vn.edu.nlu.fit.be.controller;

import jakarta.servlet.http.HttpSession;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import vn.edu.nlu.fit.be.model.Account;
import vn.edu.nlu.fit.be.model.Order;
import vn.edu.nlu.fit.be.service.OrderService;

import java.util.Map;

@Controller
public class SignToolAndStatusController {

    private final OrderService orderService;

    public SignToolAndStatusController(OrderService orderService) {
        this.orderService = orderService;
    }

    /**
     * Tải tool ký (desktop). File OrderSignApp.zip KHÔNG có trong repo —
     * đặt vào src/main/resources/downloads/OrderSignApp.zip để phục vụ. Nếu thiếu -> 404.
     */
    @GetMapping("/signing-tool/download")
    public ResponseEntity<Resource> downloadTool(HttpSession session) {
        if (session.getAttribute("USER") == null) return ResponseEntity.status(401).build();
        Resource res = new ClassPathResource("downloads/OrderSignApp.zip");
        if (!res.exists()) return ResponseEntity.notFound().build();
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"OrderSignApp.zip\"")
                .contentType(MediaType.APPLICATION_OCTET_STREAM)
                .body(res);
    }

    // Trạng thái đơn (poll từ client). Trả JSON {success, status}.
    @GetMapping("/order/status")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> orderStatus(@RequestParam int orderId, HttpSession session) {
        Account acc = (Account) session.getAttribute("USER");
        if (acc == null) return ResponseEntity.status(401).build();
        Order order = orderService.getOrder(orderId);
        if (order == null || order.getAccountId() != acc.getAccountId()) {
            return ResponseEntity.ok(Map.of("success", false));
        }
        return ResponseEntity.ok(Map.of("success", true, "status", order.getStatus()));
    }
}
