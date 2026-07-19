package vn.edu.nlu.fit.be.model;

import java.io.Serializable;

public class CartItem implements Serializable {
    private int quantity;
    private int price;
    private Product product;

    public CartItem() {
    }

    public CartItem(int quantity, int price, Product product) {
        this.quantity = quantity;
        this.price = price;
        this.product = product;
    }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public int getPrice() { return price; }
    public void setPrice(int price) { this.price = price; }

    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }

    // Cộng dồn số lượng (khi thêm sản phẩm đã có trong giỏ)
    public void updateQuantity(int quantity) {
        this.quantity += quantity;
    }
}
