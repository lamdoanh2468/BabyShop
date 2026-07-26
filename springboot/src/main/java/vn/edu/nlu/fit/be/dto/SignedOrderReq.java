package vn.edu.nlu.fit.be.dto;

// Payload upload từ tool ký (file signed_order.json)
public class SignedOrderReq {
    private int orderId;
    private int accountId;
    private int certificateId;
    private String orderHash;
    private String signatureValue;      // base64
    private String signatureAlgorithm;  // SHA256withRSA

    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }

    public int getAccountId() { return accountId; }
    public void setAccountId(int accountId) { this.accountId = accountId; }

    public int getCertificateId() { return certificateId; }
    public void setCertificateId(int certificateId) { this.certificateId = certificateId; }

    public String getOrderHash() { return orderHash; }
    public void setOrderHash(String orderHash) { this.orderHash = orderHash; }

    public String getSignatureValue() { return signatureValue; }
    public void setSignatureValue(String signatureValue) { this.signatureValue = signatureValue; }

    public String getSignatureAlgorithm() { return signatureAlgorithm; }
    public void setSignatureAlgorithm(String signatureAlgorithm) { this.signatureAlgorithm = signatureAlgorithm; }
}
