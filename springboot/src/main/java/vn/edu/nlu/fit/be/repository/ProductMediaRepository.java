package vn.edu.nlu.fit.be.repository;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

/**
 * Ảnh + khối nội dung chi tiết của sản phẩm — tương đương
 * ProductDao.getImagesListInProduct / getProductDetails.
 */
@Repository
public class ProductMediaRepository {

    private final JdbcTemplate jdbc;

    public ProductMediaRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    // Danh sách URL ảnh của sản phẩm (cho carousel)
    public List<String> images(int productId) {
        return jdbc.queryForList(
                "SELECT img.image FROM product_images img" +
                " JOIN products p ON img.product_id = p.product_id" +
                " WHERE img.product_id = ?",
                String.class, productId);
    }

    // Các khối mô tả + ảnh chi tiết (tab "Chi tiết")
    public List<Map<String, Object>> details(int productId) {
        return jdbc.queryForList(
                "SELECT detail_image, description FROM product_details" +
                " WHERE product_id = ? ORDER BY product_detail_id ASC",
                productId);
    }
}
