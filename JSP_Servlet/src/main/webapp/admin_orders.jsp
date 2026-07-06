<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <title>Admin - Quản lý đơn hàng</title>

    <!-- CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin_style.css"/>
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css"/>

    <!-- JS LIB -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <style>
        .tampered-row {
            background: #fff1f2;
        }

        .tampered-warning {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            margin-top: 6px;
            color: #dc2626;
            font-size: 12px;
            font-weight: 700;
        }
    </style>
</head>

<body>

<div class="dashboard">

    <!-- SIDEBAR -->
    <aside class="sidebar">
        <nav class="menu">
            <a href="${pageContext.request.contextPath}/admin/overview">
                <i class="fa-solid fa-house"></i>
                <span>Dashboard</span>
            </a>

            <a href="${pageContext.request.contextPath}/admin/accounts">
                <i class="fa-solid fa-user"></i>
                <span>Tài khoản</span>
            </a>

            <a href="${pageContext.request.contextPath}/admin/orders" class="active">
                <i class="fa-solid fa-box"></i>
                <span>Đơn hàng</span>
            </a>

            <a href="${pageContext.request.contextPath}/admin/products">
                <i class="fa-solid fa-cubes"></i>
                <span>Sản phẩm</span>
            </a>

            <a href="${pageContext.request.contextPath}/admin/categories">
                <i class="fa-solid fa-layer-group"></i>
                <span>Danh mục sản phẩm</span>
            </a>

            <a href="${pageContext.request.contextPath}/admin/brands">
                <i class="fa-solid fa-tags"></i>
                <span>Thương hiệu</span>
            </a>

            <a href="${pageContext.request.contextPath}/admin/contacts">
                <i class="fa-solid fa-envelope"></i>
                <span>Liên hệ</span>
            </a>

            <a href="${pageContext.request.contextPath}/admin/stocks">
                <i class="fa-solid fa-warehouse"></i>
                <span>Kho hàng</span>
            </a>

            <a href="${pageContext.request.contextPath}/admin/vouchers">
                <i class="fa-solid fa-ticket"></i>
                <span>Vouchers</span>
            </a>

            <a href="${pageContext.request.contextPath}/admin/settings">
                <i class="fa-solid fa-gear"></i>
                <span>Cài đặt</span>
            </a>
        </nav>
    </aside>

    <!-- MAIN CONTENT -->
    <main class="main">
        <h2>Quản lý đơn hàng</h2>

        <c:if test="${not empty tamperedOrderIds}">
            <div style="background:#fee2e2;color:#991b1b;border:1px solid #fecaca;border-radius:10px;padding:12px 14px;margin-bottom:16px;font-weight:700;">
                <i class="fa-solid fa-triangle-exclamation"></i>
                Phát hiện đơn hàng có dữ liệu bị thay đổi so với bản đã ký. Hệ thống đã chuyển sang trạng thái lỗi.
            </div>
        </c:if>

        <table class="data-table">
            <thead>
            <tr>
                <th>Mã đơn</th>
                <th>Khách hàng</th>
                <th>Ngày đặt</th>
                <th>Tổng tiền</th>
                <th>Thanh toán</th>
                <th>Trạng thái</th>
                <th>Hành động</th>
            </tr>
            </thead>

            <tbody>
            <c:forEach var="order" items="${orders}">
                <tr class="${order.statusOrder eq 'TAMPERED' ? 'tampered-row' : ''}">
                    <td>#${order.orderId}</td>

                    <td>${order.username}</td>

                    <td>${order.orderDate}</td>
                    <td>
                        <fmt:formatNumber value="${order.totalAmount}" type="number"/>đ
                    </td>

                    <td>${order.paymentMethod}</td>
                    <td>
                        <select class="status-select ${order.statusOrder}"
                                data-id="${order.orderId}" data-previous="${order.statusOrder}"
                                onchange="updateStatus(this)" ${order.statusOrder eq 'CANCELLED' ||
                                order.statusOrder eq 'DONE' || order.statusOrder eq 'TAMPERED' ? 'disabled' : '' }>

                            <option value="WAITING_SIGNATURE" ${order.statusOrder eq 'WAITING_SIGNATURE' ? 'selected'
                                    : '' }>
                                Chờ ký
                            </option>

                            <option value="SIGNATURE_INVALID" ${order.statusOrder eq 'SIGNATURE_INVALID' ? 'selected'
                                    : '' }>
                                Chữ ký điện tử không hợp lệ
                            </option>

                            <option value="TAMPERED" ${order.statusOrder eq 'TAMPERED' ? 'selected'
                                    : '' }>
                                Dữ liệu đơn hàng bị thay đổi
                            </option>

                            <option value="VERIFIED" ${order.statusOrder eq 'VERIFIED' ? 'selected'
                                    : '' }>
                                Chữ ký điện tử hợp lệ
                            </option>
                            <option value="DONE" ${order.statusOrder eq 'DONE' ? 'selected' : '' }>
                                Xác nhận thành công
                            </option>

                            <option value="CANCELLED" ${order.statusOrder eq 'CANCELLED'
                                    ? 'selected' : '' }>
                                Đã hủy
                            </option>
                        </select>

                        <c:if test="${order.statusOrder eq 'TAMPERED'}">
                            <div class="tampered-warning">
                                <i class="fa-solid fa-triangle-exclamation"></i>
                                Dữ liệu DB khác với bản đã ký
                            </div>
                        </c:if>
                    </td>
                    <td>
                        <a class="btn-small btn-on"
                           href="${pageContext.request.contextPath}/admin/orders/detail?id=${order.orderId}"
                           title="Xem chi tiết">
                            <i class="fa-solid fa-eye"></i>
                        </a>
                    </td>
                </tr>
            </c:forEach>

            <c:if test="${empty orders}">
                <tr>
                    <td colspan="7" style="text-align:center">
                        Không có đơn hàng
                    </td>
                </tr>
            </c:if>
            </tbody>
        </table>
    </main>

    <!-- RIGHT PANEL -->
    <aside class="right-panel"></aside>

</div>


</body>
<script>
    window.addEventListener('load', function () {
        const hasTamperedOrders = ${not empty tamperedOrderIds ? 'true' : 'false'};

        if (hasTamperedOrders) {
            Swal.fire({
                icon: 'error',
                title: 'Phát hiện dữ liệu đơn hàng bị thay đổi',
                text: 'Có đơn hàng có dữ liệu trong DB khác với dữ liệu đã được ký. Hệ thống đã chuyển đơn hàng sang trạng thái lỗi.',
                confirmButtonText: 'Đã hiểu',
                allowOutsideClick: false,
                allowEscapeKey: false
            });
        }
    });

    async function updateStatus(select) {
        const id = select.getAttribute('data-id');
        const status = select.value;
        const previousValue = select.getAttribute('data-previous') || 'WAITING_SIGNATURE';

        if (status === 'CANCELLED') {
            const result = await Swal.fire({
                icon: 'warning',
                title: 'Bạn chắc chắn muốn huỷ đơn hàng này không?',
                text: 'Hành động này sẽ không được hoàn tác.',
                showCancelButton: true,
                confirmButtonText: 'Đồng ý huỷ',
                cancelButtonText: 'Không',
                allowOutsideClick: false,
                allowEscapeKey: false,
                reverseButtons: true
            });

            if (!result.isConfirmed) {
                select.value = previousValue;
                return;
            }
        }

        const url = '${pageContext.request.contextPath}/admin/orders/status?id='
            + encodeURIComponent(id)
            + '&status='
            + encodeURIComponent(status);

        fetch(url)
            .then(function (res) {
                return res.text();
            })
            .then(function (txt) {
                if (txt === 'OK') {
                    select.setAttribute('data-previous', status);
                    select.className = 'status-select ' + status;

                    if (status === 'CANCELLED' || status === 'DONE' || status === 'TAMPERED') {
                        select.disabled = true;
                    }

                    Swal.fire({
                        icon: 'success',
                        title: 'Cập nhật thành công',
                        timer: 1200,
                        showConfirmButton: false
                    });

                } else if (txt === 'PARTIAL') {
                    select.setAttribute('data-previous', status);
                    select.className = 'status-select ' + status;

                    if (status === 'CANCELLED' || status === 'DONE' || status === 'TAMPERED') {
                        select.disabled = true;
                    }

                    Swal.fire({
                        icon: 'warning',
                        title: 'Trạng thái đã cập nhật',
                        text: 'Nhưng có lỗi khi xử lý kho hàng.'
                    });

                } else if (txt.startsWith('TAMPERED:')) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Dữ liệu đơn hàng đã bị thay đổi',
                        text: txt.replace('TAMPERED:', '').trim(),
                        confirmButtonText: 'Tải lại trang',
                        allowOutsideClick: false,
                        allowEscapeKey: false
                    }).then(function () {
                        window.location.reload();
                    });

                } else {
                    Swal.fire({
                        icon: 'error',
                        title: 'Cập nhật thất bại',
                        text: txt
                    });

                    select.value = previousValue;
                }
            })
            .catch(function (err) {
                Swal.fire({
                    icon: 'error',
                    title: 'Lỗi kết nối',
                    text: String(err)
                });

                select.value = previousValue;
            });
    }
</script>

</html>
