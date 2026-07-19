package vn.edu.nlu.fit.be.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import vn.edu.nlu.fit.be.model.Voucher;

import java.util.Optional;

public interface VoucherRepository extends JpaRepository<Voucher, Integer> {
    Optional<Voucher> findByVoucherCode(String voucherCode);
}
