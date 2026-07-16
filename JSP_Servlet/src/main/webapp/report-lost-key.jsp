<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Báo mất Private Key</title>
    <link rel="icon" type="image/x-icon" href="${pageContext.request.contextPath}/favicon.ico">
    
    <!-- Font Awesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/profile.css">
    
    <!-- SweetAlert2 -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/report-lost-key.css">
</head>
<body>
<jsp:include page="header.jsp"/>

<div class="pf-page">
    <nav class="pf-breadcrumb">
        <a href="${pageContext.request.contextPath}/">Trang chủ</a>
        <span class="dot">•</span>
        <a href="${pageContext.request.contextPath}/security-key">Khóa bảo mật</a>
        <span class="dot">•</span>
        <span>Báo mất khóa</span>
    </nav>

    <div class="pf-container">
        <!-- SIDEBAR -->
        <aside class="pf-sidebar">
            <h2><i class="fas fa-user-circle"></i> Người dùng</h2>
            <ul>
                <li onclick="location.href='${pageContext.request.contextPath}/profile'">
                    <i class="fas fa-user"></i> Thông tin cá nhân
                </li>
                <li onclick="location.href='${pageContext.request.contextPath}/bought-product'">
                    <i class="fas fa-shopping-bag"></i> Đơn hàng đã mua
                </li>
                <li onclick="location.href='${pageContext.request.contextPath}/my-favorite'">
                    <i class="fas fa-heart"></i> Sản Phẩm Yêu Thích
                </li>
                <li onclick="location.href='${pageContext.request.contextPath}/change-password'">
                    <i class="fas fa-key"></i> Đổi mật khẩu
                </li>
                <li class="active" onclick="location.href='${pageContext.request.contextPath}/security-key'">
                    <i class="fas fa-shield-halved"></i> Khóa bảo mật
                </li>
            </ul>
        </aside>

        <!-- CONTENT -->
        <main class="pf-content">
            <section class="pf-section pf-section-active">
                <div class="report-card">
                    <div class="report-header">
                        <i class="fas fa-triangle-exclamation"></i>
                        <h3>Bạn có chắc chắn muốn báo mất Private Key?</h3>
                        <p>Hành động này là không thể hoàn tác và sẽ ảnh hưởng trực tiếp đến việc ký đơn hàng của bạn.</p>
                    </div>

                    <div class="warning-box">
                        <ul>
                            <li><strong>Chứng thư hiện tại sẽ bị hủy (Revoked)</strong> ngay lập tức.</li>
                            <li><strong>Các đơn hàng mới</strong> được ký bằng Private Key cũ sẽ <strong>không còn được chấp nhận</strong>.</li>
                            <li>Bạn sẽ cần phải <strong>tạo khóa và chứng thư mới</strong> để tiếp tục mua hàng và ký điện tử.</li>
                        </ul>
                    </div>

                    <form id="reportKeyForm" onsubmit="handleReportSubmit(event)">
                        <div class="form-group">
                            <label for="password">Nhập lại mật khẩu của bạn</label>
                            <input type="password" id="password" class="form-control" placeholder="Nhập mật khẩu để xác thực..." required>
                        </div>

                        <div class="form-group">
                            <label for="otp">Mã xác thực OTP (Gửi qua Email)</label>
                            <div class="otp-group">
                                <input type="text" id="otp" class="form-control" placeholder="Nhập mã OTP 6 số..." required pattern="[0-9]{6}" title="Vui lòng nhập 6 chữ số">
                                <button type="button" id="btnGetOtp" class="btn-get-otp" onclick="requestOtp()">Nhận OTP</button>
                            </div>
                        </div>

                        <div class="action-buttons">
                            <a href="${pageContext.request.contextPath}/security-key" class="btn btn-cancel">Hủy bỏ, quay lại</a>
                            <button type="submit" class="btn btn-danger">
                                <i class="fas fa-shield-xmark"></i> Xác nhận báo mất khóa
                            </button>
                        </div>
                    </form>
                </div>
            </section>
        </main>
    </div>
</div>

<jsp:include page="footer.jsp"/>

<script>
    function requestOtp() {
        const btn = document.getElementById('btnGetOtp');
        
        // Mock API call
        btn.disabled = true;
        let countdown = 60;
        
        Swal.fire({
            icon: 'success',
            title: 'Đã gửi mã OTP!',
            text: 'Vui lòng kiểm tra email của bạn để lấy mã xác thực.',
            timer: 2000,
            showConfirmButton: false
        });

        const timer = setInterval(() => {
            btn.innerText = 'Gửi lại sau ' + countdown + 's';
            countdown--;
            if (countdown < 0) {
                clearInterval(timer);
                btn.disabled = false;
                btn.innerText = 'Nhận OTP';
            }
        }, 1000);
    }

    function handleReportSubmit(event) {
        event.preventDefault();
        
        const password = document.getElementById('password').value;
        const otp = document.getElementById('otp').value;

        if(!password || !otp) {
            Swal.fire('Lỗi', 'Vui lòng điền đầy đủ thông tin!', 'error');
            return;
        }

        Swal.fire({
            title: 'Đang xử lý...',
            text: 'Hệ thống đang thu hồi chứng thư của bạn.',
            allowOutsideClick: false,
            didOpen: () => {
                Swal.showLoading();
            }
        });

        // Giả lập thời gian delay của API
        setTimeout(() => {
            Swal.fire({
                icon: 'success',
                title: 'Báo mất thành công!',
                text: 'Chứng thư cũ đã bị thu hồi. Vui lòng tạo chứng thư mới.',
                confirmButtonColor: '#007BA8',
                confirmButtonText: 'Quay lại quản lý khóa'
            }).then(() => {
                window.location.href = '${pageContext.request.contextPath}/security-key';
            });
        }, 1500);
    }
</script>
</body>
</html>
