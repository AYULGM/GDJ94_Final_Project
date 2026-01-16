<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../includes/admin_header.jsp" />

<div class="content-wrapper">

    <!-- Main content -->
    <section class="content">
        <div class="container-fluid">

            <div class="card">
                <div class="card-header">
                    <h3 class="card-title">사용자 목록</h3>

                    <div class="card-tools">
                        <a href="./add" class="btn btn-primary">
                            <i class="fas fa-user-plus"></i> 사용자 등록
                        </a>
                    </div>
                </div>

                <div class="card-body">
                    <table class="table table-bordered table-hover">
                        <thead class="thead-light">
                            <tr class="text-center">
                                <th style="width: 50px;">No</th>
                                <th>아이디</th>
                                <th>이름</th>
                                <th>지점</th>
                                <th>부서</th>
                                <th>권한</th>
                                <th>상태</th>
                                <th>로그인 실패횟수</th>
                                <th style="width: 120px;">관리</th>
                            </tr>
                        </thead>

                        <tbody>
                        <c:if test="${empty users}">
                            <tr>
                                <td colspan="9" class="text-center text-muted">
                                    등록된 사용자가 없습니다.
                                </td>
                            </tr>
                        </c:if>

                        <c:forEach var="u" items="${users}" varStatus="st">
                            <tr class="text-center">
                                <td>${u.userId}</td>
                                <td>${u.loginId}</td>
                                <td>${u.name}</td>
                                <td>${u.branchName}</td>
                                <td>${u.departmentName}</td>
                                
							<td>
								<c:choose>
								    <c:when test="${u.roleCode eq 'RL001'}">
								        <span class="badge bg-danger">${u.roleName}</span>
								    </c:when>
								
								    <c:when test="${u.roleCode eq 'RL002'}">
								        <span class="badge bg-warning text-dark">${u.roleName}</span>
								    </c:when>
								
								    <c:when test="${u.roleCode eq 'RL003'}">
								        <span class="badge bg-primary">${u.roleName}</span>
								    </c:when>
								
								    <c:when test="${u.roleCode eq 'RL004'}">
								        <span class="badge bg-success">${u.roleName}</span>
								    </c:when>
								
								    <c:when test="${u.roleCode eq 'RL005'}">
								        <span class="badge bg-secondary">${u.roleName}</span>
								    </c:when>
								
								    <c:otherwise>
								        <span class="badge bg-light text-dark">${u.roleName}</span>
								    </c:otherwise>
								</c:choose>
							</td>
							
                                <td>
									<c:choose>
									    <c:when test="${u.userStatusCode eq 'US001'}">
									        <span class="badge bg-success">정상</span>
									    </c:when>
									
									    <c:when test="${u.userStatusCode eq 'US002'}">
									        <span class="badge bg-secondary">비활성</span>
									    </c:when>
									
									    <c:when test="${u.userStatusCode eq 'US003'}">
									        <span class="badge bg-danger">정지</span>
									    </c:when>
									
									    <c:when test="${u.userStatusCode eq 'US004'}">
									        <span class="badge bg-warning text-dark">휴면</span>
									    </c:when>
									
									    <c:otherwise>
									        <span class="badge bg-light text-dark">알 수 없음</span>
									    </c:otherwise>
									</c:choose>

                                </td>
                                <td>${u.failCount}</td>
                                <td>
                                    <a href="/userManagement/detail?userId=${u.userId}"
                                       class="btn btn-xs btn-info">
                                        상세
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </section>
</div>

<jsp:include page="../includes/admin_footer.jsp" />
