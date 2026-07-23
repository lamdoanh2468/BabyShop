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

    /* ================= Đổi mật khẩu ================= */
    @Transactional
    public boolean changePassword(int accountId, String oldPassword, String newPassword) {
        Account acc = accountRepo.findById(accountId).orElse(null);
        if (acc == null) return false;
        if (acc.getPassword() == null || !passwordEncoder.matches(oldPassword, acc.getPassword())) {
            return false; // mật khẩu hiện tại sai
        }
        acc.setPassword(passwordEncoder.encode(newPassword));
        accountRepo.save(acc);
        return true;
    }

    /* ================= Admin quản lý tài khoản ================= */

    public Account getById(int id) {
        return accountRepo.findById(id).orElse(null);
    }

    public java.util.List<Account> getAll() {
        return accountRepo.findAll(org.springframework.data.domain.Sort.by("accountId"));
    }

    public java.util.List<Account> search(String keyword) {
        if (keyword == null || keyword.isBlank()) return getAll();
        return accountRepo.findByUsernameContainingIgnoreCaseOrEmailContainingIgnoreCase(keyword, keyword);
    }

    @Transactional
    public void updateStatus(int id, AccountStatus status) {
        Account acc = accountRepo.findById(id).orElse(null);
        if (acc != null) {
            acc.setStatus(status);
            accountRepo.save(acc);
        }
    }

    public void deleteById(int id) {
        accountRepo.deleteById(id);
    }

    // Admin tự cập nhật thông tin (email/mật khẩu -> account, họ tên -> profile). Trả account đã reload.
    @Transactional
    public Account updateAdminSelf(int accountId, String fullName, String email, String rawPassword) {
        Account acc = accountRepo.findById(accountId).orElse(null);
        if (acc == null) return null;
        if (email != null && !email.isBlank()) acc.setEmail(email);
        if (rawPassword != null && !rawPassword.isBlank()) {
            acc.setPassword(passwordEncoder.encode(rawPassword)); // hash đàng hoàng (bản cũ lưu plaintext)
        }
        accountRepo.save(acc);
        Profile p = profileRepo.findById(acc.getProfileId()).orElse(null);
        if (p != null && fullName != null) {
            p.setFullName(fullName);
            profileRepo.save(p);
        }
        return acc;
    }

    // Admin thêm tài khoản với role chỉ định
    @Transactional
    public boolean adminAdd(String username, String email, String rawPassword, int role) {
        if (accountRepo.existsByEmail(email)) return false;
        Profile profile = new Profile();
        profile.setEmail(email);
        profileRepo.save(profile);

        Account acc = new Account();
        acc.setProfileId(profile.getProfileId());
        acc.setEmail(email);
        acc.setUsername(username);
        acc.setPassword(passwordEncoder.encode(rawPassword));
        acc.setStatus(AccountStatus.Active);
        acc.setRole(role);
        accountRepo.save(acc);
        return true;
    }
}
