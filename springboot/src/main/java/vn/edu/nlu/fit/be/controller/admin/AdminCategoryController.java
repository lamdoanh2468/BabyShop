package vn.edu.nlu.fit.be.controller.admin;

import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import vn.edu.nlu.fit.be.model.Category;
import vn.edu.nlu.fit.be.repository.CategoryRepository;

@Controller
public class AdminCategoryController {

    private final CategoryRepository categoryRepo;

    public AdminCategoryController(CategoryRepository categoryRepo) {
        this.categoryRepo = categoryRepo;
    }

    @GetMapping("/admin/categories")
    public String list(@RequestParam(required = false) String action,
                       @RequestParam(required = false) Integer id, Model model) {
        model.addAttribute("categories", categoryRepo.findAll(Sort.by("categoryId")));
        if ("edit".equals(action) && id != null) {
            model.addAttribute("category", categoryRepo.findById(id).orElse(null));
        }
        return "admin/categories";
    }

    @PostMapping("/admin/categories")
    public String modify(@RequestParam String action,
                         @RequestParam(required = false) Integer id,
                         @RequestParam(required = false) String categoryName,
                         @RequestParam(required = false) String categoryImage,
                         @RequestParam(required = false) String description) {
        switch (action) {
            case "create" -> {
                Category c = new Category();
                c.setCategoryName(categoryName);
                c.setCategoryImage(categoryImage);
                c.setDescription(description);
                categoryRepo.save(c);
            }
            case "update" -> {
                if (id != null) {
                    Category c = categoryRepo.findById(id).orElse(null);
                    if (c != null) {
                        c.setCategoryName(categoryName);
                        c.setCategoryImage(categoryImage);
                        c.setDescription(description);
                        categoryRepo.save(c);
                    }
                }
            }
            case "delete" -> {
                if (id != null) categoryRepo.deleteById(id);
            }
        }
        return "redirect:/admin/categories";
    }
}
