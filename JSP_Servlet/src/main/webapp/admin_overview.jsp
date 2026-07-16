<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Admin - Tổng quan</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>

<body class="bg-page font-body text-ink-700">

<div class="min-h-screen flex bg-page">
<jsp:include page="admin_sidebar.jsp"/>

<div class="flex-1 min-w-0">
    <main class="p-6 lg:p-8 max-w-[1400px] mx-auto">
        <h2 class="font-display font-bold text-2xl text-ink-900 mb-6">Thống kê dữ liệu</h2>

        <!-- KPI CARDS -->
        <section class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
            <div class="lg:col-span-2 bg-surface rounded-lg border border-border p-5 flex items-center justify-between shadow-[0_1px_2px_rgba(11,18,32,0.04)]">
                <div>
                    <h4 class="text-sm text-ink-500 mb-1">Tổng doanh thu</h4>
                    <p class="text-3xl font-bold text-ink-900 tabular-nums">
                        <fmt:formatNumber value="${totalRevenue}" type="number"/>đ
                    </p>
                </div>
                <div class="w-12 h-12 rounded-lg bg-primary-50 text-primary-700 grid place-items-center text-xl">
                    <i class="fa-solid fa-coins"></i>
                </div>
            </div>

            <div class="lg:col-span-2 bg-surface rounded-lg border border-border p-5 flex items-center justify-between shadow-[0_1px_2px_rgba(11,18,32,0.04)]">
                <div>
                    <h4 class="text-sm text-ink-500 mb-1">Tổng đơn hàng</h4>
                    <p class="text-3xl font-bold text-ink-900 tabular-nums">${totalOrders}</p>
                </div>
                <div class="w-12 h-12 rounded-lg bg-primary-50 text-primary-700 grid place-items-center text-xl">
                    <i class="fa-solid fa-cart-shopping"></i>
                </div>
            </div>

            <div class="bg-surface rounded-lg border border-border p-5 flex items-center justify-between shadow-[0_1px_2px_rgba(11,18,32,0.04)]">
                <div>
                    <h4 class="text-sm text-ink-500 mb-1">Số lượng tài khoản</h4>
                    <p class="text-2xl font-bold text-ink-900 tabular-nums">${totalCustomers}</p>
                </div>
                <div class="w-11 h-11 rounded-lg bg-primary-50 text-primary-700 grid place-items-center text-lg">
                    <i class="fa-solid fa-user-group"></i>
                </div>
            </div>

            <div class="bg-surface rounded-lg border border-border p-5 flex items-center justify-between shadow-[0_1px_2px_rgba(11,18,32,0.04)]">
                <div>
                    <h4 class="text-sm text-ink-500 mb-1">Số lượng sản phẩm</h4>
                    <p class="text-2xl font-bold text-ink-900 tabular-nums">${totalProducts}</p>
                </div>
                <div class="w-11 h-11 rounded-lg bg-primary-50 text-primary-700 grid place-items-center text-lg">
                    <i class="fa-solid fa-boxes-stacked"></i>
                </div>
            </div>
        </section>

        <!-- CHARTS -->
        <section class="grid grid-cols-1 lg:grid-cols-2 gap-4 mb-6">
            <div class="bg-surface rounded-lg border border-border p-5">
                <h3 class="text-sm font-semibold text-ink-900 mb-3">Doanh thu theo tháng</h3>
                <canvas id="revenueChart" role="img" aria-label="Biểu đồ doanh thu theo tháng"></canvas>
            </div>
            <div class="bg-surface rounded-lg border border-border p-5">
                <h3 class="text-sm font-semibold text-ink-900 mb-3">Đơn hàng theo danh mục</h3>
                <canvas id="categoryChart" role="img" aria-label="Biểu đồ đơn hàng theo danh mục"></canvas>
            </div>
        </section>

        <!-- RECENT ORDERS -->
        <section class="bg-surface rounded-lg border border-border overflow-hidden">
            <h3 class="text-sm font-semibold text-ink-900 px-5 pt-5 pb-3">Đơn hàng gần nhất</h3>

            <div class="overflow-x-auto">
                <table class="w-full text-sm">
                    <thead>
                    <tr class="text-left text-xs uppercase tracking-wide text-ink-500 border-y border-border">
                        <th class="px-5 py-2.5 font-semibold">Mã đơn</th>
                        <th class="px-5 py-2.5 font-semibold">Khách hàng</th>
                        <th class="px-5 py-2.5 font-semibold">Tổng tiền</th>
                        <th class="px-5 py-2.5 font-semibold">Ngày</th>
                        <th class="px-5 py-2.5 font-semibold">Trạng thái</th>
                    </tr>
                    </thead>

                    <tbody>
                    <c:forEach items="${recentOrders}" var="o">
                        <c:set var="badgeClass" value="bg-warning/10 text-warning"/>

                        <c:choose>
                            <c:when test="${o.statusOrder == 'Done' || o.statusOrder == 'DONE'}">
                                <c:set var="badgeClass" value="bg-success/10 text-success"/>
                            </c:when>
                            <c:when test="${o.statusOrder == 'Pending' || o.statusOrder == 'PENDING'}">
                                <c:set var="badgeClass" value="bg-warning/10 text-warning"/>
                            </c:when>
                            <c:when test="${o.statusOrder == 'WAITING_SIGNATURE'}">
                                <c:set var="badgeClass" value="bg-info/10 text-info"/>
                            </c:when>
                            <c:when test="${o.statusOrder == 'VERIFIED'}">
                                <c:set var="badgeClass" value="bg-info/10 text-info"/>
                            </c:when>
                            <c:when test="${o.statusOrder == 'CANCELLED'}">
                                <c:set var="badgeClass" value="bg-danger/10 text-danger"/>
                            </c:when>
                            <c:when test="${o.statusOrder == 'TAMPERED' || o.statusOrder == 'SIGNATURE_INVALID' || o.statusOrder == 'CERTIFICATE_INVALID'}">
                                <c:set var="badgeClass" value="bg-danger/10 text-danger"/>
                            </c:when>
                        </c:choose>

                        <tr class="border-b border-border last:border-0 hover:bg-page/60">
                            <td class="px-5 py-3 font-medium text-ink-900 tabular-nums">#${o.orderId}</td>
                            <td class="px-5 py-3">${o.username}</td>
                            <td class="px-5 py-3 tabular-nums">
                                <fmt:formatNumber value="${o.totalAmount}" type="number"/>đ
                            </td>
                            <td class="px-5 py-3 text-ink-500">
                                <fmt:formatDate value="${o.orderDate}" pattern="dd/MM/yyyy"/>
                            </td>
                            <td class="px-5 py-3">
                                <span class="inline-flex items-center rounded-full px-2.5 py-1 text-xs font-semibold ${badgeClass}">
                                        ${o.statusOrder}
                                </span>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </section>
    </main>
</div>
</div>

<script>
    window.ADMIN_DATA = {
        revenueByMonth: ${revenueByMonthJson},
        ordersByCategory: ${ordersByCategoryJson},
        contextPath: "${pageContext.request.contextPath}"
    };
</script>
<script src="${pageContext.request.contextPath}/js/admin_script.js"></script>
</body>
</html>
