package vn.edu.nlu.fit.be.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import vn.edu.nlu.fit.be.service.CategoryService;
import vn.edu.nlu.fit.be.service.ProductService;

@Controller
public class HomeController {

    private final ProductService productService;
    private final CategoryService categoryService;

    public HomeController(ProductService productService, CategoryService categoryService) {
        this.productService = productService;
        this.categoryService = categoryService;
    }

    @GetMapping("/")
    public String home(Model model) {
        // Dữ liệu query tươi mỗi request (không cache một lần lúc khởi động như bản servlet cũ)
        model.addAttribute("categories", categoryService.getAllCategories());
        model.addAttribute("NoiThatMoi",  productService.getLatestProductsByCategory(1));
        model.addAttribute("TrangTriMoi", productService.getLatestProductsByCategory(2));
        model.addAttribute("DoChoiMoi",   productService.getLatestProductsByCategory(3));
        return "home"; // -> templates/home.html
    }
}
