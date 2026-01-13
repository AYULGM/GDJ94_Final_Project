<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

<jsp:include page="../includes/admin_header.jsp" />
<!doctype html>
<html lang="ko">
<head>
    <meta charset="utf-8">
    <title>마이페이지</title>

    <!-- AdminLTE CSS -->
    <link rel="stylesheet" href="<c:url value='/css/adminlte.css'/>">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.1/font/bootstrap-icons.min.css">
</head>

<body class="hold-transition sidebar-mini">
<div class="wrapper">

    <!-- ======================
         Content Wrapper
         ====================== -->
    <div class="content-wrapper p-4">

        <!-- 페이지 제목 -->
        <section class="content-header">
            <h1>마이페이지</h1>
        </section>

        <!-- ======================
             사용자 정보 카드
             ====================== -->
        <section class="content">
        
        <c:if test="${not empty successMessage}">
		    <div class="alert alert-success alert-dismissible fade show" role="alert">
		        <i class="bi bi-check-circle-fill"></i>
		        ${successMessage}
		        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
		    </div>
		</c:if>
		
            <div class="card card-primary card-outline">
                <div class="card-body">

                    <h4 class="mb-3">
                        <i class="bi bi-person-circle"></i>
                        내 정보
                    </h4>

					<table class="table table-bordered">
					    <tr>
					        <th style="width: 200px;">로그인 ID</th>
					        <td>${user.loginId}</td>
					    </tr>
					
					    <tr>
					        <th>이름</th>
					        <td>${user.name}</td>
					    </tr>
					
					    <tr>
					        <th>이메일</th>
					        <td>${user.email}</td>
					    </tr>
					
					    <tr>
					        <th>전화번호</th>
					        <td>${user.phone}</td>
					    </tr>
					
					    <tr>
					        <th>부서</th>
					        <td>
					            <c:choose>
					                <c:when test="${empty user.departmentCode}">
					                    부서 없음
					                </c:when>
					                <c:otherwise>
					                    ${user.departmentCode} - ${user.departmentName}
					                </c:otherwise>
					            </c:choose>
					        </td>
					    </tr>
					
					    <tr>
					        <th>소속 지점 ID</th>
					        <td>
					            <c:choose>
					                <c:when test="${empty user.branchId}">
					                    미지정
					                </c:when>
					                <c:otherwise>
					                    ${user.branchId}
					                </c:otherwise>
					            </c:choose>
					        </td>
					    </tr>
					
					    <tr>
					        <th>주소</th>
					        <td>
					            (${user.postNo}) ${user.baseAddress}
					            <c:if test="${not empty user.detailAddress}">
					                , ${user.detailAddress}
					            </c:if>
					        </td>
					    </tr>
					
					    <tr>
					        <th>권한</th>
					        <td>${user.roleCode} - ${user.roleName}</td>
					    </tr>
					
					    <tr>
					        <th>계정 상태</th>
					        <td>정상</td>
					    </tr>
					</table>


                    <div class="mt-4">
                        <a href="<c:url value='/users/update'/>" class="btn btn-warning">
                            <i class="bi bi-pencil"></i> 정보 수정
                        </a>

						<a href="<c:url value='/users/password'/>" class="btn btn-danger ms-2">
						    <i class="bi bi-shield-lock"></i> 비밀번호 변경
						</a>
						
<%-- 					회원 탈퇴기능 없으면 좋겠다 하셔서 일단 주석처리
						<form action="<c:url value='/users/withdraw'/>"
						      method="post"
						      onsubmit="return confirm('정말로 회원 탈퇴하시겠습니까?\n탈퇴 후에는 로그인이 불가능합니다.');"
						      style="display:inline;">
						    <button type="submit" class="btn btn-outline-danger ms-2">
						        <i class="bi bi-person-x"></i> 회원 탈퇴
						    </button>
						</form> --%>
						
                        <a href="<c:url value='/logout'/>" class="btn btn-danger ms-2">
                            <i class="bi bi-box-arrow-right"></i> 로그아웃
                        </a>
                    </div>

                </div>
            </div>
        </section>

    </div>
</div>

<jsp:include page="../includes/admin_footer.jsp" />

</body>
</html>
