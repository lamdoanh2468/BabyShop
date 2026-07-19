package vn.edu.nlu.fit.be.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class EmailService {

    private static final Logger log = LoggerFactory.getLogger(EmailService.class);

    private final JavaMailSender mailSender;
    private final String mailUsername;

    public EmailService(JavaMailSender mailSender,
                        @Value("${spring.mail.username:}") String mailUsername) {
        this.mailSender = mailSender;
        this.mailUsername = mailUsername;
    }

    public void sendOTP(String toEmail, String otp) {
        // Chưa cấu hình SMTP (MAIL_USERNAME trống) -> log OTP thay vì gửi (dev/test), không làm gãy luồng.
        // KHÔNG hardcode tài khoản gửi mail như bản cũ.
        if (mailUsername == null || mailUsername.isBlank()) {
            log.warn("[MAIL chưa cấu hình] OTP cho {}: {}  (đặt MAIL_USERNAME/MAIL_PASSWORD để gửi thật)", toEmail, otp);
            return;
        }
        try {
            SimpleMailMessage msg = new SimpleMailMessage();
            msg.setFrom(mailUsername);
            msg.setTo(toEmail);
            msg.setSubject("Mã OTP đăng ký tài khoản");
            msg.setText("Mã OTP của bạn là: " + otp + "\nHiệu lực trong 60 giây.");
            mailSender.send(msg);
            log.info("Đã gửi OTP tới {}", toEmail);
        } catch (Exception e) {
            log.error("Lỗi gửi mail OTP tới {}: {}", toEmail, e.getMessage());
        }
    }
}
