package vn.edu.nlu.fit.be.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import vn.edu.nlu.fit.be.model.Brand;

public interface BrandRepository extends JpaRepository<Brand, Integer> {
    // findAll(), findById() có sẵn
}
