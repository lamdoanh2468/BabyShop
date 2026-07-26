package vn.edu.nlu.fit.be.controller;

import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.edu.nlu.fit.be.model.Account;
import vn.edu.nlu.fit.be.model.Cart;
import vn.edu.nlu.fit.be.model.Voucher;
import vn.edu.nlu.fit.be.service.CertificateService;
import vn.edu.nlu.fit.be.service.OrderService;
import vn.edu.nlu.fit.be.service.OrderSigningService;
import vn.edu.nlu.fit.be.service.VoucherService;

import java.util.List;

@Controller
public class OrderController {

    private final OrderService orderService;
    private final VoucherService voucherService;
    private final CertificateService certificateService;
    private final OrderSigningService orderSigningService;

    public OrderController(OrderService orderService, VoucherService voucherService,
                          CertificateService certificateService, OrderSigningService orderSigningService) {
        this.orderService = orderService;
        this.voucherService = voucherService;
        this.certificateService = certificateService;
        this.orderSigningService = orderSigningService;
    }

    @GetMapping("/order")
    public String orderGet() {
        return "redirect:/cart";
    }

    @PostMapping("/order")
    public String order(@RequestParam(name = "orderAction", required = false) String action,
                        @RequestParam(name = "deliveryAddress", required = false) String deliveryAddress,
                        @RequestParam(name = "paymentMethod", required = false) String paymentMethod,
                        @RequestParam(name = "voucherCode", required = false) String voucherCode,
                        HttpSession session, RedirectAttributes ra) {
        Account account = (Account) session.getAttribute("USER");
        if (account == null) return "redirect:/login";

        Cart cart = (Cart) session.getAttribute("cart");
        if (cart == null || cart.getTotalQuantity() == 0) {
            return "redirect:/cart";
        }

        // ===== ÁP DỤNG VOUCHER =====
        if ("applyVoucher".equals(action)) {
            String code = trimToNull(voucherCode);
            if (code == null) {
                ra.addFlashAttribute("voucherError", "Vui lòng nhập mã voucher");
                return "redirect:/cart";
            }
            Voucher v = voucherService.findByCode(code);
            if (v == null) {
                ra.addFlashAttribute("voucherError", "Mã voucher không hợp lệ");
                return "redirect:/cart";
            }
            session.setAttribute("voucherCode", code);
            session.setAttribute("discountAmount", v.getDiscountAmount());
            return "redirect:/cart";
        }

        // ===== HUỶ VOUCHER =====
        if ("removeVoucher".equals(action)) {
            session.removeAttribute("voucherCode");
            session.removeAttribute("discountAmount");
            return "redirect:/cart";
        }

        // ===== THANH TOÁN =====
        if (trimToNull(deliveryAddress) == null) {
            ra.addFlashAttribute("error", "Vui lòng nhập địa chỉ giao hàng");
            return "redirect:/cart";
        }

        List<String> bad = orderService.outOfStock(cart);
        if (!bad.isEmpty()) {
            ra.addFlashAttribute("error", "Không đủ tồn kho cho: " + String.join(", ", bad));
            return "redirect:/cart";
        }

        String code = (String) session.getAttribute("voucherCode");
        Voucher voucher = code == null ? null : voucherService.findByCode(code);
        Integer voucherId = voucher == null ? null : voucher.getVoucherId();

        int subtotal = cart.getTotalPrice();
        Integer sessionDiscount = (Integer) session.getAttribute("discountAmount");
        int discount = sessionDiscount == null ? 0 : Math.min(sessionDiscount, subtotal);
        int total = Math.max(0, subtotal - discount);

        String pm = "Card".equals(paymentMethod) ? "Card" : "COD";
        // Đơn tạo ở trạng thái chờ ký; sau đó cấp cert + tạo snapshot để ký số.
        int orderId = orderService.placeOrder(account.getAccountId(), cart, deliveryAddress.trim(),
                pm, voucherId, subtotal, discount, total, "WAITING_SIGNATURE");
        try {
            certificateService.ensureActiveCert(account.getAccountId());
            orderSigningService.createSnapshotAndStore(orderId, account.getAccountId());
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Không thể chuẩn bị ký số: " + e.getMessage());
        }

        // Dọn giỏ + voucher khỏi session
        cart.removeAllItems();
        session.setAttribute("cart", cart);
        session.removeAttribute("voucherCode");
        session.removeAttribute("discountAmount");

        ra.addFlashAttribute("orderSuccess",
                "Đã tạo đơn #" + orderId + " (chờ ký). Vào 'Chữ ký số' để tải khoá và ký đơn.");
        return "redirect:/bought-product";
    }

    private static String trimToNull(String s) {
        return (s == null || s.trim().isEmpty()) ? null : s.trim();
    }
}
