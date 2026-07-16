<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Khóa bảo mật và Chứng thư số điện tử</title>
    <link rel="icon" type="image/x-icon" href="${pageContext.request.contextPath}/favicon.ico">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/profile.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/securityKey.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body>
<jsp:include page="header.jsp"/>

<div class="pf-page">
    <nav class="pf-breadcrumb">
        <a href="${pageContext.request.contextPath}/">Trang chủ</a>
        <span class="dot">•</span>
        <span>Chữ ký điện tử và chứng thư số</span>
    </nav>

    <div class="pf-container">
        <aside class="pf-sidebar">
            <h2><i class="fas fa-user-circle"></i> ${sessionScope.USER.username}</h2>
            <ul>
                <li onclick="location.href='${pageContext.request.contextPath}/profile'">
                    <i class="fas fa-user"></i> Thông tin cá nhân
                </li>
                <li onclick="location.href='${pageContext.request.contextPath}/bought-product'">
                    <i class="fas fa-shopping-bag"></i> Đơn hàng đã mua
                </li>
                <li onclick="location.href='${pageContext.request.contextPath}/my-favorite'">
                    <i class="fas fa-heart"></i> Sản Phẩm Yêu Thích
                </li>
                <li onclick="location.href='${pageContext.request.contextPath}/change-password'">
                    <i class="fas fa-key"></i> Đổi mật khẩu
                </li>
                <li onclick="location.href='${pageContext.request.contextPath}/security-key'">
                    <i class="fas fa-shield-halved"></i> Chữ ký điện tử và chứng thư số
                </li>
            </ul>
        </aside>

        <main class="pf-content">
            <section class="pf-section pf-section-active">
                <h3><i class="fas fa-shield-halved"></i> Quản lý chữ ký điện tử và chứng thư số</h3>

                <c:if test="${not empty error}">
                    <div class="sk-message error">
                        <i class="fas fa-exclamation-circle"></i> ${error}
                    </div>
                </c:if>

                <c:if test="${param.downloadError == '1'}">
                    <div class="sk-message error">
                        <i class="fas fa-exclamation-circle"></i>
                        Private key không tồn tại hoặc đã được tải trước đó. Nếu bạn đã mất file private key,
                        hãy cấp lại chứng thư mới để nhận private key mới.
                    </div>
                </c:if>

                <c:if test="${param.created == '1'}">
                    <div class="sk-message success">
                        <i class="fas fa-check-circle"></i>
                        Đã tạo chứng thư mới và private key mới tương ứng.
                        <c:if test="${canDownloadPrivateKey}">
                            Vui lòng tải private key mới ngay. Private key cũ sẽ không dùng được với chứng thư mới.
                        </c:if>
                    </div>
                </c:if>

                <c:if test="${param.revoked == '1'}">
                    <div class="sk-message success">
                        <i class="fas fa-check-circle"></i>
                        Chứng thư cũ đã được thu hồi. Hệ thống đã cấp chứng thư mới và private key mới cho bạn.
                        <c:if test="${canDownloadPrivateKey}">
                            Vui lòng tải private key mới trước khi ký đơn hàng tiếp theo.
                        </c:if>
                    </div>
                </c:if>

                <c:if test="${canDownloadPrivateKey}">
                    <div class="sk-message warning">
                        <i class="fas fa-key"></i>
                        <div>
                            <strong>Bạn đang có private key mới chưa tải.</strong>
                            <br>
                            Private key này đi kèm chứng thư hiện tại và chỉ được tải một lần.
                            Nếu mất file này, bạn phải cấp lại chứng thư mới.
                            <br><br>

                            <a class="sk-btn primary"
                               href="${pageContext.request.contextPath}/security-key/download-private-key"
                               onclick="return confirmDownloadPrivateKey(event)">
                                Tải private key mới ngay
                            </a>
                        </div>
                    </div>
                </c:if>

                <div class="sk-card">
                    <div class="sk-card-header">
                        <div>
                            <p class="sk-eyebrow">Trạng thái khóa</p>
                            <h4>
                                <c:choose>
                                    <c:when test="${hasCertificate}">
                                        Bạn đã có chứng thư số đang hoạt động
                                    </c:when>
                                    <c:otherwise>
                                        Bạn chưa có chứng thư số đang hoạt động
                                        <p style="font-size: 0.9rem; font-weight: normal; color: #64748b; margin-top: 0.5rem; max-width: 600px; line-height: 1.5;">
                                            * Chứng thư số và private Key được sử dụng để <strong>ký xác thực điện tử các đơn hàng</strong> của bạn. Điều này giúp đảm bảo tính bảo mật, tính toàn vẹn và không thể chối bỏ giao dịch của bạn với chúng tôi. Hãy tạo chứng thư số và tải Private Key về máy (chỉ tải được 1 lần duy nhất) để tiếp tục thực hiện việc đặt hàng an toàn!
                                        </p>
                                    </c:otherwise>
                                </c:choose>
                            </h4>
                        </div>

                        <c:if test="${hasCertificate}">
                            <c:set var="statusClass" value="status-active"/>
                            <c:if test="${certificate.status == 'REVOKED'}">
                                <c:set var="statusClass" value="status-revoked"/>
                            </c:if>
                            <c:if test="${certificate.status == 'EXPIRED'}">
                                <c:set var="statusClass" value="status-expired"/>
                            </c:if>
                            <span class="sk-status-pill ${statusClass}">${certificate.status}</span>
                        </c:if>
                    </div>

                    <div class="sk-info-grid">
                        <div class="sk-info-item">
                            <span>Serial number</span>
                            <strong>
                                <c:choose>
                                    <c:when test="${hasCertificate}">
                                        ${certificate.serialNumber}
                                    </c:when>
                                    <c:otherwise>Chưa có</c:otherwise>
                                </c:choose>
                            </strong>
                        </div>

                        <div class="sk-info-item">
                            <span>Trạng thái chứng thư</span>
                            <strong>
                                <c:choose>
                                    <c:when test="${hasCertificate}">
                                        ${certificate.status}
                                    </c:when>
                                    <c:otherwise>Chưa có</c:otherwise>
                                </c:choose>
                            </strong>
                        </div>

                        <div class="sk-info-item">
                            <span>Ngày tạo khóa</span>
                            <strong>
                                <c:choose>
                                    <c:when test="${hasCertificate}">
                                        ${certificate.issuedAt}
                                    </c:when>
                                    <c:otherwise>Chưa có</c:otherwise>
                                </c:choose>
                            </strong>
                        </div>

                        <div class="sk-info-item">
                            <span>Ngày hết hạn</span>
                            <strong>
                                <c:choose>
                                    <c:when test="${hasCertificate}">
                                        ${certificate.expiredAt}
                                    </c:when>
                                    <c:otherwise>Chưa có</c:otherwise>
                                </c:choose>
                            </strong>
                        </div>
                    </div>

                    <div class="sk-actions">

                        <button type="button" class="sk-btn primary" onclick="showCreateModal()">
                            <i class="fas fa-plus-circle"></i>
                            <c:choose>
                                <c:when test="${hasCertificate}">
                                    Tạo lại chứng thư và private key
                                </c:when>
                                <c:otherwise>
                                    Tạo chứng thư và private key
                                </c:otherwise>
                            </c:choose>
                        </button>

                        <c:if test="${hasCertificate}">
                            <button type="button" class="sk-btn danger" onclick="showRevokeModal()">
                                <i class="fas fa-triangle-exclamation"></i>
                                Tôi đã mất private key
                            </button>
                        </c:if>

                        <button type="button"
                                class="sk-btn"
                                onclick="window.location.href='${pageContext.request.contextPath}/signing-tool/download'">
                            <i class="fas fa-toolbox"></i>
                            Tải tool ký
                        </button>
                    </div>

                <div class="sk-history">
                    <h4><i class="fas fa-clock-rotate-left"></i> Lịch sử chứng thư</h4>
                    <div class="sk-history-table-wrap">
                        <table class="sk-history-table">
                            <thead>
                            <tr>
                                <th>Serial</th>
                                <th>Trạng thái</th>
                                <th>Ngày tạo</th>
                                <th>Hết hạn</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:if test="${hasCertificate}">
                                <tr>
                                    <td>${certificate.serialNumber}</td>
                                    <td>
                                        <span class="sk-status-pill sk-status-inline status-active">${certificate.status}</span>
                                    </td>
                                    <td><fmt:formatDate value="${certificate.issuedAt}" pattern="dd/MM/yyyy"/></td>
                                    <td><fmt:formatDate value="${certificate.expiredAt}" pattern="dd/MM/yyyy"/></td>
                                </tr>
                            </c:if>

                            <c:forEach var="revoked" items="${revokedCertificates}">
                                <tr>
                                    <td>${revoked.serialNumber}</td>
                                    <td>
                                        <span class="sk-status-pill sk-status-inline status-revoked">${revoked.status}</span>
                                    </td>
                                    <td><fmt:formatDate value="${revoked.issuedAt}" pattern="dd/MM/yyyy"/></td>
                                    <td><fmt:formatDate value="${revoked.expiredAt}" pattern="dd/MM/yyyy"/></td>
                                </tr>
                            </c:forEach>

                            <c:if test="${not hasCertificate and empty revokedCertificates}">
                                <tr>
                                    <td colspan="4">Chưa có lịch sử chứng thư.</td>
                                </tr>
                            </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </main>
    </div>
</div>

<jsp:include page="footer.jsp"/>

<form id="createKeyForm" method="post" action="${pageContext.request.contextPath}/security-key/create"
      style="display:none"></form>
<form id="revokeKeyForm" method="post" action="${pageContext.request.contextPath}/security-key/revoke"
      style="display:none"></form>

<script>
    function showCreateModal() {
        Swal.fire({
            title: 'Tạo lại chứng thư và private key?',
            html:
                '<div style="text-align:left; line-height:1.6">' +
                '<p>Hệ thống sẽ tạo <strong>cặp khóa RSA mới</strong> và <strong>chứng thư mới</strong> cho bạn.</p>' +
                '<p>Private key mới sẽ đi kèm với chứng thư mới. Private key cũ sẽ không dùng được với chứng thư mới.</p>' +
                '<p>Nếu bạn đang có chứng thư cũ, chứng thư đó sẽ bị thu hồi.</p>' +
                '<p><strong>Lưu ý:</strong> private key mới chỉ được tải một lần sau khi tạo.</p>' +
                '</div>',
            icon: 'question',
            showCancelButton: true,
            confirmButtonText: 'Xác nhận tạo mới',
            cancelButtonText: 'Hủy',
            confirmButtonColor: '#007BA8',
            cancelButtonColor: '#64748b'
        }).then((result) => {
            if (result.isConfirmed) {
                document.getElementById('createKeyForm').submit();
            }
        });
    }

    function showRevokeModal() {
        Swal.fire({
            title: 'Bạn đã mất private key?',
            html:
                '<div style="text-align:left; line-height:1.6">' +
                '<p>Khi mất private key, bạn không thể ký đơn hàng bằng chứng thư hiện tại nữa.</p>' +
                '<p>Hệ thống sẽ thu hồi chứng thư cũ, sau đó cấp <strong>chứng thư mới</strong> và <strong>private key mới</strong>.</p>' +
                '<p>Sau khi cấp lại, bạn bắt buộc phải tải private key mới để ký đơn hàng về sau.</p>' +
                '</div>',
            icon: 'warning',
            showCancelButton: true,
            confirmButtonText: 'Thu hồi và cấp lại',
            cancelButtonText: 'Hủy',
            confirmButtonColor: '#ef4444',
            cancelButtonColor: '#64748b'
        }).then((result) => {
            if (result.isConfirmed) {
                document.getElementById('revokeKeyForm').submit();
            }
        });
    }

    function confirmDownloadPrivateKey(event) {
        event.preventDefault();

        const downloadUrl = event.currentTarget.href;

        Swal.fire({
            title: 'Tải private key mới?',
            html:
                '<div style="text-align:left; line-height:1.6">' +
                '<p>Private key này chỉ được tải <strong>một lần duy nhất</strong>.</p>' +
                '<p>Sau khi tải thành công, hệ thống sẽ xóa file private key khỏi server.</p>' +
                '<p>Hãy lưu file ở nơi an toàn. Nếu mất file này, bạn phải cấp lại chứng thư mới.</p>' +
                '</div>',
            icon: 'warning',
            showCancelButton: true,
            confirmButtonText: 'Tải ngay',
            cancelButtonText: 'Hủy',
            confirmButtonColor: '#007BA8',
            cancelButtonColor: '#64748b'
        }).then(async (result) => {
            if (!result.isConfirmed) {
                return;
            }

            try {
                Swal.fire({
                    title: 'Đang tải private key...',
                    text: 'Vui lòng chờ trong giây lát.',
                    allowOutsideClick: false,
                    allowEscapeKey: false,
                    didOpen: () => {
                        Swal.showLoading();
                    }
                });

                const response = await fetch(downloadUrl, {
                    method: 'GET',
                    credentials: 'same-origin'
                });

                if (response.redirected) {
                    window.location.href = response.url;
                    return;
                }

                if (!response.ok) {
                    throw new Error('Không thể tải private key.');
                }

                const blob = await response.blob();

                let fileName = 'private.key';
                const contentDisposition = response.headers.get('Content-Disposition');

                if (contentDisposition) {
                    const match = contentDisposition.match(/filename="?([^"]+)"?/);
                    if (match && match[1]) {
                        fileName = match[1];
                    }
                }

                const blobUrl = window.URL.createObjectURL(blob);
                const link = document.createElement('a');

                link.href = blobUrl;
                link.download = fileName;
                document.body.appendChild(link);
                link.click();

                document.body.removeChild(link);
                window.URL.revokeObjectURL(blobUrl);

                await Swal.fire({
                    title: 'Đã tải private key',
                    text: 'Trang sẽ được làm mới để cập nhật trạng thái.',
                    icon: 'success',
                    confirmButtonText: 'OK',
                    confirmButtonColor: '#007BA8',
                    timer: 1500,
                    timerProgressBar: true
                });
                // After 1.5 seconds reload
                setTimeout(() => {
                    window.location.replace('${pageContext.request.contextPath}/security-key');
                }, 3000);

            } catch (error) {
                Swal.fire({
                    title: 'Tải private key thất bại',
                    text: error.message || 'Private key không tồn tại hoặc đã được tải trước đó.',
                    icon: 'error',
                    confirmButtonText: 'Đóng',
                    confirmButtonColor: '#ef4444'
                }).then(() => {
                    setTimeout(() => {
                        window.location.replace('${pageContext.request.contextPath}/security-key?downloadError=1');
                    }, 3000);
                });
            }
        });

        return false;
    }

    <c:if test="${param.lostKey == '1'}">
    showRevokeModal();
    </c:if>
</script>
</body>
</html>
