package vn.edu.nlu.fit.be.repository;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

/**
 * Truy vấn tồn kho — tương đương StockProductDao (checkAvailable) + ProductDao.getTotalSoldQuantity.
 * Dùng JdbcTemplate cho các truy vấn scalar đơn giản.
 */
@Repository
public class StockProductRepository {

    private final JdbcTemplate jdbc;

    public StockProductRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    // Tổng đã bán của 1 sản phẩm
    public int totalSold(int productId) {
        Integer sum = jdbc.queryForObject(
                "SELECT COALESCE(SUM(sold_quantity),0) FROM stock_products WHERE product_id = ?",
                Integer.class, productId);
        return sum == null ? 0 : sum;
    }

    // Còn hàng nếu tổng total_quantity > 0
    public boolean isAvailable(int productId) {
        Integer available = jdbc.queryForObject(
                "SELECT COALESCE(SUM(total_quantity),0) FROM stock_products WHERE product_id = ?",
                Integer.class, productId);
        return available != null && available > 0;
    }

    // Tổng tồn khả dụng của 1 sản phẩm
    public int totalAvailable(int productId) {
        Integer v = jdbc.queryForObject(
                "SELECT COALESCE(SUM(total_quantity),0) FROM stock_products WHERE product_id = ?",
                Integer.class, productId);
        return v == null ? 0 : v;
    }

    /**
     * Trừ kho khi đặt đơn: chọn kho có đủ hàng nhiều nhất, giảm total_quantity và tăng sold_quantity.
     * Trả false nếu không kho nào đủ. Tương đương StockProductDao.reserveProduct + increaseSoldQuantity.
     */
    public boolean deductForOrder(int productId, int qty) {
        Integer stockId = jdbc.query(
                "SELECT stock_id FROM stock_products WHERE product_id = ? AND total_quantity >= ?" +
                " ORDER BY total_quantity DESC LIMIT 1",
                rs -> rs.next() ? rs.getInt(1) : null, productId, qty);
        if (stockId == null) return false;
        int rows = jdbc.update(
                "UPDATE stock_products SET total_quantity = total_quantity - ?, sold_quantity = sold_quantity + ?" +
                " WHERE product_id = ? AND stock_id = ? AND total_quantity >= ?",
                qty, qty, productId, stockId, qty);
        return rows > 0;
    }
}
