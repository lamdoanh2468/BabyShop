package vn.edu.nlu.fit.be.controller.admin;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import vn.edu.nlu.fit.be.repository.AdminStatRepository;

@Controller
public class AdminOverviewController {

    private final AdminStatRepository stats;

    public AdminOverviewController(AdminStatRepository stats) {
        this.stats = stats;
    }

    @GetMapping("/admin/overview")
    public String overview(Model model) {
        model.addAttribute("totalRevenue", stats.totalRevenue());
        model.addAttribute("totalOrders", stats.totalOrders());
        model.addAttribute("totalCustomers", stats.totalCustomers());
        model.addAttribute("totalProducts", stats.totalProducts());
        // List<Map> -> Thymeleaf th:inline="javascript" tự serialize sang JSON cho Chart.js
        model.addAttribute("revenueByMonth", stats.revenueByMonth());
        model.addAttribute("ordersByCategory", stats.ordersByCategory());
        model.addAttribute("recentOrders", stats.recentOrders(5));
        return "admin/overview";
    }
}
