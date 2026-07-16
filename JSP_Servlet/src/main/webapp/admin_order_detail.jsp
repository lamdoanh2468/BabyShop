<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <title>Admin - Chi tiết đơn hàng</title>
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
                    <h2>Chi tiết đơn hàng #${order.orderId}</h2>
                    <p>Xem thông tin khách hàng, trạng thái đơn và toàn bộ sản phẩm thuộc đơn hàng này.</p>
                </div>

                <a href="${pageContext.request.contextPath}/admin/orders" class="product-back-link">
                    <i class="fa-solid fa-arrow-left"></i>
                    <span>Quay lại</span>
                </a>
            </div>

            <div class="product-form-layout">
                <section class="product-form-card">
                    <div class="product-form-card-head">
                        <div>
                            <h3>Thông tin đơn hàng</h3>
                            <p>Thông tin này được lấy trực tiếp từ hệ thống tại thời điểm hiện tại.</p>
                        </div>
                    </div>

                    <div class="product-preview-meta" style="margin-bottom:20px;">
                        <div>
                            <span>Khách hàng</span>
                            <strong>${order.username}</strong>
                        </div>
                        <div>
                            <span>Ngày đặt</span>
                            <strong>${order.orderDate}</strong>
                        </div>
                        <div>
                            <span>Thanh toán</span>
                            <strong>${order.paymentMethod}</strong>
                        </div>
                        <div>
                            <span>Địa chỉ giao hàng</span>
                            <strong>${order.deliveryAddress}</strong>
                        </div>
                        <div>
                            <span>Trạng thái</span>

                            <select class="status-select ${order.statusOrder}"
                                    data-id="${order.orderId}"
                                    data-previous="${order.statusOrder}"
                                    onchange="updateStatus(this)"
                            ${order.statusOrder eq 'CANCELLED' || order.statusOrder eq 'DONE' ? 'disabled' : ''}>

                                <option value="WAITING_SIGNATURE" ${order.statusOrder eq 'WAITING_SIGNATURE' ? 'selected' : ''}>
                                    Chờ ký
                                </option>

                                <option value="SIGNATURE_INVALID" ${order.statusOrder eq 'SIGNATURE_INVALID' ? 'selected' : ''}>
                                    Chữ ký điện tử không hợp lệ
                                </option>

                                <option value="TAMPERED" ${order.statusOrder eq 'TAMPERED' ? 'selected' : ''}>
                                    Chữ ký điện tử bị sửa đổi
                                </option>

                                <option value="VERIFIED" ${order.statusOrder eq 'VERIFIED' ? 'selected' : ''}>
                                    Chữ ký điện tử hợp lệ
                                </option>

                                <option value="DONE" ${order.statusOrder eq 'DONE' ? 'selected' : ''}>
                                    Xác nhận thành công
                                </option>

                                <option value="CANCELLED" ${order.statusOrder eq 'CANCELLED' ? 'selected' : ''}>
                                    Đã hủy
                                </option>
                            </select>
                        </div>
                    </div>

                    <section class="voucher-list">
                        <h3>Sản phẩm trong đơn</h3>
                        <table class="data-table">
                            <thead>
                            <tr>
                                <th>Mã sản phẩm</th>
                                <th>Tên</th>
                                <th>Hình ảnh</th>
                                <th>Đơn giá</th>
                                <th>Số lượng</th>
                                <th>Thành tiền</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="detail" items="${orderDetails}">
                                <tr>
                                    <td>${detail.productId}</td>
                                    <td>${detail.product.productName}</td>
                                    <td>
                                        <c:if test="${detail.product != null && not empty detail.product.productImage}">
                                            <img src="${detail.product.productImage}" class="product-img"
                                                 alt="product"/>
                                        </c:if>
                                    </td>
                                    <td><fmt:formatNumber value="${detail.unitPrice}" type="number"/>đ</td>
                                    <td>${detail.quantity}</td>
                                    <td><fmt:formatNumber value="${detail.unitPrice * detail.quantity}"
                                                          type="number"/>đ
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </section>
                </section>

                <aside class="product-preview-card">
                    <div class="product-preview-media">
                        <div class="product-preview-placeholder">
                            <i class="fa-solid fa-receipt"></i>
                        </div>
                    </div>

                    <div class="product-preview-body">
                        <span class="product-preview-badge">Tóm tắt</span>
                        <h3>Đơn hàng #${order.orderId}</h3>
                        <p>Đơn này thuộc khách hàng ${order.username} và hiện có tổng giá trị hiển thị bên dưới.</p>
                        <div class="product-preview-meta">
                            <div>
                                <span>Tổng tiền</span>
                                <strong><fmt:formatNumber value="${order.totalAmount}" type="number"/>đ</strong>
                            </div>
                            <div>
                                <span>Số sản phẩm</span>
                                <strong>${orderDetails.size()}</strong>
                            </div>
                        </div>
                    </div>
                </aside>
            </div>
        </div>
    </main>
</div>
</body>
<script>
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

                    if (status === 'CANCELLED' || status === 'DONE') {
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

                    if (status === 'CANCELLED' || status === 'DONE') {
                        select.disabled = true;
                    }

                    Swal.fire({
                        icon: 'warning',
                        title: 'Trạng thái đã cập nhật',
                        text: 'Nhưng có lỗi khi xử lý kho hàng.'
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
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</html>
