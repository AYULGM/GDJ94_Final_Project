<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<jsp:include page="../includes/admin_header.jsp" />

<div class="container-fluid py-3">

  <div class="d-flex justify-content-between align-items-center mb-3">
    <h3 class="mb-0">전자결재 문서 작성</h3>
    <a class="btn btn-outline-secondary" href="<c:url value='/approval/list'/>">목록</a>
  </div>

  <!-- 저장 폼 -->
  <form action="<c:url value='/approval/save'/>" method="post" id="approvalForm">

    <!-- 문서 유형 -->
    <div class="mb-3">
      <label class="form-label">문서 유형</label>

      <select class="form-select" name="approvalTypeCode" id="approvalTypeCode" required>
        <option value="">선택</option>
        <option value="AT001">기안서</option>
        <option value="AT002">업무보고서</option>
        <option value="AT003">품의서</option>
        <option value="AT004">지출결의서</option>
        <option value="AT005">구매요청서(PR)</option>
        <option value="AT006">발주서(PO)</option>
        <option value="AT007">출장 신청서</option>
        <option value="AT008">근태 신청서</option>
        <option value="AT009">휴가 신청서</option>
        <option value="AT010">휴직 신청서</option>
        <option value="AT011">사직서</option>
        <option value="AT012">인사 발령/변경 품의서</option>
      </select>

    </div>

   
    <!-- 문서유형별 추가 입력 -->
    <div class="card mb-3">
      <div class="card-header">문서유형별 추가 입력</div>
      <div class="card-body">

        <!-- 기본 -->
        <div class="doc-extra" data-type="__DEFAULT__">
          <jsp:include page="fields/fields_default.jsp"/>
        </div>

        <!-- 휴가 신청서 (AT009) -->
        <div class="doc-extra" data-type="AT009" style="display:none;">
          <jsp:include page="fields/fields_leave.jsp"/>
        </div>

        <!-- 출장 신청서 (AT007) -->
        <div class="doc-extra" data-type="AT007" style="display:none;">
          <jsp:include page="fields/fields_trip.jsp"/>
        </div>

        <!-- 근태 신청서 (AT008) -->
        <div class="doc-extra" data-type="AT008" style="display:none;">
          <jsp:include page="fields/fields_attendance.jsp"/>
        </div>

        <!-- 구매요청서(PR) (AT005) -->
        <div class="doc-extra" data-type="AT005" style="display:none;">
          <jsp:include page="fields/fields_pr.jsp"/>
        </div>

        <!-- 발주서(PO) (AT006) -->
        <div class="doc-extra" data-type="AT006" style="display:none;">
          <jsp:include page="fields/fields_po.jsp"/>
        </div>

        <!-- 지출결의서 (AT004) -->
        <div class="doc-extra" data-type="AT004" style="display:none;">
          <jsp:include page="fields/fields_expense.jsp"/>
        </div>

        <!-- 휴직 신청서 (AT010) -->
        <div class="doc-extra" data-type="AT010" style="display:none;">
          <jsp:include page="fields/fields_leave_of_absence.jsp"/>
        </div>

        <!-- 사직서 (AT011) -->
        <div class="doc-extra" data-type="AT011" style="display:none;">
          <jsp:include page="fields/fields_resignation.jsp"/>
        </div>

        <!-- 인사 발령/변경 품의서 (AT012) -->
        <div class="doc-extra" data-type="AT012" style="display:none;">
          <jsp:include page="fields/fields_hr_change.jsp"/>
        </div>

      </div>
    </div>
    
 	<!-- 제목 -->
    <div class="mb-3">
      <label class="form-label">제목</label>
      <input type="text" class="form-control" name="title" id="title" maxlength="200" required />
    </div>

    <!-- 본문(공통) -->
    <div class="mb-3" id="contentBlock">
      <label class="form-label">내용</label>
      <textarea class="form-control" name="content" id="content" rows="10" required></textarea>
      <div class="form-text">문서 유형별 추가 입력은 아래에서 작성합니다.</div>
    </div>

    <!-- 버튼 -->
    <div class="d-flex gap-2">
      <button type="button" class="btn btn-outline-primary" onclick="submitTemp()">임시저장</button>
      <button type="submit" class="btn btn-primary">다음</button>
      <a class="btn btn-outline-secondary" href="<c:url value='/approval/list'/>">취소</a>
    </div>

    <!-- 임시저장 구분 -->
    <input type="hidden" name="tempYn" id="tempYn" value="N" />
  </form>
</div>


<script src="/approval/js/formChange.js"></script>
<jsp:include page="../includes/admin_footer.jsp" />
