<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

<!doctype html>
<html lang="en">
  <!--begin::Head-->
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>로그인</title>
    <!--begin::Accessibility Meta Tags-->
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes" />
    <meta name="color-scheme" content="light dark" />
    <meta name="theme-color" content="#007bff" media="(prefers-color-scheme: light)" />
    <meta name="theme-color" content="#1a1a1a" media="(prefers-color-scheme: dark)" />
    <!--end::Accessibility Meta Tags-->
    <!--begin::Fonts-->
    <link
      rel="stylesheet"
      href="https://cdn.jsdelivr.net/npm/@fontsource/source-sans-3@5.0.12/index.css"
      integrity="sha256-tXJfXfp6Ewt1ilPzLDtQnJV4hclT9XuaZUKyUvmyr+Q="
      crossorigin="anonymous"
      media="print"
      onload="this.media='all'"
    />
    <!--end::Fonts-->
    <!--begin::Third Party Plugin(Bootstrap Icons)-->
    <link
      rel="stylesheet"
      href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.1/font/bootstrap-icons.min.css"
      crossorigin="anonymous"
    />
    <!--end::Third Party Plugin(Bootstrap Icons)-->
    <!--begin::Required Plugin(AdminLTE)-->
    <link rel="stylesheet" href="<c:url value='/css/adminlte.css'/>" />
    <!--end::Required Plugin(AdminLTE)-->
  </head>
  <!--end::Head-->
  <!--begin::Body-->
  <body class="login-page bg-body-secondary">
    <div class="login-box">
      <div class="card card-outline card-primary">
        <div class="card-header">
          <a
            href="<c:url value='/'/>"
            class="link-dark text-center link-offset-2 link-opacity-100 link-opacity-50-hover"
          >
            <h1 class="mb-0"><b>그룹웨어</b></h1>
          </a>
        </div>
        <div class="card-body login-card-body">
            <!-- ✅ 여기: 알림 메시지 영역 -->

    		<!-- 비밀번호 변경 성공 -->
            <c:if test="${not empty successMessage}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="bi bi-check-circle-fill"></i>
            ${successMessage}
            <button type="button"
                    class="btn-close"
                    data-bs-dismiss="alert"></button>
        </div>
    		</c:if>
    		
    		    <!-- 회원 탈퇴 완료 -->
		    <c:if test="${param.withdraw != null}">
		        <div class="alert alert-warning alert-dismissible fade show" role="alert">
		            <i class="bi bi-info-circle-fill"></i>
		            회원 탈퇴가 정상적으로 처리되었습니다.
		            <button class="btn-close" data-bs-dismiss="alert"></button>
		        </div>
		    </c:if>
    
              <!-- 🔽 로그인 안내 문구 -->
    		<p class="login-box-msg">로그인 해주세요</p>
          
          <!-- 🔽 로그인 폼 -->
          <form action="<c:url value='/login'/>" method="post">
            <sec:csrfInput/>

			  <c:if test="${param.error eq 'true'}">
			    <div class="alert alert-danger py-2">
			      로그인 실패:
			      <c:out value="${param.reason}" />
			    </div>
			  </c:if>
			
			  <c:if test="${param.logout eq 'true'}">
			    <div class="alert alert-info py-2">
			      로그아웃 되었습니다.
			    </div>
			  </c:if>
          
            <div class="input-group mb-1">
              <div class="form-floating">
                <input id="loginId" name="loginId" type="text" class="form-control" placeholder="Username" />
                <label for="loginId">아이디</label>
              </div>
              <div class="input-group-text"><span class="bi bi-person"></span></div>
            </div>
            <div class="input-group mb-1">
              <div class="form-floating">
                <input id="password" name="password" type="password" class="form-control" placeholder="Password" />
                <label for="password">비밀번호</label>
              </div>
              <div class="input-group-text"><span class="bi bi-lock-fill"></span></div>
            </div>
            <!--begin::Row-->
            <div class="row">
              <div class="col-8 d-inline-flex align-items-center">
                <div class="form-check">
                  <input class="form-check-input" type="checkbox" id="rememberMe" name="remember-me" value="on"/>
                  <label class="form-check-label" for="rememberMe"> 자동 로그인 </label>
                </div>
              </div>
              <!-- /.col -->
              
              
              <div class="col-4">
                <div class="d-grid gap-2">
                  <button type="submit" class="btn btn-primary">로그인</button>
                </div>
              </div>
              <!-- /.col -->
            </div>
            <!--end::Row-->
          </form>
			<p class="mb-1">
  				<a href="<c:url value='/users/join'/>">회원가입</a>
			</p>
          <p class="mb-1">
			    <a href="<c:url value='/users/password/find'/>">
			        비밀번호를 잊으셨나요?
			    </a>
		  </p>
        </div>
        <!-- /.login-card-body -->
      </div>
    </div>
    <!-- /.login-box -->
    <!--begin::Required Plugin(Bootstrap 5)-->
    <script
      src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/js/bootstrap.bundle.min.js"
      crossorigin="anonymous"
    ></script>
    <!--end::Required Plugin(Bootstrap 5)-->
    <!--begin::Required Plugin(AdminLTE)-->
    <script src="<c:url value='/js/adminlte.js'/>"></script>
    <!--end::Required Plugin(AdminLTE)-->
  </body>
  <!--end::Body-->
</html>
