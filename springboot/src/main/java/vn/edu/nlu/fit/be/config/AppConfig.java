package vn.edu.nlu.fit.be.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

@Configuration
public class AppConfig {

    /**
     * BCryptPasswordEncoder đọc được hash $2a$ cũ do jbcrypt tạo -> tài khoản cũ đăng nhập bình thường.
     * (Chỉ dùng lớp crypto của Spring Security, chưa bật Spring Security filter chain — Phase 1.)
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
