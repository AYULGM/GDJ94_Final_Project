<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

<jsp:include page="../includes/admin_header.jsp" />

<div class="row">
  <div class="col-12">
    <div class="card card-warning">
      <div class="card-header">
        <h3 class="card-title">지점 수정</h3>
      </div>

      <!-- 수정은 반드시 branchId가 필요 -->
      <form action="/branch/update" method="post">

        <input type="hidden" name="branchId" value="${branch.branchId}">

        <div class="card-body">

          <!-- 지점명 -->
          <div class="mb-3">
            <label class="form-label required-label">지점명</label>
            <input type="text"
                   name="branchName"
                   class="form-control"
                   value="${branch.branchName}"
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

          <!-- 우편번호 -->
          <div class="mb-3">
            <label class="form-label required-label">우편번호</label>
            <input type="text"
                   name="postNo"
                   id="postNo"
                   class="form-control"
                   value="${branch.postNo}"
                   required readonly>
          </div>

          <!-- 기본주소 -->
          <div class="mb-3">
            <label class="form-label required-label">기본 주소</label>
            <input type="text"
                   name="baseAddress"
                   id="baseAddress"
                   class="form-control"
                   value="${branch.baseAddress}"
                   required readonly>
          </div>

          <!-- 상세주소 -->
          <div class="mb-3">
            <label class="form-label">상세 주소</label>
            <input type="text"
                   name="detailAddress"
                   id="detailAddress"
                   class="form-control"
                   value="${branch.detailAddress}">
          </div>

          <!-- 담당자 -->
          <div class="mb-3">
            <label class="form-label required-label">담당자명</label>
            <input type="text"
                   name="managerName"
                   class="form-control"
                   value="${branch.managerName}"
                   required>
          </div>

          <!-- 연락처 -->
          <div class="mb-3">
            <label class="form-label required-label">담당자 연락처</label>
            <input type="text"
                   name="managerPhone"
                   class="form-control"
                   value="${branch.managerPhone}"
                   required>
          </div>

          <!-- 운영시간 -->
          <div class="mb-3">
            <label class="form-label required-label">운영시간</label>

            <div class="d-flex align-items-center gap-2">
              <input type="time"
                     id="openTime"
                     class="form-control"
                     style="max-width:150px"
                     value="${fn:split(branch.operatingHours,'~')[0]}"
                     required>

              <span>~</span>

              <input type="time"
                     id="closeTime"
                     class="form-control"
                     style="max-width:150px"
                     value="${fn:split(branch.operatingHours,'~')[1]}"
                     required>
            </div>

            <!-- DB로 실제 전달될 값 -->
            <input type="hidden"
                   name="operatingHours"
                   id="operatingHours"
                   value="${branch.operatingHours}">
          </div>
          
          <div class="mb-3">
			  <label class="form-label required-label">수정 사유</label>
			  <textarea name="reason"
			            class="form-control"
			            rows="3"
			            required></textarea>
			</div>

        </div>

        <div class="card-footer">
          <button type="submit" class="btn btn-warning">
            수정
          </button>
          <a href="/branch/detail?branchId=${branch.branchId}"
             class="btn btn-secondary">
            취소
          </a>
        </div>

      </form>
    </div>
  </div>
</div>

<!-- 카카오 주소 API -->
<script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>

<!-- 공통 주소 스크립트 -->
<script src="<c:url value='/js/address.js'/>"></script>

<!-- 운영시간 조합 스크립트 -->
<script src="<c:url value='/js/operating-hours.js'/>"></script>

<jsp:include page="../includes/admin_footer.jsp" />
