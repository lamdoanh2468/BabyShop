package vn.edu.nlu.fit.be.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.server.ResponseStatusException;
import vn.edu.nlu.fit.be.model.Product;
import vn.edu.nlu.fit.be.service.*;

@Controller
public class ProductDetailController {

    private final ProductService productService;
    private final StockProductService stockProductService;
    private final CategoryService categoryService;
    private final BrandService brandService;
    private final ReviewService reviewService;

    public ProductDetailController(ProductService productService,
                                   StockProductService stockProductService,
                                   CategoryService categoryService,
                                   BrandService brandService,
                                   ReviewService reviewService) {
        this.productService = productService;
        this.stockProductService = stockProductService;
        this.categoryService = categoryService;
        this.brandService = brandService;
        this.reviewService = reviewService;
    }

    @GetMapping("/product-detail")
    public String productDetail(@RequestParam("product_id") int productId, Model model) {
        Product product = productService.getProductById(productId);
        if (product == null) {
            // Không có sản phẩm -> 404 thay vì NPE như bản servlet cũ
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy sản phẩm");
        }
        model.addAttribute("product", product);
        model.addAttribute("category", categoryService.getCategoryById(product.getCategoryId()));
        model.addAttribute("brand", brandService.getBrandById(product.getBrandId()));

        model.addAttribute("soldQuantity", productService.getTotalSoldQuantity(productId));
        model.addAttribute("isAvailable", stockProductService.checkProductAvailable(productId));

        model.addAttribute("productImages", productService.getImagesListInProduct(productId));
        model.addAttribute("details", productService.getProductDetails(productId));
        model.addAttribute("reviewList", reviewService.getReviewsByProductId(productId));

        return "productDetail"; // -> templates/productDetail.html
    }
}
