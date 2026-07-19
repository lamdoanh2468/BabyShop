package vn.edu.nlu.fit.be.repository;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

/**
 * Đánh giá sản phẩm — tương đương ReviewDao.getReviewsByProductId.
 * Trả về List<Map> (giống mapToMap() của JDBI cũ) để template đọc rv.username / rv.comment / rv.created_at.
 */
@Repository
public class ReviewRepository {

    private final JdbcTemplate jdbc;

    public ReviewRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public List<Map<String, Object>> findByProductId(int productId) {
        String sql = "SELECT r.*, a.username FROM reviews r " +
                "JOIN accounts a ON r.account_id = a.account_id " +
                "WHERE r.product_id = ? ORDER BY r.created_at DESC";
        return jdbc.queryForList(sql, productId);
    }

    public void insert(int accountId, int productId, String comment) {
        jdbc.update("INSERT INTO reviews (account_id, product_id, comment, created_at)" +
                " VALUES (?, ?, ?, NOW())", accountId, productId, comment);
    }
}
