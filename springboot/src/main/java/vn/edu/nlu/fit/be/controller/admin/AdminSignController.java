package vn.edu.nlu.fit.be.controller.admin;

import jakarta.servlet.http.HttpSession;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import vn.edu.nlu.fit.be.model.Account;

/**
 * Admin xem trạng thái ký của các đơn. Route /admin-sign KHÔNG khớp /admin/** nên tự guard role.
 */
@Controller
public class AdminSignController {

    private final JdbcTemplate jdbc;

    public AdminSignController(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @GetMapping("/admin-sign")
    public String list(HttpSession session, Model model) {
        Account acc = (Account) session.getAttribute("USER");
        if (acc == null) return "redirect:/login";
        if (acc.getRole() == null || acc.getRole() <= 0) return "redirect:/";

        model.addAttribute("signs", jdbc.queryForList(
                "SELECT os.order_id AS orderId, a.username AS username, os.order_hash AS orderHash," +
                " os.status AS status, os.created_at AS createdAt, os.verified_at AS verifiedAt" +
                " FROM order_signs os JOIN orders o ON os.order_id = o.order_id" +
                " JOIN accounts a ON o.account_id = a.account_id ORDER BY os.order_sign_id DESC"));
        return "admin/sign_list";
    }
}
