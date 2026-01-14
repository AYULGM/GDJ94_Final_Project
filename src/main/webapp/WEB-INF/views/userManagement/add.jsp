<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../includes/admin_header.jsp" />

<div class="content-wrapper">
    <section class="content">
        <div class="container-fluid">
        
        <!-- 에러메시지 출력 -->
        <c:if test="${not empty error}">
		    <div class="alert alert-danger text-center">
		        ${error}
		    </div>
		</c:if>

            <form action="/userManagement/add" method="post">
                <div class="card card-outline card-primary">
                    <div class="card-header">
                        <h3 class="card-title">사용자 등록</h3>
                    </div>

                    <div class="card-body">

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label>아이디</label>
                                <input type="text" name="loginId" class="form-control" required>
                            </div>

                            <div class="col-md-6 mb-3">
                                <label>이름</label>
                                <input type="text" name="name" class="form-control" required>
                            </div>

                            <div class="col-md-6 mb-3">
                                <label>이메일</label>
                                <input type="email" name="email" class="form-control" required>
                            </div>

                            <div class="col-md-6 mb-3">
                                <label>연락처</label>
                                <input type="text" name="phone" class="form-control">
                            </div>

							<div class="col-md-6 mb-3">
							    <label>지점 ID</label>
							    <input type="number"
							           name="branchId"
							           class="form-control"
							           placeholder="지점 ID 입력 (예: 1)"
							           required>
							</div>
							
							<div class="mb-3">
						        <button type="button"
						                class="btn btn-outline-primary"
						                onclick="execDaumPostcode()">
						            <i class="bi bi-search"></i> 주소 검색
						        </button>
					        </div>
		        
							<div class="col-md-6 mb-3">
							    <label>우편번호</label>
							    <input type="text"
							           name="postNo"
							           id="postNo"
							           class="form-control"
							           placeholder="우편번호(필수 입력)"
							           required>
							</div>
							
							<div class="col-md-6 mb-3">
							    <label>기본주소</label>
							    <input type="text"
							           name="baseAddress"
							           id="baseAddress"
							           class="form-control"
							           placeholder="기본 주소(필수 입력)"
							           required>
							</div>
							
							<div class="col-md-6 mb-3">
							    <label>상세주소</label>
							    <input type="text"
							           name="detailAddress"
							           id="detailAddress"
							           class="form-control">
							</div>
							

                            <div class="col-md-6 mb-3">
                                <label>부서</label>
                                <select name="departmentCode" class="form-select">
						        	<option value="" selected>부서 없음(선택)</option>
								        <option value="DP001">시스템관리팀 (SYSTEM)</option>
								        <option value="DP002">지점운영팀 (BRANCH)</option>
								        <option value="DP003">회원관리팀 (USER)</option>
								        <option value="DP004">구매·발주팀 (PURCHASE)</option>
								        <option value="DP005">정산·회계팀 (ACCOUNTING)</option>
								        <option value="DP006">기획·공지팀 (PLANNING)</option>
								        <option value="DP007">일정관리팀 (SCHEDULE)</option>
                                </select>
                            </div>

                            <div class="col-md-6 mb-3">
                                <label>권한</label>
                                <select name="roleCode" class="form-select">
                                    <option value="RL002">MASTER</option>
                                    <option value="RL003">ADMIN</option>
                                    <option value="RL004">CAPTAIN</option>
                                    <option value="RL005" selected>CREW</option>
                                </select>
                            </div>

                        </div>

                    </div>

                    <div class="card-footer text-right">
                        <a href="/userManagement/list" class="btn btn-secondary">취소</a>
                        <button type="submit" class="btn btn-primary">등록</button>
                    </div>
                </div>
            </form>

        </div>
    </section>
</div>
<!-- 카카오 주소 API -->
<script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>

<script>
document.addEventListener("DOMContentLoaded", function () {

    document.getElementById("postNo")
        .addEventListener("keydown", e => e.preventDefault());

    document.getElementById("baseAddress")
        .addEventListener("keydown", e => e.preventDefault());

});
</script>

<script src="<c:url value='/js/address.js'/>"></script>

<jsp:include page="../includes/admin_footer.jsp" />
