package vn.edu.nlu.fit.be.model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Giỏ hàng lưu trong HttpSession (không phải entity). Giữ nguyên logic bản JSP cũ.
 */
public class Cart implements Serializable {

    private final Map<Integer, CartItem> data = new HashMap<>();

    public void addItem(Product product, int quantity) {
        if (quantity <= 0) quantity = 1;
        CartItem existing = data.get(product.getProductId());
        if (existing != null) {
            existing.updateQuantity(quantity);
        } else {
            data.put(product.getProductId(), new CartItem(quantity, product.getProductPrice(), product));
        }
    }

    public boolean updateItem(int productId, int quantity) {
        CartItem item = data.get(productId);
        if (item == null) return false;
        if (quantity <= 0) quantity = 1;
        item.setQuantity(quantity);
        return true;
    }

    public CartItem removeItem(int productId) {
        return data.remove(productId);
    }

    public List<CartItem> removeAllItems() {
        List<CartItem> items = new ArrayList<>(data.values());
        data.clear();
        return items;
    }

    public List<CartItem> getItems() {
        return new ArrayList<>(data.values());
    }

    public CartItem get(int productId) {
        return data.get(productId);
    }

    public int getTotalQuantity() {
        int total = 0;
        for (CartItem item : data.values()) total += item.getQuantity();
        return total;
    }

    public int getTotalPrice() {
        int total = 0;
        for (CartItem item : data.values()) total += item.getQuantity() * item.getPrice();
        return total;
    }
}
