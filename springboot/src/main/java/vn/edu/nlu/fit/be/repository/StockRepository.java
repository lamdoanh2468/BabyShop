package vn.edu.nlu.fit.be.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import vn.edu.nlu.fit.be.model.Stock;

public interface StockRepository extends JpaRepository<Stock, Integer> {
}
