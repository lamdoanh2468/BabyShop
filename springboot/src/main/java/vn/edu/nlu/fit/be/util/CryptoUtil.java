package vn.edu.nlu.fit.be.util;

import org.bouncycastle.asn1.pkcs.PrivateKeyInfo;
import org.bouncycastle.asn1.x500.X500Name;
import org.bouncycastle.asn1.x509.BasicConstraints;
import org.bouncycastle.asn1.x509.Extension;
import org.bouncycastle.asn1.x509.KeyUsage;
import org.bouncycastle.cert.X509CertificateHolder;
import org.bouncycastle.cert.jcajce.JcaX509CertificateConverter;
import org.bouncycastle.cert.jcajce.JcaX509ExtensionUtils;
import org.bouncycastle.cert.jcajce.JcaX509v3CertificateBuilder;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.bouncycastle.openssl.PEMKeyPair;
import org.bouncycastle.openssl.PEMParser;
import org.bouncycastle.openssl.jcajce.JcaPEMKeyConverter;
import org.bouncycastle.operator.ContentSigner;
import org.bouncycastle.operator.jcajce.JcaContentSignerBuilder;

import java.math.BigInteger;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.*;
import java.security.cert.X509Certificate;
import java.util.Base64;
import java.util.Date;

public class CryptoUtil {

    private static final String KEY_ALGORITHM = "RSA";
    private static final String SIGNATURE_ALGORITHM = "SHA256withRSA";
    private static final String PROVIDER = "BC";

    static {
        if (Security.getProvider(PROVIDER) == null) {
            Security.addProvider(new BouncyCastleProvider());
        }
    }

    public static KeyPair generateRsaKeyPair(int bits) throws GeneralSecurityException {
        KeyPairGenerator keyPairGenerator = KeyPairGenerator.getInstance(KEY_ALGORITHM);
        keyPairGenerator.initialize(bits, new SecureRandom());
        return keyPairGenerator.generateKeyPair();
    }

    public static String toPemPublicKey(PublicKey key) {
        String b64 = Base64.getEncoder().encodeToString(key.getEncoded());

        StringBuilder builder = new StringBuilder();
        builder.append("-----BEGIN PUBLIC KEY-----\n");
        builder.append(wrap(b64));
        builder.append("-----END PUBLIC KEY-----\n");

        return builder.toString();
    }

    public static String toPemPrivateKey(PrivateKey key) {
        String b64 = Base64.getEncoder().encodeToString(key.getEncoded());

        StringBuilder builder = new StringBuilder();
        builder.append("-----BEGIN PRIVATE KEY-----\n");
        builder.append(wrap(b64));
        builder.append("-----END PRIVATE KEY-----\n");

        return builder.toString();
    }

    public static String toPemCertificate(X509Certificate certificate) throws Exception {
        String b64 = Base64.getEncoder().encodeToString(certificate.getEncoded());

        StringBuilder builder = new StringBuilder();
        builder.append("-----BEGIN CERTIFICATE-----\n");
        builder.append(wrap(b64));
        builder.append("-----END CERTIFICATE-----\n");

        return builder.toString();
    }

    private static String wrap(String value) {
        StringBuilder builder = new StringBuilder();

        int index = 0;
        while (index < value.length()) {
            int end = Math.min(index + 64, value.length());
            builder.append(value, index, end).append('\n');
            index = end;
        }

        return builder.toString();
    }

    public static X509Certificate loadCertificate(Path path) throws Exception {
        try (PEMParser pemParser = new PEMParser(Files.newBufferedReader(path))) {
            Object pemObject = pemParser.readObject();
            if (pemObject == null) {
                throw new IllegalArgumentException("Certificate file is empty: " + path);
            }
            if (!(pemObject instanceof X509CertificateHolder certificateHolder)) {
                throw new IllegalArgumentException("Invalid certificate PEM file: " + path);
            }
            return new JcaX509CertificateConverter()
                    .setProvider("BC")
                    .getCertificate(certificateHolder);
        }
    }

    public static PrivateKey loadPrivateKey(Path path) throws Exception {
        try (PEMParser pemParser = new PEMParser(Files.newBufferedReader(path))) {
            Object pemObject = pemParser.readObject();
            if (pemObject == null) {
                throw new IllegalArgumentException("Private key file is empty: " + path);
            }
            JcaPEMKeyConverter converter = new JcaPEMKeyConverter()
                    .setProvider("BC");

            if (pemObject instanceof PEMKeyPair keyPair) {
                return converter.getKeyPair(keyPair).getPrivate();
            }

            if (pemObject instanceof PrivateKeyInfo privateKeyInfo) {
                return converter.getPrivateKey(privateKeyInfo);
            }

            throw new IllegalArgumentException("Invalid private key PEM file: " + path);

        }
    }

    public static X509Certificate genCertSignedByCA(PublicKey pubKey, PrivateKey caPriKey, X509Certificate caCert, String subDn, int validDays)
            throws Exception {
        {
            Date notBefore = new Date();
            Date notAfter = new Date(System.currentTimeMillis() + validDays * 24L * 60L * 60L * 1000L);

            BigInteger serial = BigInteger.valueOf(System.currentTimeMillis());

            X500Name issuer = new X500Name(caCert.getSubjectX500Principal().getName());
            X500Name subject = new X500Name(subDn);

            JcaX509v3CertificateBuilder certBuilder = new JcaX509v3CertificateBuilder(
                    issuer,
                    serial,
                    notBefore,
                    notAfter,
                    subject,
                    pubKey
            );

            certBuilder.addExtension(
                    Extension.basicConstraints,
                    true,
                    new BasicConstraints(false)
            );

            certBuilder.addExtension(
                    Extension.keyUsage,
                    true,
                    new KeyUsage(KeyUsage.digitalSignature | KeyUsage.nonRepudiation)
            );

            certBuilder.addExtension(
                    Extension.subjectKeyIdentifier,
                    false,
                    new JcaX509ExtensionUtils().createSubjectKeyIdentifier(pubKey)
            );

            certBuilder.addExtension(
                    Extension.authorityKeyIdentifier,
                    false,
                    new JcaX509ExtensionUtils().createAuthorityKeyIdentifier(caCert)
            );

            ContentSigner signer = new JcaContentSignerBuilder("SHA256withRSA")
                    .build(caPriKey);

            X509CertificateHolder holder = certBuilder.build(signer);

            return new JcaX509CertificateConverter()
                    .getCertificate(holder);
        }
    }

    public static X509Certificate genSelfSignedCA(KeyPair caKeyPair, String caDn, int validDays)
            throws Exception {
        Date notBefore = new Date();
        Date notAfter = new Date(System.currentTimeMillis() + validDays * 24L * 60L * 60L * 1000L);
        BigInteger serial = BigInteger.valueOf(System.currentTimeMillis());

        X500Name issuer = new X500Name(caDn);
        X500Name subject = new X500Name(caDn);

        JcaX509v3CertificateBuilder certBuilder = new JcaX509v3CertificateBuilder(
                issuer,
                serial,
                notBefore,
                notAfter,
                subject,
                caKeyPair.getPublic()
        );

        certBuilder.addExtension(
                Extension.basicConstraints,
                true,
                new BasicConstraints(true)
        );

        certBuilder.addExtension(
                Extension.keyUsage,
                true,
                new KeyUsage(KeyUsage.keyCertSign | KeyUsage.cRLSign | KeyUsage.digitalSignature)
        );

        certBuilder.addExtension(
                Extension.subjectKeyIdentifier,
                false,
                new JcaX509ExtensionUtils().createSubjectKeyIdentifier(caKeyPair.getPublic())
        );

        ContentSigner signer = new JcaContentSignerBuilder(SIGNATURE_ALGORITHM)
                .build(caKeyPair.getPrivate());

        X509CertificateHolder holder = certBuilder.build(signer);

        return new JcaX509CertificateConverter()
                .setProvider(PROVIDER)
                .getCertificate(holder);
    }
}
