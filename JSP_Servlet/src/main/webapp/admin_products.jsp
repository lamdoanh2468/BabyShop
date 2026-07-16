<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <title>Admin - Quản lý sản phẩm</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin_style.css"/>
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css"/>
</head>

<body>
<div class="dashboard">

    <!-- SIDEBAR -->

                    <jsp:include page="admin_sidebar.jsp"/>

<!-- MAIN -->
    <main class="main">
        <h2>Quản lý sản phẩm</h2>

        <!-- ADD -->
        <a href="${pageContext.request.contextPath}/admin/products?action=add"
           class="btn-add" style="margin-bottom:20px;    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 12px 20px;
    background: linear-gradient(135deg, #007BA8, #00658F);
    color: #fff;
    font-weight: 600;
    font-size: 14px;
    border-radius: 12px;
    text-decoration: none;
    transition: 0.3s ease, transform 0.2s;">
            <i class="fa-solid fa-plus"></i> Thêm sản phẩm
        </a>

        <!-- TABLE -->
        <table class="data-table">
            <thead>
            <tr>
                <th>ID</th>
                <th>Tên</th>
                <th>Danh mục</th>
                <th>Giá</th>
                <th>Ảnh</th>
                <th>Thao tác</th>
            </tr>
            </thead>

            <tbody>
            <c:if test="${empty products}">
                <tr>
                    <td colspan="6" style="text-align:center;padding:20px">
                        Không có sản phẩm
                    </td>
                </tr>
            </c:if>

            <c:forEach var="p" items="${products}">
                <tr>
                    <td>#${p.productId}</td>
                    <td><strong>${p.productName}</strong></td>
                    <td>${categoryMap[p.categoryId]}</td>
                    <td>${p.productPrice}</td>

                    <td>
                        <c:if test="${not empty p.productImage}">
                            <img src="${p.productImage}"
                                 style="width:60px;height:60px;object-fit:cover;border-radius:8px">
                        </c:if>
                    </td>

                    <td>
                        <a class="btn-small btn-on"
                           href="${pageContext.request.contextPath}/admin/products?action=edit&id=${p.productId}">
                            <i class="fa-solid fa-pen"></i>
                        </a>

                        <form method="post"
                              action="${pageContext.request.contextPath}/admin/products"
                              style="display:inline"
                              onsubmit="return confirm('Xóa sản phẩm này?')">
                            <input type="hidden" name="action" value="delete"/>
                            <input type="hidden" name="id" value="${p.productId}"/>
                            <button type="submit" class="btn-small btn-delete">
                                <i class="fa-solid fa-trash"></i>
                            </button>
                        </form>
                    </td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </main>

</div>
</body>
</html>
