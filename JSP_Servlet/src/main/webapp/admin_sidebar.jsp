<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%-- Shared admin chrome: Tailwind/fonts/icons setup + the left sidebar nav.
     Include once per admin page, right after <body> opens. Tokens come from
     design-system/admin/MASTER.md — keep this file in sync with that doc. --%>

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@500;600;700;800&family=Noto+Sans:wght@400;500;600&display=swap" rel="stylesheet">

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css" />

<script src="https://cdn.tailwindcss.com"></script>
<script>
    tailwind.config = {
        darkMode: 'selector',
        theme: {
            extend: {
                colors: {
                    // Shares the storefront brand scale (see design-system/admin/MASTER.md).
                    // primary-500 (#008BC6) is identity-only — fills, icons, borders, focus
                    // rings. Normal-size text uses primary-600 (4.8:1) or primary-700.
                    primary: {
                        50: '#ECF8FD', 100: '#CDEDF9', 200: '#9BDBF3',
                        500: '#008BC6', 600: '#007BA8', 700: '#00658F', 900: '#013E58',
                        dark: '#4FC3F0', // dark-mode brand — 8.6:1 on the dark surface
                    },
                    brand: {
                        50: '#ECF8FD', 100: '#CDEDF9', 200: '#9BDBF3',
                        500: '#008BC6', 600: '#007BA8', 700: '#00658F', 900: '#013E58',
                    },
                    ink: { 900: '#1D1B20', 700: '#49454F', 500: '#6E6779' },
                    surface: '#FFFFFF',
                    page: '#FEF7FF',
                    border: '#E7E0EC',
                    borderStrong: '#79747E',
                    success: '#15803D', warning: '#B45309', info: '#0369A1', danger: '#DC2626',
                },
                fontFamily: {
                    display: ['"Be Vietnam Pro"', 'sans-serif'],
                    body: ['"Noto Sans"', 'sans-serif'],
                },
            },
        },
    };
</script>
<style>
    body { font-family: 'Noto Sans', sans-serif; }
    .font-display { font-family: 'Be Vietnam Pro', sans-serif; }
    html[data-theme="dark"] body { background: #0F1117; color: #F2F3F8; }
    @media (prefers-reduced-motion: reduce) {
        * { animation-duration: 0.01ms !important; transition-duration: 0.01ms !important; }
    }
</style>

<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="uri" value="${pageContext.request.requestURI}"/>

<%-- Self-contained: emits just the <aside>. Each page wraps its own
     <div class="min-h-screen flex bg-page ..."> ... <jsp:include page="admin_sidebar.jsp"/>
     <div class="flex-1 min-w-0"> page content </div> </div> --%>
<aside class="w-60 shrink-0 bg-primary-700 text-white flex flex-col py-6 px-3 sticky top-0 h-screen overflow-y-auto">
        <div class="font-display font-extrabold text-xl px-3 mb-6">Baby<span class="text-primary-50/70">Shop</span> <span class="text-xs font-semibold align-top opacity-70">Admin</span></div>

        <nav class="flex flex-col gap-1 text-sm font-semibold">
            <a href="${ctx}/admin/overview"
               class="flex items-center gap-3 h-11 px-3 rounded-lg transition ${fn:endsWith(uri, '/overview') ? 'bg-white text-primary-700' : 'text-white/80 hover:bg-white/10 hover:text-white'}">
                <i class="fa-solid fa-house w-4 text-center"></i><span>Dashboard</span>
            </a>
            <a href="${ctx}/admin/accounts"
               class="flex items-center gap-3 h-11 px-3 rounded-lg transition ${fn:contains(uri, '/admin/account') ? 'bg-white text-primary-700' : 'text-white/80 hover:bg-white/10 hover:text-white'}">
                <i class="fa-solid fa-user w-4 text-center"></i><span>Tài khoản</span>
            </a>
            <a href="${ctx}/admin/orders"
               class="flex items-center gap-3 h-11 px-3 rounded-lg transition ${fn:contains(uri, '/admin/order') ? 'bg-white text-primary-700' : 'text-white/80 hover:bg-white/10 hover:text-white'}">
                <i class="fa-solid fa-box w-4 text-center"></i><span>Đơn hàng</span>
            </a>
            <a href="${ctx}/admin/products"
               class="flex items-center gap-3 h-11 px-3 rounded-lg transition ${fn:contains(uri, '/admin/product') ? 'bg-white text-primary-700' : 'text-white/80 hover:bg-white/10 hover:text-white'}">
                <i class="fa-solid fa-cubes w-4 text-center"></i><span>Sản phẩm</span>
            </a>
            <a href="${ctx}/admin/categories"
               class="flex items-center gap-3 h-11 px-3 rounded-lg transition ${fn:contains(uri, '/admin/categor') ? 'bg-white text-primary-700' : 'text-white/80 hover:bg-white/10 hover:text-white'}">
                <i class="fa-solid fa-layer-group w-4 text-center"></i><span>Danh mục sản phẩm</span>
            </a>
            <a href="${ctx}/admin/brands"
               class="flex items-center gap-3 h-11 px-3 rounded-lg transition ${fn:contains(uri, '/admin/brand') ? 'bg-white text-primary-700' : 'text-white/80 hover:bg-white/10 hover:text-white'}">
                <i class="fa-solid fa-tags w-4 text-center"></i><span>Thương hiệu</span>
            </a>
            <a href="${ctx}/admin/contacts"
               class="flex items-center gap-3 h-11 px-3 rounded-lg transition ${fn:contains(uri, '/admin/contact') ? 'bg-white text-primary-700' : 'text-white/80 hover:bg-white/10 hover:text-white'}">
                <i class="fa-solid fa-envelope w-4 text-center"></i><span>Liên hệ</span>
            </a>
            <a href="${ctx}/admin/stocks"
               class="flex items-center gap-3 h-11 px-3 rounded-lg transition ${fn:contains(uri, '/admin/stock') ? 'bg-white text-primary-700' : 'text-white/80 hover:bg-white/10 hover:text-white'}">
                <i class="fa-solid fa-warehouse w-4 text-center"></i><span>Kho hàng</span>
            </a>
            <a href="${ctx}/admin/vouchers"
               class="flex items-center gap-3 h-11 px-3 rounded-lg transition ${fn:contains(uri, '/admin/voucher') ? 'bg-white text-primary-700' : 'text-white/80 hover:bg-white/10 hover:text-white'}">
                <i class="fa-solid fa-ticket w-4 text-center"></i><span>Vouchers</span>
            </a>
            <a href="${ctx}/admin/settings"
               class="flex items-center gap-3 h-11 px-3 rounded-lg transition ${fn:contains(uri, '/admin/setting') ? 'bg-white text-primary-700' : 'text-white/80 hover:bg-white/10 hover:text-white'}">
                <i class="fa-solid fa-gear w-4 text-center"></i><span>Cài đặt</span>
            </a>
        </nav>

        <button type="button" id="admin-theme-toggle"
                class="mt-auto flex items-center gap-3 h-11 px-3 rounded-lg text-white/80 hover:bg-white/10 hover:text-white transition text-sm font-semibold"
                aria-pressed="false">
            <i class="fa-solid fa-moon w-4 text-center"></i><span>Chế độ tối</span>
        </button>
</aside>

<script>
    (function () {
        const toggle = document.getElementById('admin-theme-toggle');
        if (!toggle) return;
        const root = document.documentElement;
        const stored = localStorage.getItem('babyshop-admin-theme');
        if (stored === 'dark') { root.setAttribute('data-theme', 'dark'); toggle.setAttribute('aria-pressed', 'true'); }

        toggle.addEventListener('click', () => {
            const isDark = root.getAttribute('data-theme') === 'dark';
            if (isDark) {
                root.removeAttribute('data-theme');
                localStorage.setItem('babyshop-admin-theme', 'light');
                toggle.setAttribute('aria-pressed', 'false');
            } else {
                root.setAttribute('data-theme', 'dark');
                localStorage.setItem('babyshop-admin-theme', 'dark');
                toggle.setAttribute('aria-pressed', 'true');
            }
        });
    })();
</script>
