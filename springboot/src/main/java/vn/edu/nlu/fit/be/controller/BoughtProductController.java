package vn.edu.nlu.fit.be.controller;

import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import vn.edu.nlu.fit.be.model.Account;
import vn.edu.nlu.fit.be.model.Order;
import vn.edu.nlu.fit.be.service.OrderService;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Controller
public class BoughtProductController {

    private final OrderService orderService;

    public BoughtProductController(OrderService orderService) {
        this.orderService = orderService;
    }

    @GetMapping("/bought-product")
    public String boughtProduct(HttpSession session, Model model) {
        Account acc = (Account) session.getAttribute("USER");
        if (acc == null) return "redirect:/login";

        // Mỗi đơn kèm danh sách item (đã JOIN sản phẩm)
        List<Map<String, Object>> orders = new ArrayList<>();
        for (Order o : orderService.getMyOrders(acc.getAccountId())) {
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("order", o);
            row.put("items", orderService.getOrderItems(o.getOrderId()));
            orders.add(row);
        }
        model.addAttribute("orders", orders);
        return "bought_product";
    }
}
