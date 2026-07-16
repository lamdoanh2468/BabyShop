<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <title>Admin - Quản lý Voucher</title>

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
            <h2>Quản lý Voucher</h2>

            <a href="${pageContext.request.contextPath}/admin/vouchers?action=add"
               class="btn-add" style="margin-bottom:20px">
                <i class="fa-solid fa-plus"></i> Thêm Voucher
            </a>

            <table class="data-table">
                <thead>
                <tr>
                    <th>ID</th>
                    <th>Ảnh</th>
                    <th>Mã</th>
                    <th>Tên</th>
                    <th>Giảm</th>
                    <th>Bắt đầu</th>
                    <th>Kết thúc</th>
                    <th>Hành động</th>
                </tr>
                </thead>

                <tbody>
                <c:forEach var="v" items="${vouchers}">
                    <tr>
                        <td>#${v.voucherId}</td>
                        <td>
                            <c:if test="${not empty v.voucherImage}">
                                <img src="${v.voucherImage}"
                                     style="width:60px;height:40px;object-fit:cover;border-radius:6px"/>
                            </c:if>
                        </td>
                        <td><b>${v.voucherCode}</b></td>
                        <td>${v.voucherName}</td>
                        <td>${v.discountAmount} đ</td>
                        <td>${v.startDate}</td>
                        <td>${v.endDate}</td>
                        <td>
                            <a class="btn-small btn-on"
                               href="${pageContext.request.contextPath}/admin/vouchers?action=edit&id=${v.voucherId}">
                                <i class="fa-solid fa-pen"></i>
                            </a>

                            <form method="post"
                                  action="${pageContext.request.contextPath}/admin/vouchers"
                                  style="display:inline"
                                  onsubmit="return confirm('Xóa voucher này?')">
                                <input type="hidden" name="action" value="delete"/>
                                <input type="hidden" name="id" value="${v.voucherId}"/>
                                <button class="btn-small btn-delete">
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
                            <c:when test="${param.action == 'add'}">Thêm voucher</c:when>
                            <c:otherwise>Sửa voucher</c:otherwise>
                        </c:choose>
                    </h3>

                    <form method="post"
                          action="${pageContext.request.contextPath}/admin/vouchers">

                        <!-- PHÂN BIỆT ADD / EDIT -->
                        <input type="hidden" name="action" value="${param.action}"/>

                        <c:if test="${param.action == 'edit'}">
                            <input type="hidden" name="id" value="${voucherToEdit.voucherId}"/>
                        </c:if>

                        <div class="form-grid">
                            <div class="form-item">
                                <label>Mã voucher</label>
                                <input type="text" name="voucherCode"
                                       value="${voucherToEdit.voucherCode}" required/>
                            </div>

                            <div class="form-item">
                                <label>Link hình ảnh</label>
                                <input type="text" name="voucherImage"
                                       value="${voucherToEdit.voucherImage}"
                                       placeholder="https://..."/>
                            </div>

                            <div class="form-item">
                                <label>Tên voucher</label>
                                <input type="text" name="voucherName"
                                       value="${voucherToEdit.voucherName}" required/>
                            </div>

                            <div class="form-item">
                                <label>Giá trị giảm</label>
                                <input type="number" name="discountAmount"
                                       value="${voucherToEdit.discountAmount}" required/>
                            </div>

                            <div class="form-item">
                                <label>Ngày bắt đầu</label>
                                <input type="date" name="startDate"
                                       value="${voucherToEdit.startDate}" required/>
                            </div>

                            <div class="form-item">
                                <label>Ngày kết thúc</label>
                                <input type="date" name="endDate"
                                       value="${voucherToEdit.endDate}" required/>
                            </div>

                            <div class="form-item textarea-full">
                                <label>Mô tả</label>
                                <textarea name="description">${voucherToEdit.description}</textarea>
                            </div>
                        </div>

                        <div style="margin-top:20px;text-align:right">
                            <button class="btn-primary" type="submit">
                                <i class="fa-solid fa-save"></i>
                                <c:choose>
                                    <c:when test="${param.action == 'add'}">Thêm</c:when>
                                    <c:otherwise>Cập nhật</c:otherwise>
                                </c:choose>
                            </button>
                        </div>
                    </form>
                </div>
            </c:if>
        </aside>
    </div>
</div>
</body>
</html>
