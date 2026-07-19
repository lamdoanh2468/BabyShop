package vn.edu.nlu.fit.be.service;

import org.springframework.stereotype.Service;
import vn.edu.nlu.fit.be.repository.StockProductRepository;

@Service
public class StockProductService {

    private final StockProductRepository stockRepo;

    public StockProductService(StockProductRepository stockRepo) {
        this.stockRepo = stockRepo;
    }

    public boolean checkProductAvailable(int productId) {
        return stockRepo.isAvailable(productId);
    }
}
