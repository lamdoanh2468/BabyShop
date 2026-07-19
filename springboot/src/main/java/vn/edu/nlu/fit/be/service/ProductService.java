package vn.edu.nlu.fit.be.service;

import org.springframework.stereotype.Service;
import vn.edu.nlu.fit.be.model.Product;
import vn.edu.nlu.fit.be.repository.ProductMediaRepository;
import vn.edu.nlu.fit.be.repository.ProductRepository;
import vn.edu.nlu.fit.be.repository.StockProductRepository;

import java.util.List;
import java.util.Map;

@Service
public class ProductService {

    private final ProductRepository productRepo;
    private final ProductMediaRepository mediaRepo;
    private final StockProductRepository stockRepo;

    public ProductService(ProductRepository productRepo,
                          ProductMediaRepository mediaRepo,
                          StockProductRepository stockRepo) {
        this.productRepo = productRepo;
        this.mediaRepo = mediaRepo;
        this.stockRepo = stockRepo;
    }

    public Product getProductById(int id) {
        return productRepo.findById(id).orElse(null);
    }

    // ==== Cho trang chi tiết sản phẩm ====

    public int getTotalSoldQuantity(int productId) {
        return stockRepo.totalSold(productId);
    }

    public List<String> getImagesListInProduct(int productId) {
        return mediaRepo.images(productId);
    }

    public List<Map<String, Object>> getProductDetails(int productId) {
        return mediaRepo.details(productId);
    }

    // 20 sản phẩm mới nhất theo category — cho trang chủ
    public List<Product> getLatestProductsByCategory(int categoryId) {
        return productRepo.findTop20ByCategoryIdOrderByCreatedAtDesc(categoryId);
    }

    // Danh sách sản phẩm có lọc + phân trang — cho /product-list
    public List<Product> getProducts(Integer categoryId, String[] brandNames, String sortType,
                                     String keyword, int pageIndex, int pageSize) {
        int offset = (pageIndex - 1) * pageSize;
        return productRepo.search(categoryId, brandNames, sortType, keyword, pageSize, offset);
    }

    public int countTotalProductsBy(Integer categoryId, String[] brands, String keyword) {
        return (int) productRepo.countBy(categoryId, brands, keyword);
    }

    // Map productId -> tổng đã bán (1 query, không N+1)
    public Map<Integer, Integer> getSoldMap(List<Product> products) {
        List<Integer> ids = products.stream().map(Product::getProductId).toList();
        return productRepo.soldMap(ids);
    }
}
