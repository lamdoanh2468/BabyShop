package vn.edu.nlu.fit.be.model;

import jakarta.persistence.*;

@Entity
@Table(name = "brands")
public class Brand {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "brand_id")
    private int brandId;

    @Column(name = "brand_name")
    private String brandName;

    @Column(name = "brand_logo")
    private String brandLogo;

    // Cột thật trong bảng brands là "description"
    @Column(name = "description")
    private String brandDescription;

    public Brand() {
    }

    public int getBrandId() { return brandId; }
    public void setBrandId(int brandId) { this.brandId = brandId; }

    public String getBrandName() { return brandName; }
    public void setBrandName(String brandName) { this.brandName = brandName; }

    public String getBrandLogo() { return brandLogo; }
    public void setBrandLogo(String brandLogo) { this.brandLogo = brandLogo; }

    public String getBrandDescription() { return brandDescription; }
    public void setBrandDescription(String brandDescription) { this.brandDescription = brandDescription; }
}
