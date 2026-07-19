// Chuyển đổi giữa các mục trong menu
const btnInfo = document.getElementById("btn-info");
const btnOrders = document.getElementById("btn-orders");
const infoSection = document.getElementById("info-section");
const ordersSection = document.getElementById("orders-section");

btnInfo.addEventListener("click", () => {
    btnInfo.classList.add("active");
    btnOrders.classList.remove("active");
    infoSection.classList.add("active");
    ordersSection.classList.remove("active");
});

btnOrders.addEventListener("click", () => {
    btnOrders.classList.add("active");
    btnInfo.classList.remove("active");
    ordersSection.classList.add("active");
    infoSection.classList.remove("active");
});

// Xử lý tải ảnh avatar
const avatarInput = document.getElementById("avatar-upload");
const avatarPreview = document.getElementById("avatar-preview");

avatarInput.addEventListener("change", function () {
    const file = this.files[0];
    if (file) {
        const reader = new FileReader();
        reader.onload = function (e) {
            avatarPreview.src = e.target.result;
        };
        reader.readAsDataURL(file);
    }
});

// Lưu thông tin
document.getElementById("save-btn").addEventListener("click", () => {
    const info = {
        full_name: document.getElementById("full_name").value,
        phone: document.getElementById("phone").value,
        address: document.getElementById("address").value,
        gender: document.getElementById("gender").value,
        bod: document.getElementById("bod").value,
    };
    alert("Thông tin đã được lưu:\n" + JSON.stringify(info, null, 2));
});

