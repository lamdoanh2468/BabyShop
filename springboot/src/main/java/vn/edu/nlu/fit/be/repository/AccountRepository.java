package vn.edu.nlu.fit.be.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import vn.edu.nlu.fit.be.model.Account;

import java.util.Optional;

public interface AccountRepository extends JpaRepository<Account, Integer> {

    // WHERE username = ? OR email = ?  (gọi với cùng 1 key: findByUsernameOrEmail(key, key))
    Optional<Account> findByUsernameOrEmail(String username, String email);

    boolean existsByEmail(String email);

    Optional<Account> findByEmail(String email);
}
