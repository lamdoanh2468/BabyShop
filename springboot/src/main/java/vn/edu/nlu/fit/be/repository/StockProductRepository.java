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
}
