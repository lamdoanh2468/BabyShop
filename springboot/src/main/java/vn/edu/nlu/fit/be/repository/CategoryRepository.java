package vn.edu.nlu.fit.be.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import vn.edu.nlu.fit.be.model.Category;

public interface CategoryRepository extends JpaRepository<Category, Integer> {
    // findAll(), findById() có sẵn
}
