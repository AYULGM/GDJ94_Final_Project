<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<jsp:include page="../includes/admin_header.jsp" />

<div class="container-fluid py-3">

  <div class="d-flex justify-content-between align-items-center mb-3">
    <h3 class="mb-0">
      
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
		
		  <c:choose>
		    <c:when test="${entry == 'buy'}">
		      <option value="AT005" <c:if test="${draft.typeCode == 'AT005'}">selected</c:if>>구매요청서(PR)</option>
		      <option value="AT006" <c:if test="${draft.typeCode == 'AT006'}">selected</c:if>>발주서(PO)</option>
		      <option value="AT004" <c:if test="${draft.typeCode == 'AT004'}">selected</c:if>>재고조정요청서</option>
		    </c:when>
		
		    <c:otherwise>
		      <option value="AT001" <c:if test="${draft.typeCode == 'AT001'}">selected</c:if>>지출결의서</option>
		      <option value="AT002" <c:if test="${draft.typeCode == 'AT002'}">selected</c:if>>정산결재서</option>
		      <option value="AT003" <c:if test="${draft.typeCode == 'AT003'}">selected</c:if>>매출결의서</option>
		      <option value="AT009" <c:if test="${draft.typeCode == 'AT009'}">selected</c:if>>휴가 신청서</option>
			  <option value="AT005" <c:if test="${draft.typeCode == 'AT005'}">selected</c:if>>구매요청서(PR)</option>
		      <option value="AT006" <c:if test="${draft.typeCode == 'AT006'}">selected</c:if>>발주서(PO)</option>
		      <option value="AT004" <c:if test="${draft.typeCode == 'AT004'}">selected</c:if>>재고조정요청서</option>
		      <option value="AT007" <c:if test="${draft.typeCode == 'AT007'}">selected</c:if> disabled>출장 신청서</option>
		      <option value="AT008" <c:if test="${draft.typeCode == 'AT008'}">selected</c:if> disabled>근태 신청서</option>
		      <option value="AT010" <c:if test="${draft.typeCode == 'AT010'}">selected</c:if> disabled>휴직 신청서</option>
		      <option value="AT011" <c:if test="${draft.typeCode == 'AT011'}">selected</c:if> disabled>사직서</option>
		      <option value="AT012" <c:if test="${draft.typeCode == 'AT012'}">selected</c:if> disabled>인사 발령/변경 품의서</option>
		    </c:otherwise>
		  </c:choose>
		
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
      <label class="form-label required-label">
      제목</label>
      <input type="text"
             class="form-control"
             name="title"
             id="title"
             maxlength="200"
             required
             value="<c:out value='${empty draft ? "" : draft.title}'/>" />
    </div>

    <!-- 본문 (Quill) -->
		<div class="mb-3">
		  <label class="form-label required-label">
		  내용</label>
		
		  <!-- 서버로 실제 제출될 값 -->
		  <input type="hidden"
		         name="body"
		         id="bodyHidden"
		         value="${empty draft ? '' : draft.body}" />
		
		  <!-- Quill이 붙을 영역 -->
		  <div id="quillEditor" style="height:300px;">
		    ${empty draft ? '' : draft.body}
		  </div>
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
<!-- Quill -->
<link href="https://cdn.jsdelivr.net/npm/quill@1.3.7/dist/quill.snow.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/quill@1.3.7/dist/quill.min.js"></script>

<script>
  function submitTemp() {
    document.getElementById("tempYn").value = "Y";
    document.getElementById("approvalForm").submit();
  }

  document.addEventListener("DOMContentLoaded", function () {
    // 1) 문서유형별 extra 영역 토글 (기존 로직 유지)
    const typeSel = document.getElementById("approvalTypeCode");
    if (typeSel) {
      try { typeSel.dispatchEvent(new Event("change")); } catch (e) {}

      const formCode = document.getElementById("formCode");
      if (formCode && !formCode.value) {
        try { typeSel.dispatchEvent(new Event("change")); } catch (e) {}
      }
    }

    // 2) Quill 초기화
    const editorEl = document.getElementById("quillEditor");
    if (!editorEl) return;

    const quill = new Quill("#quillEditor", {
      theme: "snow",
      modules: {
        toolbar: [
          [{ header: [1, 2, 3, false] }],
          ["bold", "italic", "underline", "strike"],
          [{ list: "ordered" }, { list: "bullet" }],
          ["blockquote", "code-block"],
          ["link"],
          ["clean"]
        ]
      }
    });

    // 3) submit 직전에 HTML을 hidden input에 담아서 전송
    const form = document.getElementById("approvalForm");
    const hidden = document.getElementById("bodyHidden");

    form.addEventListener("submit", function () {
      const html = quill.root.innerHTML;

      // 빈 값 처리(Quill은 빈 편집기여도 <p><br></p>가 들어갈 수 있음)
      const normalized = (html === "<p><br></p>") ? "" : html;

      hidden.value = normalized;

      // required 대체 검증(원하면 유지)
      if (!hidden.value || hidden.value.trim() === "") {
        alert("내용을 입력해주세요.");
        hidden.focus();
        event.preventDefault();
        return false;
      }
    });
  });
</script>


<jsp:include page="../includes/admin_footer.jsp" />

