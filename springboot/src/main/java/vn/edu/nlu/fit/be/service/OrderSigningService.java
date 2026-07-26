package vn.edu.nlu.fit.be.service;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import vn.edu.nlu.fit.be.model.Order;
import vn.edu.nlu.fit.be.repository.OrderRepository;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.List;
import java.util.Map;

/**
 * Tạo "snapshot" chuỗi hoá đơn (deterministic) + hash SHA-256, lưu order_signs.
 * Đúng định dạng snapshot của bản JSP (để giữ hành vi hash).
 */
@Service
public class OrderSigningService {

    private static final String HASH_ALGORITHM = "SHA-256";

    private final OrderRepository orderRepo;
    private final JdbcTemplate jdbc;

    public OrderSigningService(OrderRepository orderRepo, JdbcTemplate jdbc) {
        this.orderRepo = orderRepo;
        this.jdbc = jdbc;
    }

    /** Tạo snapshot + hash cho đơn, lưu order_signs (WAITING_SIGNATURE). Trả orderHash. */
    public String createSnapshotAndStore(int orderId, int accountId) {
        Order order = orderRepo.findById(orderId).orElseThrow();
        String snapshot = buildSnapshot(order);
        String hash = sha256Hex(snapshot);

        jdbc.update("INSERT INTO order_signs (order_id, account_id, snapshot_json, order_hash, hash_algorithm, status, created_at)" +
                " VALUES (?,?,?,?,?,?,NOW())",
                orderId, accountId, snapshot, hash, HASH_ALGORITHM, "WAITING_SIGNATURE");
        return hash;
    }

    /** order_signs mới nhất của đơn (dùng khi verify). Trả null nếu chưa có. */
    public Map<String, Object> getLatestSign(int orderId) {
        List<Map<String, Object>> rows = jdbc.queryForList(
                "SELECT * FROM order_signs WHERE order_id = ? ORDER BY created_at DESC, order_sign_id DESC LIMIT 1", orderId);
        return rows.isEmpty() ? null : rows.get(0);
    }

    public void markSignStatus(int orderId, String status) {
        jdbc.update("UPDATE order_signs SET status = ?, verified_at = NOW() WHERE order_id = ?", status, orderId);
    }

    /** Hash tính lại từ trạng thái đơn HIỆN TẠI (phát hiện đơn bị sửa sau khi ký). */
    public String currentOrderHash(int orderId) {
        Order order = orderRepo.findById(orderId).orElse(null);
        if (order == null) return null;
        return sha256Hex(buildSnapshot(order));
    }

    // ===== Snapshot deterministic (khớp định dạng bản JSP) =====
    private String buildSnapshot(Order order) {
        StringBuilder sb = new StringBuilder();
        sb.append("orderId=").append(order.getOrderId()).append(";");
        sb.append("accountId=").append(order.getAccountId()).append(";");
        sb.append("voucherId=").append(order.getVoucherId() == null ? 0 : order.getVoucherId()).append(";");
        sb.append("subtotal=").append(order.getSubtotalAmount()).append(";");
        sb.append("discountAmount=").append(order.getDiscountAmount()).append(";");
        sb.append("total=").append(order.getTotalAmount()).append(";");
        sb.append("paymentMethod=").append(order.getPaymentMethod()).append(";");
        sb.append("address=").append(order.getDeliveryAddress() == null ? "" : order.getDeliveryAddress().trim()).append(";");
        sb.append("details=[");

        // Chi tiết sắp theo product_id (deterministic)
        List<Map<String, Object>> details = jdbc.queryForList(
                "SELECT product_id, quantity, unit_price FROM order_details WHERE order_id = ? ORDER BY product_id",
                order.getOrderId());
        for (Map<String, Object> d : details) {
            sb.append("{")
              .append("productId=").append(d.get("product_id")).append(";")
              .append("quantity=").append(d.get("quantity")).append(";")
              .append("price=").append(d.get("unit_price")).append(";")
              .append("}");
        }
        sb.append("]");
        return sb.toString();
    }

    public String sha256Hex(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance(HASH_ALGORITHM);
            byte[] digest = md.digest(input.getBytes(StandardCharsets.UTF_8));
            StringBuilder hex = new StringBuilder();
            for (byte b : digest) hex.append(String.format("%02x", b));
            return hex.toString();
        } catch (Exception e) {
            throw new RuntimeException("Cannot hash order snapshot", e);
        }
    }
}
