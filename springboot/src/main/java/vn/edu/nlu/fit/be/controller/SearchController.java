package vn.edu.nlu.fit.be.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import vn.edu.nlu.fit.be.model.Product;
import vn.edu.nlu.fit.be.service.ProductService;

import java.util.List;
import java.util.Map;

@Controller
public class SearchController {

    private static final int PAGE_SIZE = 20;

    private final ProductService productService;

    public SearchController(ProductService productService) {
        this.productService = productService;
    }

    @GetMapping("/search")
    public String search(@RequestParam(required = false) String keyword,
                         @RequestParam(required = false) String sort,
                         @RequestParam(name = "page", defaultValue = "1") int page,
                         Model model) {
        if (page < 1) page = 1;

        int total = productService.countTotalProductsBy(null, null, keyword);
        List<Product> products = productService.getProducts(null, null, sort, keyword, page, PAGE_SIZE);
        Map<Integer, Integer> soldMap = productService.getSoldMap(products);
        int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);

        model.addAttribute("products", products);
        model.addAttribute("soldMap", soldMap);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", totalPages);
        model.addAttribute("currentSort", sort);
        model.addAttribute("keyword", keyword); // bật "chế độ tìm kiếm" trong productList.html
        return "productList";
    }
}
