<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!doctype html>
<html lang="ko">
<head>
    <meta charset="utf-8">
    <title>회원가입</title>

    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- AdminLTE / Bootstrap -->
    <link rel="stylesheet" href="<c:url value='/css/adminlte.css'/>">
    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.1/font/bootstrap-icons.min.css">
</head>

<body class="register-page bg-body-secondary">

<div class="register-box">
    <div class="card card-outline card-primary">
        <div class="card-header text-center">
            <h1 class="mb-0"><b>그룹웨어</b></h1>
            <small class="text-muted">회원가입</small>
        </div>

        <div class="card-body register-card-body">
            <p class="login-box-msg">아래 정보를 입력하세요</p>

            <form action="<c:url value='/users/joinProc'/>" method="post">

                <!-- 아이디 -->
                <div class="input-group mb-3">
                    <div class="input-group-text">
                        <span class="bi bi-person"></span>
                    </div>
                    <input type="text" name="loginId" class="form-control" placeholder="아이디(필수 입력)" required>
                </div>

                <!-- 비밀번호 -->
                <div class="input-group mb-3">
                    <div class="input-group-text">
                        <span class="bi bi-lock-fill"></span>
                    </div>
                    <input type="password" name="password" class="form-control" placeholder="비밀번호(필수 입력)" required>
                </div>

                <!-- 이름 -->
                <div class="input-group mb-3">
                    <div class="input-group-text">
                        <span class="bi bi-card-text"></span>
                    </div>
                    <input type="text" name="name" class="form-control" placeholder="이름(필수 입력)" required>
                </div>

                <!-- 이메일 -->
                <div class="input-group mb-3">
                    <div class="input-group-text">
                        <span class="bi bi-envelope"></span>
                    </div>
                    <input type="email" name="email" class="form-control" placeholder="이메일(필수 입력)" required>
                </div>

                <!-- 전화번호 -->
                <div class="input-group mb-3">
                    <div class="input-group-text">
                        <span class="bi bi-telephone"></span>
                    </div>
                    <input type="text" name="phone" class="form-control" placeholder="전화번호">
                </div>
                
				<!-- 부서 코드 (SELECT) -->
				<div class="input-group mb-3">
				    <div class="input-group-text">
				        <span class="bi bi-diagram-3"></span>
				    </div>
				    <select name="departmentCode" class="form-select">
				        <option value="" selected>부서 없음(선택)</option>
					        <option value="DP001">시스템관리팀</option>
					        <option value="DP002">지점운영팀</option>
					        <option value="DP003">회원관리팀</option>
					        <option value="DP004">구매·발주팀</option>
					        <option value="DP005">정산·회계팀</option>
					        <option value="DP006">기획·공지팀</option>
					        <option value="DP007">일정관리팀</option>
					    </select>
					</div>
				
				<!-- 소속 지점 ID (수기 입력) -->
				<div class="input-group mb-3">
				    <div class="input-group-text">
				        <span class="bi bi-building"></span>
				    </div>
				    <input type="number" name="branchId" class="form-control" placeholder="소속 지점 ID (예: 1), (필수입력)" min="1" required>
				</div>
				
				<div class="mb-3">
		        <button type="button"
		                class="btn btn-outline-primary"
		                onclick="execDaumPostcode()">
		            <i class="bi bi-search"></i> 주소 검색
		        </button>
		        </div>
        
                <!-- 우편번호 -->
                <div class="input-group mb-3">
                    <div class="input-group-text">
                        <span class="bi bi-geo-alt"></span>
                    </div>
                    <input type="text" name="postNo" id="postNo" class="form-control" placeholder="우편번호(필수 입력)" required>
                </div>
				
                <!-- 기본주소 -->
                <div class="input-group mb-3">
                    <div class="input-group-text">
                        <span class="bi bi-house"></span>
                    </div>
                    <input type="text" name="baseAddress" id="baseAddress" class="form-control" placeholder="기본 주소(필수 입력)" required>
                </div>

                <!-- 상세주소 -->
                <div class="input-group mb-3">
                    <div class="input-group-text">
                        <span class="bi bi-building"></span>
                    </div>
                    <input type="text" name="detailAddress" id="detailAddress" class="form-control" placeholder="상세 주소">
                </div>
                
                
                
                <!-- 버튼 -->
                <div class="row">
                    <div class="col-12 d-grid">
                        <button type="submit" class="btn btn-primary">
                            <i class="bi bi-person-plus"></i> 가입하기
                        </button>
                    </div>
                </div>
            </form>

            <div class="mt-3 text-center">
                <a href="<c:url value='/login'/>">이미 계정이 있으신가요? 로그인</a>
            </div>
        </div>
    </div>
</div>

<!-- AdminLTE JS -->
<!-- 카카오 주소 API -->
<script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>

<script src="<c:url value='/js/address.js'/>"></script>

<script>
document.addEventListener("DOMContentLoaded", function () {

    document.getElementById("postNo")
        .addEventListener("keydown", e => e.preventDefault());

    document.getElementById("baseAddress")
        .addEventListener("keydown", e => e.preventDefault());

});
</script>

<script src="<c:url value='/js/adminlte.js'/>"></script>

</body>
</html>
