package vn.edu.nlu.fit.be.controller;

import jakarta.servlet.http.HttpSession;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import vn.edu.nlu.fit.be.model.Account;
import vn.edu.nlu.fit.be.service.FavoriteProductService;

import java.util.Map;

@Controller
public class FavoriteController {

    private final FavoriteProductService favoriteService;

    public FavoriteController(FavoriteProductService favoriteService) {
        this.favoriteService = favoriteService;
    }

    /* ===== GET: thêm/bỏ yêu thích rồi quay lại trang danh sách ===== */
    @GetMapping(value = "/my-favorite", params = "action=add")
    public String toggleAndRedirect(@RequestParam("product_id") int productId, HttpSession session) {
        Account acc = (Account) session.getAttribute("USER");
        if (acc == null) return "redirect:/login";
        favoriteService.toggle(acc.getAccountId(), productId);
        return "redirect:/my-favorite";
    }

    /* ===== GET: xem danh sách yêu thích ===== */
    @GetMapping("/my-favorite")
    public String viewFavorites(HttpSession session, Model model) {
        Account acc = (Account) session.getAttribute("USER");
        if (acc == null) return "redirect:/login";
        model.addAttribute("FAVORITES", favoriteService.getFavorites(acc.getAccountId()));
        return "favorite";
    }

    /* ===== POST action=remove: xoá khỏi danh sách (form trong favorite.html) ===== */
    @PostMapping(value = "/my-favorite", params = "action=remove")
    public String removeFavorite(@RequestParam("product_id") int productId, HttpSession session) {
        Account acc = (Account) session.getAttribute("USER");
        if (acc == null) return "redirect:/login";
        favoriteService.toggle(acc.getAccountId(), productId);
        return "redirect:/my-favorite";
    }

    /* ===== POST (AJAX, không có action): toggle trả JSON {"liked": bool} ===== */
    @PostMapping("/my-favorite")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> toggleAjax(@RequestParam("product_id") int productId,
                                                          HttpSession session) {
        Account acc = (Account) session.getAttribute("USER");
        if (acc == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        boolean liked = favoriteService.toggle(acc.getAccountId(), productId);
        return ResponseEntity.ok(Map.of("liked", liked));
    }
}
