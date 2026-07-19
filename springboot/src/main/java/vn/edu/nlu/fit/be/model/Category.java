package vn.edu.nlu.fit.be.model;

import jakarta.persistence.*;

@Entity
@Table(name = "categories")
public class Category {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "category_id")
    private int categoryId;

    @Column(name = "category_name")
    private String categoryName;

    @Column(name = "category_image")
    private String categoryImage;

    @Column(name = "description")
    private String description;

    public Category() {
    }

    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public String getCategoryImage() { return categoryImage; }
    public void setCategoryImage(String categoryImage) { this.categoryImage = categoryImage; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}
