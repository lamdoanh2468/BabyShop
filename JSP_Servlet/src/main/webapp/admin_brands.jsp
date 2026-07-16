<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>

    <title>Admin - Quản lý hãng</title>

    <!-- CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin_style.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin_chart.css"/>
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
            box-shadow: 0 4px 12px rgba(108, 99, 255, 0.25);
        }

        .btn-add i {
            font-size: 16px;
        }

        /* Hover */
        .btn-add:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(0, 139, 198, 0.35);
            background: linear-gradient(135deg, #00658F, #007BA8);
        }

        /* Active click */
        .btn-add:active {
            transform: translateY(1px);
            box-shadow: 0 3px 8px rgba(108, 99, 255, 0.25);
        }
    </style>

    <!-- JS LIB -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>

<body>

<div class="dashboard">

    <!-- SIDEBAR -->

                    <jsp:include page="admin_sidebar.jsp"/>

<!-- MAIN -->
    <main class="main">
        <h2>Quản lý thương hiệu</h2>

        <button style="margin-bottom:20px">
            <a href="${pageContext.request.contextPath}/admin/brands?action=add"
               class="btn btn-add">
                <i class="fa-solid fa-plus"></i> Thêm thương hiệu
            </a>
        </button>

        <table class="data-table">
            <thead>
            <tr>
                <th>ID</th>
                <th>Tên hãng</th>
                <th>Logo</th>
                <th>Thao tác</th>
            </tr>
            </thead>

            <tbody>
            <c:if test="${empty brandList}">
                <tr>
                    <td colspan="4" style="text-align:center;padding:20px;">
                        Không có thương hiệu
                    </td>
                </tr>
            </c:if>

            <c:forEach var="b" items="${brandList}">
                <tr>
                    <td>#${b.brandId}</td>
                    <td><strong>${b.brandName}</strong></td>
                    <td>
                        <c:if test="${not empty b.brandLogo}">
                            <img src="${b.brandLogo}" alt="${b.brandName}" style="height:40px;object-fit:contain"/>
                        </c:if>
                    </td>
                    <td>
                        <!-- Sửa -->
                        <a class="btn-small btn-on"
                           href="${pageContext.request.contextPath}/admin/brands?action=edit&id=${b.brandId}">
                            <i class="fa-solid fa-pen"></i>
                        </a>

                        <!-- Xóa -->
                        <form action="${pageContext.request.contextPath}/admin/brands"
                              method="post" style="display:inline"
                              onsubmit="return confirm('Bạn chắc chắn muốn xóa thương hiệu này?')">
                            <input type="hidden" name="action" value="delete"/>
                            <input type="hidden" name="brandId" value="${b.brandId}"/>
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

    <aside class="right-panel">
        <c:if test="${param.action == 'add' || param.action == 'edit'}">
            <div class="voucher-form">
                <h3>
                    <c:choose>
                        <c:when test="${param.action == 'add'}">Thêm thương hiệu</c:when>
                        <c:otherwise>Sửa thương hiệu</c:otherwise>
                    </c:choose>
                </h3>

                <form action="${pageContext.request.contextPath}/admin/brands" method="post">
                    <input type="hidden" name="action" value="${param.action}"/>
                    <c:if test="${param.action == 'edit'}">
                        <input type="hidden" name="brandId" value="${brandToEdit.brandId}"/>
                    </c:if>

                    <div class="form-grid">
                        <!-- Tên thương hiệu -->
                        <div class="form-item">
                            <label>Tên thương hiệu</label>
                            <input type="text"
                                   name="brandName"
                                   value="${brandToEdit != null ? brandToEdit.brandName : ''}"
                                   placeholder="Nhập tên thương hiệu"
                                   required/>
                        </div>

                        <!-- Logo -->
                        <div class="form-item">
                            <label>Logo (URL)</label>
                            <input type="text"
                                   name="brandLogo"
                                   value="${brandToEdit != null ? brandToEdit.brandLogo : ''}"
                                   placeholder="https://example.com/logo.png"/>
                        </div>

                        <!-- Mô tả -->
                        <div class="form-item textarea-full">
                            <label>Mô tả</label>
                            <textarea name="brandDescription"
                                      placeholder="Mô tả thương hiệu">${brandToEdit != null ? brandToEdit.brandDescription : ''}</textarea>
                        </div>
                    </div>

                    <div style="margin-top: 20px; text-align: right;">
                        <button type="submit" class="btn-primary">
                            <i class="fa-solid ${param.action == 'add' ? 'fa-plus' : 'fa-pen'}"></i>
                            <c:choose>
                                <c:when test="${param.action == 'add'}">Thêm thương hiệu</c:when>
                                <c:otherwise>Cập nhật thương hiệu</c:otherwise>
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
