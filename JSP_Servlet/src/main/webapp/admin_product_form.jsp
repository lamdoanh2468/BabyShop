<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <title>Admin - ${param.action == 'edit' ? 'Sửa' : 'Thêm'} sản phẩm</title>

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
                    <span class="product-form-eyebrow">Product Workspace</span>
                    <h2>
                        <c:choose>
                            <c:when test="${param.action == 'edit'}">Sửa sản phẩm</c:when>
                            <c:otherwise>Thêm sản phẩm</c:otherwise>
                        </c:choose>
                    </h2>
                    <p>Điền thông tin sản phẩm, xem trước dữ liệu hiện tại và lưu khi hoàn tất.</p>
                </div>

                <a href="${pageContext.request.contextPath}/admin/products" class="product-back-link">
                    <i class="fa-solid fa-arrow-left"></i>
                    <span>Quay lại danh sách</span>
                </a>
            </div>

            <div class="product-form-layout">
                <section class="product-form-card">
                    <div class="product-form-card-head">
                        <div>
                            <h3>
                                <c:choose>
                                    <c:when test="${param.action == 'edit'}">Thông tin cần cập nhật</c:when>
                                    <c:otherwise>Thông tin sản phẩm mới</c:otherwise>
                                </c:choose>
                            </h3>
                            <p>Nhập đầy đủ tên, giá, danh mục, thương hiệu và thông tin hiển thị.</p>
                        </div>
                        <div class="product-form-state">
                            <i class="fa-solid fa-box-open"></i>
                            <span>${param.action == 'edit' ? 'Editing' : 'Creating'}</span>
                        </div>
                    </div>

                    <form method="post" action="${pageContext.request.contextPath}/admin/products">
                        <input type="hidden" name="action"
                               value="${param.action == 'edit' ? 'update' : 'create'}"/>

                        <c:if test="${param.action == 'edit'}">
                            <input type="hidden" name="productId" value="${product.productId}"/>
                        </c:if>

                        <div class="form-grid product-form-grid">
                            <div class="form-item">
                                <label>Tên sản phẩm</label>
                                <input type="text" name="productName"
                                       value="${product != null ? product.productName : ''}"
                                       placeholder="Ví dụ: Bàn học thông minh TopKids"
                                       required/>
                            </div>

                            <div class="form-item">
                                <label>Giá</label>
                                <input type="number" name="productPrice"
                                       value="${product != null ? product.productPrice : ''}"
                                       placeholder="Ví dụ: 2490000"
                                       required/>
                            </div>

                            <div class="form-item">
                                <label>Danh mục</label>
                                <select name="categoryId">
                                    <c:forEach var="c" items="${categories}">
                                        <option value="${c.categoryId}"
                                            ${product != null && product.categoryId == c.categoryId ? 'selected' : ''}>
                                                ${c.categoryName}
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="form-item">
                                <label>Thương hiệu</label>
                                <select name="brandId">
                                    <c:forEach var="b" items="${brands}">
                                        <option value="${b.brandId}"
                                            ${product != null && product.brandId == b.brandId ? 'selected' : ''}>
                                                ${b.brandName}
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="form-item">
                                <label>Kích thước</label>
                                <input type="text" name="productSize"
                                       value="${product != null ? product.productSize : ''}"
                                       placeholder="Ví dụ: 120x60x75 cm"/>
                            </div>

                            <div class="form-item">
                                <label>Chất liệu</label>
                                <input type="text" name="productMaterial"
                                       value="${product != null ? product.productMaterial : ''}"
                                       placeholder="Ví dụ: Gỗ MDF chống ẩm"/>
                            </div>

                            <div class="form-item textarea-full">
                                <label>Ảnh sản phẩm (URL)</label>
                                <input type="text" name="productImage"
                                       value="${product != null ? product.productImage : ''}"
                                       placeholder="https://..."/>
                            </div>
                        </div>

                        <div class="product-form-actions">
                            <a href="${pageContext.request.contextPath}/admin/products" class="product-cancel-link">
                                Hủy
                            </a>
                            <button type="submit" class="btn-primary product-submit-btn">
                                <i class="fa-solid ${param.action == 'edit' ? 'fa-floppy-disk' : 'fa-plus'}"></i>
                                <span>
                                    <c:choose>
                                        <c:when test="${param.action == 'edit'}">Cập nhật sản phẩm</c:when>
                                        <c:otherwise>Tạo sản phẩm</c:otherwise>
                                    </c:choose>
                                </span>
                            </button>
                        </div>
                    </form>
                </section>

                <aside class="product-preview-card">
                    <div class="product-preview-media">
                        <c:choose>
                            <c:when test="${product != null && not empty product.productImage}">
                                <img src="${product.productImage}" alt="Product preview"/>
                            </c:when>
                            <c:otherwise>
                                <div class="product-preview-placeholder">
                                    <i class="fa-regular fa-image"></i>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <div class="product-preview-body">
                        <span class="product-preview-badge">${param.action == 'edit' ? 'Preview hiện tại' : 'Preview mẫu'}</span>
                        <h3>${product != null && product.productName != null ? product.productName : 'Tên sản phẩm sẽ hiển thị ở đây'}</h3>
                        <p>${product != null && product.productMaterial != null && !product.productMaterial.isBlank() ? product.productMaterial : 'Thêm chất liệu, kích thước và ảnh để khối preview này đầy đủ hơn.'}</p>

                        <div class="product-preview-meta">
                            <div>
                                <span>Giá</span>
                                <strong>${product != null && product.productPrice > 0 ? product.productPrice : '--'}</strong>
                            </div>
                            <div>
                                <span>Kích thước</span>
                                <strong>${product != null && product.productSize != null && !product.productSize.isBlank() ? product.productSize : '--'}</strong>
                            </div>
                        </div>
                    </div>
                </aside>
            </div>
        </div>
    </main>
</div>
</body>
</html>
