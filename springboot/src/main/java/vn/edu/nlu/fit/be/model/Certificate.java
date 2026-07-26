package vn.edu.nlu.fit.be.model;

import jakarta.persistence.*;
import java.sql.Timestamp;

@Entity
@Table(name = "certificates")
public class Certificate {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "certificate_id")
    private int certificateId;

    @Column(name = "account_id")
    private int accountId;

    @Column(name = "public_key_pem")
    private String publicKeyPem;

    @Column(name = "certificate_pem")
    private String certificatePem;

    @Column(name = "serial_number")
    private String serialNumber;

    @Column(name = "status")
    private String status; // ACTIVE / REVOKED / EXPIRED / LOST_KEY

    @Column(name = "issued_at")
    private Timestamp issuedAt;

    @Column(name = "expires_at")
    private Timestamp expiresAt;

    @Column(name = "created_at", insertable = false, updatable = false)
    private Timestamp createdAt;

    @Column(name = "revoked_at")
    private Timestamp revokedAt;

    @Column(name = "lost_at")
    private Timestamp lostAt;

    @Column(name = "revoke_reason")
    private String revokeReason;

    public Certificate() {
    }

    public int getCertificateId() { return certificateId; }
    public void setCertificateId(int certificateId) { this.certificateId = certificateId; }

    public int getAccountId() { return accountId; }
    public void setAccountId(int accountId) { this.accountId = accountId; }

    public String getPublicKeyPem() { return publicKeyPem; }
    public void setPublicKeyPem(String publicKeyPem) { this.publicKeyPem = publicKeyPem; }

    public String getCertificatePem() { return certificatePem; }
    public void setCertificatePem(String certificatePem) { this.certificatePem = certificatePem; }

    public String getSerialNumber() { return serialNumber; }
    public void setSerialNumber(String serialNumber) { this.serialNumber = serialNumber; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getIssuedAt() { return issuedAt; }
    public void setIssuedAt(Timestamp issuedAt) { this.issuedAt = issuedAt; }

    public Timestamp getExpiresAt() { return expiresAt; }
    public void setExpiresAt(Timestamp expiresAt) { this.expiresAt = expiresAt; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getRevokedAt() { return revokedAt; }
    public void setRevokedAt(Timestamp revokedAt) { this.revokedAt = revokedAt; }

    public Timestamp getLostAt() { return lostAt; }
    public void setLostAt(Timestamp lostAt) { this.lostAt = lostAt; }

    public String getRevokeReason() { return revokeReason; }
    public void setRevokeReason(String revokeReason) { this.revokeReason = revokeReason; }
}
