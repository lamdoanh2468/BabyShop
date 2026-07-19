document.addEventListener("DOMContentLoaded", () => {

    const { revenueByMonth, ordersByCategory, contextPath } = window.ADMIN_DATA || {};

    if (revenueByMonth && revenueByMonth.length) {

        const labels = revenueByMonth.map(r => `Tháng ${r.month}`);
        const data = revenueByMonth.map(r => r.revenue);

        new Chart(document.getElementById('revenueChart'), {
            type: 'bar',
            data: {
                labels,
                datasets: [{
                    label: 'Doanh thu (VNĐ)',
                    data
                }]
            }
        });
    }

    if (ordersByCategory && ordersByCategory.length) {
        new Chart(document.getElementById('categoryChart'), {
            type: 'doughnut',
            data: {
                labels: ordersByCategory.map(c => c.categoryName),
                datasets: [{
                    data: ordersByCategory.map(c => c.totalOrders)
                }]
            }
        });
    }

    window.updateStatus = function (id, status) {
        fetch(`${contextPath}/admin/accounts/status?id=${id}&status=${status}`)
            .then(res => res.text())
            .then(txt => {
                if (txt !== "OK") alert("Cập nhật thất bại");
            });
    };


    /* ================= PROFILE POPUP ================= */
    const popup = document.getElementById("profile-popup");

    window.showProfile = function (row) {
        const id = row.dataset.id;
        const rect = row.getBoundingClientRect();

        popup.style.top = rect.top + "px";
        popup.style.left = rect.right + 12 + "px";
        popup.style.display = "block";
        popup.innerHTML = "Loading...";

        fetch(`${window.APP_CONTEXT}/admin/accounts/profile?accountId=${id}`)
            .then(res => res.json())
            .then(p => {
                popup.innerHTML = `
                    <img src="${p.avatar_url || '/img/default-avatar.png'}">
                    <b>${p.full_name || ''}</b><br>
                    📧 ${p.email || ''}<br>
                    📞 ${p.phone || ''}<br>
                    🏠 ${p.address || ''}<br>
                    ⚥ ${p.gender || ''}<br>
                `;
            })
            .catch(() => popup.innerHTML = "Không có dữ liệu");
    };

    window.hideProfile = () => popup.style.display = "none";

    /* ================= TOGGLE ADD FORM ================= */
    window.toggleAddForm = function () {
        const form = document.getElementById("add-account-form");
        if (!form) return;
        
        if (form.style.display === "none" || !form.style.display) {
            form.style.display = "block";
            // Optional: Scroll to form
            form.scrollIntoView({ behavior: 'smooth', block: 'start' });
        } else {
            form.style.display = "none";
        }
    };
});
