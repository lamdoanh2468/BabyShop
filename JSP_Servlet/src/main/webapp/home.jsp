<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>BabyShop Việt Nam</title>

    <link rel="icon" type="image/x-icon" href="${pageContext.request.contextPath}/favicon.ico">

    <!-- SweetAlert dùng cho header logout -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <!-- Bootstrap: kept only for its carousel JS (data-bs-slide etc.) below; Tailwind (loaded
         inside header.jsp) supplies all visual styling and is injected after this stylesheet
         so it wins the cascade for anything both frameworks touch. -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</head>

<body class="bg-page text-ink-700 font-body">
<jsp:include page="header.jsp"/>

<!-- Banner chính -->
<section class="max-w-6xl mx-auto px-4 pt-6">
    <div class="rounded-xl2 overflow-hidden shadow-card aspect-[21/9] sm:aspect-[3/1] bg-brand-50">
        <img src="${pageContext.request.contextPath}/img/banner/banner.png" alt="Banner"
             class="w-full h-full object-cover">
    </div>
</section>

<!-- Danh mục sản phẩm -->
<section class="max-w-6xl mx-auto px-4 pt-12">
    <h2 class="font-display font-bold text-2xl text-center text-ink-900 mb-8">Danh mục sản phẩm</h2>

    <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6 gap-4">
        <c:forEach items="${categories}" var="c">
            <a href="${pageContext.request.contextPath}/product-list?category_id=${c.categoryId}"
               class="group bg-surface rounded-xl2 p-3 shadow-card hover:shadow-raised hover:-translate-y-1 transition text-center">
                <div class="aspect-square rounded-lg overflow-hidden bg-page mb-2">
                    <img src="${c.categoryImage}" alt="${c.categoryName}" class="w-full h-full object-cover group-hover:scale-105 transition">
                </div>
                <p class="text-sm font-semibold text-ink-900 line-clamp-1">${c.categoryName}</p>
            </a>
        </c:forEach>
    </div>
</section>

<!-- Giới thiệu -->
<section class="max-w-6xl mx-auto px-4 pt-12">
    <div class="rounded-xl2 overflow-hidden shadow-card bg-surface">
        <img src="${pageContext.request.contextPath}/img/banner/intro.jpg" alt="Giới thiệu BabyShop" class="w-full h-auto">
    </div>
</section>

<!-- Chính sách -->
<section class="max-w-6xl mx-auto px-4">
    <div class="mt-10 -mb-10 relative z-10 bg-surface rounded-xl2 shadow-raised px-6 py-6 grid grid-cols-2 lg:grid-cols-4 gap-6">
        <div class="flex items-center gap-3">
            <i class="fa-solid fa-certificate text-2xl text-brand-600"></i>
            <span class="text-sm font-bold text-ink-900 uppercase tracking-wide">Bảo hành chính hãng</span>
        </div>
        <div class="flex items-center gap-3">
            <i class="fa-solid fa-screwdriver-wrench text-2xl text-brand-600"></i>
            <span class="text-sm font-bold text-ink-900 uppercase tracking-wide">Bảo trì trọn đời</span>
        </div>
        <div class="flex items-center gap-3">
            <i class="fa-solid fa-truck-ramp-box text-2xl text-brand-600"></i>
            <span class="text-sm font-bold text-ink-900 uppercase tracking-wide">Lắp đặt miễn phí</span>
        </div>
        <div class="flex items-center gap-3">
            <i class="fa-solid fa-truck-fast text-2xl text-brand-600"></i>
            <span class="text-sm font-bold text-ink-900 uppercase tracking-wide">Miễn phí vận chuyển</span>
        </div>
    </div>
</section>

<!-- ====== CAROUSEL SECTION TEMPLATE ====== -->
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<!-- 1) ĐỒ NỘI THẤT MỚI NHẤT -->
<section class="max-w-6xl mx-auto px-4 pt-20 pb-4">
    <h2 class="font-display font-bold text-2xl text-center text-ink-900 mb-8">Đồ nội thất mới nhất</h2>

    <c:if test="${empty NoiThatMoi}">
        <div class="text-center text-ink-500 py-8">Chưa có sản phẩm để hiển thị.</div>
    </c:if>

    <c:if test="${not empty NoiThatMoi}">
        <div id="noiThatCarousel" class="carousel slide" data-bs-ride="false" data-bs-touch="true">
            <div class="carousel-inner">
                <c:forEach items="${NoiThatMoi}" var="p" varStatus="st">
                    <c:if test="${st.index % 6 == 0}">
                        <div class="carousel-item ${st.index == 0 ? 'active' : ''}">
                        <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-6 gap-4">
                    </c:if>

                    <div class="bg-surface rounded-xl2 p-3 shadow-card hover:shadow-raised transition flex flex-col gap-2">
                        <a href="${ctx}/product-detail?product_id=${p.productId}"
                           class="block aspect-square rounded-lg overflow-hidden bg-page">
                            <img src="${p.productImage}" alt="${p.productName}" class="w-full h-full object-contain">
                        </a>

                        <h4 class="text-sm font-semibold text-ink-900 line-clamp-2 min-h-[2.5rem]">${p.productName}</h4>
                        <p class="text-brand-600 font-bold">
                            <fmt:setLocale value="vi_VN"/>
                            <fmt:formatNumber value="${p.productPrice}" type="number" groupingUsed="true"/>đ
                        </p>

                        <div class="flex gap-1.5 mt-auto">
                            <a href="<c:url value='/cart?action=add&product_id=${p.productId}&quantity=1&returnUrl=${pageContext.request.contextPath}/home'/>"
                               aria-label="Thêm vào giỏ"
                               class="filter-btn cart-btn flex-1 h-9 grid place-items-center rounded-lg border border-border text-ink-700 hover:bg-brand-50 hover:border-brand-600 hover:text-brand-600 transition">
                                <i class="fa-solid fa-cart-plus text-sm"></i>
                            </a>
                            <a href="${ctx}/product-detail?product_id=${p.productId}" aria-label="Xem chi tiết"
                               class="flex-1 h-9 grid place-items-center rounded-lg border border-border text-ink-700 hover:bg-trust-50 hover:border-trust-700 hover:text-trust-700 transition">
                                <i class="fa-solid fa-eye text-sm"></i>
                            </a>
                            <a href="${pageContext.request.contextPath}/my-favorite?action=add&product_id=${p.productId}" aria-label="Yêu thích"
                               class="filter-btn favor-btn flex-1 h-9 grid place-items-center rounded-lg border border-border text-ink-700 hover:bg-brand-50 hover:border-brand-600 hover:text-brand-600 transition">
                                <i class="fa-solid fa-heart text-sm"></i>
                            </a>
                        </div>
                    </div>

                    <c:if test="${st.index % 6 == 5 || st.last}">
                        </div>
                        </div>
                    </c:if>
                </c:forEach>
            </div>

            <c:if test="${fn:length(NoiThatMoi) > 6}">
                <button type="button" class="carousel-control-prev !w-10 !opacity-100" data-bs-target="#noiThatCarousel" data-bs-slide="prev">
                    <span class="w-10 h-10 grid place-items-center rounded-full bg-surface shadow-raised text-ink-900"><i class="fa-solid fa-chevron-left"></i></span>
                    <span class="sr-only">Trước</span>
                </button>
                <button type="button" class="carousel-control-next !w-10 !opacity-100" data-bs-target="#noiThatCarousel" data-bs-slide="next">
                    <span class="w-10 h-10 grid place-items-center rounded-full bg-surface shadow-raised text-ink-900"><i class="fa-solid fa-chevron-right"></i></span>
                    <span class="sr-only">Sau</span>
                </button>
            </c:if>
        </div>
    </c:if>
</section>

<!-- 2) ĐỒ TRANG TRÍ MỚI NHẤT -->
<section class="max-w-6xl mx-auto px-4 py-4">
    <h2 class="font-display font-bold text-2xl text-center text-ink-900 mb-8">Đồ trang trí mới nhất</h2>

    <c:if test="${empty TrangTriMoi}">
        <div class="text-center text-ink-500 py-8">Chưa có sản phẩm để hiển thị.</div>
    </c:if>

    <c:if test="${not empty TrangTriMoi}">
        <div id="trangTriCarousel" class="carousel slide" data-bs-ride="false" data-bs-touch="true">
            <div class="carousel-inner">
                <c:forEach items="${TrangTriMoi}" var="p" varStatus="st">
                    <c:if test="${st.index % 6 == 0}">
                        <div class="carousel-item ${st.index == 0 ? 'active' : ''}">
                        <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-6 gap-4">
                    </c:if>

                    <div class="bg-surface rounded-xl2 p-3 shadow-card hover:shadow-raised transition flex flex-col gap-2">
                        <a href="${ctx}/product-detail?product_id=${p.productId}"
                           class="block aspect-square rounded-lg overflow-hidden bg-page">
                            <img src="${p.productImage}" alt="${p.productName}" class="w-full h-full object-contain">
                        </a>

                        <h4 class="text-sm font-semibold text-ink-900 line-clamp-2 min-h-[2.5rem]">${p.productName}</h4>
                        <p class="text-brand-600 font-bold">
                            <fmt:formatNumber value="${p.productPrice}" type="number"/>đ
                        </p>

                        <div class="flex gap-1.5 mt-auto">
                            <a href="<c:url value='/cart?action=add&product_id=${p.productId}&quantity=1&returnUrl=${pageContext.request.contextPath}/home'/>"
                               aria-label="Thêm vào giỏ"
                               class="filter-btn cart-btn flex-1 h-9 grid place-items-center rounded-lg border border-border text-ink-700 hover:bg-brand-50 hover:border-brand-600 hover:text-brand-600 transition">
                                <i class="fa-solid fa-cart-plus text-sm"></i>
                            </a>
                            <a href="${ctx}/product-detail?product_id=${p.productId}" aria-label="Xem chi tiết"
                               class="flex-1 h-9 grid place-items-center rounded-lg border border-border text-ink-700 hover:bg-trust-50 hover:border-trust-700 hover:text-trust-700 transition">
                                <i class="fa-solid fa-eye text-sm"></i>
                            </a>
                            <a href="${pageContext.request.contextPath}/my-favorite?action=add&product_id=${p.productId}" aria-label="Yêu thích"
                               class="filter-btn favor-btn flex-1 h-9 grid place-items-center rounded-lg border border-border text-ink-700 hover:bg-brand-50 hover:border-brand-600 hover:text-brand-600 transition">
                                <i class="fa-solid fa-heart text-sm"></i>
                            </a>
                        </div>
                    </div>

                    <c:if test="${st.index % 6 == 5 || st.last}">
                        </div>
                        </div>
                    </c:if>
                </c:forEach>
            </div>

            <c:if test="${fn:length(TrangTriMoi) > 6}">
                <button type="button" class="carousel-control-prev !w-10 !opacity-100" data-bs-target="#trangTriCarousel" data-bs-slide="prev">
                    <span class="w-10 h-10 grid place-items-center rounded-full bg-surface shadow-raised text-ink-900"><i class="fa-solid fa-chevron-left"></i></span>
                    <span class="sr-only">Trước</span>
                </button>
                <button type="button" class="carousel-control-next !w-10 !opacity-100" data-bs-target="#trangTriCarousel" data-bs-slide="next">
                    <span class="w-10 h-10 grid place-items-center rounded-full bg-surface shadow-raised text-ink-900"><i class="fa-solid fa-chevron-right"></i></span>
                    <span class="sr-only">Sau</span>
                </button>
            </c:if>
        </div>
    </c:if>
</section>

<!-- 3) ĐỒ CHƠI MỚI NHẤT -->
<section class="max-w-6xl mx-auto px-4 py-4 pb-16">
    <h2 class="font-display font-bold text-2xl text-center text-ink-900 mb-8">Đồ chơi mới nhất</h2>

    <c:if test="${empty DoChoiMoi}">
        <div class="text-center text-ink-500 py-8">Chưa có sản phẩm để hiển thị.</div>
    </c:if>

    <c:if test="${not empty DoChoiMoi}">
        <div id="doChoiCarousel" class="carousel slide" data-bs-ride="false" data-bs-touch="true">
            <div class="carousel-inner">
                <c:forEach items="${DoChoiMoi}" var="p" varStatus="st">
                    <c:if test="${st.index % 6 == 0}">
                        <div class="carousel-item ${st.index == 0 ? 'active' : ''}">
                        <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-6 gap-4">
                    </c:if>

                    <div class="bg-surface rounded-xl2 p-3 shadow-card hover:shadow-raised transition flex flex-col gap-2">
                        <a href="${ctx}/product-detail?product_id=${p.productId}"
                           class="block aspect-square rounded-lg overflow-hidden bg-page">
                            <img src="${p.productImage}" alt="${p.productName}" class="w-full h-full object-contain">
                        </a>

                        <h4 class="text-sm font-semibold text-ink-900 line-clamp-2 min-h-[2.5rem]">${p.productName}</h4>
                        <p class="text-brand-600 font-bold">
                            <fmt:formatNumber value="${p.productPrice}" type="number"/>đ
                        </p>

                        <div class="flex gap-1.5 mt-auto">
                            <a href="<c:url value='/cart?action=add&product_id=${p.productId}&quantity=1&returnUrl=${pageContext.request.contextPath}/home'/>"
                               aria-label="Thêm vào giỏ"
                               class="filter-btn cart-btn flex-1 h-9 grid place-items-center rounded-lg border border-border text-ink-700 hover:bg-brand-50 hover:border-brand-600 hover:text-brand-600 transition">
                                <i class="fa-solid fa-cart-plus text-sm"></i>
                            </a>
                            <a href="${ctx}/product-detail?product_id=${p.productId}" aria-label="Xem chi tiết"
                               class="flex-1 h-9 grid place-items-center rounded-lg border border-border text-ink-700 hover:bg-trust-50 hover:border-trust-700 hover:text-trust-700 transition">
                                <i class="fa-solid fa-eye text-sm"></i>
                            </a>
                            <a href="${pageContext.request.contextPath}/my-favorite?action=add&product_id=${p.productId}" aria-label="Yêu thích"
                               class="filter-btn favor-btn flex-1 h-9 grid place-items-center rounded-lg border border-border text-ink-700 hover:bg-brand-50 hover:border-brand-600 hover:text-brand-600 transition">
                                <i class="fa-solid fa-heart text-sm"></i>
                            </a>
                        </div>
                    </div>

                    <c:if test="${st.index % 6 == 5 || st.last}">
                        </div>
                        </div>
                    </c:if>
                </c:forEach>
            </div>

            <c:if test="${fn:length(DoChoiMoi) > 6}">
                <button type="button" class="carousel-control-prev !w-10 !opacity-100" data-bs-target="#doChoiCarousel" data-bs-slide="prev">
                    <span class="w-10 h-10 grid place-items-center rounded-full bg-surface shadow-raised text-ink-900"><i class="fa-solid fa-chevron-left"></i></span>
                    <span class="sr-only">Trước</span>
                </button>
                <button type="button" class="carousel-control-next !w-10 !opacity-100" data-bs-target="#doChoiCarousel" data-bs-slide="next">
                    <span class="w-10 h-10 grid place-items-center rounded-full bg-surface shadow-raised text-ink-900"><i class="fa-solid fa-chevron-right"></i></span>
                    <span class="sr-only">Sau</span>
                </button>
            </c:if>
        </div>
    </c:if>
</section>

<jsp:include page="footer.jsp"/>

<script src="${pageContext.request.contextPath}/js/home.js"></script>

<style>
    @media (prefers-reduced-motion: reduce) {
        * { animation-duration: 0.01ms !important; animation-iteration-count: 1 !important; transition-duration: 0.01ms !important; }
    }
</style>
</body>

</html>
