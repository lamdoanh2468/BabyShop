<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- Fonts -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@500;600;700;800&family=Noto+Sans:wght@400;500;600&display=swap" rel="stylesheet">

<!-- Font Awesome (shared icon set for the whole storefront) -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.0.1/css/all.min.css"
      integrity="sha512-2SwdPD6INVrV/lHTZbO2nodKhrnDdJK9/kg2XD1r9uGqPo1cUbujc+IYdlYdEErWNu69gVcYgdxlmVmzTWnetw=="
      crossorigin="anonymous" referrerpolicy="no-referrer" />

<!-- Tailwind (CDN, no build step) — see design-system/storefront/MASTER.md for the source of these tokens -->
<script src="https://cdn.tailwindcss.com"></script>
<script>
    tailwind.config = {
        theme: {
            extend: {
                colors: {
                    // brand-500 (#008BC6) is the identity color — 3.8:1 on white, so it is
                    // valid for fills, icons, borders and focus rings, but NOT for normal-size
                    // text. Anything text-sized uses brand-600 (4.8:1) or brand-700.
                    brand: {
                        50: '#ECF8FD', 100: '#CDEDF9', 200: '#9BDBF3',
                        500: '#008BC6', 600: '#007BA8', 700: '#00658F', 900: '#013E58',
                    },
                    // Retained alias: existing markup uses trust-* for secondary//info accents.
                    trust: { 50: '#ECF8FD', 700: '#00658F' },
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
                borderRadius: { xl2: '16px' },
                boxShadow: {
                    card: '0 1px 2px rgba(29,27,32,0.06)',
                    raised: '0 8px 24px -12px rgba(29,27,32,0.18)',
                },
            },
        },
    };
</script>
<style>
    body { font-family: 'Noto Sans', sans-serif; background: #FEF7FF; color: #49454F; }
    .font-display { font-family: 'Be Vietnam Pro', sans-serif; }
</style>

<header id="siteHeader" class="sticky top-0 z-50 bg-surface/95 backdrop-blur border-b border-border shadow-sm font-body">
    <!-- Top bar -->
    <div class="bg-ink-900 text-white text-sm">
        <div class="max-w-6xl mx-auto px-4 flex items-center justify-between gap-4 py-2">
            <div>
                Hotline:
                <a href="tel:0964163168" class="font-semibold hover:underline">0964 163 168</a>
            </div>

            <div>
                <c:choose>
                    <c:when test="${empty sessionScope.USER}">
                        <a href="${pageContext.request.contextPath}/login" class="font-semibold hover:underline">Đăng nhập</a>
                        <span class="opacity-60 mx-2">/</span>
                        <a href="${pageContext.request.contextPath}/register" class="font-semibold hover:underline">Đăng ký</a>
                    </c:when>
                    <c:otherwise>
                        Xin chào, <strong>${sessionScope.USER.username}</strong>
                        <span class="opacity-60 mx-2">/</span>
                        <a class="logout-btn font-semibold hover:underline cursor-pointer" href="${pageContext.request.contextPath}/logout">Đăng xuất</a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <!-- Main row -->
    <div class="max-w-6xl mx-auto px-4 py-3 flex items-center gap-4">
        <!-- Brand -->
        <a href="${pageContext.request.contextPath}/" class="shrink-0 font-display font-extrabold text-2xl tracking-tight" aria-label="BabyShop">
            <span class="text-ink-900">Baby</span><span class="text-brand-600">Shop</span>
        </a>

        <!-- Search (desktop) -->
        <div class="hidden md:flex flex-1 justify-center">
            <form action="${pageContext.request.contextPath}/search" method="get" role="search"
                  class="w-full max-w-lg flex items-center gap-2 bg-surface border border-border rounded-full pl-4 pr-1.5 py-1.5 shadow-card focus-within:border-brand-600 focus-within:ring-2 focus-within:ring-brand-100 transition">
                <input type="search" name="keyword" value="${param.keyword}" placeholder="Tìm bàn ghế, tủ, đồ chơi..."
                       class="flex-1 bg-transparent outline-none text-sm text-ink-900 placeholder:text-ink-500" />
                <button type="submit" aria-label="Tìm"
                        class="w-9 h-9 shrink-0 grid place-items-center rounded-full bg-brand-600 text-white hover:bg-brand-700 transition">
                    <i class="fa-solid fa-magnifying-glass text-sm"></i>
                </button>
            </form>
        </div>

        <!-- Right side -->
        <div class="flex items-center gap-2 ml-auto">
            <nav aria-label="Điều hướng chính" class="hidden lg:block">
                <ul class="flex items-center gap-1 text-sm font-semibold text-ink-700">
                    <li><a href="${pageContext.request.contextPath}/" class="block px-3 py-2.5 rounded-lg hover:bg-brand-50 hover:text-brand-600 transition">Trang chủ</a></li>
                    <li><a href="${pageContext.request.contextPath}/product-list" class="block px-3 py-2.5 rounded-lg hover:bg-brand-50 hover:text-brand-600 transition">Sản phẩm</a></li>
                    <li><a href="${pageContext.request.contextPath}/news" class="block px-3 py-2.5 rounded-lg hover:bg-brand-50 hover:text-brand-600 transition">Tin tức</a></li>
                    <li><a href="${pageContext.request.contextPath}/voucher-list" class="block px-3 py-2.5 rounded-lg hover:bg-brand-50 hover:text-brand-600 transition">Ưu đãi</a></li>
                    <li><a href="${pageContext.request.contextPath}/contact" class="block px-3 py-2.5 rounded-lg hover:bg-brand-50 hover:text-brand-600 transition">Liên hệ</a></li>
                </ul>
            </nav>

            <div class="flex items-center gap-2">
                <a href="${pageContext.request.contextPath}/profile" aria-label="Tài khoản"
                   class="w-11 h-11 grid place-items-center rounded-xl border border-border bg-surface text-ink-900 shadow-card hover:-translate-y-0.5 hover:shadow-raised transition">
                    <i class="fa-solid fa-user text-base"></i>
                </a>

                <a href="${pageContext.request.contextPath}/cart" aria-label="Giỏ hàng"
                   class="relative w-11 h-11 grid place-items-center rounded-xl border border-border bg-surface text-ink-900 shadow-card hover:-translate-y-0.5 hover:shadow-raised transition">
                    <i class="fa-solid fa-cart-shopping text-base"></i>
                    <span aria-hidden="true"
                          class="absolute -top-1.5 -right-1.5 min-w-[20px] h-5 px-1 rounded-full bg-brand-600 text-white text-xs font-bold grid place-items-center border-2 border-surface">
                        <c:choose>
                            <c:when test="${sessionScope.cart != null}">${sessionScope.cart.totalQuantity}</c:when>
                            <c:otherwise>0</c:otherwise>
                        </c:choose>
                    </span>
                </a>

                <button type="button" class="sh-hamburger lg:hidden w-11 h-11 grid place-items-center rounded-xl border border-border bg-surface text-ink-900 shadow-card"
                        aria-label="Mở menu" aria-controls="mobileMenu" aria-expanded="false">
                    <i class="fa-solid fa-bars text-base"></i>
                </button>
            </div>
        </div>
    </div>

    <!-- Mobile drawer -->
    <div id="mobileMenu" class="hidden fixed inset-0 z-50 bg-ink-900/40 backdrop-blur-sm" aria-hidden="true">
        <div class="h-full w-[min(88vw,360px)] bg-surface shadow-raised p-5 overflow-y-auto">
            <div class="flex items-center justify-between mb-4">
                <span class="font-display font-extrabold text-lg text-ink-900">Menu</span>
                <button type="button" class="sh-hamburger-close w-9 h-9 grid place-items-center rounded-lg hover:bg-brand-50" aria-label="Đóng menu">
                    <i class="fa-solid fa-xmark"></i>
                </button>
            </div>

            <form action="${pageContext.request.contextPath}/search" method="get" role="search" class="mb-4">
                <input type="search" name="keyword" value="${param.keyword}" placeholder="Tìm sản phẩm..."
                       class="w-full rounded-xl border border-border px-4 py-3 text-sm outline-none focus:border-brand-600" />
            </form>

            <ul class="flex flex-col gap-1 text-sm font-semibold text-ink-900">
                <li><a href="${pageContext.request.contextPath}/" class="block px-3 py-3 rounded-xl hover:bg-brand-50 hover:text-brand-600">Trang chủ</a></li>
                <li><a href="${pageContext.request.contextPath}/product-list" class="block px-3 py-3 rounded-xl hover:bg-brand-50 hover:text-brand-600">Danh sách sản phẩm</a></li>
                <li><a href="${pageContext.request.contextPath}/news" class="block px-3 py-3 rounded-xl hover:bg-brand-50 hover:text-brand-600">Tin tức</a></li>
                <li><a href="${pageContext.request.contextPath}/voucher-list" class="block px-3 py-3 rounded-xl hover:bg-brand-50 hover:text-brand-600">Ưu đãi</a></li>
                <li><a href="${pageContext.request.contextPath}/contact" class="block px-3 py-3 rounded-xl hover:bg-brand-50 hover:text-brand-600">Liên hệ</a></li>
                <li><a href="${pageContext.request.contextPath}/profile" class="block px-3 py-3 rounded-xl hover:bg-brand-50 hover:text-brand-600">Tài khoản</a></li>
                <li><a href="${pageContext.request.contextPath}/cart" class="block px-3 py-3 rounded-xl hover:bg-brand-50 hover:text-brand-600">Giỏ hàng</a></li>
            </ul>
        </div>
    </div>
</header>

<script>
    document.addEventListener("DOMContentLoaded", () => {
        const header = document.getElementById('siteHeader');
        if (!header) return;

        const btn = header.querySelector('.sh-hamburger');
        const closeBtn = header.querySelector('.sh-hamburger-close');
        const menu = document.getElementById('mobileMenu');
        if (!btn || !menu) return;

        function setOpen(open) {
            btn.setAttribute('aria-expanded', String(open));
            menu.setAttribute('aria-hidden', String(!open));
            menu.classList.toggle('hidden', !open);
            document.body.classList.toggle('overflow-hidden', open);
        }

        btn.addEventListener('click', () => {
            const isOpen = btn.getAttribute('aria-expanded') === 'true';
            setOpen(!isOpen);
        });

        if (closeBtn) closeBtn.addEventListener('click', () => setOpen(false));

        menu.addEventListener('click', (e) => {
            if (e.target === menu) setOpen(false);
        });

        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') setOpen(false);
        });
    });

    const logOutBtn = document.querySelector(".logout-btn");
    if (logOutBtn) {
        logOutBtn.addEventListener("click", (event) => {
            event.preventDefault();
            const url = logOutBtn.getAttribute("href");

            fetch(url)
                .then(response => {
                    Swal.fire({
                        icon: "success",
                        title: "Đã đăng xuất",
                        text: "Đăng xuất khỏi tài khoản thành công.",
                        timer: 1500,
                        showConfirmButton: false,
                    }).then(() => {
                        window.location.href = response.url;
                    });
                })
                .catch(error => {
                    console.error(error);
                    Swal.fire({
                        icon: "error",
                        title: "Lỗi",
                        text: "Có lỗi xảy ra, vui lòng thử lại sau.",
                    });
                });
        });
    }
</script>
