package vn.edu.nlu.fit.be.controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import vn.edu.nlu.fit.be.model.Cart;
import vn.edu.nlu.fit.be.model.Product;
import vn.edu.nlu.fit.be.service.ProductService;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;

@Controller
public class CartController {

    private final ProductService productService;

    public CartController(ProductService productService) {
        this.productService = productService;
    }

    /* ===================== XEM GIỎ HÀNG ===================== */
    @GetMapping("/cart")
    public String viewCart(HttpSession session, HttpServletRequest request) {
        if (isGuest(session)) return loginRedirect(request);
        getOrCreateCart(session); // đảm bảo có cart để header/view đọc
        return "cart";
    }

    /* ===================== THÊM VÀO GIỎ ===================== */
    @GetMapping(value = "/cart", params = "action=add")
    public String addToCart(@RequestParam("product_id") int productId,
                            @RequestParam(name = "quantity", defaultValue = "1") int quantity,
                            @RequestParam(name = "returnUrl", required = false) String returnUrl,
                            HttpSession session, HttpServletRequest request) {
        if (isGuest(session)) return loginRedirect(request);

        Product product = productService.getProductById(productId);
        if (product == null) return "redirect:/product-list";

        getOrCreateCart(session).addItem(product, quantity);

        // Chỉ redirect nội bộ (chặn open-redirect)
        if (returnUrl != null && returnUrl.startsWith("/")) {
            return "redirect:" + returnUrl;
        }
        return "redirect:/product-list";
    }

    /* ===================== MUA NGAY ===================== */
    @GetMapping(value = "/cart", params = "action=buy_now")
    public String buyNow(@RequestParam("product_id") int productId,
                         @RequestParam(name = "quantity", defaultValue = "1") int quantity,
                         HttpSession session, HttpServletRequest request) {
        if (isGuest(session)) return loginRedirect(request);
        Product product = productService.getProductById(productId);
        if (product == null) return "redirect:/product-list";
        getOrCreateCart(session).addItem(product, quantity);
        return "redirect:/cart";
    }

    /* ===================== CẬP NHẬT SỐ LƯỢNG (AJAX JSON) ===================== */
    @GetMapping(value = "/cart", params = "action=update")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updateCart(@RequestParam("product_id") int productId,
                                                          @RequestParam("quantity") int quantity,
                                                          HttpSession session) {
        if (isGuest(session)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("success", false, "message", "Chưa đăng nhập"));
        }
        boolean updated = getOrCreateCart(session).updateItem(productId, quantity);
        if (!updated) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("success", false, "message", "Sản phẩm không có trong giỏ hàng"));
        }
        return ResponseEntity.ok(Map.of("success", true));
    }

    /* ===================== XOÁ 1 SẢN PHẨM ===================== */
    @GetMapping(value = "/cart", params = "action=remove")
    public String removeFromCart(@RequestParam("product_id") int productId,
                                 HttpSession session, HttpServletRequest request) {
        if (isGuest(session)) return loginRedirect(request);
        getOrCreateCart(session).removeItem(productId);
        return "redirect:/cart";
    }

    /* ===================== XOÁ TẤT CẢ ===================== */
    @GetMapping(value = "/cart", params = "action=remove_all")
    public String removeAll(HttpSession session, HttpServletRequest request) {
        if (isGuest(session)) return loginRedirect(request);
        getOrCreateCart(session).removeAllItems();
        return "redirect:/cart";
    }

    /* ===================== helpers ===================== */

    private boolean isGuest(HttpSession session) {
        return session.getAttribute("USER") == null;
    }

    private Cart getOrCreateCart(HttpSession session) {
        Cart cart = (Cart) session.getAttribute("cart");
        if (cart == null) {
            cart = new Cart();
            session.setAttribute("cart", cart);
        }
        return cart;
    }

    // Chưa đăng nhập -> chuyển sang /login kèm returnUrl để quay lại
    private String loginRedirect(HttpServletRequest request) {
        String url = request.getRequestURI();
        if (request.getQueryString() != null) {
            url += "?" + request.getQueryString();
        }
        String encoded = URLEncoder.encode(url, StandardCharsets.UTF_8);
        return "redirect:/login?returnUrl=" + encoded;
    }
}
