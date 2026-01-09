<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<jsp:include page="../includes/admin_header.jsp" />

<div class="container-fluid py-3">

  <div class="d-flex justify-content-between align-items-center mb-3">
    <h3 class="mb-0">
      <c:choose>
        <c:when test="${mode == 'edit'}">전자결재 문서 수정</c:when>
        <c:otherwise>전자결재 문서 작성</c:otherwise>
      </c:choose>
    </h3>
    <a class="btn btn-outline-secondary" href="<c:url value='/approval/list'/>">목록</a>
  </div>

  <form action="<c:url value='/approval/saveDraftForm'/>"
        method="post"
        id="approvalForm">

    <!-- (선택) Spring Security CSRF 사용 시 -->
    <c:if test="${not empty _csrf}">
      <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
    </c:if>

    <!-- 모드/키 -->
    <input type="hidden" name="mode" id="mode" value="${mode}" />
    <input type="hidden" name="docVerId" id="docVerId" value="<c:out value='${draft.docVerId}'/>" />

    <!-- 문서 유형 -->
    <div class="mb-3">
      <label class="form-label">문서 유형</label>

      <select class="form-select"
              name="typeCode"
              id="approvalTypeCode"
              required
              <c:if test="${mode == 'edit'}">disabled</c:if>>
        <option value="">선택</option>

        <option value="AT001" <c:if test="${draft.typeCode == 'AT001'}">selected</c:if>>지출결의서</option>
        <option value="AT002" <c:if test="${draft.typeCode == 'AT002'}">selected</c:if>>정산결재서</option>
        <option value="AT003" <c:if test="${draft.typeCode == 'AT003'}">selected</c:if>>매출결의서</option>
        <option value="AT004" <c:if test="${draft.typeCode == 'AT004'}">selected</c:if>>재고조정요청서</option>
        <option value="AT005" <c:if test="${draft.typeCode == 'AT005'}">selected</c:if>>구매요청서(PR)</option>
        <option value="AT006" <c:if test="${draft.typeCode == 'AT006'}">selected</c:if>>발주서(PO)</option>
        <option value="AT007" <c:if test="${draft.typeCode == 'AT007'}">selected</c:if>>출장 신청서</option>
        <option value="AT008" <c:if test="${draft.typeCode == 'AT008'}">selected</c:if>>근태 신청서</option>
        <option value="AT009" <c:if test="${draft.typeCode == 'AT009'}">selected</c:if>>휴가 신청서</option>
        <option value="AT010" <c:if test="${draft.typeCode == 'AT010'}">selected</c:if>>휴직 신청서</option>
        <option value="AT011" <c:if test="${draft.typeCode == 'AT011'}">selected</c:if>>사직서</option>
        <option value="AT012" <c:if test="${draft.typeCode == 'AT012'}">selected</c:if>>인사 발령/변경 품의서</option>
      </select>

      <!-- disabled면 값이 제출되지 않아서 hidden으로 보완 -->
      <c:if test="${mode == 'edit'}">
        <input type="hidden" name="typeCode" value="<c:out value='${draft.typeCode}'/>" />
        <div class="form-text text-muted">수정 모드에서는 문서 유형을 변경할 수 없습니다.</div>
      </c:if>
    </div>

    <!-- form_code (DB NOT NULL) -->
    <input type="hidden" name="formCode" id="formCode" value="<c:out value='${draft.formCode}'/>" />

    <!-- 문서유형별 추가 입력 -->
    <div class="card mb-3">
      <div class="card-header">문서유형별 추가 입력</div>
      <div class="card-body">

        <!-- 기본 -->
        <div class="doc-extra" data-type="__DEFAULT__">
          <jsp:include page="fields/fields_default.jsp"/>
        </div>

        <!-- AT001 -->
        <div class="doc-extra" data-type="AT001" style="display:none;">
          <jsp:include page="fields/fields_expense.jsp"/>
        </div>

        <!-- AT002 -->
        <div class="doc-extra" data-type="AT002" style="display:none;">
          <jsp:include page="fields/fields_settlement.jsp"/>
        </div>

        <!-- AT003 -->
        <div class="doc-extra" data-type="AT003" style="display:none;">
          <jsp:include page="fields/fields_sales.jsp"/>
        </div>

        <!-- AT004 -->
        <div class="doc-extra" data-type="AT004" style="display:none;">
          <jsp:include page="fields/fields_inventory_adjust.jsp"/>
        </div>

        <!-- AT005 -->
        <div class="doc-extra" data-type="AT005" style="display:none;">
          <jsp:include page="fields/fields_pr.jsp"/>
        </div>

        <!-- AT006 -->
        <div class="doc-extra" data-type="AT006" style="display:none;">
          <jsp:include page="fields/fields_po.jsp"/>
        </div>

        <!-- AT007 -->
        <div class="doc-extra" data-type="AT007" style="display:none;">
          <jsp:include page="fields/fields_trip.jsp"/>
        </div>

        <!-- AT008 -->
        <div class="doc-extra" data-type="AT008" style="display:none;">
          <jsp:include page="fields/fields_attendance.jsp"/>
        </div>

        <!-- AT009 -->
        <div class="doc-extra" data-type="AT009" style="display:none;">
          <jsp:include page="fields/fields_leave.jsp"/>
        </div>

        <!-- AT010 -->
        <div class="doc-extra" data-type="AT010" style="display:none;">
          <jsp:include page="fields/fields_leave_of_absence.jsp"/>
        </div>

        <!-- AT011 -->
        <div class="doc-extra" data-type="AT011" style="display:none;">
          <jsp:include page="fields/fields_resignation.jsp"/>
        </div>

        <!-- AT012 -->
        <div class="doc-extra" data-type="AT012" style="display:none;">
          <jsp:include page="fields/fields_hr_change.jsp"/>
        </div>

      </div>
    </div>

    <!-- 제목 -->
    <div class="mb-3">
      <label class="form-label">제목</label>
      <input type="text"
             class="form-control"
             name="title"
             id="title"
             maxlength="200"
             required
             value="<c:out value='${empty draft ? "" : draft.title}'/>" />
    </div>

    <!-- 본문 -->
    <div class="mb-3">
      <label class="form-label">내용</label>
      <textarea class="form-control"
                name="body"
                id="body"
                rows="10"
                required><c:out value='${empty draft ? "" : draft.body}'/></textarea>
    </div>

      <button type="submit" class="btn btn-primary">
        <c:choose>
          <c:when test="${mode == 'edit'}">저장</c:when>
          <c:otherwise>다음</c:otherwise>
        </c:choose>
      </button>

      <a class="btn btn-outline-secondary" href="<c:url value='/approval/list'/>">취소</a>
    </div>

    <!-- 임시저장 구분 -->
    <input type="hidden" name="tempYn" id="tempYn" value="N" />

  </form>
</div>

<script src="/approval/js/formChange.js"></script>

<script>
  function submitTemp() {
    document.getElementById("tempYn").value = "Y";
    document.getElementById("approvalForm").submit();
  }

  // 수정/작성 공통: 로드시 현재 typeCode에 맞게 doc-extra 열기
  // (formChange.js가 change 이벤트 기반이면 트리거만 해주면 됨)
  document.addEventListener("DOMContentLoaded", function () {
    const typeSel = document.getElementById("approvalTypeCode");
    if (!typeSel) return;

    // edit 모드에서는 select가 disabled라 change 이벤트가 안 먹는 구현이 있을 수 있어
    // 그래서 강제로 한 번 토글 로직을 실행해주는 안전장치
    try {
      typeSel.dispatchEvent(new Event("change"));
    } catch (e) {}

    // 신규 작성인데 formCode가 비어있으면, formChange.js 매핑이 세팅하도록 change 한번 더
    const formCode = document.getElementById("formCode");
    if (formCode && !formCode.value) {
      try { typeSel.dispatchEvent(new Event("change")); } catch (e) {}
    }
  });
</script>

<jsp:include page="../includes/admin_footer.jsp" />
