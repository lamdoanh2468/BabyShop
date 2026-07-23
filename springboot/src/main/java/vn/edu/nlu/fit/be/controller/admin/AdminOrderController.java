package vn.edu.nlu.fit.be.controller.admin;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import vn.edu.nlu.fit.be.model.Order;
import vn.edu.nlu.fit.be.service.OrderService;

@Controller
public class AdminOrderController {

    private final OrderService orderService;

    public AdminOrderController(OrderService orderService) {
        this.orderService = orderService;
    }

    @GetMapping("/admin/orders")
    public String list(Model model) {
        model.addAttribute("orders", orderService.getAllOrdersWithUser());
        return "admin/orders";
    }

    @GetMapping("/admin/orders/detail")
    public String detail(@RequestParam int id, Model model) {
        Order order = orderService.getOrder(id);
        if (order == null) return "redirect:/admin/orders";
        model.addAttribute("order", order);
        model.addAttribute("items", orderService.getOrderItems(id));
        return "admin/order_detail";
    }

    @PostMapping("/admin/orders/status")
    public String updateStatus(@RequestParam int id, @RequestParam String status) {
        orderService.updateStatus(id, status);
        return "redirect:/admin/orders/detail?id=" + id;
    }
}
