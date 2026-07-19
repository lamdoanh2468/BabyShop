package vn.edu.nlu.fit.be.service;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.nlu.fit.be.model.Account;
import vn.edu.nlu.fit.be.model.AccountStatus;
import vn.edu.nlu.fit.be.model.Profile;
import vn.edu.nlu.fit.be.repository.AccountRepository;
import vn.edu.nlu.fit.be.repository.ProfileRepository;

import java.util.Optional;

@Service
public class AccountService {

    private final AccountRepository accountRepo;
    private final ProfileRepository profileRepo;
    private final PasswordEncoder passwordEncoder;

    public AccountService(AccountRepository accountRepo,
                          ProfileRepository profileRepo,
                          PasswordEncoder passwordEncoder) {
        this.accountRepo = accountRepo;
        this.profileRepo = profileRepo;
        this.passwordEncoder = passwordEncoder;
    }

    /* ================= Register ================= */
    @Transactional
    public boolean register(String username, String email, String rawPassword) {
        if (accountRepo.existsByEmail(email)) {
            return false;
        }

        // Tạo profile trước để lấy profile_id (giống transaction JDBI cũ)
        Profile profile = new Profile();
        profile.setEmail(email);
        profileRepo.save(profile);

        Account acc = new Account();
        acc.setProfileId(profile.getProfileId());
        acc.setEmail(email);
        acc.setUsername(username);
        acc.setPassword(passwordEncoder.encode(rawPassword));
        acc.setStatus(AccountStatus.Active);
        acc.setRole(0);
        accountRepo.save(acc);
        return true;
    }

    /* ================= Login ================= */
    public Account login(String key, String rawPassword) {
        Optional<Account> opt = accountRepo.findByUsernameOrEmail(key, key);
        if (opt.isEmpty()) {
            return null; // không có tài khoản
        }

        Account acc = opt.get();

        // Tài khoản Google (password NULL) không đăng nhập bằng mật khẩu
        if (acc.getPassword() == null || !passwordEncoder.matches(rawPassword, acc.getPassword())) {
            return null; // sai mật khẩu
        }

        if (acc.getStatus() != AccountStatus.Active) {
            throw new IllegalStateException("Tài khoản của bạn đã bị khoá. Vui lòng liên hệ quản trị viên.");
        }

        if (acc.getRole() != null && acc.getRole() < 0) {
            return null;
        }

        return acc;
    }

    public boolean existsByEmail(String email) {
        return accountRepo.existsByEmail(email);
    }
}
