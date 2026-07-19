package vn.edu.nlu.fit.be.service;

import org.springframework.stereotype.Service;

import java.security.SecureRandom;

@Service
public class OtpService {

    private final SecureRandom random = new SecureRandom();

    // OTP 6 chữ số (100000..999999) — như OTPUtil cũ nhưng dùng SecureRandom
    public String generateOTP() {
        int otp = 100000 + random.nextInt(900000);
        return String.valueOf(otp);
    }
}
