package vn.edu.nlu.fit.be.config;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;
import vn.edu.nlu.fit.be.model.Account;

/**
 * Chặn mọi route /admin/** (Phase 1 — session thủ công). Thay cho đoạn check role
 * lặp lại trong từng servlet admin cũ.
 *   - Chưa đăng nhập  -> /login
 *   - Đăng nhập nhưng không phải admin (role <= 0) -> 403
 */
@Component
public class AdminInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        HttpSession session = request.getSession(false);
        Account acc = (session == null) ? null : (Account) session.getAttribute("USER");

        if (acc == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }
        if (acc.getRole() == null || acc.getRole() <= 0) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập trang quản trị.");
            return false;
        }
        return true;
    }
}
