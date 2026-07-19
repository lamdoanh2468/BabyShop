package vn.edu.nlu.fit.be.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import vn.edu.nlu.fit.be.model.Product;

import java.util.List;

public interface ProductRepository extends JpaRepository<Product, Integer>, ProductRepositoryCustom {

    // getLatestProductsByCategory(catId, 20) — 20 sản phẩm mới nhất theo category (trang chủ)
    List<Product> findTop20ByCategoryIdOrderByCreatedAtDesc(int categoryId);

    // Danh sách sản phẩm yêu thích của 1 tài khoản (favorite_products JOIN products)
    @Query(value = "SELECT p.* FROM favorite_products fp" +
            " JOIN products p ON fp.product_id = p.product_id" +
            " WHERE fp.account_id = :accountId ORDER BY fp.favorite_id DESC", nativeQuery = true)
    List<Product> findFavoritesByAccountId(@Param("accountId") int accountId);
}
