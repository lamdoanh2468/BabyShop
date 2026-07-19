package vn.edu.nlu.fit.be.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import vn.edu.nlu.fit.be.model.Product;
import vn.edu.nlu.fit.be.service.BrandService;
import vn.edu.nlu.fit.be.service.CategoryService;
import vn.edu.nlu.fit.be.service.ProductService;

import java.util.List;
import java.util.Map;

@Controller
public class ProductListController {

    private static final int PAGE_SIZE = 20;

    private final ProductService productService;
    private final CategoryService categoryService;
    private final BrandService brandService;

    public ProductListController(ProductService productService,
                                 CategoryService categoryService,
                                 BrandService brandService) {
        this.productService = productService;
        this.categoryService = categoryService;
        this.brandService = brandService;
    }

    @GetMapping("/product-list")
    public String productList(
            @RequestParam(name = "page", defaultValue = "1") int page,
            @RequestParam(name = "category_id", required = false) Integer categoryId,
            @RequestParam(name = "brand", required = false) String[] brand,
            @RequestParam(name = "sort", required = false) String sort,
            Model model) {

        if (page < 1) page = 1;

        int totalProducts = productService.countTotalProductsBy(categoryId, brand, null);
        List<Product> products = productService.getProducts(categoryId, brand, sort, null, page, PAGE_SIZE);
        Map<Integer, Integer> soldMap = productService.getSoldMap(products);

        int totalPages = (int) Math.ceil((double) totalProducts / PAGE_SIZE);

        model.addAttribute("products", products);
        model.addAttribute("soldMap", soldMap);
        model.addAttribute("categories", categoryService.getAllCategories());
        model.addAttribute("brands", brandService.getBrands());
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", totalPages);
        // Dùng để giữ trạng thái lọc trên view
        model.addAttribute("currentCategoryId", categoryId);
        model.addAttribute("currentSort", sort);
        model.addAttribute("currentBrand", brand);

        return "productList"; // -> templates/productList.html
    }
}
