package vn.edu.nlu.fit.be.controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import vn.edu.nlu.fit.be.model.Account;
import vn.edu.nlu.fit.be.service.AccountService;

import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;

/**
 * Đăng nhập Google theo luồng OAuth2 thủ công (khớp mô hình session thủ công của app):
 * đổi authorization code -> access_token -> userinfo -> login/tạo account -> set session.
 * Cấu hình qua GOOGLE_CLIENT_ID / GOOGLE_CLIENT_SECRET / GOOGLE_REDIRECT_URI.
 */
@Controller
public class LoginGoogleController {

    private final AccountService accountService;
    private final HttpClient http = HttpClient.newHttpClient();
    private final ObjectMapper mapper = new ObjectMapper();

    private final String clientId;
    private final String clientSecret;
    private final String redirectUri;

    public LoginGoogleController(AccountService accountService,
                                 @Value("${google.client-id:}") String clientId,
                                 @Value("${google.client-secret:}") String clientSecret,
                                 @Value("${google.redirect-uri:}") String redirectUri) {
        this.accountService = accountService;
        this.clientId = clientId;
        this.clientSecret = clientSecret;
        this.redirectUri = redirectUri;
    }

    @GetMapping("/login-google")
    public String callback(@RequestParam(required = false) String code, HttpSession session) {
        if (code == null || code.isBlank()) {
            return "redirect:/login";
        }
        if (clientId.isBlank() || clientSecret.isBlank()) {
            return "redirect:/login?error=google_not_configured";
        }
        try {
            // 1) code -> access_token
            String body = "code=" + enc(code)
                    + "&client_id=" + enc(clientId)
                    + "&client_secret=" + enc(clientSecret)
                    + "&redirect_uri=" + enc(redirectUri)
                    + "&grant_type=authorization_code";
            HttpResponse<String> tokenRes = http.send(HttpRequest.newBuilder()
                            .uri(URI.create("https://oauth2.googleapis.com/token"))
                            .header("Content-Type", "application/x-www-form-urlencoded")
                            .POST(HttpRequest.BodyPublishers.ofString(body))
                            .build(),
                    HttpResponse.BodyHandlers.ofString());
            String accessToken = mapper.readTree(tokenRes.body()).path("access_token").asText(null);
            if (accessToken == null) return "redirect:/login?error=google";

            // 2) access_token -> userinfo
            HttpResponse<String> infoRes = http.send(HttpRequest.newBuilder()
                            .uri(URI.create("https://www.googleapis.com/oauth2/v2/userinfo?access_token=" + enc(accessToken)))
                            .GET().build(),
                    HttpResponse.BodyHandlers.ofString());
            JsonNode info = mapper.readTree(infoRes.body());
            String email = info.path("email").asText(null);
            String name = info.path("name").asText(email);
            if (email == null) return "redirect:/login?error=google";

            // 3) login/tạo account
            Account acc = accountService.loginWithGoogle(email, name);
            if (acc == null) return "redirect:/login?error=blocked";

            // 4) session
            session.setAttribute("USER", acc);
            session.setMaxInactiveInterval(30 * 60);
            return "redirect:/";
        } catch (Exception e) {
            return "redirect:/login?error=google";
        }
    }

    private static String enc(String s) {
        return URLEncoder.encode(s, StandardCharsets.UTF_8);
    }
}
