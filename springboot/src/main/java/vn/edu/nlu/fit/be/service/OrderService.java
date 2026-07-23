package vn.edu.nlu.fit.be.service;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.nlu.fit.be.model.Cart;
import vn.edu.nlu.fit.be.model.CartItem;
import vn.edu.nlu.fit.be.model.Order;
import vn.edu.nlu.fit.be.repository.OrderRepository;
import vn.edu.nlu.fit.be.repository.StockProductRepository;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Service
public class OrderService {

    private final OrderRepository orderRepo;
    private final StockProductRepository stockRepo;
    private final JdbcTemplate jdbc;

    public OrderService(OrderRepository orderRepo, StockProductRepository stockRepo, JdbcTemplate jdbc) {
        this.orderRepo = orderRepo;
        this.stockRepo = stockRepo;
        this.jdbc = jdbc;
    }

    // Sản phẩm không đủ tồn kho (rỗng = mua được)
    public List<String> outOfStock(Cart cart) {
        List<String> bad = new ArrayList<>();
        for (CartItem item : cart.getItems()) {
            if (stockRepo.totalAvailable(item.getProduct().getProductId()) < item.getQuantity()) {
                bad.add(item.getProduct().getProductName());
            }
        }
        return bad;
    }

    /**
     * Đặt đơn cơ bản (chưa ký số): tạo order (Done) + order_details + trừ kho, trong 1 transaction.
     * Trả orderId.
     */
    @Transactional
    public int placeOrder(int accountId, Cart cart, String deliveryAddress, String paymentMethod,
                          Integer voucherId, int subtotal, int discount, int total) {
        Order order = new Order();
        order.setAccountId(accountId);
        order.setVoucherId(voucherId);
        order.setStatus("Done"); // đơn cơ bản hoàn tất ngay (luồng ký số làm ở nhóm sau)
        order.setSubtotalAmount(subtotal);
        order.setDiscountAmount(discount);
        order.setTotalAmount(total);
        order.setDeliveryAddress(deliveryAddress);
        order.setPaymentMethod(paymentMethod);
        orderRepo.save(order);
        int orderId = order.getOrderId();

        for (CartItem item : cart.getItems()) {
            int productId = item.getProduct().getProductId();
            int qty = item.getQuantity();
            jdbc.update("INSERT INTO order_details (order_id, product_id, unit_price, quantity) VALUES (?,?,?,?)",
                    orderId, productId, item.getPrice(), qty);
            stockRepo.deductForOrder(productId, qty); // trừ kho
        }
        return orderId;
    }

    /* ===================== Hiển thị ===================== */

    public List<Order> getMyOrders(int accountId) {
        return orderRepo.findByAccountIdOrderByOrderIdDesc(accountId);
    }

    // Item của 1 đơn kèm thông tin sản phẩm (JOIN products)
    public List<Map<String, Object>> getOrderItems(int orderId) {
        return jdbc.queryForList(
                "SELECT od.product_id AS productId, p.product_name AS productName, p.product_image AS productImage," +
                " od.unit_price AS unitPrice, od.quantity AS quantity, (od.unit_price * od.quantity) AS lineTotal" +
                " FROM order_details od JOIN products p ON od.product_id = p.product_id" +
                " WHERE od.order_id = ?", orderId);
    }

    /* ===================== Admin ===================== */

    public List<Map<String, Object>> getAllOrdersWithUser() {
        return jdbc.queryForList(
                "SELECT o.order_id AS orderId, a.username AS username, o.total_amount AS totalAmount," +
                " o.status AS status, o.payment_method AS paymentMethod, o.order_date AS orderDate" +
                " FROM orders o JOIN accounts a ON o.account_id = a.account_id ORDER BY o.order_id DESC");
    }

    public Order getOrder(int orderId) {
        return orderRepo.findById(orderId).orElse(null);
    }

    @Transactional
    public void updateStatus(int orderId, String status) {
        Order o = orderRepo.findById(orderId).orElse(null);
        if (o != null) {
            o.setStatus(status);
            orderRepo.save(o);
        }
    }
}
