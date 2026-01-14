<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<div class="row g-2">
  <div class="col-md-3">
    <label class="form-label"><span style="color:red; font-weight: normal;">*</span>휴가 시작일</label>
    <input type="date"
           class="form-control"
           name="extDt1"
           required
           value="<c:out value='${draft.extDt1}'/>" />
  </div>

  <div class="col-md-3">
    <label class="form-label"><span style="color:red; font-weight: normal;">*</span>휴가 종료일</label>
    <input type="date"
           class="form-control"
           name="extDt2"
           required
           value="<c:out value='${draft.extDt2}'/>" />
  </div>

  <div class="col-md-3">
    <label class="form-label"><span style="color:red; font-weight: normal;">*</span>휴가 구분</label>
    <select class="form-select" name="extCode1" required>
      <option value="">선택</option>
      <option value="연차"      <c:if test="${draft.extCode1 == '연차'}">selected</c:if>>연차</option>
      <option value="반차(오전)" <c:if test="${draft.extCode1 == '반차(오전)'}">selected</c:if>>반차(오전)</option>
      <option value="반차(오후)" <c:if test="${draft.extCode1 == '반차(오후)'}">selected</c:if>>반차(오후)</option>
      <option value="병가"      <c:if test="${draft.extCode1 == '병가'}">selected</c:if>>병가</option>
      <option value="경조"      <c:if test="${draft.extCode1 == '경조'}">selected</c:if>>경조</option>
      <option value="기타"      <c:if test="${draft.extCode1 == '기타'}">selected</c:if>>기타</option>
    </select>
  </div>

  <div class="col-md-3">
	  <label class="form-label">사용 일수</label>
	  <input type="number"
	         class="form-control"
	         name="extNo1"
	         min="0"
	         step="1"
	         placeholder="예: 1"
	         readonly
	         style="background:#f8f9fa;"
	         value="<c:out value='${draft.extNo1}'/>" />
	</div>


  <div class="col-md-6">
  <label class="form-label mt-2"><span style="color:red; font-weight: normal;">*</span>인수인계자</label>

  <select class="form-select" name="extTxt1">
    <option value="">선택</option>

    <c:forEach items="${handoverCandidates}" var="u">
      <option value="${u.userId}"
        <c:if test="${draft.extTxt1 == u.userId}">selected</c:if>>
        <c:out value="${u.name}"/> (<c:out value="${u.roleCode}"/>)
      </option>
    </c:forEach>

  </select>
</div>


  <div class="col-12">
    <label class="form-label mt-2"><span style="color:red; font-weight: normal;">*</span>휴가 사유</label>
    <textarea class="form-control"
              name="extTxt2"
              rows="3"
              maxlength="500"
              required><c:out value="${draft.extTxt2}" /></textarea>
  </div>

  <div class="col-12">
    <label class="form-label mt-2">인수인계 내용</label>
    <textarea class="form-control"
              name="extTxt3"
              rows="3"
              maxlength="800"><c:out value="${draft.extTxt3}" /></textarea>
  </div>
</div>
<script>
  function findLeaveEls(fromEl) {
    const root = fromEl?.closest(".row.g-2") || document.querySelector(".row.g-2");
    if (!root) return null;

    const startEl = root.querySelector("input[name='extDt1']");
    const endEl   = root.querySelector("input[name='extDt2']");
    const typeEl  = root.querySelector("select[name='extCode1']");
    const daysEl  = root.querySelector("input[name='extNo1']");

    if (!startEl || !endEl || !typeEl || !daysEl) return null;
    return { root, startEl, endEl, typeEl, daysEl };
  }

  function setDays(daysEl, v) {
    daysEl.value = v;
    daysEl.dispatchEvent(new Event("input", { bubbles: true }));
  }

  function calcLeaveDays(fromEl) {
    const els = findLeaveEls(fromEl);
    if (!els) return;

    const { startEl, endEl, typeEl, daysEl } = els;

    const s = startEl.value;
    const e = endEl.value;
    const type = typeEl.value;

    // 반차는 0.5 고정
    if (type === "반차(오전)" || type === "반차(오후)") {
      setDays(daysEl, 0.5);
      return;
    }

    if (!s || !e) {
      setDays(daysEl, 0);
      return;
    }

    const sd = new Date(s + "T00:00:00");
    const ed = new Date(e + "T00:00:00");

    if (ed < sd) {
      setDays(daysEl, 0);
      return;
    }

    const diffDays = Math.floor((ed - sd) / (1000 * 60 * 60 * 24)) + 1;
    setDays(daysEl, diffDays);
  }

  // 1) 사용자가 직접 수정 못 하게(키/붙여넣기 차단) + 2) 언제 로딩되든 이벤트 위임으로 계산
  document.addEventListener("keydown", (e) => {
    if (e.target && e.target.matches("input[name='extNo1']")) e.preventDefault();
  });
  document.addEventListener("paste", (e) => {
    if (e.target && e.target.matches("input[name='extNo1']")) e.preventDefault();
  });

  document.addEventListener("input", (e) => {
    if (e.target && (e.target.matches("input[name='extDt1']") || e.target.matches("input[name='extDt2']"))) {
      calcLeaveDays(e.target);
    }
  });
  document.addEventListener("change", (e) => {
    if (e.target && (e.target.matches("input[name='extDt1']") || e.target.matches("input[name='extDt2']") || e.target.matches("select[name='extCode1']"))) {
      calcLeaveDays(e.target);
    }
  });

  // 초기에도 바로 계산 (동적 로딩 타이밍 대비로 0ms/300ms 두 번)
  setTimeout(() => calcLeaveDays(document.querySelector("input[name='extDt1']")), 0);
  setTimeout(() => calcLeaveDays(document.querySelector("input[name='extDt1']")), 300);
</script>
