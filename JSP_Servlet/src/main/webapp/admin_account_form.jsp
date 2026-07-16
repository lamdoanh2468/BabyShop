<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <title>Admin - Thêm tài khoản</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin_style.css?v=20260502-2"/>
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css"/>
</head>
<body>
<div class="dashboard">

                    <jsp:include page="admin_sidebar.jsp"/>

<main class="main">
        <div class="product-form-shell">
            <div class="product-form-hero">
                <div class="product-form-copy">
                    <span class="product-form-eyebrow">Account Workspace</span>
                    <h2>Thêm tài khoản</h2>
                    <p>Tạo nhanh tài khoản mới cho hệ thống và chọn đúng vai trò trước khi lưu.</p>
                </div>

                <a href="${pageContext.request.contextPath}/admin/accounts" class="product-back-link">
                    <i class="fa-solid fa-arrow-left"></i>
                    <span>Quay lại danh sách</span>
                </a>
            </div>

            <div class="product-form-layout">
                <section class="product-form-card">
                    <div class="product-form-card-head">
                        <div>
                            <h3>Thông tin tài khoản mới</h3>
                            <p>Username và email cần duy nhất. Tài khoản mới sẽ được tạo ở trạng thái hoạt động.</p>
                        </div>
                        <div class="product-form-state">
                            <i class="fa-solid fa-user-plus"></i>
                            <span>Creating</span>
                        </div>
                    </div>

                    <form method="post" action="${pageContext.request.contextPath}/admin/accounts/add">
                        <div class="form-grid product-form-grid">
                            <div class="form-item">
                                <label>Username</label>
                                <input type="text" name="username" placeholder="Ví dụ: nguyenan" required/>
                            </div>

                            <div class="form-item">
                                <label>Email</label>
                                <input type="email" name="email" placeholder="Ví dụ: an@example.com" required/>
                            </div>

                            <div class="form-item">
                                <label>Password</label>
                                <input type="password" name="password" placeholder="Nhập mật khẩu" required/>
                            </div>

                            <div class="form-item">
                                <label>Vai trò</label>
                                <select name="role">
                                    <option value="0">User</option>
                                    <option value="1">Admin</option>
                                </select>
                            </div>
                        </div>

                        <div class="product-form-actions">
                            <a href="${pageContext.request.contextPath}/admin/accounts" class="product-cancel-link">
                                Hủy
                            </a>
                            <button type="submit" class="btn-primary product-submit-btn">
                                <i class="fa-solid fa-user-plus"></i>
                                <span>Tạo tài khoản</span>
                            </button>
                        </div>
                    </form>
                </section>

                <aside class="product-preview-card">
                    <div class="product-preview-media">
                        <div class="product-preview-placeholder">
                            <i class="fa-regular fa-id-badge"></i>
                        </div>
                    </div>

                    <div class="product-preview-body">
                        <span class="product-preview-badge">Tạo mới</span>
                        <h3>Tài khoản sẽ xuất hiện trong danh sách admin accounts</h3>
                        <p>Sau khi tạo xong, bạn có thể đổi trạng thái Active hoặc Block ngay trong bảng quản lý tài khoản.</p>

                        <div class="product-preview-meta">
                            <div>
                                <span>Trạng thái mặc định</span>
                                <strong>Active</strong>
                            </div>
                            <div>
                                <span>Quyền truy cập</span>
                                <strong>User/Admin</strong>
                            </div>
                        </div>
                    </div>
                </aside>
            </div>
        </div>
    </main>
</div>
</body>
</html>
