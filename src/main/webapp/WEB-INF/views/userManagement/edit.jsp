<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../includes/admin_header.jsp" />

<div class="content-wrapper">
    <section class="content">
        <div class="container-fluid">

            <form action="/userManagement/edit" method="post">
                <!-- PK -->
                <input type="hidden" name="userId" value="${user.userId}" />

                <div class="card card-outline card-warning">
                    <div class="card-header">
                        <h3 class="card-title">사용자 수정</h3>
                    </div>

                    <div class="card-body">
                        <div class="row">

                            <!-- 아이디 (수정 불가) -->
                            <div class="col-md-6 mb-3">
                                <label class="form-label required-label">아이디</label>
                                <input type="text"
                                       class="form-control"
                                       value="${user.loginId}"
                                       required readonly>
                            </div>

                            <div class="col-md-6 mb-3">
                                <label class="form-label required-label">이름</label>
                                <input type="text"
                                       name="name"
                                       class="form-control"
                                       value="${user.name}"
                                       required>
                            </div>

                            <div class="col-md-6 mb-3">
                                <label class="form-label required-label">이메일</label>
                                <input type="email"
                                       name="email"
                                       class="form-control"
                                       value="${user.email}"
                                       required>
                            </div>

                            <div class="col-md-6 mb-3">
                                <label class="form-label required-label">연락처</label>
                                <input type="text"
                                       name="phone"
                                       class="form-control"
                                       value="${user.phone}"
                                       required>
                            </div>

                            <!-- 소속 지점 ID -->
                            <div class="col-md-6 mb-3">
                                <label class="form-label required-label">소속 지점 ID</label>
                                <input type="number"
                                       name="branchId"
                                       class="form-control"
                                       value="${user.branchId}"
                                       required>
                            </div>

                            <!-- 주소 검색 -->
                            <div class="mb-3">
                                <button type="button"
                                        class="btn btn-outline-primary"
                                        onclick="execDaumPostcode()">
                                    <i class="bi bi-search"></i> 주소 검색
                                </button>
                            </div>

                            <div class="col-md-6 mb-3">
                                <label class="form-label required-label">우편번호</label>
                                <input type="text"
                                       name="postNo"
                                       id="postNo"
                                       class="form-control"
                                       value="${user.postNo}"
                                       required readonly>
                            </div>

                            <div class="col-md-6 mb-3">
                                <label class="form-label required-label">기본주소</label>
                                <input type="text"
                                       name="baseAddress"
                                       id="baseAddress"
                                       class="form-control"
                                       value="${user.baseAddress}"
                                       required readonly>
                            </div>

                            <div class="col-md-6 mb-3">
                                <label>상세주소</label>
                                <input type="text"
                                       name="detailAddress"
                                       id="detailAddress"
                                       class="form-control"
                                       value="${user.detailAddress}">
                            </div>

                            <!-- 부서 -->
                            <div class="col-md-6 mb-3">
                                <label>부서</label>
                                <select name="departmentCode" class="form-select">
                                    <option value="">부서 없음</option>
                                    <option value="DP001" ${user.departmentCode=='DP001'?'selected':''}>시스템관리팀</option>
                                    <option value="DP002" ${user.departmentCode=='DP002'?'selected':''}>지점운영팀</option>
                                    <option value="DP003" ${user.departmentCode=='DP003'?'selected':''}>회원관리팀</option>
                                    <option value="DP004" ${user.departmentCode=='DP004'?'selected':''}>구매·발주팀</option>
                                    <option value="DP005" ${user.departmentCode=='DP005'?'selected':''}>정산·회계팀</option>
                                    <option value="DP006" ${user.departmentCode=='DP006'?'selected':''}>기획·공지팀</option>
                                    <option value="DP007" ${user.departmentCode=='DP007'?'selected':''}>일정관리팀</option>
                                </select>
                            </div>

                            <!-- 권한 -->
                            <div class="col-md-6 mb-3">
                                <label>권한</label>
                                <select name="roleCode" class="form-select">
                                    <option value="RL002" ${user.roleCode=='RL002'?'selected':''}>본사인사팀</option>
                                    <option value="RL003" ${user.roleCode=='RL003'?'selected':''}>본사관리자</option>
                                    <option value="RL004" ${user.roleCode=='RL004'?'selected':''}>지점관리자</option>
                                    <option value="RL005" ${user.roleCode=='RL005'?'selected':''}>직원</option>
                                </select>
                            </div>
                            
                            <!-- 수정 사유 -->
							<div class="mb-3">
							    <label class="form-label required-label"">수정 사유</label>
							    <textarea name="reason"
							              class="form-control"
							              rows="3"
							              required>
							    </textarea>
							</div>

                        </div>
                    </div>

                    <div class="card-footer text-right">
                        <a href="/userManagement/detail?userId=${user.userId}"
                           class="btn btn-secondary">취소</a>
                        <button type="submit"
                                class="btn btn-warning">수정</button>
                    </div>

                </div>
            </form>

        </div>
    </section>
</div>

<!-- 카카오 주소 API -->
<script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<script src="<c:url value='/js/address.js'/>"></script>

<jsp:include page="../includes/admin_footer.jsp" />
