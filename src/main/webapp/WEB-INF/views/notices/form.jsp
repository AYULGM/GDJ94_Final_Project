<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<jsp:include page="../includes/admin_header.jsp" />

<div class="row">
  <div class="col-12">
    <div class="card">
      <div class="card-header d-flex align-items-center justify-content-between">
        <h3 class="card-title mb-0">공지 등록</h3>
        <a class="btn btn-outline-secondary btn-sm" href="<c:url value='/notices'/>">목록</a>
      </div>

      <div class="card-body">
        <form method="post" action="<c:url value='/notices'/>">

          <div class="mb-3">
            <label class="form-label">제목</label>
            <input type="text" name="title" class="form-control" required />
          </div>

          <div class="mb-3">
            <label class="form-label">내용</label>
            <textarea name="content" class="form-control" rows="7" required></textarea>
          </div>

          <!-- 옵션 1줄: 공지유형 / 대상 / 상태 / 카테고리 -->
          <div class="row g-3 mb-3">
            <div class="col-md-3">
              <label class="form-label">공지 유형</label>
              <select name="noticeType" class="form-select" required>
                <c:choose>
                  <c:when test="${empty noticeTypes}">
                    <option value="NT001">긴급</option>
                    <option value="NT002" selected>일반</option>
                    <option value="NT003">이벤트</option>
                  </c:when>
                  <c:otherwise>
                    <c:forEach items="${noticeTypes}" var="c">
                      <option value="${c.code}">${c.codeDesc}</option>
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
                    <option value="TT001" selected>전체</option>
                    <option value="TT002">지점</option>
                  </c:when>
                  <c:otherwise>
                    <c:forEach items="${targetTypes}" var="c">
                      <option value="${c.code}">${c.codeDesc}</option>
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
                    <option value="NS001" selected>게시</option>
					<option value="NS002">임시저장</option>
					<option value="NS003">종료</option>
                  </c:when>
                  <c:otherwise>
                    <c:forEach items="${statusCodes}" var="c">
                      <option value="${c.code}">${c.codeDesc}</option>
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
                    <option value="CAT001" selected>일반</option>
                    <option value="CAT002">운영</option>
                    <option value="CAT003">이벤트</option>
                  </c:when>
                  <c:otherwise>
                    <c:forEach items="${categories}" var="c">
                      <option value="${c.code}">${c.codeDesc}</option>
                    </c:forEach>
                  </c:otherwise>
                </c:choose>
              </select>
            </div>
          </div>

          <!-- 옵션 2줄: 게시 시작 / 게시 종료 -->
          <div class="row g-3 mb-3">
            <div class="col-md-3">
              <label class="form-label">게시 시작</label>
              <input type="datetime-local" name="publishStartDate" class="form-control" />
            </div>

            <div class="col-md-3">
              <label class="form-label">게시 종료</label>
              <input type="datetime-local" name="publishEndDate" class="form-control" />
            </div>
          </div>

          <!-- 사유 + 상단고정 (같은 row로 정상 배치) -->
          <div class="row g-3 mb-3">
            <div class="col-md-9">
              <label class="form-label">사유(이력)</label>
              <input type="text" name="reason" class="form-control" placeholder="예: 신규 공지 등록" />
            </div>

            <div class="col-md-3 d-flex align-items-end">
              <div class="form-check">
                <input class="form-check-input" type="checkbox" name="isPinned" value="true" id="isPinned">
                <label class="form-check-label" for="isPinned">상단 고정</label>
              </div>
            </div>
          </div>

          <!-- 대상 지점(지점 공지일 때만) -->
          <div class="mb-3" id="branchTargetArea">
            <label class="form-label">대상 지점 (지점 공지일 때만)</label>
            <div class="form-text mb-2">targetType이 지점(TT002)일 때 선택하세요.</div>

            <div class="d-flex gap-2 mb-2">
              <input type="text" id="branchSearch" class="form-control form-control-sm" placeholder="지점 검색(예: 서울, 인천 등)" />
              <button type="button" class="btn btn-outline-secondary btn-sm" id="btnSelectAll">전체선택</button>
              <button type="button" class="btn btn-outline-secondary btn-sm" id="btnUnselectAll">전체해제</button>
            </div>

            <div class="border rounded p-2" id="branchListBox" style="max-height: 260px; overflow: auto;">
              <c:choose>
                <c:when test="${empty branches}">
                  <div class="text-muted">지점 목록이 없습니다.</div>
                </c:when>
                <c:otherwise>
                  <c:forEach items="${branches}" var="b">
                    <div class="form-check branch-item" data-name="${b.branchName}">
                      <input class="form-check-input branch-cb"
                             type="checkbox"
                             name="branchIds"
                             value="${b.branchId}"
                             id="br_${b.branchId}">
                      <label class="form-check-label" for="br_${b.branchId}">
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
            <button type="submit" class="btn btn-primary">등록</button>
            <a href="<c:url value='/notices'/>" class="btn btn-secondary">취소</a>
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
        // 전체 공지면 체크 해제
        branchArea.querySelectorAll("input[name='branchIds']").forEach(function (cb) {
          cb.checked = false;
        });
        updateCount();
      }
    }

    function normalize(s) {
      return (s || "").toLowerCase().replace(/\s+/g, "");
    }

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

    // 초기
    toggleBranchArea();
    updateCount();

    targetTypeSelect.addEventListener("change", function () {
      toggleBranchArea();
      filterBranches();
      updateCount();
    });

    if (searchInput) searchInput.addEventListener("input", filterBranches);

    if (btnSelectAll) btnSelectAll.addEventListener("click", function () {
      visibleCheckboxes().forEach(function (cb) { cb.checked = true; });
      updateCount();
    });

    if (btnUnselectAll) btnUnselectAll.addEventListener("click", function () {
      visibleCheckboxes().forEach(function (cb) { cb.checked = false; });
      updateCount();
    });

    // 이벤트 위임
    branchArea.addEventListener("change", function (e) {
      if (e.target && e.target.matches("input[name='branchIds']")) {
        updateCount();
      }
    });
  });
</script>

<jsp:include page="../includes/admin_footer.jsp" />
