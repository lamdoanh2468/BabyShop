package vn.edu.nlu.fit.be.repository;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

/**
 * Bảng favorite_products (account_id, product_id). Toggle bằng exists/insert/delete —
 * tương đương FavoriteProductDao cũ. Danh sách sản phẩm yêu thích nằm ở ProductRepository.
 */
@Repository
public class FavoriteRepository {

    private final JdbcTemplate jdbc;

    public FavoriteRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public boolean exists(int accountId, int productId) {
        Integer one = jdbc.query(
                "SELECT 1 FROM favorite_products WHERE account_id = ? AND product_id = ?",
                rs -> rs.next() ? 1 : null, accountId, productId);
        return one != null;
    }

    public void insert(int accountId, int productId) {
        jdbc.update("INSERT INTO favorite_products (account_id, product_id) VALUES (?, ?)",
                accountId, productId);
    }

    public void delete(int accountId, int productId) {
        jdbc.update("DELETE FROM favorite_products WHERE account_id = ? AND product_id = ?",
                accountId, productId);
    }
}
