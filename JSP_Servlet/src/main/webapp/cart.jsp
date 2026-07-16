<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="vn.edu.nlu.fit.be.service.CertificateService" %>
<%@ page import="vn.edu.nlu.fit.be.model.Account" %>
<%
    Account userAcc = (Account) session.getAttribute("USER");
    if (userAcc != null) {
        CertificateService certSvc = new CertificateService();
        if (!certSvc.hasPendingPrivateKey(userAcc.getAccountId())) {
            session.removeAttribute("privateKeyUrl");
        }
    }
%>


<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Giỏ hàng của bạn</title>

    <link rel="icon" type="image/x-icon" href="${pageContext.request.contextPath}/favicon.ico">

    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.0.1/css/all.min.css"
          integrity="sha512-2SwdPD6INVrV/lHTZbO2nodKhrnDdJK9/kg2XD1r9uGqPo1cUbujc+IYdlYdEErWNu69gVcYgdxlmVmzTWnetw=="
          crossorigin="anonymous"
          referrerpolicy="no-referrer"/>

    <link rel="stylesheet" href="../fontawesome-free-7.1.0-web/css/all.min.css"/>

    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <link rel="stylesheet"
          type="text/css"
          href="${pageContext.request.contextPath}/css/cartStyle.css?v=sign-popup-3"/>

    <style>
        .sign-popup-content {
            text-align: left;
        }

        .sign-popup-desc {
            color: #334155;
            line-height: 1.6;
            margin-bottom: 1rem;
        }

        .sign-popup-steps {
            display: grid;
            gap: 0.75rem;
            margin-top: 1rem;
        }

        .sign-step-card {
            display: block;
            text-decoration: none;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 0.85rem 1rem;
            color: #0f172a;
            background: #ffffff;
            transition: 0.2s ease;
        }

        .sign-step-card:hover {
            border-color: #008BC6;
            background: #FEF7FF;
        }

        .sign-step-card.primary {
            border-color: #008BC6;
            background: #ECF8FD;
        }

        .sign-step-card.success {
            border-color: #10b981;
            background: #ecfdf5;
        }

        .sign-step-card.warning {
            border-color: #f59e0b;
            background: #fffbeb;
        }

        .sign-step-card strong {
            display: block;
            margin-bottom: 0.25rem;
        }

        .sign-step-card span {
            display: block;
            font-size: 0.85rem;
            color: #475569;
        }

        .sign-upload-box {
            border: 1px dashed #94a3b8;
            border-radius: 12px;
            padding: 1rem;
            background: #f8fafc;
        }

        .sign-upload-box label {
            display: block;
            font-weight: 700;
            color: #0f172a;
            margin-bottom: 0.5rem;
        }

        .sign-upload-box input[type="file"] {
            width: 100%;
            margin-bottom: 0.75rem;
        }

        #signStatusBox {
            margin-top: 0.75rem;
            font-size: 0.9rem;
            color: #334155;
        }

        .sign-status-error {
            color: #dc2626;
            font-weight: 600;
        }

        .sign-status-loading {
            color: #007BA8;
            font-weight: 600;
        }
    </style>
</head>

<body>
<jsp:include page="header.jsp"/>

<nav class="breadcrumb-nav">
    <a href="${pageContext.request.contextPath}/">Trang chủ</a>
    <span class="dot">•</span>
    <a href="${pageContext.request.contextPath}/cart">Giỏ hàng</a>
</nav>

<div class="cart-header">
    <h3 class="page-title">Giỏ hàng</h3>
</div>

<div class="cart-container">
    <c:choose>
        <c:when test="${sessionScope.cart == null || sessionScope.cart.getTotalQuantity() == 0}">
            <div class="empty-cart">
                <img src="../img/cart-null.png" alt=""/>

                <p style="font-weight: 550">Giỏ hàng trống</p>
                <p>
                    Bạn tham khảo thêm các sản phẩm
                    <a href="<c:url value='/product-list' />">tại đây</a> nhé!
                </p>
            </div>
        </c:when>

        <c:otherwise>
            <div class="cart-items">
                <div class="cart-items-header">
                    <span class="cart-items-count">
                        ${sessionScope.cart.getTotalQuantity()} sản phẩm
                    </span>

                    <button onclick="location.href='cart?action=remove_all'"
                            class="clear-cart-btn">
                        🗑 Xoá tất cả
                    </button>
                </div>

                <c:forEach var="item" items="${sessionScope.cart.items}">
                    <div class="cart-item">
                        <div>
                            <img class="item-image"
                                 src="${item.product.productImage}"
                                 alt="${item.product.productName}"/>
                        </div>

                        <div class="item-details">
                            <h3 class="item-title">${item.product.productName}</h3>

                            <p class="item-variant">
                                Mã SP:
                                <c:choose>
                                    <c:when test="${item.product.productId < 10}">
                                        00${item.product.productId}
                                    </c:when>
                                    <c:when test="${item.product.productId < 100}">
                                        0${item.product.productId}
                                    </c:when>
                                    <c:otherwise>
                                        ${item.product.productId}
                                    </c:otherwise>
                                </c:choose>
                            </p>

                            <div class="item-price">
                                <span class="current-price">
                                    <fmt:setLocale value="vi_VN"/>
                                    <fmt:formatNumber value="${item.price}"
                                                      type="number"
                                                      groupingUsed="true"/>đ
                                </span>
                            </div>
                        </div>

                        <div class="item-actions">
                            <button type="button"
                                    class="delete-btn"
                                    title="Xóa sản phẩm"
                                    onclick="location.href='cart?action=remove&product_id=${item.product.productId}'">
                                <i class="fa-solid fa-trash"></i>
                            </button>

                            <div class="quantity-control">
                                <button type="button"
                                        class="quantity-btn"
                                        onclick="decreaseUI(${item.product.productId})">
                                    −
                                </button>

                                <input type="text"
                                       class="quantity-input"
                                       value="${item.quantity}"
                                       id="quantity-${item.product.productId}"
                                       readonly/>

                                <button type="button"
                                        class="quantity-btn"
                                        onclick="increaseUI(${item.product.productId})">
                                    +
                                </button>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <div class="order-summary">
                <h2 class="summary-title">Thông tin thanh toán</h2>

                <form id="checkoutForm"
                      method="post"
                      action="${pageContext.request.contextPath}/order"
                      class="checkout-form">

                    <div class="form-section voucher-section">
                        <div class="form-section-header">
                            <i class="fa-solid fa-ticket"></i>
                            <span>Mã giảm giá</span>
                        </div>

                        <c:choose>
                            <c:when test="${not empty sessionScope.voucherCode}">
                                <div class="voucher-applied">
                                    <div class="voucher-tag">
                                        <i class="fa-solid fa-check-circle"></i>
                                        <span class="voucher-code">${sessionScope.voucherCode}</span>

                                        <input type="hidden"
                                               name="voucherCode"
                                               value="${sessionScope.voucherCode}"/>
                                    </div>

                                    <button type="submit"
                                            name="orderAction"
                                            value="removeVoucher"
                                            class="remove-voucher-btn"
                                            formaction="${pageContext.request.contextPath}/order"
                                            formnovalidate>
                                        Hủy
                                    </button>
                                </div>

                                <c:if test="${empty requestScope.voucherError}">
                                    <div class="voucher-success-text">
                                        <i class="fa-solid fa-gift"></i>
                                        Bạn đã được giảm giá!
                                    </div>
                                </c:if>
                            </c:when>

                            <c:otherwise>
                                <div class="voucher-input-wrapper">
                                    <input type="text"
                                           name="voucherCode"
                                           class="voucher-input"
                                           placeholder="Nhập mã voucher"/>

                                    <button type="submit"
                                            name="orderAction"
                                            value="applyVoucher"
                                            class="voucher-apply-btn"
                                            formaction="${pageContext.request.contextPath}/order"
                                            formnovalidate>
                                        Áp dụng
                                    </button>
                                </div>
                            </c:otherwise>
                        </c:choose>

                        <c:if test="${not empty requestScope.voucherError}">
                            <div class="voucher-error">
                                <i class="fa-solid fa-exclamation-circle"></i>
                                    ${voucherError}
                            </div>
                        </c:if>
                    </div>

                    <div class="form-section">
                        <div class="form-section-header">
                            <i class="fa-solid fa-truck-fast"></i>
                            <span>Thông tin giao hàng</span>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="deliveryAddress">
                                <i class="fa-solid fa-location-dot"></i>
                                Địa chỉ giao hàng
                            </label>

                            <input type="text"
                                   id="deliveryAddress"
                                   name="deliveryAddress"
                                   class="form-input"
                                   placeholder="Nhập địa chỉ nhận hàng của bạn"
                                   value="${sessionScope.deliveryAddress}"
                                   required/>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="paymentMethod">
                                <i class="fa-solid fa-credit-card"></i>
                                Phương thức thanh toán
                            </label>

                            <div class="select-wrapper">
                                <c:set var="pm" value="${sessionScope.paymentMethod}"/>

                                <select id="paymentMethod"
                                        name="paymentMethod"
                                        class="form-select">
                                    <option value="COD" ${pm == 'COD' ? 'selected' : ''}>
                                        💵 Thanh toán khi nhận hàng (COD)
                                    </option>

                                    <option value="Card" ${pm == 'Card' ? 'selected' : ''}>
                                        💳 Thanh toán bằng thẻ
                                    </option>
                                </select>

                                <i class="fa-solid fa-chevron-down select-arrow"></i>
                            </div>
                        </div>
                    </div>

                    <div class="form-section">
                        <div class="form-section-header">
                            <i class="fa-solid fa-receipt"></i>
                            <span>Chi tiết thanh toán</span>
                        </div>

                        <div class="summary-row">
                            <span class="label">Giá trị đơn hàng</span>
                            <span class="value" id="subtotal">
                                <fmt:formatNumber value="${sessionScope.cart.getTotalPrice()}"
                                                  type="currency"
                                                  currencySymbol="đ"/>
                            </span>
                        </div>

                        <div class="summary-row discount-row">
                            <span class="label">Tiết kiệm với mã giảm</span>
                            <span class="value discount-value" id="discount">
                                <fmt:formatNumber value="${sessionScope.discountAmount}"
                                                  type="currency"
                                                  currencySymbol="đ"/>
                            </span>
                        </div>

                        <div class="summary-row total">
                            <span class="label">Tổng thanh toán</span>
                            <span class="value" id="total">
                                <fmt:formatNumber value="${sessionScope.finalPrice}"
                                                  type="currency"
                                                  currencySymbol="đ"/>
                            </span>
                        </div>
                    </div>

                    <button type="submit" class="submit-btn">
                        <i class="fa-solid fa-lock"></i>
                        Xác nhận thanh toán
                    </button>

                    <p class="secure-notice">
                        <i class="fa-solid fa-shield-halved"></i>
                        Giao dịch được bảo mật an toàn
                    </p>
                </form>
            </div>
        </c:otherwise>
    </c:choose>

    <c:if test="${param.paid == '1'}">
        <script>
            Swal.fire({
                icon: "success",
                title: "Thanh toán thành công!",
                text: "Mã đơn hàng: <fmt:formatNumber value="${param.orderId}" pattern="000"/>"
            });
        </script>
    </c:if>

    <c:if test="${param.paid == '0'}">
        <script>
            Swal.fire({
                icon: "error",
                title: "Oops! Sản phẩm không đủ số lượng",
                text: "Số lượng sản phẩm vượt quá tồn kho",
                confirmButtonText: "Đã hiểu"
            });
        </script>

        <% session.removeAttribute("stockError"); %>
    </c:if>

    <c:if test="${not empty requestScope.error}">
        <script>
            if (window.Swal) {
                Swal.fire({
                    icon: "error",
                    title: "Lỗi tạo đơn hàng",
                    text: "${requestScope.error}",
                    confirmButtonText: "Đã hiểu"
                });
            } else {
                alert("${requestScope.error}");
            }
        </script>
    </c:if>
</div>

<script>
    const CONTEXT_PATH = "${pageContext.request.contextPath}";
    const checkoutForm = document.getElementById("checkoutForm");

    if (checkoutForm) {
        checkoutForm.addEventListener("submit", async function (event) {
            const submitter = event.submitter;

            if (submitter && submitter.name === "orderAction") {
                return;
            }

            event.preventDefault();
            if (typeof waitForCartUpdates === "function") {
                await waitForCartUpdates();
            }

            const params = new URLSearchParams();

            const deliveryAddressInput = document.getElementById("deliveryAddress");
            const paymentMethodInput = document.getElementById("paymentMethod");
            const voucherInput = checkoutForm.querySelector("input[name='voucherCode']");

            const deliveryAddress = deliveryAddressInput ? deliveryAddressInput.value.trim() : "";
            const paymentMethod = paymentMethodInput ? paymentMethodInput.value : "COD";
            const voucherCode = voucherInput ? voucherInput.value.trim() : "";

            if (!deliveryAddress) {
                Swal.fire({
                    icon: "warning",
                    title: "Thiếu địa chỉ giao hàng",
                    text: "Vui lòng nhập địa chỉ giao hàng.",
                    confirmButtonText: "Đã hiểu"
                });
                return;
            }

            params.set("deliveryAddress", deliveryAddress);
            params.set("paymentMethod", paymentMethod);

            if (voucherCode) {
                params.set("voucherCode", voucherCode);
            }

            console.log("Params gửi lên:", params.toString());

            const confirmResult = await Swal.fire({
                icon: "question",
                title: "Xác nhận thanh toán?",
                text: "Sau khi xác nhận, số lượng sản phẩm trong đơn hàng sẽ được khóa để ký điện tử.",
                showCancelButton: true,
                confirmButtonText: "Xác nhận",
                cancelButtonText: "Kiểm tra lại"
            });

            if (!confirmResult.isConfirmed) {
                return;
            }

            Swal.fire({
                title: "Đang tạo đơn hàng...",
                text: "Vui lòng không đóng trang.",
                allowOutsideClick: false,
                allowEscapeKey: false,
                showConfirmButton: false,
                showCloseButton: false,
                didOpen: function () {
                    Swal.showLoading();
                }
            });

            try {
                const checkoutUrl = checkoutForm.getAttribute("action") || CONTEXT_PATH + "/order";
                if (typeof syncAllCartQuantitiesFromUI === "function") {
                    await syncAllCartQuantitiesFromUI();
                }
                const response = await fetch(checkoutUrl, {
                    method: "POST",
                    body: params,
                    headers: {
                        "X-Requested-With": "XMLHttpRequest",
                        "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8"
                    }
                });

                const data = await readJsonResponse(response);

                if (!data.success) {
                    Swal.fire({
                        icon: "error",
                        title: "Không thể tạo đơn hàng",
                        text: data.message || "Vui lòng thử lại.",
                        confirmButtonText: "Đã hiểu"
                    });
                    return;
                }

                showSigningPopup(data);
            } catch (error) {
                Swal.fire({
                    icon: "error",
                    title: "Lỗi kết nối",
                    text: error.message || "Không thể gửi yêu cầu thanh toán.",
                    confirmButtonText: "Đã hiểu"
                });
            }
        });
    }

    function showSigningPopup(orderData) {
        const orderId = Number(orderData.orderId);
        const signingUrl = orderData.signingUrl || "#";
        const signToolUrl = orderData.signToolUrl || (CONTEXT_PATH + "/signing-tool/download");
        const privateKeyUrl = normalizeAppUrl(orderData.privateKeyUrl || "");
        const mustDownloadPrivateKey = !!privateKeyUrl;
        const retryMessage = orderData.retryMessage || "";
        const hasActiveCert = orderData.hasActiveCert === true || orderData.hasActiveCert === "true";
        const downloadDataTitle = retryMessage
            ? "1. Tải lại dữ liệu đơn hàng"
            : "1. Tải dữ liệu đơn hàng";

        let privateKeyHtml = "";

        if (!orderData.hasActiveCert) {
            privateKeyHtml =
                '<div class="sign-step-card warning">' +
                '   <strong>3. Chưa có chứng thư ký điện tử</strong>' +
                '   <span>Hệ thống chưa tạo được chứng thư cho tài khoản này. Vui lòng thử lại hoặc vào trang quản lý khóa bảo mật.</span>' +
                '   <a href="' + CONTEXT_PATH + '/security-key" target="_blank">Mở trang chữ ký điện tử và chứng thư số </a>' +
                '</div>';
        } else if (privateKeyUrl) {
            privateKeyHtml =
                '<a id="btnDownloadPrivateKey" ' +
                '   class="sign-step-card warning" ' +
                '   href="' + escapeAttr(privateKeyUrl) + '">' +
                '   <strong>3. Tải private key mới</strong>' +
                '   <span>Đây là lần đầu bạn ký đơn hàng. Hệ thống đã tạo chứng thư và private key cho bạn. ' +
                'Private key chỉ tải được một lần, hãy lưu lại an toàn trước khi ký.</span>' +
                '</a>';
        } else {
            privateKeyHtml =
                '<div class="sign-step-card success">' +
                '   <strong>3. Bạn đã tải private key</strong>' +
                '   <span>Nếu bạn vẫn còn private key, hãy dùng file đó để ký đơn hàng.</span>' +
                '   <button type="button" id="btnReissuePrivateKey" class="sign-lost-key-link">' +
                '       Tôi mất private key - tạo lại chứng thư và key mới' +
                '   </button>' +
                '</div>';
        }
        const html =
            '<div class="sign-popup-content">' +
            '   <p class="sign-popup-desc">' +
            '       Đơn hàng đã được tạo ở trạng thái <strong>CHỜ KÝ</strong>. ' +
            '       Vui lòng tải dữ liệu đơn hàng, ký bằng private key, rồi upload file chữ ký để xác minh.' +
            '   </p>' +
            '   <div class="sign-popup-steps">' +
            (hasActiveCert
                    ? '       <button type="button" id="btnDownloadOrderData" class="sign-step-card primary" ' +
                    'style="width:100%; text-align:left; cursor:pointer;">' +
                    '           <strong>' + escapeHtml(downloadDataTitle) + '</strong>' +
                    '           <span>Tải file dữ liệu đơn hàng để ký bằng tool.</span>' +
                    '       </button>'
                    : '       <div class="sign-step-card warning">' +
                    '           <strong>1. Chưa thể tải dữ liệu đơn hàng</strong>' +
                    '           <span>Tài khoản chưa có chứng thư ký điện tử. Vui lòng tạo chứng thư trước khi ký đơn hàng.</span>' +
                    '       </div>'
            ) +

            '       <a class="sign-step-card" href="' + escapeAttr(signToolUrl) + '">' +
            '           <strong>2. Tải tool ký</strong>' +
            '           <span>Dùng tool để ký đơn hàng bằng private key.</span>' +
            '       </a>' +

            privateKeyHtml +

            '       <div class="sign-upload-box">' +
            '           <label for="signedOrderFile">4. Upload file chữ ký</label>' +
            '           <input id="signedOrderFile" type="file" accept=".json,application/json">' +
            '           <button type="button" id="btnUploadSignature" class="swal2-confirm swal2-styled" ' +
            (mustDownloadPrivateKey ? 'disabled style="opacity:0.6; cursor:not-allowed;"' : '') +
            '           >' +
            '               Upload chữ ký' +
            '           </button>' +
            '           <div id="signStatusBox">' +
            (mustDownloadPrivateKey
                ? '<p class="sign-status-error">Bạn cần tải private key trước, sau đó dùng tool để ký đơn hàng.</p>'
                : retryMessage
                    ? '<p class="sign-status-error">' + escapeHtml(retryMessage) + '</p>'
                    : '') +
            '           </div>' +
            '       </div>' +
            '   </div>' +
            '</div>';

        Swal.fire({
            icon: "info",
            title: "Đơn hàng #" + orderId + " đang chờ ký",
            width: 760,
            allowOutsideClick: false,
            allowEscapeKey: false,
            showCloseButton: false,
            showConfirmButton: false,
            html: html,
            didOpen: function () {
                const btnUploadSignature = document.getElementById("btnUploadSignature");
                const btnReissuePrivateKey = document.getElementById("btnReissuePrivateKey");

                const btnDownloadHash = document.getElementById("btnDownloadHash");
                const btnDownloadOrderData = document.getElementById("btnDownloadOrderData");

                if (btnDownloadHash) {
                    btnDownloadHash.addEventListener("click", function () {
                        const oid = this.getAttribute("data-order-id");
                        const hash = this.getAttribute("data-order-hash") || "";
                        downloadOrderHash(oid, hash);
                    });
                }
                if (btnDownloadOrderData) {
                    btnDownloadOrderData.addEventListener("click", function () {
                        downloadSigningPayload(signingUrl, orderId);
                    });
                }

                if (btnUploadSignature) {
                    btnUploadSignature.addEventListener("click", function () {
                        uploadSignature(orderId);
                    });
                }

                if (btnReissuePrivateKey) {
                    btnReissuePrivateKey.addEventListener("click", function () {
                        reissuePrivateKey(orderData);
                    });
                }
                const btnDownloadPrivateKey = document.getElementById("btnDownloadPrivateKey");
                let hasNavigatedToSecurityKey = false;
                if (btnDownloadPrivateKey) {
                    btnDownloadPrivateKey.addEventListener("click", function () {
                        hasNavigatedToSecurityKey = true;
                    });
                }

                document.addEventListener("visibilitychange", function () {
                    if (document.visibilityState === 'visible' && hasNavigatedToSecurityKey) {
                        window.location.reload();
                    }
                });
            }
        });
    }

    async function uploadSignature(orderId) {
        const fileInput = document.getElementById("signedOrderFile");
        const statusBox = document.getElementById("signStatusBox");

        if (!fileInput || !fileInput.files || fileInput.files.length === 0) {
            if (statusBox) {
                statusBox.innerHTML =
                    '<p class="sign-status-error">Vui lòng chọn file signed_order.json.</p>';
            }
            return;
        }

        const file = fileInput.files[0];

        if (!file.name.toLowerCase().endsWith(".json")) {
            if (statusBox) {
                statusBox.innerHTML =
                    '<p class="sign-status-error">Hệ thống chỉ nhận file .json.</p>';
            }
            return;
        }

        const formData = new FormData();
        formData.append("orderId", orderId);
        formData.append("signedOrderFile", file);

        if (statusBox) {
            statusBox.innerHTML =
                '<p class="sign-status-loading">' +
                '<i class="fa-solid fa-circle-notch fa-spin"></i> Đang xác minh chữ ký...' +
                '</p>';
        }

        try {
            const response = await fetch(CONTEXT_PATH + "/upload-signature", {
                method: "POST",
                body: formData,
                headers: {
                    "X-Requested-With": "XMLHttpRequest"
                }
            });

            const data = await readJsonResponse(response);

            if (!data.success) {
                Swal.fire({
                    icon: "error",
                    title: "Xác minh thất bại",
                    text: data.message || "Chữ ký không hợp lệ hoặc dữ liệu đơn hàng đã bị thay đổi.",
                    allowOutsideClick: false,
                    allowEscapeKey: false,
                    showCloseButton: false,
                    confirmButtonText: "Thử lại"
                }).then(function () {
                    showSigningPopup({
                        orderId: orderId,
                        orderHash: data.orderHash || "",
                        signingUrl: data.signingUrl || (CONTEXT_PATH + "/order-sign/order-json?orderId=" + encodeURIComponent(orderId)),
                        signToolUrl: data.signToolUrl || (CONTEXT_PATH + "/signing-tool/download"),

                        // Không tự ép link tải private key nếu server không trả về
                        privateKeyUrl: normalizeAppUrl(data.privateKeyUrl || ""),
                        retryMessage: "Vui lòng chọn lại file chữ ký .json rồi upload lại."
                    });
                });
                return;
            }

            Swal.fire({
                icon: "success",
                title: "Chữ ký hợp lệ",
                text: "Đơn hàng đã được xác minh. Đang chờ admin xử lý...",
                allowOutsideClick: false,
                allowEscapeKey: false,
                showCloseButton: false,
                showConfirmButton: false,
                didOpen: function () {
                    Swal.showLoading();
                }
            });

            pollOrderStatus(orderId);
        } catch (error) {
            Swal.fire({
                icon: "error",
                title: "Lỗi upload chữ ký",
                text: error.message || "Không thể upload hoặc xác minh chữ ký.",
                confirmButtonText: "Đã hiểu"
            });
        }
    }

    function pollOrderStatus(orderId) {
        const timer = setInterval(async function () {
            try {
                const response = await fetch(CONTEXT_PATH + "/order/status?orderId=" + encodeURIComponent(orderId), {
                    headers: {
                        "X-Requested-With": "XMLHttpRequest"
                    }
                });

                const data = await readJsonResponse(response);

                if (!data.success) {
                    return;
                }

                const status = data.status;

                if (status === "DONE") {
                    clearInterval(timer);

                    Swal.fire({
                        icon: "success",
                        title: "Đơn hàng đã hoàn tất",
                        text: "Admin đã xác nhận hoàn tất đơn hàng.",
                        confirmButtonText: "Xem đơn hàng",
                        allowOutsideClick: false,
                        allowEscapeKey: false,
                        showCloseButton: false
                    }).then(function () {
                        window.location.href = CONTEXT_PATH + "/bought-product";
                    });
                }

                if (status === "SIGNATURE_INVALID") {
                    clearInterval(timer);

                    Swal.fire({
                        icon: "error",
                        title: "Chữ ký không hợp lệ",
                        text: "Chữ ký chưa hợp lệ. Vui lòng tải lại dữ liệu đơn hàng, ký lại rồi upload file chữ ký mới.",
                        confirmButtonText: "Ký lại",
                        allowOutsideClick: false,
                        allowEscapeKey: false,
                        showCloseButton: false
                    }).then(function () {
                        showSigningPopup({
                            orderId: orderId,
                            orderHash: data.orderHash || "",
                            signingUrl: data.signingUrl || (CONTEXT_PATH + "/order-sign/order-json?orderId=" + encodeURIComponent(orderId)),
                            signToolUrl: data.signToolUrl || (CONTEXT_PATH + "/signing-tool/download"),
                            privateKeyUrl: normalizeAppUrl(data.privateKeyUrl || ""),
                            hasActiveCert: true,
                            retryMessage: "Vui lòng tải lại dữ liệu đơn hàng, ký lại rồi upload file chữ ký mới."
                        });
                    });

                    return;
                }

                if (status === "TAMPERED") {
                    clearInterval(timer);

                    Swal.fire({
                        icon: "error",
                        title: "Dữ liệu đơn hàng không hợp lệ",
                        text: "Dữ liệu đơn hàng có dấu hiệu bị thay đổi. Đơn hàng không thể tiếp tục xử lý.",
                        confirmButtonText: "Xem đơn hàng",
                        allowOutsideClick: false,
                        allowEscapeKey: false,
                        showCloseButton: false
                    }).then(function () {
                        window.location.href = CONTEXT_PATH + "/bought-product";
                    });

                    return;
                }


                if (status === "CANCELLED") {
                    clearInterval(timer);

                    Swal.fire({
                        icon: "warning",
                        title: "Đơn hàng đã bị hủy",
                        text: "Đơn hàng không thể tiếp tục xử lý.",
                        confirmButtonText: "Xem đơn hàng",
                        allowOutsideClick: false,
                        allowEscapeKey: false,
                        showCloseButton: false
                    }).then(function () {
                        window.location.href = CONTEXT_PATH + "/bought-product";
                    });
                }
                if (status === "VERIFIED") {
                    clearInterval(timer);

                    Swal.fire({
                        icon: "success",
                        title: "Ký điện tử thành công",
                        text: "Chữ ký đã được xác minh. Đơn hàng đang chờ admin xử lý.",
                        confirmButtonText: "Xem đơn hàng",
                        allowOutsideClick: false,
                        allowEscapeKey: false,
                        showCloseButton: false
                    }).then(function () {
                        window.location.href = CONTEXT_PATH + "/bought-product";
                    });
                }
            } catch (error) {
                console.error("Lỗi khi lấy trạng thái đơn hàng:", error);
            }
        }, 3000);
    }

    async function readJsonResponse(response) {
        const contentType = response.headers.get("content-type") || "";

        if (!contentType.includes("application/json")) {
            throw new Error("Server không đọc được file JSON. Hãy kiểm tra lại.");
        }

        const data = await response.json();

        if (!response.ok) {
            throw new Error(data.message || "Request thất bại.");
        }

        return data;
    }

    function normalizeAppUrl(value) {
        if (!value) {
            return "";
        }

        if (value.startsWith("http://") || value.startsWith("https://")) {
            return value;
        }

        if (CONTEXT_PATH && value.startsWith(CONTEXT_PATH + "/")) {
            return value;
        }

        if (value.startsWith("/")) {
            return CONTEXT_PATH + value;
        }

        return value;
    }

    function escapeHtml(value) {
        return String(value)
            .replaceAll("&", "&amp;")
            .replaceAll("<", "&lt;")
            .replaceAll(">", "&gt;")
            .replaceAll('"', "&quot;")
            .replaceAll("'", "&#039;");
    }

    function escapeAttr(value) {
        return escapeHtml(value);
    }

    function downloadOrderHash(orderId, orderHash) {
        try {
            const filename = 'order_hash_' + String(orderId) + '.txt';
            const blob = new Blob([orderHash || ''], {type: 'text/plain;charset=utf-8'});

            if (window.navigator && window.navigator.msSaveOrOpenBlob) {
                window.navigator.msSaveOrOpenBlob(blob, filename);
                return;
            }

            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = filename;
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
        } catch (e) {
            console.error('Không thể tải hash:', e);
            Swal.fire({icon: 'error', title: 'Lỗi', text: 'Không thể tạo file hash.'});
        }
    }

    <c:if test="${not empty sessionScope.signOrderId}">
    window.addEventListener("load", function () {
        showSigningPopup({
            orderId: Number("${sessionScope.signOrderId}"),
            orderHash: "${sessionScope.signOrderHash}",
            signingUrl: "${pageContext.request.contextPath}${sessionScope.signingUrl}",
            signToolUrl: "${pageContext.request.contextPath}/signing-tool/download",
            privateKeyUrl: "${not empty sessionScope.privateKeyUrl ? pageContext.request.contextPath : ''}${not empty sessionScope.privateKeyUrl ? sessionScope.privateKeyUrl : ''}",
            hasActiveCert: ${sessionScope.hasActiveCert != null ? sessionScope.hasActiveCert : false},
            retryMessage: "Vui lòng tải lên lại file chữ ký có định dạng .json"
        });
    });
    </c:if>

    async function reissuePrivateKey(orderData) {
        const statusBox = document.getElementById("signStatusBox");

        const confirmResult = await Swal.fire({
            icon: "warning",
            title: "Tạo private key mới?",
            html:
                "Private key cũ sẽ được xem như đã mất.<br>" +
                "Chứng thư hiện tại sẽ bị thu hồi và hệ thống sẽ cấp cặp khóa mới.<br><br>" +
                "<strong>Bạn phải tải private key mới và lưu lại an toàn.</strong>",
            showCancelButton: true,
            confirmButtonText: "Tạo key mới",
            cancelButtonText: "Hủy",
            confirmButtonColor: "#f59e0b",
            allowOutsideClick: false,
            allowEscapeKey: false,
            showCloseButton: false
        });

        if (!confirmResult.isConfirmed) {
            showSigningPopup(orderData);
            return;
        }

        Swal.fire({
            title: "Đang tạo private key mới...",
            text: "Vui lòng không đóng trang.",
            allowOutsideClick: false,
            allowEscapeKey: false,
            showConfirmButton: false,
            showCloseButton: false,
            didOpen: function () {
                Swal.showLoading();
            }
        });

        try {
            const params = new URLSearchParams();
            params.set("orderId", orderData.orderId);

            const response = await fetch(CONTEXT_PATH + "/security-key/reissue", {
                method: "POST",
                body: params,
                headers: {
                    "X-Requested-With": "XMLHttpRequest",
                    "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8"
                }
            });

            const data = await readJsonResponse(response);

            if (!data.success) {
                Swal.fire({
                    icon: "error",
                    title: "Không thể tạo key mới",
                    text: data.message || "Vui lòng thử lại.",
                    confirmButtonText: "Đã hiểu",
                    allowOutsideClick: false,
                    allowEscapeKey: false,
                    showCloseButton: false
                }).then(function () {
                    showSigningPopup(orderData);
                });
                return;
            }

            showSigningPopup({
                orderId: orderData.orderId,
                orderHash: data.orderHash || orderData.orderHash || "",
                signingUrl: data.signingUrl || orderData.signingUrl || "#",
                signToolUrl: data.signToolUrl || orderData.signToolUrl || (CONTEXT_PATH + "/signing-tool/download"),
                privateKeyUrl: normalizeAppUrl(data.privateKeyUrl || "/security-key/download-private-key"),
                hasActiveCert: true
            });
        } catch (error) {
            Swal.fire({
                icon: "error",
                title: "Lỗi tạo private key mới",
                text: error.message || "Không thể tạo private key mới.",
                confirmButtonText: "Đã hiểu",
                allowOutsideClick: false,
                allowEscapeKey: false,
                showCloseButton: false
            }).then(function () {
                showSigningPopup(orderData);
            });
        }
    }

    async function downloadSigningPayload(signingUrl, orderId) {
        try {
            const response = await fetch(signingUrl, {
                method: "GET",
                headers: {
                    "X-Requested-With": "XMLHttpRequest"
                }
            });

            if (!response.ok) {
                let message = "Không thể tải dữ liệu đơn hàng.";

                const contentType = response.headers.get("content-type") || "";

                if (contentType.includes("application/json")) {
                    const data = await response.json();
                    message = data.message || message;
                } else {
                    const text = await response.text();
                    if (text) {
                        message = text;
                    }
                }

                Swal.fire({
                    icon: "error",
                    title: "Không thể tải dữ liệu ký",
                    text: message,
                    confirmButtonText: "Đã hiểu",
                    allowOutsideClick: false,
                    allowEscapeKey: false,
                    showCloseButton: false
                });

                return;
            }

            const blob = await response.blob();
            const url = URL.createObjectURL(blob);

            const a = document.createElement("a");
            a.href = url;
            a.download = "order_to_sign_" + orderId + ".json";
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);

            URL.revokeObjectURL(url);
        } catch (error) {
            Swal.fire({
                icon: "error",
                title: "Lỗi tải dữ liệu ký",
                text: error.message || "Không thể tải dữ liệu đơn hàng.",
                confirmButtonText: "Đã hiểu"
            });
        }
    }
</script>

<script src="${pageContext.request.contextPath}/js/header.js"></script>
<script src="${pageContext.request.contextPath}/js/cart.js"></script>
</body>

</html>