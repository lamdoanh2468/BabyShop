package vn.edu.nlu.fit.be.repository;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.Query;
import org.springframework.stereotype.Repository;
import vn.edu.nlu.fit.be.model.Product;

import java.util.*;

@Repository
public class ProductRepositoryImpl implements ProductRepositoryCustom {

    @PersistenceContext
    private EntityManager em;

    @Override
    public List<Product> search(Integer categoryId, String[] brandNames, String sortType,
                                String keyword, Integer limit, Integer offset) {
        boolean hasBrand = brandNames != null && brandNames.length > 0;
        boolean hasKeyword = keyword != null && !keyword.isEmpty();

        // Map thẳng về entity Product => chỉ SELECT p.* (không kèm total_sold).
        StringBuilder sql = new StringBuilder("SELECT p.* FROM products p");
        sql.append(" LEFT JOIN stock_products sp ON p.product_id = sp.product_id");
        sql.append(" LEFT JOIN brands b ON p.brand_id = b.brand_id");
        sql.append(" WHERE 1=1");
        if (categoryId != null) sql.append(" AND p.category_id = :catId");
        if (hasKeyword)         sql.append(" AND LOWER(p.product_name) LIKE LOWER(:keyword)");
        if (hasBrand)           sql.append(" AND b.brand_name IN (:brands)");
        // product_id là PK nên MySQL 8 chấp nhận SELECT p.* với GROUP BY p.product_id
        sql.append(" GROUP BY p.product_id");
        sql.append(orderClause(sortType));
        if (limit != null)  sql.append(" LIMIT :limit");
        if (offset != null) sql.append(" OFFSET :offset");

        Query q = em.createNativeQuery(sql.toString(), Product.class);
        if (categoryId != null) q.setParameter("catId", categoryId);
        if (hasKeyword)         q.setParameter("keyword", "%" + keyword + "%");
        if (hasBrand)           q.setParameter("brands", Arrays.asList(brandNames));
        if (limit != null)      q.setParameter("limit", limit);
        if (offset != null)     q.setParameter("offset", offset);

        @SuppressWarnings("unchecked")
        List<Product> result = q.getResultList();
        return result;
    }

    @Override
    public long countBy(Integer categoryId, String[] brandNames, String keyword) {
        boolean hasBrand = brandNames != null && brandNames.length > 0;
        boolean hasKeyword = keyword != null && !keyword.isEmpty();

        StringBuilder sql = new StringBuilder("SELECT COUNT(DISTINCT p.product_id) FROM products p");
        sql.append(" LEFT JOIN brands b ON p.brand_id = b.brand_id");
        sql.append(" WHERE 1=1");
        if (categoryId != null) sql.append(" AND p.category_id = :catId");
        if (hasKeyword)         sql.append(" AND LOWER(p.product_name) LIKE LOWER(:keyword)");
        if (hasBrand)           sql.append(" AND b.brand_name IN (:brands)");

        Query q = em.createNativeQuery(sql.toString());
        if (categoryId != null) q.setParameter("catId", categoryId);
        if (hasKeyword)         q.setParameter("keyword", "%" + keyword + "%");
        if (hasBrand)           q.setParameter("brands", Arrays.asList(brandNames));

        return ((Number) q.getSingleResult()).longValue();
    }

    @Override
    public Map<Integer, Integer> soldMap(List<Integer> productIds) {
        Map<Integer, Integer> map = new HashMap<>();
        if (productIds == null || productIds.isEmpty()) return map;

        Query q = em.createNativeQuery(
                "SELECT product_id, COALESCE(SUM(sold_quantity),0) FROM stock_products" +
                " WHERE product_id IN (:ids) GROUP BY product_id");
        q.setParameter("ids", productIds);

        @SuppressWarnings("unchecked")
        List<Object[]> rows = q.getResultList();
        for (Object[] row : rows) {
            map.put(((Number) row[0]).intValue(), ((Number) row[1]).intValue());
        }
        // Sản phẩm không có bản ghi tồn kho => coi như đã bán 0
        for (Integer id : productIds) map.putIfAbsent(id, 0);
        return map;
    }

    private String orderClause(String sortType) {
        if (sortType == null) return " ORDER BY p.product_id DESC";
        return switch (sortType) {
            case "price_asc"    -> " ORDER BY p.product_price ASC";
            case "price_desc"   -> " ORDER BY p.product_price DESC";
            case "oldest"       -> " ORDER BY p.created_at ASC";
            case "latest"       -> " ORDER BY p.created_at DESC";
            case "best_selling" -> " ORDER BY SUM(sp.sold_quantity) DESC";
            default             -> " ORDER BY p.product_id DESC";
        };
    }
}
