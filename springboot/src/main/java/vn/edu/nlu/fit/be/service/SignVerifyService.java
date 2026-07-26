package vn.edu.nlu.fit.be.service;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.nlu.fit.be.dto.SignedOrderReq;
import vn.edu.nlu.fit.be.model.Certificate;
import vn.edu.nlu.fit.be.repository.CertificateRepository;
import vn.edu.nlu.fit.be.util.CryptoUtil;

import java.io.ByteArrayInputStream;
import java.nio.charset.StandardCharsets;
import java.security.Signature;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;
import java.util.Base64;
import java.util.Map;
import java.util.Set;

/**
 * Xác minh file chữ ký upload: hash khớp -> cert hợp lệ (ký bởi CA, còn hạn) -> chữ ký hợp lệ ->
 * đơn không bị sửa. Đặt trạng thái order + order_signs, lưu order_signatures. Bản Spring của SignVerifyService.
 */
@Service
public class SignVerifyService {

    private static final Set<String> ALLOWED_ALGOS = Set.of("SHA256withRSA");

    private final OrderSigningService orderSigningService;
    private final CertificateService certificateService;
    private final CertificateRepository certRepo;
    private final OrderService orderService;
    private final JdbcTemplate jdbc;

    public SignVerifyService(OrderSigningService orderSigningService,
                             CertificateService certificateService,
                             CertificateRepository certRepo,
                             OrderService orderService,
                             JdbcTemplate jdbc) {
        this.orderSigningService = orderSigningService;
        this.certificateService = certificateService;
        this.certRepo = certRepo;
        this.orderService = orderService;
        this.jdbc = jdbc;
    }

    public record Result(boolean success, String status, String message) {}

    @Transactional
    public Result verify(SignedOrderReq req, int accountId) {
        if (req == null || req.getOrderHash() == null || req.getSignatureValue() == null) {
            return new Result(false, "INVALID", "Dữ liệu chữ ký không hợp lệ");
        }

        Map<String, Object> sign = orderSigningService.getLatestSign(req.getOrderId());
        if (sign == null) {
            return new Result(false, "INVALID", "Không tìm thấy dữ liệu ký cho đơn này");
        }
        if (((Number) sign.get("account_id")).intValue() != accountId) {
            return new Result(false, "INVALID", "Đơn không thuộc tài khoản này");
        }

        String storedHash = (String) sign.get("order_hash");

        // 1) Hash upload phải khớp hash đã lưu
        if (!storedHash.equals(req.getOrderHash())) {
            return finalize(req, accountId, "TAMPERED", "FAIL_HASH_MISMATCH",
                    "Order hash không khớp snapshot đã lưu");
        }

        // 2) Đơn không bị sửa sau khi ký (hash tính lại từ đơn hiện tại)
        String currentHash = orderSigningService.currentOrderHash(req.getOrderId());
        if (currentHash != null && !currentHash.equals(storedHash)) {
            return finalize(req, accountId, "TAMPERED", "FAIL_ORDER_CHANGED",
                    "Dữ liệu đơn hàng đã bị thay đổi");
        }

        // 3) Cert của tài khoản
        Certificate cert = certRepo.findByCertificateIdAndAccountId(req.getCertificateId(), accountId).orElse(null);
        if (cert == null) {
            return finalize(req, accountId, "CERTIFICATE_INVALID", "FAIL_NO_CERT", "Không có chứng thư cho tài khoản");
        }

        X509Certificate x509;
        try {
            x509 = parseCert(cert.getCertificatePem());
            verifyCertSignedByCa(x509);
            x509.checkValidity();
        } catch (Exception e) {
            return finalize(req, accountId, "CERTIFICATE_INVALID", "FAIL_CERT", "Chứng thư không hợp lệ: " + e.getMessage());
        }

        // 4) Chữ ký hợp lệ (RSA/SHA256 trên chuỗi orderHash)
        try {
            String algo = req.getSignatureAlgorithm();
            if (algo == null || !ALLOWED_ALGOS.contains(algo)) algo = "SHA256withRSA";
            Signature verifier = Signature.getInstance(algo);
            verifier.initVerify(x509.getPublicKey());
            verifier.update(storedHash.getBytes(StandardCharsets.UTF_8));
            byte[] sigBytes = Base64.getMimeDecoder().decode(req.getSignatureValue().trim());
            if (!verifier.verify(sigBytes)) {
                return finalize(req, accountId, "SIGNATURE_INVALID", "FAIL_SIGNATURE", "Chữ ký không hợp lệ");
            }
        } catch (Exception e) {
            return finalize(req, accountId, "SIGNATURE_INVALID", "FAIL_SIGNATURE", "Lỗi xác minh chữ ký: " + e.getMessage());
        }

        // OK
        return finalize(req, accountId, "VERIFIED", "OK", "Chữ ký hợp lệ");
    }

    private Result finalize(SignedOrderReq req, int accountId, String orderStatus, String verifyStatus, String message) {
        // Lưu bản ghi chữ ký
        jdbc.update("INSERT INTO order_signatures (order_id, account_id, certificate_id, order_hash," +
                " signature_value, signature_algorithm, signed_payload_json, uploaded_at, verify_status, verify_message)" +
                " VALUES (?,?,?,?,?,?,?,NOW(),?,?)",
                req.getOrderId(), accountId, req.getCertificateId(), req.getOrderHash(),
                req.getSignatureValue(), req.getSignatureAlgorithm(), null, verifyStatus, message);

        orderSigningService.markSignStatus(req.getOrderId(), orderStatus);
        orderService.updateStatus(req.getOrderId(), orderStatus);

        boolean ok = "VERIFIED".equals(orderStatus);
        return new Result(ok, orderStatus, message);
    }

    private X509Certificate parseCert(String pem) throws Exception {
        CertificateFactory cf = CertificateFactory.getInstance("X.509");
        return (X509Certificate) cf.generateCertificate(
                new ByteArrayInputStream(pem.getBytes(StandardCharsets.UTF_8)));
    }

    private void verifyCertSignedByCa(X509Certificate userCert) throws Exception {
        X509Certificate caCert = CryptoUtil.loadCertificate(certificateService.getCaCertPath());
        userCert.verify(caCert.getPublicKey()); // throws nếu không phải do CA ký
    }
}
