package vn.edu.nlu.fit.be.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import vn.edu.nlu.fit.be.model.Certificate;

import java.util.List;
import java.util.Optional;

public interface CertificateRepository extends JpaRepository<Certificate, Integer> {

    Optional<Certificate> findFirstByAccountIdAndStatus(int accountId, String status);

    Optional<Certificate> findByCertificateIdAndAccountId(int certificateId, int accountId);

    List<Certificate> findByAccountIdAndStatusIn(int accountId, List<String> statuses);
}
