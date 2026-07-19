package vn.edu.nlu.fit.be.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import vn.edu.nlu.fit.be.model.Product;

import java.util.List;

public interface ProductRepository extends JpaRepository<Product, Integer>, ProductRepositoryCustom {

    // getLatestProductsByCategory(catId, 20) — 20 sản phẩm mới nhất theo category (trang chủ)
    List<Product> findTop20ByCategoryIdOrderByCreatedAtDesc(int categoryId);
}
