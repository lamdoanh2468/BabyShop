<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Admin - Quản lý danh mục</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin_style.css"/>
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css"/>

    <style>
        .btn-add {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 12px 20px;
            background: linear-gradient(135deg, #007BA8, #00658F);
            color: #fff;
            font-weight: 600;
            font-size: 14px;
            border-radius: 12px;
            text-decoration: none;
            transition: 0.3s ease, transform 0.2s;
        }
        .btn-add:hover { transform: translateY(-2px); }
    </style>
</head>

<body>
<div class="dashboard">

    <!-- SIDEBAR -->
    <!-- SIDEBAR -->

                    <jsp:include page="admin_sidebar.jsp"/>

<!-- MAIN -->
    <main class="main">
        <h2>Quản lý danh mục</h2>

        <!-- ADD -->
        <a href="${pageContext.request.contextPath}/admin/categories?action=add"
           class="btn-add" style="margin-bottom:20px;display:inline-block">
            <i class="fa-solid fa-plus"></i> Thêm danh mục
        </a>

        <!-- TABLE -->
        <table class="data-table">
            <thead>
            <tr>
                <th>ID</th>
                <th>Tên danh mục</th>
                <th>Ảnh</th>
                <th>Mô tả</th>
                <th>Thao tác</th>
            </tr>
            </thead>

            <tbody>
            <c:if test="${empty categories}">
                <tr>
                    <td colspan="3" style="text-align:center;padding:20px;">
                        Không có danh mục
                    </td>
                </tr>
            </c:if>

            <c:forEach var="c" items="${categories}">
                <tr>
                    <td>#${c.categoryId}</td>
                    <!-- TÊN -->
                    <td><strong>${c.categoryName}</strong></td>

                    <!-- ẢNH -->
                    <td>
                        <c:if test="${not empty c.categoryImage}">
                            <img src="${c.categoryImage}"
                                 alt="${c.categoryName}"
                                 style="width:60px;height:60px;object-fit:cover;border-radius:8px"/>
                        </c:if>
                    </td>
                    <!-- MÔ TẢ NGẮN -->
                    <td style="max-width:300px">
                        <c:choose>
                            <c:when test="${not empty c.description}">
                                ${fn:length(c.description) > 120
                        ? fn:substring(c.description, 0, 120).concat("...")
                        : c.description}
                            </c:when>
                            <c:otherwise>
                                <i>Chưa có mô tả</i>
                            </c:otherwise>
                        </c:choose>
                    </td>

                    <!-- ACTION -->
                    <td>
                        <a class="btn-small btn-on"
                           href="${pageContext.request.contextPath}/admin/categories?action=edit&id=${c.categoryId}">
                            <i class="fa-solid fa-pen"></i>
                        </a>

                        <form method="post"
                              action="${pageContext.request.contextPath}/admin/categories"
                              style="display:inline"
                              onsubmit="return confirm('Xóa danh mục này?')">
                            <input type="hidden" name="action" value="delete"/>
                            <input type="hidden" name="id" value="${c.categoryId}"/>
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

    <!-- RIGHT PANEL -->
    <aside class="right-panel">
        <c:if test="${param.action == 'add' || param.action == 'edit'}">
            <div class="voucher-form">
                <h3>
                    <c:choose>
                        <c:when test="${param.action == 'add'}">Thêm danh mục</c:when>
                        <c:otherwise>Sửa danh mục</c:otherwise>
                    </c:choose>
                </h3>

                <form method="post"
                      action="${pageContext.request.contextPath}/admin/categories">

                    <!-- ACTION -->
                    <input type="hidden" name="action"
                           value="${param.action == 'add' ? 'create' : 'update'}"/>

                    <!-- ID (EDIT) -->
                    <c:if test="${param.action == 'edit'}">
                        <input type="hidden" name="id" value="${category.categoryId}"/>
                    </c:if>

                    <div class="form-grid">

                        <div class="form-item">
                            <label>Tên danh mục</label>
                            <input type="text"
                                   name="categoryName"
                                   value="${category != null ? category.categoryName : ''}"
                                   required/>
                        </div>

                        <div class="form-item">
                            <label>Ảnh danh mục (URL)</label>
                            <input type="text"
                                   name="categoryImage"
                                   value="${category != null ? category.categoryImage : ''}"
                                   placeholder="https://example.com/image.jpg"/>
                        </div>

                        <div class="form-item textarea-full">
                            <label>Mô tả</label>
                            <textarea name="description"
                                      placeholder="Mô tả ngắn danh mục">${category != null ? category.description : ''}</textarea>
                        </div>
                    </div>

                    <div style="margin-top:20px;text-align:right">
                        <button type="submit" class="btn-primary">
                            <i class="fa-solid ${param.action == 'add' ? 'fa-plus' : 'fa-pen'}"></i>
                            <c:choose>
                                <c:when test="${param.action == 'add'}">Thêm danh mục</c:when>
                                <c:otherwise>Cập nhật danh mục</c:otherwise>
                            </c:choose>
                        </button>
                    </div>
                </form>
            </div>
        </c:if>
    </aside>
</div>
</body>
</html>
