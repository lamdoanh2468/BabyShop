<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Admin - Quản lý kho hàng</title>

    <!-- CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin_style.css"/>
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css"/>
</head>

<body>
<div class="dashboard">

    <!-- SIDEBAR -->

                    <jsp:include page="admin_sidebar.jsp"/>

<!-- CONTENT -->
    <div class="content-wrapper">

        <!-- MAIN -->
        <main class="main">
            <div class="product-header">
                <h2>Quản lý kho hàng</h2>
                <a class="btn-add" href="${pageContext.request.contextPath}/admin/stocks?action=add">
                    <i class="fa-solid fa-plus"></i> Thêm kho hàng
                </a>
            </div>

            <!-- DANH SÁCH KHO -->
            <section class="voucher-list">
                <h3>Danh sách kho hàng</h3>

                <table class="data-table">
                    <thead>
                    <tr>
                        <th>ID</th>
                        <th>Tên kho</th>
                        <th>Địa chỉ</th>
                        <th>Số lượng SP</th>
                        <th>Hành động</th>
                    </tr>
                    </thead>

                    <tbody>
                    <c:if test="${empty stocks}">
                        <tr>
                            <td colspan="5" style="text-align:center;padding:20px;">
                                Chưa có kho hàng
                            </td>
                        </tr>
                    </c:if>

                    <c:forEach var="stock" items="${stocks}">
                        <tr>
                            <td>${stock.stockId}</td>
                            <td>${stock.stockName}</td>
                            <td>${stock.stockAddress}</td>
                            <td>${stock.productCount}</td>
                            <td>
                                <!-- Sửa -->
                                <a class="btn-small btn-on"
                                   href="${pageContext.request.contextPath}/admin/stocks?action=edit&id=${stock.stockId}">
                                    <i class="fa-solid fa-pen"></i>
                                </a>

                                <!-- Xóa -->
                                <form action="${pageContext.request.contextPath}/admin/stocks"
                                      method="post"
                                      style="display:inline"
                                      onsubmit="return confirm('Bạn chắc chắn muốn xóa kho này?')">

                                    <input type="hidden" name="action" value="delete"/>
                                    <input type="hidden" name="id" value="${stock.stockId}"/>

                                    <button type="submit" class="btn-small btn-delete">
                                        <i class="fa-solid fa-trash"></i>
                                    </button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </section>
        </main>


</div>
</div>
</body>
</html>
