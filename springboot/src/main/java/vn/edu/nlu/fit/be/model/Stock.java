package vn.edu.nlu.fit.be.model;

import jakarta.persistence.*;

@Entity
@Table(name = "stocks")
public class Stock {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "stock_id")
    private int stockId;

    @Column(name = "stock_name")
    private String stockName;

    @Column(name = "stock_address")
    private String stockAddress;

    public Stock() {
    }

    public int getStockId() { return stockId; }
    public void setStockId(int stockId) { this.stockId = stockId; }

    public String getStockName() { return stockName; }
    public void setStockName(String stockName) { this.stockName = stockName; }

    public String getStockAddress() { return stockAddress; }
    public void setStockAddress(String stockAddress) { this.stockAddress = stockAddress; }
}
