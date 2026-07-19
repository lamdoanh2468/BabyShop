package vn.edu.nlu.fit.be.model;

import jakarta.persistence.*;
import java.sql.Timestamp;

@Entity
@Table(name = "products")
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "product_id")
    private int productId;

    @Column(name = "category_id")
    private int categoryId;

    @Column(name = "brand_id")
    private int brandId;

    @Column(name = "product_image")
    private String productImage;

    @Column(name = "product_name")
    private String productName;

    @Column(name = "product_price")
    private int productPrice;

    @Column(name = "product_size")
    private String productSize;

    @Column(name = "product_material")
    private String productMaterial;

    @Column(name = "created_at")
    private Timestamp createdAt;

    public Product() {
    }

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

    public int getBrandId() { return brandId; }
    public void setBrandId(int brandId) { this.brandId = brandId; }

    public String getProductImage() { return productImage; }
    public void setProductImage(String productImage) { this.productImage = productImage; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public int getProductPrice() { return productPrice; }
    public void setProductPrice(int productPrice) { this.productPrice = productPrice; }

    public String getProductSize() { return productSize; }
    public void setProductSize(String productSize) { this.productSize = productSize; }

    public String getProductMaterial() { return productMaterial; }
    public void setProductMaterial(String productMaterial) { this.productMaterial = productMaterial; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
