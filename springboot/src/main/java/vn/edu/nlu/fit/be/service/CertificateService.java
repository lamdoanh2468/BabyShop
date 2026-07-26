package vn.edu.nlu.fit.be.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import vn.edu.nlu.fit.be.model.Certificate;
import vn.edu.nlu.fit.be.repository.CertificateRepository;
import vn.edu.nlu.fit.be.util.CryptoUtil;

import java.nio.file.Files;
import java.nio.file.Path;
import java.security.KeyPair;
import java.security.PrivateKey;
import java.security.cert.X509Certificate;
import java.sql.Timestamp;
import java.util.List;
import java.util.Optional;

/**
 * Quản lý CA cục bộ + cấp chứng thư người dùng. CA lưu trên filesystem (thư mục data),
 * cert lưu DB, private key ghi file tạm để tải 1 lần. Tương đương CertificateService cũ.
 */
@Service
public class CertificateService {

    private final CertificateRepository certRepo;
    private final Path dataDir;
    private final Path caDir;
    private final Path caCertPath;
    private final Path caPrivateKeyPath;
    private final Path privateKeyDir;

    public CertificateService(CertificateRepository certRepo,
                              @Value("${babyshop.data.dir:data}") String dataDirCfg) {
        this.certRepo = certRepo;
        this.dataDir = Path.of(dataDirCfg).toAbsolutePath().normalize();
        this.caDir = dataDir.resolve("ca");
        this.caCertPath = caDir.resolve("ca_certificate.pem");
        this.caPrivateKeyPath = caDir.resolve("ca_private_key.pem");
        this.privateKeyDir = dataDir.resolve("private_keys");
    }

    public Path getCaCertPath() { return caCertPath; }

    public Optional<Certificate> getActiveCertByAccountId(int accountId) {
        return certRepo.findFirstByAccountIdAndStatus(accountId, "ACTIVE");
    }

    public List<Certificate> findRevokedByAccountId(int accountId) {
        return certRepo.findByAccountIdAndStatusIn(accountId, List.of("REVOKED", "LOST_KEY", "EXPIRED"));
    }

    public void ensureActiveCert(int accountId) throws Exception {
        if (getActiveCertByAccountId(accountId).isEmpty()) {
            createNewCertAccount(accountId);
        }
    }

    public void createNewCertAccount(int accountId) throws Exception {
        ensureLocalCa();
        KeyPair userKeyPair = CryptoUtil.generateRsaKeyPair(2048);
        X509Certificate caCert = CryptoUtil.loadCertificate(caCertPath);
        PrivateKey caPrivateKey = CryptoUtil.loadPrivateKey(caPrivateKeyPath);
        X509Certificate userCert = CryptoUtil.genCertSignedByCA(
                userKeyPair.getPublic(), caPrivateKey, caCert,
                "CN=account-" + accountId + ", UID=" + accountId, 365);

        Certificate certificate = new Certificate();
        certificate.setAccountId(accountId);
        certificate.setPublicKeyPem(CryptoUtil.toPemPublicKey(userKeyPair.getPublic()));
        certificate.setCertificatePem(CryptoUtil.toPemCertificate(userCert));
        certificate.setSerialNumber(Long.toString(userCert.getSerialNumber().longValue()));
        certificate.setStatus("ACTIVE");
        certificate.setIssuedAt(new Timestamp(System.currentTimeMillis()));
        certificate.setExpiresAt(new Timestamp(userCert.getNotAfter().getTime()));
        certRepo.save(certificate);

        // Ghi private key ra file tạm để tải đúng 1 lần
        Files.createDirectories(privateKeyDir);
        Files.writeString(privateKeyPath(accountId), CryptoUtil.toPemPrivateKey(userKeyPair.getPrivate()));
    }

    // Thu hồi cert đang active vì mất khoá
    public void revokeActiveCertByLostKey(int accountId, String reason) {
        certRepo.findFirstByAccountIdAndStatus(accountId, "ACTIVE").ifPresent(cert -> {
            cert.setStatus("LOST_KEY");
            cert.setLostAt(new Timestamp(System.currentTimeMillis()));
            cert.setRevokeReason(reason);
            certRepo.save(cert);
        });
    }

    public boolean hasPendingPrivateKey(int accountId) {
        return Files.exists(privateKeyPath(accountId));
    }

    // Đọc & xoá private key (tải 1 lần). Trả null nếu không còn.
    public byte[] consumePrivateKey(int accountId) throws Exception {
        Path p = privateKeyPath(accountId);
        if (!Files.exists(p)) return null;
        byte[] bytes = Files.readAllBytes(p);
        Files.deleteIfExists(p);
        return bytes;
    }

    private Path privateKeyPath(int accountId) {
        return privateKeyDir.resolve("account_" + accountId + "_private.key");
    }

    private synchronized void ensureLocalCa() throws Exception {
        if (Files.exists(caCertPath) && Files.exists(caPrivateKeyPath)) return;
        Files.createDirectories(caDir);
        KeyPair caKeyPair = CryptoUtil.generateRsaKeyPair(2048);
        X509Certificate caCert = CryptoUtil.genSelfSignedCA(caKeyPair, "CN=BabyShop Local CA", 3650);
        Files.writeString(caCertPath, CryptoUtil.toPemCertificate(caCert));
        Files.writeString(caPrivateKeyPath, CryptoUtil.toPemPrivateKey(caKeyPair.getPrivate()));
    }
}
