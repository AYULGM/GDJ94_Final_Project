<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../includes/admin_header.jsp" />

<div class="content-wrapper p-4">

    <!-- 메인 콘텐츠 -->
    <section class="content">
        <div class="row justify-content-center">
            <div class="col-md-6 col-lg-5">

                <div class="card card-warning card-outline">
                    <div class="card-header text-center">
                        <h3 class="mb-0"><b>정보 수정</b></h3>
                    </div>

                    <div class="card-body">

                        <form action="<c:url value='/users/updateProc'/>" method="post">

                            <!-- 이름 -->
                            <div class="mb-3">
                                <label class="form-label">이름</label>
                                <input type="text"
                                       name="name"
                                       class="form-control"
                                       value="${user.name}"
                                       required>
                            </div>

                            <!-- 이메일 -->
                            <div class="mb-3">
                                <label class="form-label">이메일</label>
                                <input type="email"
                                       name="email"
                                       class="form-control"
                                       value="${user.email}">
                            </div>

                            <!-- 전화번호 -->
                            <div class="mb-3">
                                <label class="form-label">전화번호</label>
                                <input type="text"
                                       name="phone"
                                       class="form-control"
                                       value="${user.phone}">
                            </div>

                            <!-- 부서 -->
                            <div class="mb-3">
                                <label class="form-label">부서</label>
                                <select name="departmentCode" class="form-select">
                                    <option value="">부서 없음</option>
                                    <option value="DP001" ${user.departmentCode == 'DP001' ? 'selected' : ''}>시스템관리팀 (SYSTEM)</option>
                                    <option value="DP002" ${user.departmentCode == 'DP002' ? 'selected' : ''}>지점운영팀 (BRANCH)</option>
                                    <option value="DP003" ${user.departmentCode == 'DP003' ? 'selected' : ''}>회원관리팀 (USER)</option>
                                    <option value="DP004" ${user.departmentCode == 'DP004' ? 'selected' : ''}>구매·발주팀 (PURCHASE)</option>
                                    <option value="DP005" ${user.departmentCode == 'DP005' ? 'selected' : ''}>정산·회계팀 (ACCOUNTING)</option>
                                    <option value="DP006" ${user.departmentCode == 'DP006' ? 'selected' : ''}>기획·공지팀 (PLANNING)</option>
                                    <option value="DP007" ${user.departmentCode == 'DP007' ? 'selected' : ''}>일정관리팀 (SCHEDULE)</option>
                                </select>
                            </div>

                            <!-- 소속 지점 -->
                            <div class="mb-3">
                                <label class="form-label">소속 지점 ID</label>
                                <input type="number"
                                       name="branchId"
                                       class="form-control"
                                       value="${user.branchId}">
                            </div>

							<!-- 주소 -->
							
							<div class="mb-3">
					        <button type="button"
					                class="btn btn-outline-primary"
					                onclick="execDaumPostcode()">
					            <i class="bi bi-search"></i> 주소 검색
					        </button>
					        </div>
					        
                            <div class="mb-3">
                                <label class="form-label">우편번호</label>
                                <input type="text"
                                       name="postNo"
                                       id="postNo"
                                       class="form-control"
                                       value="${user.postNo}"
                                       readonly>
                            </div>
							
                            <div class="mb-3">
                                <label class="form-label">기본 주소</label>
                                <input type="text"
                                       name="baseAddress"
                                       id="baseAddress"
                                       class="form-control"
                                       value="${user.baseAddress}"
                                       readonly>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">상세 주소</label>
                                <input type="text"
                                       name="detailAddress"
                                       id="detailAddress"
                                       class="form-control"
                                       value="${user.detailAddress}">
                            </div>

                            <!-- 버튼 -->
                            <div class="d-grid mt-4">
                                <button type="submit" class="btn btn-warning">
                                    <i class="bi bi-pencil"></i> 정보 수정
                                </button>
                            </div>

                        </form>

                    </div>
                </div>

            </div>
        </div>
    </section>

</div>
<!-- 카카오 주소 API -->
<script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>

<script src="<c:url value='/js/address.js'/>"></script>

</body>
<jsp:include page="../includes/admin_footer.jsp" />
