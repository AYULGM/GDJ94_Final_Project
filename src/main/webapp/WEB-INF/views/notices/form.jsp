<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>

<jsp:include page="../includes/admin_header.jsp" />

<style>
#branchListBox{
  max-height: 260px;
  overflow: auto;
  display: grid;
  gap: 8px;
  grid-template-columns: repeat(3, minmax(0, 1fr));
}

@media (max-width: 992px){
  #branchListBox{ grid-template-columns: repeat(2, minmax(0, 1fr)); }
}
@media (max-width: 576px){
  #branchListBox{ grid-template-columns: repeat(1, minmax(0, 1fr)); }
}

#branchListBox .branch-item{
  display: flex;
  align-items: center;
  gap: 8px;

  margin: 0;
  padding: 8px 10px;
  border: 1px solid #e9ecef;
  border-radius: 8px;
  background: #fff;
  min-width: 0;
}

#branchListBox .branch-item .form-check-input{
  margin: 0;
  flex: 0 0 auto;
}

#branchListBox .branch-label{
  flex: 1 1 auto;
  min-width: 0;
  margin: 0;

  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

#branchListBox .branch-item:hover{
  background: #f8f9fa;
}

</style>

<!-- 수정이면 /notices/{id}/edit, 등록이면 /notices -->
<c:set var="formAction" value="/notices" />
<c:if test="${not empty notice.noticeId}">
  <c:set var="formAction" value="/notices/${notice.noticeId}/edit" />
</c:if>

<!-- 관리자면 admin 목록으로 이동 -->
<c:set var="backToList" value="/notices" />
<c:if test="${isAdmin}">
  <c:set var="backToList" value="/notices/admin" />
</c:if>

<!-- 지점 체크용 문자열(",1,2,3,") 생성 -->
<c:set var="branchIdsStr" value="," />
<c:if test="${not empty notice.branchIds}">
  <c:forEach items="${notice.branchIds}" var="bid">
    <c:set var="branchIdsStr" value="${branchIdsStr}${bid}," />
  </c:forEach>
</c:if>

<div class="row">
  <div class="col-12">
    <div class="card">
      <div class="card-header d-flex align-items-center justify-content-between">
        <h3 class="card-title mb-0  col-10">
          <c:choose>
            <c:when test="${empty notice.noticeId}">공지 등록</c:when>
            <c:otherwise>공지 수정</c:otherwise>
          </c:choose>
        </h3>
        <a class="btn btn-outline-secondary btn-sm" href="<c:url value='${backToList}'/>">목록</a>
      </div>

      <div class="card-body">
        <form method="post" action="<c:url value='${formAction}'/>" id="noticeForm">

          <c:if test="${not empty notice.noticeId}">
            <input type="hidden" name="noticeId" value="${notice.noticeId}" />
          </c:if>

          <div class="mb-3">
            <label class="form-label">제목</label>
            <input type="text" name="title" class="form-control" required
                   value="<c:out value='${notice.title}'/>" />
          </div>

          <div class="mb-3">
            <label class="form-label">내용</label>
            <textarea name="content" class="form-control" rows="7" required><c:out value="${notice.content}" /></textarea>
          </div>

          <div class="row g-3 mb-3">
            <div class="col-md-3">
              <label class="form-label">공지 유형</label>
              <select name="noticeType" class="form-select" required>
                <c:choose>
                  <c:when test="${empty noticeTypes}">
                    <option value="NT001" <c:if test="${notice.noticeType eq 'NT001'}">selected</c:if>>긴급</option>
                    <option value="NT002" <c:if test="${empty notice.noticeType || notice.noticeType eq 'NT002'}">selected</c:if>>일반</option>
                    <option value="NT003" <c:if test="${notice.noticeType eq 'NT003'}">selected</c:if>>이벤트</option>
                  </c:when>
                  <c:otherwise>
                    <c:forEach items="${noticeTypes}" var="cc">
                      <option value="${cc.code}" <c:if test="${cc.code eq notice.noticeType}">selected</c:if>>
                        <c:out value="${cc.codeDesc}" />
                      </option>
                    </c:forEach>
                  </c:otherwise>
                </c:choose>
              </select>
            </div>

            <div class="col-md-3">
              <label class="form-label">대상</label>
              <select name="targetType" id="targetType" class="form-select" required>
                <c:choose>
                  <c:when test="${empty targetTypes}">
                    <option value="TT001" <c:if test="${empty notice.targetType || notice.targetType eq 'TT001'}">selected</c:if>>전체</option>
                    <option value="TT002" <c:if test="${notice.targetType eq 'TT002'}">selected</c:if>>지점</option>
                  </c:when>
                  <c:otherwise>
                    <c:forEach items="${targetTypes}" var="cc">
                      <option value="${cc.code}" <c:if test="${cc.code eq notice.targetType}">selected</c:if>>
                        <c:out value="${cc.codeDesc}" />
                      </option>
                    </c:forEach>
                  </c:otherwise>
                </c:choose>
              </select>
            </div>

            <div class="col-md-3">
              <label class="form-label">상태</label>
              <select name="status" class="form-select">
                <c:choose>
                  <c:when test="${empty statusCodes}">
                    <option value="NS001" <c:if test="${empty notice.status || notice.status eq 'NS001'}">selected</c:if>>게시</option>
                    <option value="NS002" <c:if test="${notice.status eq 'NS002'}">selected</c:if>>임시저장</option>
                    <option value="NS003" <c:if test="${notice.status eq 'NS003'}">selected</c:if>>종료</option>
                  </c:when>
                  <c:otherwise>
                    <c:forEach items="${statusCodes}" var="cc">
                      <option value="${cc.code}" <c:if test="${cc.code eq notice.status}">selected</c:if>>
                        <c:out value="${cc.codeDesc}" />
                      </option>
                    </c:forEach>
                  </c:otherwise>
                </c:choose>
              </select>
            </div>

            <div class="col-md-3">
              <label class="form-label">카테고리</label>
              <select name="categoryCode" class="form-select" required>
                <c:choose>
                  <c:when test="${empty categories}">
                    <option value="CAT001" <c:if test="${empty notice.categoryCode || notice.categoryCode eq 'CAT001'}">selected</c:if>>일반</option>
                    <option value="CAT002" <c:if test="${notice.categoryCode eq 'CAT002'}">selected</c:if>>운영</option>
                    <option value="CAT003" <c:if test="${notice.categoryCode eq 'CAT003'}">selected</c:if>>이벤트</option>
                  </c:when>
                  <c:otherwise>
                    <c:forEach items="${categories}" var="cc">
                      <option value="${cc.code}" <c:if test="${cc.code eq notice.categoryCode}">selected</c:if>>
                        <c:out value="${cc.codeDesc}" />
                      </option>
                    </c:forEach>
                  </c:otherwise>
                </c:choose>
              </select>
            </div>
          </div>

          <!-- ===== datetime-local -> date + time + hidden 제출 ===== -->
          <div class="row g-3 mb-3">
            <div class="col-md-3">
              <label class="form-label">게시 시작(날짜)</label>
              <input type="date" id="publishStartDateOnly" class="form-control"
                     value="<c:out value='${notice.publishStartDateOnly}'/>" />
            </div>

            <div class="col-md-3">
              <label class="form-label">게시 시작(시간)</label>
              <input type="time" id="publishStartTimeOnly" class="form-control"
                     value="<c:out value='${notice.publishStartTimeOnly}'/>" />
            </div>

            <div class="col-md-3">
              <label class="form-label">게시 종료(날짜)</label>
              <input type="date" id="publishEndDateOnly" class="form-control"
                     value="<c:out value='${notice.publishEndDateOnly}'/>" />
            </div>

            <div class="col-md-3">
              <label class="form-label">게시 종료(시간)</label>
              <input type="time" id="publishEndTimeOnly" class="form-control"
                     value="<c:out value='${notice.publishEndTimeOnly}'/>" />
            </div>

            <!-- 서버로 실제 제출될 값(기존 name 유지) -->
            <input type="hidden" name="publishStartDate" id="publishStartHidden"
                   value="<c:out value='${notice.publishStartInput}'/>" />
            <input type="hidden" name="publishEndDate" id="publishEndHidden"
                   value="<c:out value='${notice.publishEndInput}'/>" />
          </div>

          <div class="row g-3 mb-3">
            <div class="col-md-3 d-flex align-items-end">
              <div class="form-check">
                <input class="form-check-input" type="checkbox" name="isPinned" value="true" id="isPinned"
                       <c:if test="${notice.isPinned}">checked</c:if>>
                <label class="form-check-label" for="isPinned">상단 고정</label>
              </div>
            </div>
          </div>

          <!-- ===== 지점 대상 영역 ===== -->
          <div class="mb-3" id="branchTargetArea">
            <label class="form-label">대상 지점 (지점 공지일 때만)</label>
            <div class="form-text mb-2">targetType이 지점(TT002)일 때 선택하세요.</div>

            <div class="d-flex gap-2 mb-2">
              <input type="text" id="branchSearch" class="form-control form-control-sm" placeholder="지점 검색(예: 서울, 인천 등)" />
              <button type="button" class="btn btn-outline-secondary btn-sm" id="btnSelectAll">전체선택</button>
              <button type="button" class="btn btn-outline-secondary btn-sm" id="btnUnselectAll">전체해제</button>
            </div>

            <div class="border rounded p-2" id="branchListBox">
			  <c:choose>
			    <c:when test="${empty branches}">
			      <div class="text-muted">지점 목록이 없습니다.</div>
			    </c:when>
			    <c:otherwise>
			      <c:forEach items="${branches}" var="b">
			        <c:set var="token" value=",${b.branchId}," />
			
			        <div class="branch-item" data-name="${b.branchName}">
			          <input class="form-check-input branch-cb"
			                 type="checkbox"
			                 name="branchIds"
			                 value="${b.branchId}"
			                 id="br_${b.branchId}"
			                 <c:if test="${fn:contains(branchIdsStr, token)}">checked</c:if> />
			
			          <label class="branch-label" for="br_${b.branchId}" title="${b.branchName}">
			            <c:out value="${b.branchName}" />
			          </label>
			        </div>
			      </c:forEach>
			    </c:otherwise>
			  </c:choose>
			</div>


            <div class="form-text mt-2" id="branchCountText">선택된 지점: 0개</div>
          </div>

          <div class="d-flex gap-2">
            <button type="submit" class="btn btn-primary">
              <c:choose>
                <c:when test="${empty notice.noticeId}">등록</c:when>
                <c:otherwise>저장</c:otherwise>
              </c:choose>
            </button>
            <a href="<c:url value='${backToList}'/>" class="btn btn-secondary">취소</a>
          </div>

        </form>
      </div>
    </div>
  </div>
</div>

<script>
  document.addEventListener("DOMContentLoaded", function () {
    var targetTypeSelect = document.getElementById("targetType");
    var branchArea = document.getElementById("branchTargetArea");
    if (!targetTypeSelect || !branchArea) return;

    var searchInput = document.getElementById("branchSearch");
    var btnSelectAll = document.getElementById("btnSelectAll");
    var btnUnselectAll = document.getElementById("btnUnselectAll");
    var countText = document.getElementById("branchCountText");
    var items = branchArea.querySelectorAll(".branch-item");

    function toggleBranchArea() {
      if (targetTypeSelect.value === "TT002") {
        branchArea.style.display = "block";
      } else {
        branchArea.style.display = "none";
        branchArea.querySelectorAll("input[name='branchIds']").forEach(function (cb) { cb.checked = false; });
        updateCount();
      }
    }

    function normalize(s) { return (s || "").toLowerCase().replace(/\s+/g, ""); }

    function filterBranches() {
      if (!searchInput) return;
      var q = normalize(searchInput.value);
      items.forEach(function (item) {
        var name = normalize(item.getAttribute("data-name"));
        item.style.display = (!q || name.indexOf(q) !== -1) ? "" : "none";
      });
    }

    function visibleCheckboxes() {
      return Array.from(items)
        .filter(function (item) { return item.style.display !== "none"; })
        .map(function (item) { return item.querySelector("input[name='branchIds']"); })
        .filter(Boolean);
    }

    function updateCount() {
      if (!countText) return;
      var checked = branchArea.querySelectorAll("input[name='branchIds']:checked").length;
      countText.textContent = "선택된 지점: " + checked + "개";
    }

    toggleBranchArea();
    filterBranches();
    updateCount();

    targetTypeSelect.addEventListener("change", function () {
      toggleBranchArea();
      filterBranches();
      updateCount();
    });

    if (searchInput) searchInput.addEventListener("input", function () {
      filterBranches();
      // 검색 후 보이는 항목 기준 카운트는 그대로 "체크된 전체"로 유지(원하면 visible checked로 변경 가능)
      updateCount();
    });

    if (btnSelectAll) btnSelectAll.addEventListener("click", function () {
      visibleCheckboxes().forEach(function (cb) { cb.checked = true; });
      updateCount();
    });

    if (btnUnselectAll) btnUnselectAll.addEventListener("click", function () {
      visibleCheckboxes().forEach(function (cb) { cb.checked = false; });
      updateCount();
    });

    branchArea.addEventListener("change", function (e) {
      if (e.target && e.target.matches("input[name='branchIds']")) {
        updateCount();
      }
    });
  });
</script>

<script>
  document.addEventListener("DOMContentLoaded", function () {
    var form = document.getElementById("noticeForm");
    if (!form) return;

    var sD = document.getElementById("publishStartDateOnly");
    var sT = document.getElementById("publishStartTimeOnly");
    var eD = document.getElementById("publishEndDateOnly");
    var eT = document.getElementById("publishEndTimeOnly");

    var sH = document.getElementById("publishStartHidden");
    var eH = document.getElementById("publishEndHidden");

    form.addEventListener("submit", function (ev) {
      var hasStartDate = !!(sD && sD.value);
      var hasStartTime = !!(sT && sT.value);

      if (hasStartDate !== hasStartTime) {
        ev.preventDefault();
        alert("게시 시작일과 시작시간은 함께 입력해야 합니다.");
        return;
      }

      if (hasStartDate && hasStartTime) {
        sH.value = sD.value + "T" + sT.value; // yyyy-MM-ddTHH:mm
      } else {
        sH.value = "";
      }

      var hasEndDate = !!(eD && eD.value);
      var hasEndTime = !!(eT && eT.value);

      if (hasEndDate !== hasEndTime) {
        ev.preventDefault();
        alert("게시 종료일과 종료시간은 함께 입력해야 합니다.");
        return;
      }

      if (hasEndDate && hasEndTime) {
        eH.value = eD.value + "T" + eT.value;
      } else {
        eH.value = "";
      }

      if (sH.value && eH.value) {
        var start = new Date(sH.value);
        var end = new Date(eH.value);
        if (end < start) {
          ev.preventDefault();
          alert("게시 종료일시는 시작일시보다 빠를 수 없습니다.");
        }
      }
    });
  });
</script>

<jsp:include page="../includes/admin_footer.jsp" />
