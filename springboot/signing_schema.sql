-- Bảng cho tính năng ký số đơn hàng (nếu dump chưa có).
-- Áp: docker compose exec -T mysql mysql -uroot db_babyshop < signing_schema.sql

CREATE TABLE IF NOT EXISTS certificates (
    certificate_id  INT NOT NULL AUTO_INCREMENT,
    account_id      INT NOT NULL,
    public_key_pem  TEXT,
    certificate_pem TEXT,
    serial_number   VARCHAR(64),
    status          VARCHAR(20) DEFAULT 'ACTIVE',   -- ACTIVE / REVOKED / EXPIRED / LOST_KEY
    issued_at       TIMESTAMP NULL,
    expires_at      TIMESTAMP NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    revoked_at      TIMESTAMP NULL,
    lost_at         TIMESTAMP NULL,
    revoke_reason   VARCHAR(255),
    PRIMARY KEY (certificate_id),
    KEY idx_cert_account (account_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS order_signs (
    order_sign_id  BIGINT NOT NULL AUTO_INCREMENT,
    order_id       BIGINT NOT NULL,
    account_id     BIGINT NOT NULL,
    certificate_id INT NULL,
    snapshot_json  TEXT,
    order_hash     VARCHAR(128),
    hash_algorithm VARCHAR(32),
    status         VARCHAR(32),
    created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    verified_at    TIMESTAMP NULL,
    PRIMARY KEY (order_sign_id),
    KEY idx_ordersign_order (order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS order_signatures (
    signature_id       BIGINT NOT NULL AUTO_INCREMENT,
    order_id           BIGINT NOT NULL,
    account_id         BIGINT NOT NULL,
    certificate_id     BIGINT NULL,
    order_hash         VARCHAR(128),
    signature_value    TEXT,
    signature_algorithm VARCHAR(32),
    signed_payload_json TEXT,
    uploaded_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    verify_status      VARCHAR(32),
    verify_message     VARCHAR(255),
    PRIMARY KEY (signature_id),
    KEY idx_ordersig_order (order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
