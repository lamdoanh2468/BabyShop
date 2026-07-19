package vn.edu.nlu.fit.be.service;

import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import vn.edu.nlu.fit.be.model.Category;
import vn.edu.nlu.fit.be.repository.CategoryRepository;

import java.util.List;

@Service
public class CategoryService {

    private final CategoryRepository categoryRepo;

    public CategoryService(CategoryRepository categoryRepo) {
        this.categoryRepo = categoryRepo;
    }

    public List<Category> getAllCategories() {
        return categoryRepo.findAll(Sort.by("categoryId"));
    }

    public Category getCategoryById(int id) {
        return categoryRepo.findById(id).orElse(null);
    }
}
