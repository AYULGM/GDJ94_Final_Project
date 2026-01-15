<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<jsp:include page="../includes/admin_header.jsp" />

<div class="row">
  <div class="col-12">
    <div class="card card-primary">
      <div class="card-header">
        <h3 class="card-title">지점 등록</h3>
      </div>

      <form action="/branch/register" method="post">
        <div class="card-body">

          <div class="mb-3">
            <label class="form-label required-label">지점명</label>
            <input type="text" name="branchName" class="form-control" required>
          </div>

			<div class="mb-3">
	        <button type="button"
	                class="btn btn-outline-primary"
	                onclick="execDaumPostcode()">
	            <i class="bi bi-search"></i> 주소 검색
	        </button>
	        </div>
        
          <div class="mb-3">
            <label class="form-label required-label">우편번호</label>
            <div class="input-group">
              <input type="text" name="postNo" id="postNo" class="form-control" required>
            </div>
          </div>

          <div class="mb-3">
            <label class="form-label required-label">기본 주소</label>
            <input type="text" name="baseAddress" id="baseAddress" class="form-control" required>
          </div>

          <div class="mb-3">
            <label class="form-label">상세 주소</label>
            <input type="text" name="detailAddress" id="detailAddress" class="form-control">
          </div>

          <div class="mb-3">
            <label class="form-label required-label">담당자명</label>
            <input type="text" name="managerName" class="form-control" required>
          </div>

          <div class="mb-3">
            <label class="form-label required-label">담당자 연락처</label>
            <input type="text" name="managerPhone" class="form-control" required>
          </div>

			<div class="mb-3">
			    <label class="form-label required-label">운영시간</label>
			
			    <div class="d-flex align-items-center gap-2">
			        <input type="time"
			               id="openTime"
			               class="form-control"
			               style="max-width: 150px;"
			               required>
			
			        <span>~</span>
			
			        <input type="time"
			               id="closeTime"
			               class="form-control"
			               style="max-width: 150px;"
			               required>
			    </div>
			
			    <!-- 실제 DB로 넘어갈 값 -->
			    <input type="hidden" name="operatingHours" id="operatingHours">
			</div>

        </div>

        <div class="card-footer">
          <button type="submit" class="btn btn-primary">등록</button>
          <a href="/branch/list" class="btn btn-secondary">취소</a>
        </div>
      </form>
    </div>
  </div>
</div>
<!-- 카카오 주소 API -->
<script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<script src="<c:url value='/js/address.js'/>"></script>
<script src="<c:url value='/js/operating-hours.js'/>"></script>

<jsp:include page="../includes/admin_footer.jsp" />
