function moneyToNumber(text) {
    return parseInt(String(text).replace(/[^\d]/g, "")) || 0;
}

function updateCartTotalsUI() {
    let subtotal = 0;

    document.querySelectorAll(".cart-item").forEach(itemEl => {
        const priceText = itemEl.querySelector(".current-price")?.textContent ?? "0";
        const qtyInput = itemEl.querySelector(".quantity-input");
        const price = moneyToNumber(priceText);
        const qty = parseInt(qtyInput?.value || "1", 10);

        subtotal += price * qty;
    });

    const discountEl = document.getElementById("discount");
    const discount = discountEl ? moneyToNumber(discountEl.textContent) : 0;

    const subtotalEl = document.getElementById("subtotal");
    const totalEl = document.getElementById("total");

    if (subtotalEl) subtotalEl.textContent = subtotal.toLocaleString("vi-VN") + "đ";
    const total = Math.max(0, subtotal - discount);
    if (totalEl) totalEl.textContent = total.toLocaleString("vi-VN") + "đ";
}

async function increaseUI(productId) {
    const input = document.getElementById(`quantity-${productId}`);
    if (!input) return;

    const oldQuantity = parseInt(input.value || "1", 10);
    const newQuantity = oldQuantity + 1;

    input.value = newQuantity;
    updateCartTotalsUI();

    try {
        await updateCartQuantity(productId, newQuantity);
    } catch (error) {
        input.value = oldQuantity;
        updateCartTotalsUI();

        Swal.fire({
            icon: "error",
            title: "Không thể cập nhật giỏ hàng",
            text: error.message || "Vui lòng thử lại."
        });
    }
}

async function decreaseUI(productId) {
    const input = document.getElementById(`quantity-${productId}`);
    if (!input) return;

    const oldQuantity = parseInt(input.value || "1", 10);
    if (oldQuantity <= 1) return;

    const newQuantity = oldQuantity - 1;

    input.value = newQuantity;
    updateCartTotalsUI();

    try {
        await updateCartQuantity(productId, newQuantity);
    } catch (error) {
        input.value = oldQuantity;
        updateCartTotalsUI();

        Swal.fire({
            icon: "error",
            title: "Không thể cập nhật giỏ hàng",
            text: error.message || "Vui lòng thử lại."
        });
    }
}

document.addEventListener("DOMContentLoaded", updateCartTotalsUI);
const promoInput = document.querySelector(".promo-input");

//input sẽ rung nhẹ khi nhập mã sai

function applyPromo() {
    const code = document.getElementById("promoCode").value.trim().toUpperCase();
    let discount = document.getElementById("discount");
    if (code === "CODE001") {
        Swal.fire({
            icon: "success",
            title: "Áp dụng giảm giá",
            text: "Mã giảm giá đã được áp dụng",
            timer: 1500,
            showConfirmButton: false,
        });
        discount.textContent = "1.500.000đ";
        updateCartTotalsUI();
    } else if (code === "") {
        Swal.fire({
            icon: "error",
            title: "Chưa nhập mã",
            text: "Vui lòng nhập mã giảm giá",
            timer: 1500,
            showConfirmButton: false,
        });
    } else {
        promoInput.classList.add("shake");
        setTimeout(() => promoInput.classList.remove("shake"), 500);
        Swal.fire({
            icon: "error",
            title: "Áp dụng giảm giá",
            text: "Mã giảm giá không tồn tại",
            timer: 1500,
            showConfirmButton: false,
        });
    }
}

// Add event listeners
document.addEventListener("DOMContentLoaded", () => {
    const promoBtn = document.querySelector(".promo-btn");
    if (promoBtn) {
        promoBtn.addEventListener("click", applyPromo);
    }

    if (promoInput) {
        promoInput.addEventListener("keydown", (e) => {
            if (e.key === "Enter" || e.key === " ") {
                applyPromo();
            }
        });
    }
});

async function submitPayment(e) {
    if (e) e.preventDefault();
    await Swal.fire({
        icon: "success",
        title: "Thanh toán thành công",
        text: "Cảm ơn bạn đã mua hàng!",
        timer: 2000,
        showConfirmButton: false,
    });
}

function getContextPath() {
    return typeof CONTEXT_PATH !== "undefined" ? CONTEXT_PATH : "";
}

function signEscapeHtml(value) {
    return String(value ?? "")
        .replaceAll("&", "&amp;")
        .replaceAll("<", "&lt;")
        .replaceAll(">", "&gt;")
        .replaceAll('"', "&quot;")
        .replaceAll("'", "&#039;");
}

function signNormalizeAppUrl(value) {
    const contextPath = getContextPath();
    if (!value) return "";
    if (value.startsWith("http://") || value.startsWith("https://")) return value;
    if (contextPath && value.startsWith(contextPath + "/")) return value;
    if (value.startsWith("/")) return contextPath + value;
    return value;
}

function renderPrivateKeyStep(orderData) {
    const contextPath = getContextPath();
    const privateKeyUrl = signNormalizeAppUrl(orderData.privateKeyUrl || "");

    if (!orderData.hasActiveCert) {
        return '' +
            '<a id="btnDownloadPrivateKey" class="sign-step-card warning" href="' + contextPath + '/security-key" target="_blank">' +
            '   <strong>3. Người dùng chưa có private key, tải private key</strong>' +
            '   <span>Chuyển hướng sang trang quản lý để tạo chứng chỉ và tải private key.</span>' +
            '</a>';
    }

    if (privateKeyUrl) {
        return '' +
            '<a id="btnDownloadPrivateKey" class="sign-step-card warning" href="' + contextPath + '/security-key" target="_blank">' +
            '   <strong>3. Bạn chưa tải private key, tải ngay</strong>' +
            '   <span>Sau khi tải xong, quay lại tab giỏ hàng. Popup sẽ tự cập nhật trạng thái.</span>' +
            '</a>';
    }

    return '' +
        '<div class="sign-step-card success">' +
        '   <strong>3. Bạn đã tải private key</strong>' +
        '   <span>Nếu bạn vẫn còn private key, hãy dùng file đó để ký đơn hàng.</span>' +
        '   <button type="button" id="btnReissuePrivateKey" class="sign-lost-key-link">' +
        '       Tôi mất private key - tạo lại chứng thư và key mới' +
        '   </button>' +
        '</div>';
}

function buildSigningPopupHtml(orderData) {
    const contextPath = getContextPath();
    const retryMessage = orderData.retryMessage || "";
    const downloadDataTitle = retryMessage
        ? "1. Tải lại dữ liệu đơn hàng"
        : "1. Tải dữ liệu đơn hàng";
    const signingUrl = orderData.signingUrl || "#";
    const signToolUrl = orderData.signToolUrl || (contextPath + "/signing-tool/download");

    return '' +
        '<div class="sign-popup-content">' +
        '   <p class="sign-popup-desc">' +
        '       Đơn hàng đã được tạo ở trạng thái <strong>CHỜ KÝ</strong>. ' +
        '       Vui lòng tải dữ liệu đơn hàng, ký bằng private key, rồi upload file chữ ký để xác minh.' +
        '   </p>' +
        '   <div class="sign-popup-steps">' +
        '       <a class="sign-step-card primary" href="' + signEscapeHtml(signingUrl) + '">' +
        '           <strong>' + signEscapeHtml(downloadDataTitle) + '</strong>' +
        '           <span>Tải file dữ liệu đơn hàng để ký bằng tool.</span>' +
        '       </a>' +
        '       <a class="sign-step-card" href="' + signEscapeHtml(signToolUrl) + '">' +
        '           <strong>2. Tải tool ký</strong>' +
        '           <span>Dùng tool để ký đơn hàng bằng private key.</span>' +
        '       </a>' +
        renderPrivateKeyStep(orderData) +
        '       <div class="sign-upload-box">' +
        '           <label for="signedOrderFile">4. Upload file chữ ký</label>' +
        '           <input id="signedOrderFile" type="file" accept=".json,application/json">' +
        '           <button type="button" id="btnUploadSignature" class="swal2-confirm swal2-styled">' +
        '               Upload chữ ký' +
        '           </button>' +
        '           <div id="signStatusBox">' +
        (retryMessage ? '<p class="sign-status-error">' + signEscapeHtml(retryMessage) + '</p>' : '') +
        '           </div>' +
        '       </div>' +
        '   </div>' +
        '</div>';
}

function showSigningPopup(orderData) {
    const contextPath = getContextPath();
    const normalizedOrderData = {
        ...orderData,
        orderId: Number(orderData.orderId),
        signingUrl: orderData.signingUrl || (contextPath + "/order-sign/order-json?orderId=" + encodeURIComponent(orderData.orderId)),
        signToolUrl: orderData.signToolUrl || (contextPath + "/signing-tool/download"),
        privateKeyUrl: signNormalizeAppUrl(orderData.privateKeyUrl || ""),
        hasActiveCert: Boolean(orderData.hasActiveCert)
    };

    let visibilityHandler = null;

    Swal.fire({
        icon: "info",
        title: "Đơn hàng #" + normalizedOrderData.orderId + " đang chờ ký",
        width: 760,
        allowOutsideClick: false,
        allowEscapeKey: false,
        showCloseButton: false,
        showConfirmButton: false,
        html: buildSigningPopupHtml(normalizedOrderData),
        didOpen: function () {
            const btnUploadSignature = document.getElementById("btnUploadSignature");
            const btnReissuePrivateKey = document.getElementById("btnReissuePrivateKey");

            if (btnUploadSignature) {
                btnUploadSignature.addEventListener("click", function () {
                    uploadSignature(normalizedOrderData.orderId);
                });
            }

            if (btnReissuePrivateKey && typeof reissuePrivateKey === "function") {
                btnReissuePrivateKey.addEventListener("click", function () {
                    reissuePrivateKey(normalizedOrderData);
                });
            }

            refreshPrivateKeyStatus(normalizedOrderData, false);

            visibilityHandler = function () {
                if (document.visibilityState === "visible" && document.getElementById("signStatusBox")) {
                    refreshPrivateKeyStatus(normalizedOrderData, true);
                }
            };

            document.addEventListener("visibilitychange", visibilityHandler);
            window.addEventListener("focus", visibilityHandler);
        },
        willClose: function () {
            if (visibilityHandler) {
                document.removeEventListener("visibilitychange", visibilityHandler);
                window.removeEventListener("focus", visibilityHandler);
            }
        }
    });
}

async function refreshPrivateKeyStatus(orderData, showSuccessMessage) {
    const contextPath = getContextPath();
    const statusBox = document.getElementById("signStatusBox");

    try {
        const response = await fetch(contextPath + "/security-key/status", {
            headers: {
                "X-Requested-With": "XMLHttpRequest"
            }
        });
        const data = await readJsonResponse(response);

        if (!data.success) return;

        const updatedOrderData = {
            ...orderData,
            hasActiveCert: Boolean(data.hasActiveCert),
            privateKeyUrl: data.hasPendingPrivateKey ? signNormalizeAppUrl(data.privateKeyUrl || "/security-key/download-private-key") : ""
        };

        const currentPrivateKeyStep = document.getElementById("btnDownloadPrivateKey")
            || document.querySelector(".sign-step-card.success");

        if (currentPrivateKeyStep) {
            const wrapper = document.createElement("div");
            wrapper.innerHTML = renderPrivateKeyStep(updatedOrderData).trim();
            currentPrivateKeyStep.replaceWith(wrapper.firstElementChild);
        }

        const btnReissuePrivateKey = document.getElementById("btnReissuePrivateKey");
        if (btnReissuePrivateKey && typeof reissuePrivateKey === "function") {
            btnReissuePrivateKey.addEventListener("click", function () {
                reissuePrivateKey(updatedOrderData);
            });
        }

        if (showSuccessMessage && data.privateKeyDownloaded && statusBox) {
            statusBox.innerHTML = '<p class="sign-status-loading">Private key đã được tải. Bạn có thể ký đơn hàng rồi upload file chữ ký.</p>';
        }
    } catch (error) {
        console.error("Không thể kiểm tra trạng thái private key:", error);
    }
}

async function uploadSignature(orderId) {
    const contextPath = getContextPath();
    const fileInput = document.getElementById("signedOrderFile");
    const statusBox = document.getElementById("signStatusBox");

    if (!fileInput || !fileInput.files || fileInput.files.length === 0) {
        if (statusBox) {
            statusBox.innerHTML = '<p class="sign-status-error">Vui lòng chọn file signed_order.json.</p>';
        }
        return;
    }

    const file = fileInput.files[0];

    if (!file.name.toLowerCase().endsWith(".json")) {
        if (statusBox) {
            statusBox.innerHTML = '<p class="sign-status-error">Hệ thống chỉ nhận file .json.</p>';
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
        const response = await fetch(contextPath + "/upload-signature", {
            method: "POST",
            body: formData,
            headers: {
                "X-Requested-With": "XMLHttpRequest"
            }
        });

        const data = await readJsonResponse(response);

        if (!data.success) {
            handleUploadSignatureFailure(orderId, data);
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

function handleUploadSignatureFailure(orderId, data) {
    const contextPath = getContextPath();
    const status = data.status || "INVALID_REQUEST";

    if (status === "SIGNATURE_INVALID") {
        Swal.fire({
            icon: "error",
            title: "Chữ ký không hợp lệ",
            text: data.message || "Vui lòng tải lại dữ liệu đơn hàng, ký lại rồi upload file chữ ký mới.",
            allowOutsideClick: false,
            allowEscapeKey: false,
            showCloseButton: false,
            confirmButtonText: "Ký lại"
        }).then(function () {
            showSigningPopup({
                orderId: orderId,
                orderHash: data.orderHash || "",
                signingUrl: data.signingUrl || (contextPath + "/order-sign/order-json?orderId=" + encodeURIComponent(orderId)),
                signToolUrl: data.signToolUrl || (contextPath + "/signing-tool/download"),
                privateKeyUrl: signNormalizeAppUrl(data.privateKeyUrl || ""),
                hasActiveCert: true,
                retryMessage: "Vui lòng tải lại dữ liệu đơn hàng, ký lại rồi upload file chữ ký mới."
            });
        });
        return;
    }

    if (status === "TAMPERED") {
        Swal.fire({
            icon: "error",
            title: "Dữ liệu đơn hàng không hợp lệ",
            text: data.message || "Dữ liệu đơn hàng có dấu hiệu bị thay đổi. Đơn hàng không thể tiếp tục xử lý.",
            confirmButtonText: "Xem đơn hàng",
            allowOutsideClick: false,
            allowEscapeKey: false,
            showCloseButton: false
        }).then(function () {
            window.location.href = contextPath + "/bought-product";
        });
        return;
    }

    if (status === "CERTIFICATE_INVALID") {
        Swal.fire({
            icon: "error",
            title: "Chứng thư không hợp lệ",
            text: data.message || "Vui lòng kiểm tra lại chứng thư và private key đang dùng.",
            confirmButtonText: "Quản lý chứng thư",
            allowOutsideClick: false,
            allowEscapeKey: false,
            showCloseButton: false
        }).then(function () {
            window.location.href = contextPath + "/security-key";
        });
        return;
    }

    Swal.fire({
        icon: "error",
        title: "File chữ ký không hợp lệ",
        text: data.message || "Vui lòng chọn lại file chữ ký .json rồi upload lại.",
        allowOutsideClick: false,
        allowEscapeKey: false,
        showCloseButton: false,
        confirmButtonText: "Thử lại"
    }).then(function () {
        showSigningPopup({
            orderId: orderId,
            orderHash: data.orderHash || "",
            signingUrl: data.signingUrl || (contextPath + "/order-sign/order-json?orderId=" + encodeURIComponent(orderId)),
            signToolUrl: data.signToolUrl || (contextPath + "/signing-tool/download"),
            privateKeyUrl: signNormalizeAppUrl(data.privateKeyUrl || ""),
            hasActiveCert: true,
            retryMessage: "Vui lòng chọn lại file chữ ký .json rồi upload lại."
        });
    });
}
const pendingCartUpdates = new Map();

async function updateCartQuantity(productId, quantity) {
    const contextPath = typeof CONTEXT_PATH !== "undefined" ? CONTEXT_PATH : "";

    const params = new URLSearchParams();
    params.set("action", "update");
    params.set("product_id", productId);
    params.set("quantity", quantity);

    const request = fetch(`${contextPath}/cart?${params.toString()}`, {
        method: "GET",
        headers: {
            "X-Requested-With": "XMLHttpRequest"
        }
    }).then(response => {
        if (!response.ok) {
            throw new Error("Không thể cập nhật số lượng giỏ hàng");
        }
        return response;
    });

    pendingCartUpdates.set(productId, request);

    try {
        await request;
    } finally {
        if (pendingCartUpdates.get(productId) === request) {
            pendingCartUpdates.delete(productId);
        }
    }
}

async function waitForCartUpdates() {
    if (pendingCartUpdates.size === 0) {
        return;
    }

    await Promise.allSettled(Array.from(pendingCartUpdates.values()));
}
async function syncAllCartQuantitiesFromUI() {
    const inputs = document.querySelectorAll(".quantity-input");

    for (const input of inputs) {
        const id = input.id || "";
        const productId = id.replace("quantity-", "");
        const quantity = parseInt(input.value || "1", 10);

        if (!productId || Number.isNaN(quantity)) {
            continue;
        }

        await updateCartQuantity(productId, Math.max(1, quantity));
    }
}


