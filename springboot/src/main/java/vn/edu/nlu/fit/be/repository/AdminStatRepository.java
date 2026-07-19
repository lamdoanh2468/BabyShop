package vn.edu.nlu.fit.be.repository;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

/**
 * Thống kê cho trang admin overview — tương đương AdminOverviewDao.
 * Toàn bộ là truy vấn aggregate read-only trên orders/order_details.
 */
@Repository
public class AdminStatRepository {

    private final JdbcTemplate jdbc;

    public AdminStatRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public int totalRevenue() {
        Integer v = jdbc.queryForObject(
                "SELECT COALESCE(SUM(total_amount),0) FROM orders WHERE status = 'Done'", Integer.class);
        return v == null ? 0 : v;
    }

    public int totalOrders() {
        Integer v = jdbc.queryForObject("SELECT COUNT(*) FROM orders", Integer.class);
        return v == null ? 0 : v;
    }

    public int totalCustomers() {
        Integer v = jdbc.queryForObject("SELECT COUNT(*) FROM accounts", Integer.class);
        return v == null ? 0 : v;
    }

    public int totalProducts() {
        Integer v = jdbc.queryForObject("SELECT COUNT(*) FROM products", Integer.class);
        return v == null ? 0 : v;
    }

    // [{month, revenue}] theo tháng (status Done)
    public List<Map<String, Object>> revenueByMonth() {
        return jdbc.queryForList(
                "SELECT MONTH(order_date) AS month, SUM(total_amount) AS revenue" +
                " FROM orders WHERE status = 'Done' GROUP BY MONTH(order_date) ORDER BY month");
    }

    // [{categoryName, totalOrders}]
    public List<Map<String, Object>> ordersByCategory() {
        return jdbc.queryForList(
                "SELECT c.category_name AS categoryName, COUNT(o.order_id) AS totalOrders" +
                " FROM orders o" +
                " JOIN order_details od ON o.order_id = od.order_id" +
                " JOIN products p ON od.product_id = p.product_id" +
                " JOIN categories c ON p.category_id = c.category_id" +
                " GROUP BY c.category_name");
    }

    // 5 đơn gần nhất kèm tên khách
    public List<Map<String, Object>> recentOrders(int limit) {
        return jdbc.queryForList(
                "SELECT o.order_id AS orderId, a.username AS username, o.total_amount AS totalAmount," +
                " o.order_date AS orderDate, o.status AS statusOrder" +
                " FROM orders o JOIN accounts a ON o.account_id = a.account_id" +
                " ORDER BY o.order_date DESC LIMIT ?", limit);
    }
}
