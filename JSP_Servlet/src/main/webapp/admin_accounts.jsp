<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ page import="vn.edu.nlu.fit.be.model.AccountStatus" %>

            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8" />
                <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                <title>Admin - Quản lý tài khoản</title>

                <!-- CSS -->
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin_style.css" />
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin_chart.css" />
                <link rel="stylesheet"
                    href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css" />

                <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
            </head>

            <body>

                <div class="dashboard">

                    <!-- SIDEBAR -->

                    <jsp:include page="admin_sidebar.jsp"/>

<!-- CONTENT -->
                    <div class="content-wrapper">
                        <main class="main">
                            <div class="product-header">
                                <h2>Quản lý tài khoản</h2>
                                <a class="btn-add" href="${pageContext.request.contextPath}/admin/accounts/add">
                                    <i class="fa-solid fa-plus"></i> Thêm tài khoản
                                </a>
                            </div>

                            <!-- SEARCH BAR -->
                            <form action="${pageContext.request.contextPath}/admin/accounts" method="get"
                                class="search-box">
                                <input type="text" name="search" placeholder="Tìm kiếm theo username, email..."
                                    value="${param.search}">
                                <i class="fa-solid fa-magnifying-glass"></i>
                            </form>

                            <!-- TABLE -->
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Username</th>
                                        <th>Email</th>
                                        <th>Role</th>
                                        <th>Trạng thái</th>
                                        <th>Hành động</th>
                                    </tr>
                                </thead>

                                <tbody>
                                    <c:forEach var="a" items="${accounts}">
                                        <tr class="account-row" data-id="${a.accountId}"
                                            onmouseenter="showProfile(this)" onmouseleave="hideProfile()">

                                            <td>#${a.accountId}</td>
                                            <td style="font-weight: 500; color: #007BA8;">${a.username}</td>
                                            <td>${a.email}</td>

                                            <td>
                                                <span class="status ${a.role == 1 ? 'on' : 'off'}"
                                                    style="background: ${a.role == 1 ? '#ECF8FD' : '#E7E0EC'}; color: ${a.role == 1 ? '#00658F' : '#49454F'};">
                                                    ${a.role == 1 ? 'Admin' : 'User'}
                                                </span>
                                            </td>

                                            <td>
                                                <form action="${pageContext.request.contextPath}/admin/accounts/status"
                                                    method="post">
                                                    <input type="hidden" name="id" value="${a.accountId}" />
                                                    <select name="status" onchange="this.form.submit()"
                                                        class="status-select ${a.status == 'Active' ? 'success' : 'cancel'}">
                                                        <option value="Active" ${a.status=='Active' ? 'selected' : '' }>
                                                            Active</option>
                                                        <option value="UnActive" ${a.status=='UnActive' ? 'selected'
                                                            : '' }>Block</option>
                                                    </select>
                                                </form>
                                            </td>

                                            <td>
                                                <form action="${pageContext.request.contextPath}/admin/accounts/delete"
                                                    method="post"
                                                    onsubmit="return confirm('Xóa tài khoản này? Hanh dong khong the hoan tac!');"
                                                    style="display: inline-block;">
                                                    <input type="hidden" name="id" value="${a.accountId}">
                                                    <button type="submit" class="btn-small btn-delete" title="Xóa">
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
                </div>
                <!-- PROFILE POPUP -->
                <div id="profile-popup" class="profile-popup"></div>
                <!-- JS -->
                <script>
                    const contextPath = '${pageContext.request.contextPath}';
                </script>
                <script src="${pageContext.request.contextPath}/js/admin_script.js"></script>
            </body>

            </html>
