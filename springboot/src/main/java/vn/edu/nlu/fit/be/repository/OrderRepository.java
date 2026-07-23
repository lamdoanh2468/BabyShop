package vn.edu.nlu.fit.be.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import vn.edu.nlu.fit.be.model.Order;

import java.util.List;

public interface OrderRepository extends JpaRepository<Order, Integer> {

    // Đơn của 1 tài khoản, mới nhất trước (trang "đơn đã mua")
    List<Order> findByAccountIdOrderByOrderIdDesc(int accountId);
}
