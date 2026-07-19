package vn.edu.nlu.fit.be.controller;

import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.util.UriComponentsBuilder;
import vn.edu.nlu.fit.be.model.Account;
import vn.edu.nlu.fit.be.service.ReviewService;

@Controller
public class ReviewController {

    private final ReviewService reviewService;

    public ReviewController(ReviewService reviewService) {
        this.reviewService = reviewService;
    }

    @PostMapping("/add-review")
    public String addReview(@RequestParam("product_id") int productId,
                            @RequestParam("comment") String comment,
                            HttpSession session) {
        Account account = (Account) session.getAttribute("USER");
        if (account == null) {
            // Nhớ trang cần quay lại sau khi đăng nhập (như bản cũ)
            session.setAttribute("redirectAfterLogin", "/product-detail?product_id=" + productId);
            return "redirect:/login";
        }

        reviewService.addReview(account.getAccountId(), productId, comment);

        // Quay lại đúng trang chi tiết sản phẩm
        String url = UriComponentsBuilder.fromPath("/product-detail")
                .queryParam("product_id", productId)
                .toUriString();
        return "redirect:" + url;
    }
}
