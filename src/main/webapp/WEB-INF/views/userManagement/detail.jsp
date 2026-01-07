<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../includes/admin_header.jsp" />

<div class="content-wrapper">
    <section class="content">
        <div class="container-fluid">

            <!-- ================= 사용자 상세 ================= -->
            <div class="card card-outline card-info">
                <div class="card-header">
                    <h3 class="card-title">사용자 상세</h3>
                </div>

                <div class="card-body">
                    <table class="table table-bordered">
                        <tr>
                            <th style="width: 200px;">사용자 ID</th>
                            <td>${user.userId}</td>
                        </tr>
                        <tr>
                            <th>아이디</th>
                            <td>${user.loginId}</td>
                        </tr>
                        <tr>
                            <th>이름</th>
                            <td>${user.name}</td>
                        </tr>
                        <tr>
                            <th>지점</th>
                            <td>${user.branchName}</td>
                        </tr>
                        <tr>
                            <th>부서</th>
                            <td>${user.departmentName}</td>
                        </tr>
                        <tr>
                            <th>권한</th>
                            <td>
                                <span class="badge bg-info text-dark">
                                    ${user.roleName}
                                </span>
                            </td>
                        </tr>
                        <tr>
                            <th>상태</th>
                            <td>
                                <c:choose>
                                    <c:when test="${user.userStatusCode eq 'US001'}">
                                        <span class="badge bg-success">정상</span>
                                    </c:when>
                                    <c:when test="${user.userStatusCode eq 'US002'}">
                                        <span class="badge bg-secondary">비활성</span>
                                    </c:when>
                                    <c:when test="${user.userStatusCode eq 'US003'}">
                                        <span class="badge bg-danger">정지</span>
                                    </c:when>
                                    <c:when test="${user.userStatusCode eq 'US004'}">
                                        <span class="badge bg-warning text-dark">휴면</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-light text-dark">알 수 없음</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                        <tr>
                            <th>로그인 실패 횟수</th>
                            <td>${user.failCount}</td>
                        </tr>
                        <tr>
                            <th>등록일</th>
                            <td>${user.createDate}</td>
                        </tr>
                    </table>
                </div>

                <div class="card-footer text-right">
                    <a href="/userManagement/list" class="btn btn-secondary">
                        목록
                    </a>
                    <a href="/userManagement/edit?userId=${user.userId}"
                       class="btn btn-primary">
                        수정
                    </a>
                </div>
            </div>

            <!-- ================= 사용자 상태 변경 ================= -->
            <div class="card card-outline card-warning mt-3">
                <div class="card-header">
                    <h3 class="card-title">사용자 상태 변경</h3>
                </div>

                <div class="card-body text-center">
                    <form action="/userManagement/status" method="post">
                        <input type="hidden" name="userId" value="${user.userId}" />

                        <div class="btn-group">
                            <button type="submit"
                                    name="statusCode"
                                    value="US001"
                                    class="btn btn-success">
                                정상
                            </button>

                            <button type="submit"
                                    name="statusCode"
                                    value="US002"
                                    class="btn btn-secondary">
                                비활성
                            </button>

                            <button type="submit"
                                    name="statusCode"
                                    value="US003"
                                    class="btn btn-danger">
                                정지
                            </button>

                            <button type="submit"
                                    name="statusCode"
                                    value="US004"
                                    class="btn btn-warning">
                                휴면
                            </button>
                        </div>
                    </form>
                </div>
            </div>

			<!-- 비밀번호 초기화 -->
			<div class="card card-outline card-danger mt-3">
			    <div class="card-header">
			        <h3 class="card-title">비밀번호 초기화</h3>
			    </div>
			
			    <div class="card-body text-center">
			        <form action="/userManagement/reset-password" method="post"
			              onsubmit="return confirm('비밀번호를 초기화하시겠습니까?');">
			            <input type="hidden" name="userId" value="${user.userId}" />
			            <button type="submit" class="btn btn-danger">
			                비밀번호 초기화
			            </button>
			        </form>
			        <small class="text-muted d-block mt-2">
			            초기 비밀번호는 <b>아이디 + !123</b> 으로 설정됩니다.
			        </small>
			    </div>
			</div>

            <!-- ================= 변경 이력 ================= -->
            <div class="card card-outline card-secondary mt-3">
                <div class="card-header">
                    <h3 class="card-title">변경 이력</h3>
                </div>

                <div class="card-body">

                    <ul class="nav nav-tabs" role="tablist">
                        <li class="nav-item">
                            <a class="nav-link active" data-bs-toggle="tab"
                               href="#tab-basic">기본정보</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" data-bs-toggle="tab"
                               href="#tab-branch">지점</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" data-bs-toggle="tab"
                               href="#tab-role">권한</a>
                        </li>
                    </ul>

                    <div class="tab-content mt-3">

                        <!-- 기본정보 / 상태 -->
                        <div class="tab-pane fade show active" id="tab-basic">
                            <table class="table table-sm table-bordered">
                                <tr>
                                    <th>항목</th>
                                    <th>이전</th>
                                    <th>변경</th>
                                    <th>사유</th>
                                    <th>일시</th>
                                </tr>
                                <c:forEach var="h" items="${historyList}">
                                    <tr>
                                        <td>${h.changeType}</td>
                                        <td>${h.beforeValue}</td>
                                        <td>${h.afterValue}</td>
                                        <td>${h.reason}</td>
                                        <td>${h.createDate}</td>
                                    </tr>
                                </c:forEach>
                            </table>
                        </div>

                        <!-- 지점 -->
                        <div class="tab-pane fade" id="tab-branch">
                            <table class="table table-sm table-bordered">
                                <tr>
                                    <th>이전 지점</th>
                                    <th>변경 지점</th>
                                    <th>사유</th>
                                    <th>일시</th>
                                </tr>
                                <c:forEach var="b" items="${branchLogList}">
                                    <tr>
                                        <td>${b.beforeBranchId}</td>
                                        <td>${b.afterBranchId}</td>
                                        <td>${b.reason}</td>
                                        <td>${b.createDate}</td>
                                    </tr>
                                </c:forEach>
                            </table>
                        </div>

                        <!-- 권한 -->
                        <div class="tab-pane fade" id="tab-role">
                            <table class="table table-sm table-bordered">
                                <tr>
                                    <th>이전 권한</th>
                                    <th>변경 권한</th>
                                    <th>사유</th>
                                    <th>일시</th>
                                </tr>
                                <c:forEach var="r" items="${roleLogList}">
                                    <tr>
                                        <td>${r.beforeRoleCode}</td>
                                        <td>${r.afterRoleCode}</td>
                                        <td>${r.reason}</td>
                                        <td>${r.createDate}</td>
                                    </tr>
                                </c:forEach>
                            </table>
                        </div>

                    </div>
                </div>
            </div>

        </div>
    </section>
</div>

<jsp:include page="../includes/admin_footer.jsp" />
