package vn.edu.nlu.fit.be.model;

import jakarta.persistence.*;
import java.sql.Date;

@Entity
@Table(name = "vouchers")
public class Voucher {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "voucher_id")
    private int voucherId;

    @Column(name = "voucher_code")
    private String voucherCode;

    @Column(name = "voucher_name")
    private String voucherName;

    @Column(name = "voucher_image")
    private String voucherImage;

    @Column(name = "description")
    private String description;

    @Column(name = "discount_amount")
    private int discountAmount;

    @Column(name = "start_date")
    private Date startDate;

    @Column(name = "end_date")
    private Date endDate;

    public Voucher() {
    }

    public int getVoucherId() { return voucherId; }
    public void setVoucherId(int voucherId) { this.voucherId = voucherId; }

    public String getVoucherCode() { return voucherCode; }
    public void setVoucherCode(String voucherCode) { this.voucherCode = voucherCode; }

    public String getVoucherName() { return voucherName; }
    public void setVoucherName(String voucherName) { this.voucherName = voucherName; }

    public String getVoucherImage() { return voucherImage; }
    public void setVoucherImage(String voucherImage) { this.voucherImage = voucherImage; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public int getDiscountAmount() { return discountAmount; }
    public void setDiscountAmount(int discountAmount) { this.discountAmount = discountAmount; }

    public Date getStartDate() { return startDate; }
    public void setStartDate(Date startDate) { this.startDate = startDate; }

    public Date getEndDate() { return endDate; }
    public void setEndDate(Date endDate) { this.endDate = endDate; }
}
