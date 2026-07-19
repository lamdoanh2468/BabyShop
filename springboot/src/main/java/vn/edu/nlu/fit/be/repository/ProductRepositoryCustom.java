package vn.edu.nlu.fit.be.repository;

import vn.edu.nlu.fit.be.model.Product;

import java.util.List;
import java.util.Map;

/**
 * Query động cho danh sách sản phẩm — tương đương ProductDao.getProductsBy / countTotalProductsBy
 * của bản JSP. Tách riêng vì lọc nhiều điều kiện + sort theo cột tính toán (total_sold) không map
 * được sang derived query của Spring Data.
 */
public interface ProductRepositoryCustom {

    List<Product> search(Integer categoryId, String[] brandNames, String sortType,
                         String keyword, Integer limit, Integer offset);

    long countBy(Integer categoryId, String[] brandNames, String keyword);

    /** Tổng đã bán theo từng productId — gộp 1 query thay cho vòng lặp N+1 ở bản cũ. */
    Map<Integer, Integer> soldMap(List<Integer> productIds);
}
