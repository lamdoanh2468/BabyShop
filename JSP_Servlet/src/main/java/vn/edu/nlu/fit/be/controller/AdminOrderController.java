package vn.edu.nlu.fit.be.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import vn.edu.nlu.fit.be.dao.OrderDetailDao;
import vn.edu.nlu.fit.be.model.Account;
import vn.edu.nlu.fit.be.model.Order;
import vn.edu.nlu.fit.be.model.OrderDetail;
import vn.edu.nlu.fit.be.model.OrderStatus;
import vn.edu.nlu.fit.be.service.AdminSignService;
import vn.edu.nlu.fit.be.service.OrdersService;
import vn.edu.nlu.fit.be.service.StockProductService;

import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {
        "/admin/orders",
        "/admin/orders/status",
        "/admin/orders/detail"
})
public class AdminOrderController extends HttpServlet {

    private final OrdersService service = new OrdersService();
    private final AdminSignService adminSignService = new AdminSignService();
    private final StockProductService stockService = new StockProductService();
    private final OrderDetailDao orderDetailDao = new OrderDetailDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);

        //chưa login
        if (session == null || session.getAttribute("USER") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Account acc = (Account) session.getAttribute("USER");

        //không phải admin
        if (acc.getRole() <= 0) {
            resp.sendRedirect(req.getContextPath() + "/error/403.jsp");
            return;
        }
        String path = req.getServletPath();

        // ===== AJAX UPDATE STATUS =====
        if (path.equals("/admin/orders/status")) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                OrderStatus newStatus = OrderStatus.valueOf(req.getParameter("status"));

                if (adminSignService.markTamperedIfCurrentDataChanged(id)) {
                    resp.setContentType("text/plain;charset=UTF-8");
                    resp.getWriter().write("TAMPERED: Dữ liệu đơn hàng đã bị thay đổi so với bản đã ký. Không thể cập nhật trạng thái.");
                    return;
                }

                // Cập nhật trạng thái đơn hàng trước
                boolean statusUpdated = service.updateStatus(id, newStatus);

                if (!statusUpdated) {
                    resp.setContentType("text/plain");
                    resp.getWriter().write("FAIL");
                    return;
                }

                // Xử lý stock (nếu có lỗi thì vẫn coi như thành công vì status đã update)
                boolean stockUpdated = true;
                try {
                    List<OrderDetail> details = orderDetailDao.getOrderDetailsByOrderId(id);

                    if (newStatus == OrderStatus.DONE) {
                        for (OrderDetail detail : details) {
                            boolean stockReserved = stockService.updateStockProduct(
                                    detail.getProductId(),
                                    detail.getQuantity()
                            );

                            boolean soldUpdated = stockService.updateSoldQuantity(
                                    detail.getProductId(),
                                    detail.getQuantity()
                            );

                            if (!stockReserved || !soldUpdated) {
                                stockUpdated = false;
                            }
                        }
                    } else if (newStatus == OrderStatus.CANCELLED) {
                        // Khi Cancelled: hoàn lại stock (tăng total_quantity)
                        for (OrderDetail detail : details) {
                            if (!stockService.restoreStock(detail.getProductId(), detail.getQuantity())) {
                                stockUpdated = false;
                            }
                        }
                    }
                } catch (Exception stockEx) {
                    String errorMessage = stockEx.getMessage();
                    System.out.println("Stock update error: " + errorMessage);
                    stockUpdated = false;
                }

                resp.setContentType("text/plain");
                if (stockUpdated) {
                    resp.getWriter().write("OK");
                } else {
                    resp.getWriter().write("PARTIAL");
                }
            } catch (Exception e) {
                resp.setContentType("text/plain");
                resp.getWriter().write("FAIL: " + e.getMessage());
            }
            return;
        }
        if (path.equals("/admin/orders/detail")) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));

                boolean tamperedDetected = adminSignService.markTamperedIfCurrentDataChanged(id);

                Order order = service.getById(id);
                if (order == null) {
                    resp.sendRedirect(req.getContextPath() + "/admin/orders");
                    return;
                }

                List<OrderDetail> orderDetails = orderDetailDao.getOrderDetailsByOrderId(id);

                req.setAttribute("order", order);
                req.setAttribute("orderDetails", orderDetails);
                req.setAttribute("tamperedDetected", tamperedDetected);

                req.getRequestDispatcher("/admin_order_detail.jsp").forward(req, resp);
            } catch (Exception e) {
                resp.sendRedirect(req.getContextPath() + "/admin/orders");
            }
            return;
        }

        // ===== LOAD ORDER LIST =====
        List<Order> orders = service.getAll();
        List<Integer> tamperedOrderIds = adminSignService.findAndMarkTamperedOrders(orders);
        req.setAttribute("orders", orders);
        req.setAttribute("tamperedOrderIds", tamperedOrderIds);

        req.getRequestDispatcher("/admin_orders.jsp").forward(req, resp);
    }
}
