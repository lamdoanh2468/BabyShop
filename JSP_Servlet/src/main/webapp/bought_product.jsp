<%-- Bought Products Page - Modern UI --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Danh sách sản phẩm đã mua</title>
    <link rel="icon" type="image/x-icon"
          href="${pageContext.request.contextPath}/favicon.ico">
    <!-- Font Awesome Icons -->
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap"
          rel="stylesheet">

    <!-- CSS Files -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/profile.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/boughtProduct.css">

    <!-- SweetAlert2 -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <style>
        body {
            font-family: 'Inter', 'Segoe UI', sans-serif;
        }
    </style>
</head>

<body>
<jsp:include page="header.jsp"/>

<div class="pf-page">

    <!-- BREADCRUMB -->
    <nav class="pf-breadcrumb">
        <a href="${pageContext.request.contextPath}/">
            Trang chủ
        </a>
        <span class="dot">•</span>
        <span>Đơn hàng đã mua</span>
    </nav>

    <div class="pf-container">

        <!-- SIDEBAR -->
        <aside class="pf-sidebar">
            <h2><i class="fas fa-user-circle"></i> ${sessionScope.USER.username}</h2>
            <ul>
                <li onclick="location.href='${pageContext.request.contextPath}/profile'">
                    <i class="fas fa-user"></i> Thông tin cá nhân
                </li>
                <li class="active">
                    <i class="fas fa-shopping-bag"></i> Đơn hàng đã mua
                </li>
                <li onclick="location.href='${pageContext.request.contextPath}/my-favorite'">
                    <i class="fas fa-heart"></i> Sản Phẩm Yêu Thích
                </li>
                <li onclick="location.href='${pageContext.request.contextPath}/change-password'">
                    <i class="fas fa-key"></i> Đổi mật khẩu
                </li>
                <li onclick="location.href='${pageContext.request.contextPath}/security-key'">
                    <i class="fas fa-shield-halved"></i> Chữ ký điện tử và chứng thư số
                </li>
            </ul>
        </aside>

        <!-- CONTENT -->
        <main class="pf-content">

            <section class="pf-section pf-section-active">
                <h3>Danh sách đơn hàng đã mua</h3>

                <c:if test="${empty BOUGHTS}">
                    <div class="bp-empty">
                        <p>Bạn chưa có đơn hàng nào</p>
                        <p style="margin-top: 10px; font-size: 14px;">
                            Hãy khám phá các sản phẩm tuyệt vời của chúng tôi!
                        </p>
                        <a href="${pageContext.request.contextPath}/product-list" style="display: inline-block; margin-top: 20px; padding: 12px 24px;
                                      background: linear-gradient(135deg, #007BA8 0%, #00658F 100%); 
                                      color: white; text-decoration: none; border-radius: 10px; 
                                      font-weight: 600; transition: all 0.3s ease;">
                            <i class="fas fa-shopping-cart"></i> Mua sắm ngay
                        </a>
                    </div>
                </c:if>

                <div class="bp-wrap">
                    <!-- BOUGHTS là Map<orderId, List<OrderDetail>> -->
                    <c:forEach items="${BOUGHTS}" var="entry" varStatus="orderLoop">
                        <c:set var="orderStatus" value="${ORDER_STATUSES[entry.key]}"/>

                        <c:set var="statusLabel" value="Không xác định"/>
                        <c:set var="statusClass" value="bp-status-unknown"/>
                        <c:set var="statusIcon" value="fa-circle-question"/>

                        <c:choose>
                            <c:when test="${orderStatus == 'WAITING_SIGNATURE'}">
                                <c:set var="statusLabel" value="Chờ ký"/>
                                <c:set var="statusClass" value="bp-status-waiting-signature"/>
                                <c:set var="statusIcon" value="fa-file-signature"/>
                            </c:when>

                            <c:when test="${orderStatus == 'SIGNATURE_INVALID'}">
                                <c:set var="statusLabel" value="Chữ ký không hợp lệ"/>
                                <c:set var="statusClass" value="bp-status-signature-invalid"/>
                                <c:set var="statusIcon" value="fa-triangle-exclamation"/>
                            </c:when>

                            <c:when test="${orderStatus == 'TAMPERED'}">
                                <c:set var="statusLabel" value="Dữ liệu bị thay đổi"/>
                                <c:set var="statusClass" value="bp-status-tampered"/>
                                <c:set var="statusIcon" value="fa-shield-virus"/>
                            </c:when>

                            <c:when test="${orderStatus == 'VERIFIED'}">
                                <c:set var="statusLabel" value="Đang chờ xác nhận"/>
                                <c:set var="statusClass" value="bp-status-verified"/>
                                <c:set var="statusIcon" value="fa-solid fa-certificate"/>
                            </c:when>

                            <c:when test="${orderStatus == 'DONE'}">
                                <c:set var="statusLabel" value="Đã hoàn thành"/>
                                <c:set var="statusClass" value="bp-status-done"/>
                                <c:set var="statusIcon" value="fa-check-circle"/>
                            </c:when>

                            <c:when test="${orderStatus == 'CANCELLED'}">
                                <c:set var="statusLabel" value="Đã hủy"/>
                                <c:set var="statusClass" value="bp-status-cancelled"/>
                                <c:set var="statusIcon" value="fa-ban"/>
                            </c:when>
                        </c:choose>
                        <div class="bp-order">
                            <!-- Order Header -->
                            <div class="bp-order-head">
                                <h4 class="bp-order-title">
                                    <i class="fas fa-receipt"></i>
                                    Đơn hàng #${entry.key}
                                </h4>
                                <div class="bp-order-badge ${statusClass}">
                                    <i class="fas ${statusIcon}"></i>
                                        ${statusLabel}
                                </div>
                            </div>

                            <!-- Order Body -->
                            <div class="bp-body">
                                <c:forEach items="${entry.value}" var="d" varStatus="itemLoop">
                                    <div class="bp-item">
                                        <c:choose>
                                            <c:when test="${not empty d.product}">
                                                <img class="bp-img" src="${d.product.productImage}"
                                                     alt="${d.product.productName}"
                                                     onerror="this.src='${pageContext.request.contextPath}/images/placeholder.png'">
                                                <div class="bp-info">
                                                    <h4 class="bp-name">${d.product.productName}
                                                    </h4>
                                                    <div class="bp-meta">
                                                        <span class="bp-price"><i class="fas fa-tag"></i><fmt:setLocale
                                                                value="vi_VN"/><fmt:formatNumber
                                                                value="${d.product.productPrice}" type="number"
                                                                groupingUsed="true"/>đ
                                                                            </span>
                                                        <span class="bp-pill bp-qty">
                                                            <i class="fas fa-times"></i>
                                                                ${d.quantity}
                                                        </span>
                                                        <span class="bp-subtotal">
                                                            <i class="fas fa-coins"></i>
                                                            <fmt:formatNumber
                                                                    value="${d.product.productPrice * d.quantity}"
                                                                    type="number"
                                                                    groupingUsed="true"/>
                                                            đ
                                                        </span>
                                                    </div>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <%-- Fallback: nếu OrderDetail chưa có Product --%>
                                                <div class="bp-img"
                                                     style="display: flex; align-items: center; justify-content: center; background: #f1f5f9;">
                                                    <i class="fas fa-image"
                                                       style="font-size: 24px; color: #94a3b8;"></i>
                                                </div>
                                                <div class="bp-info">
                                                    <h4 class="bp-name">
                                                        <i class="fas fa-barcode"></i>
                                                        Mã sản phẩm: ${d.productId}
                                                    </h4>
                                                    <div class="bp-meta">
                                                        <span class="bp-price">
                                                            <i class="fas fa-tag"></i>
                                                            <fmt:setLocale value="vi_VN"/>
                                                            <fmt:formatNumber
                                                                    value="${d.unitPrice}"
                                                                    type="number"
                                                                    groupingUsed="true"/>đ
                                                        </span>
                                                        <span class="bp-pill bp-qty">
                                                                                    <i class="fas fa-times"></i>
                                                                                    ${d.quantity}
                                                                                </span>
                                                        <span class="bp-subtotal">
                                                                                    <i class="fas fa-coins"></i>
                                                                                    <fmt:formatNumber
                                                                                            value="${d.unitPrice * d.quantity}"
                                                                                            type="number"
                                                                                            groupingUsed="true"/>đ
                                                                                </span>
                                                    </div>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </c:forEach>
                            </div>
                            <!-- Order Footer -->
                            <div class="bp-order-footer">
                                <div class="bp-date">
                                    <i class="fas ${statusIcon}"></i>
                                    <span>Trạng thái đơn hàng: ${statusLabel}</span>
                                </div>
                                <div class="bp-total">
                                    <c:set var="order" value="${ORDERS[entry.key]}"/>

                                    <c:set var="subtotal" value="${order.subtotalAmount}"/>
                                    <c:set var="discount" value="${order.discountAmount}"/>
                                    <c:set var="finalTotal" value="${order.totalAmount}"/>

                                    <div style="display:flex; flex-direction:column; gap:6px; align-items:flex-end;">
                                        <div style="font-size:13px; color:#64748b;">
                                            Tổng tiền:
                                            <b>
                                                <fmt:setLocale value="vi_VN"/>
                                                <fmt:formatNumber value="${subtotal}" type="number"
                                                                  groupingUsed="true"/>đ
                                            </b>
                                        </div>

                                        <div style="font-size:13px; color:#ef4444;">
                                            Giảm giá voucher:
                                            <b>
                                                <fmt:formatNumber value="${discount}" type="number"
                                                                  groupingUsed="true"/>đ
                                            </b>
                                        </div>

                                        <div style="font-size:16px; font-weight:800; color:#0f172a;">
                                            Thành tiền:
                                            <span class="bp-total-amount">
                                <fmt:formatNumber value="${finalTotal}" type="number" groupingUsed="true"/>đ
                     </span>
                                        </div>
                                    </div>
                                </div>

                            </div>
                        </div>
                    </c:forEach>
                </div>
            </section>
        </main>
    </div>
</div>

<jsp:include page="footer.jsp"/>
</body>

</html>