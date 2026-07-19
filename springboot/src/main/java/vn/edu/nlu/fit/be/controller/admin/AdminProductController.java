package vn.edu.nlu.fit.be.controller.admin;

import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import vn.edu.nlu.fit.be.model.Category;
import vn.edu.nlu.fit.be.model.Product;
import vn.edu.nlu.fit.be.repository.BrandRepository;
import vn.edu.nlu.fit.be.repository.CategoryRepository;
import vn.edu.nlu.fit.be.repository.ProductRepository;

import java.util.LinkedHashMap;
import java.util.Map;

@Controller
public class AdminProductController {

    private final ProductRepository productRepo;
    private final CategoryRepository categoryRepo;
    private final BrandRepository brandRepo;

    public AdminProductController(ProductRepository productRepo,
                                  CategoryRepository categoryRepo,
                                  BrandRepository brandRepo) {
        this.productRepo = productRepo;
        this.categoryRepo = categoryRepo;
        this.brandRepo = brandRepo;
    }

    @GetMapping("/admin/products")
    public String list(@RequestParam(required = false) String action,
                       @RequestParam(required = false) Integer id, Model model) {
        loadFormData(model);
        if ("add".equals(action) || "edit".equals(action)) {
            if ("edit".equals(action) && id != null) {
                model.addAttribute("product", productRepo.findById(id).orElse(null));
            }
            return "admin/product_form";
        }
        model.addAttribute("products", productRepo.findAll(Sort.by(Sort.Direction.DESC, "productId")));
        return "admin/products";
    }

    @PostMapping("/admin/products")
    public String modify(@RequestParam String action,
                         @RequestParam(required = false) Integer productId,
                         @RequestParam(required = false) Integer id,
                         @RequestParam(required = false) String productName,
                         @RequestParam(required = false) Integer productPrice,
                         @RequestParam(required = false) Integer categoryId,
                         @RequestParam(required = false) Integer brandId,
                         @RequestParam(required = false) String productSize,
                         @RequestParam(required = false) String productMaterial,
                         @RequestParam(required = false) String productImage) {
        switch (action) {
            case "create" -> productRepo.save(build(new Product(), productName, productPrice,
                    categoryId, brandId, productSize, productMaterial, productImage));
            case "update" -> {
                if (productId != null) {
                    Product p = productRepo.findById(productId).orElse(null);
                    if (p != null) {
                        productRepo.save(build(p, productName, productPrice, categoryId, brandId,
                                productSize, productMaterial, productImage));
                    }
                }
            }
            case "delete" -> {
                if (id != null) productRepo.deleteById(id);
            }
        }
        return "redirect:/admin/products";
    }

    private Product build(Product p, String name, Integer price, Integer catId, Integer brandId,
                          String size, String material, String image) {
        p.setProductName(name);
        if (price != null) p.setProductPrice(price);
        if (catId != null) p.setCategoryId(catId);
        if (brandId != null) p.setBrandId(brandId);
        p.setProductSize(size);
        p.setProductMaterial(material);
        p.setProductImage(image);
        return p;
    }

    private void loadFormData(Model model) {
        var categories = categoryRepo.findAll(Sort.by("categoryId"));
        model.addAttribute("categories", categories);
        model.addAttribute("brands", brandRepo.findAll(Sort.by("brandId")));
        Map<Integer, String> categoryMap = new LinkedHashMap<>();
        for (Category c : categories) categoryMap.put(c.getCategoryId(), c.getCategoryName());
        model.addAttribute("categoryMap", categoryMap);
    }
}
