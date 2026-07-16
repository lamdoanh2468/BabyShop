<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>

    <title>Admin - Cài đặt hệ thống</title>

    <!-- CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin_style.css"/>
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css"/>

    <style>
        .settings-container {
            background: #fff;
            border-radius: 20px;
            padding: 25px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
        }

        .settings-tabs {
            display: flex;
            gap: 20px;
            margin-bottom: 25px;
            border-bottom: 2px solid #eee;
        }

        .settings-tab {
            cursor: pointer;
            font-weight: 600;
            padding: 10px 15px;
            color: #777;
        }

        .settings-tab.active {
            color: #007BA8;
            border-bottom: 3px solid #008BC6;
        }

        .tab-content {
            display: none;
        }

        .tab-content.active {
            display: block;
        }
    </style>
</head>

<body>

<div class="dashboard">
    <!-- SIDEBAR -->

                    <jsp:include page="admin_sidebar.jsp"/>

<!-- CONTENT -->
    <div class="content-wrapper">
        <main class="main">
            <h2>Cài đặt hệ thống</h2>

            <div class="settings-container">

                <!-- TAB HEADER -->
                <div class="settings-tabs">
                    <div class="settings-tab active" data-tab="account">👤 Tài khoản</div>
                </div>

                <!-- TAB: TÀI KHOẢN -->
                <div class="tab-content active" id="account">

                    <form class="form-grid"
                          method="post"
                          action="${pageContext.request.contextPath}/admin/settings">

                        <input type="hidden" name="action" value="update"/>

                        <div class="form-item">
                            <label>Tên hiển thị</label>
                            <input type="text"
                                   name="fullName"
                                   value="${sessionScope.USER.fullName}"
                                   required>
                        </div>

                        <div class="form-item">
                            <label>Email</label>
                            <input type="email"
                                   name="email"
                                   value="${sessionScope.USER.email}"
                                   required>
                        </div>

                        <div class="form-item">
                            <label>Mật khẩu mới</label>
                            <input type="password"
                                   name="password"
                                   placeholder="Để trống nếu không đổi">
                        </div>

                        <button type="submit" class="btn-primary">
                            💾 Cập nhật thông tin
                        </button>
                    </form>

                    <!-- LOGOUT -->
                    <form method="post"
                          action="${pageContext.request.contextPath}/admin/settings"
                          style="margin-top:15px">

                        <input type="hidden" name="action" value="logout"/>

                        <button type="submit" class="btn-small btn-delete">
                            🚪 Đăng xuất
                        </button>
                    </form>

                </div>
            </div>
        </main>
    </div>
</div>

<script>
    const tabs = document.querySelectorAll(".settings-tab");
    const contents = document.querySelectorAll(".tab-content");

    tabs.forEach(tab => {
        tab.addEventListener("click", () => {
            tabs.forEach(t => t.classList.remove("active"));
            contents.forEach(c => c.classList.remove("active"));

            tab.classList.add("active");
            document.getElementById(tab.dataset.tab).classList.add("active");
        });
    });
</script>

</body>
</html>
