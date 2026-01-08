<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

<!doctype html>
<html lang="ko">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>비밀번호 찾기</title>

    <meta name="viewport" content="width=device-width, initial-scale=1.0" />

    <!-- Fonts -->
    <link
      rel="stylesheet"
      href="https://cdn.jsdelivr.net/npm/@fontsource/source-sans-3@5.0.12/index.css"
      crossorigin="anonymous"
      media="print"
      onload="this.media='all'"
    />

    <!-- Bootstrap Icons -->
    <link
      rel="stylesheet"
      href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.1/font/bootstrap-icons.min.css"
      crossorigin="anonymous"
    />

    <!-- AdminLTE -->
    <link rel="stylesheet" href="<c:url value='/css/adminlte.css'/>" />
  </head>

  <body class="login-page bg-body-secondary">
    <div class="login-box">
      <div class="card card-outline card-primary">

        <!-- 헤더 -->
        <div class="card-header text-center">
          <a href="<c:url value='/'/>" class="link-dark">
            <h1 class="mb-0"><b>그룹웨어</b></h1>
          </a>
        </div>

        <!-- 바디 -->
        <div class="card-body login-card-body">

          <!-- 안내 문구 -->
          <p class="login-box-msg">
            비밀번호를 잊으셨나요?<br/>
            가입 시 사용한 정보를 입력해주세요.
          </p>

          <!-- 에러 메시지 -->
          <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
              <i class="bi bi-exclamation-triangle-fill"></i>
              ${errorMessage}
              <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
          </c:if>

          <!-- 성공 메시지 -->
          <c:if test="${not empty successMessage}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
              <i class="bi bi-check-circle-fill"></i>
              ${successMessage}
              <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
          </c:if>

          <!-- 비밀번호 찾기 폼 -->
          <form action="<c:url value='/users/password/findProc'/>" method="post">
            <sec:csrfInput/>

            <!-- 아이디 -->
            <div class="input-group mb-3">
              <div class="form-floating">
                <input
                  type="text"
                  name="loginId"
                  id="loginId"
                  class="form-control"
                  placeholder="아이디"
                  required
                />
                <label for="loginId">아이디</label>
              </div>
              <div class="input-group-text">
                <span class="bi bi-person"></span>
              </div>
            </div>

            <!-- 이메일 -->
            <div class="input-group mb-3">
              <div class="form-floating">
                <input
                  type="email"
                  name="email"
                  id="email"
                  class="form-control"
                  placeholder="이메일"
                  required
                />
                <label for="email">이메일</label>
              </div>
              <div class="input-group-text">
                <span class="bi bi-envelope-fill"></span>
              </div>
            </div>

            <!-- 버튼 -->
            <div class="d-grid gap-2">
              <button type="submit" class="btn btn-primary">
                임시 비밀번호 발급
              </button>
            </div>
          </form>

          <!-- 하단 링크 -->
          <p class="mt-3 mb-1 text-center">
            <a href="<c:url value='/login'/>">로그인 페이지로 돌아가기</a>
          </p>

        </div>
      </div>
    </div>

    <!-- JS -->
    <script
      src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/js/bootstrap.bundle.min.js"
      crossorigin="anonymous"
    ></script>
    <script src="<c:url value='/js/adminlte.js'/>"></script>
  </body>
</html>
