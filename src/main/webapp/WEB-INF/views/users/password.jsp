<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../includes/admin_header.jsp" />

<div class="content-wrapper p-4">

    <section class="content">
        <div class="row justify-content-center">
            <div class="col-md-5">

                <!-- 알림 -->
                <c:if test="${not empty errorMessage}">
                    <div class="alert alert-danger alert-dismissible fade show">
                        ${errorMessage}
                        <button class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <div class="card card-outline card-danger">
                    <div class="card-header text-center">
                        <h3><b>비밀번호 변경</b></h3>
                    </div>

                    <div class="card-body">
                        <form action="<c:url value='/users/passwordProc'/>" method="post">

                            <div class="mb-3">
                                <label class="form-label">현재 비밀번호</label>
                                <input type="password" name="currentPassword"
                                       class="form-control" required>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">새 비밀번호</label>
                                <input type="password" name="newPassword"
                                       class="form-control" required>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">새 비밀번호 확인</label>
                                <input type="password" name="confirmPassword"
                                       class="form-control" required>
                            </div>

                            <div class="d-grid">
                                <button type="submit" class="btn btn-danger">
                                    비밀번호 변경
                                </button>
                            </div>

                        </form>
                    </div>
                </div>

            </div>
        </div>
    </section>

</div>

<jsp:include page="../includes/admin_footer.jsp" />
