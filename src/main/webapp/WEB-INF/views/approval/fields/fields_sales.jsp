<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!-- 다건 내역 JSON 저장 -->
<input type="hidden" name="extTxt6" id="salesItemsJson" />

<div class="row g-3">

  <!-- 지점 : extNo1 = branchId -->
  <div class="col-md-6">
    <label class="form-label"><span style="color:red;">*</span>지점</label>
    <select class="form-select" name="extNo1" id="salesBranchId" required>
      <option value="">지점 선택</option>
      <c:forEach var="b" items="${branches}">
        <option value="${b.branchId}">
          <c:out value="${b.branchName}"/>
        </option>
      </c:forEach>
    </select>
  </div>

  <!-- 합계금액(자동) : extNo2 -->
  <div class="col-md-6">
    <label class="form-label">합계금액</label>
    <input type="number" class="form-control bg-secondary-subtle" name="extNo2" id="salesTotal" readonly />
  </div>

  <!-- 비고(공통) : extTxt2 -->
  <div class="col-12">
    <label class="form-label">비고</label>
    <input type="text" class="form-control" name="extTxt2" maxlength="500" />
  </div>

  <!-- 매출 내역(다건) -->
  <div class="col-12">
    <div class="d-flex justify-content-between align-items-center">
      <label class="form-label mb-0">매출 내역</label>
      <button type="button" class="btn btn-outline-secondary btn-sm" id="btnAddSalesRow">+ 행 추가</button>
    </div>

    <div class="table-responsive mt-2">
      <table class="table table-sm table-bordered align-middle" id="salesTable">
        <thead class="table-light">
          <tr>
            <th style="width: 180px;"><span style="color:red;">*</span>매출 항목</th>
            <th style="width: 140px;"><span style="color:red;">*</span>매출 금액</th>
            <th style="width: 150px;"><span style="color:red;">*</span>판매일자</th>
            <th>비고</th>
            <th style="width: 80px;"></th>
          </tr>
        </thead>
        <tbody>
          <!-- 기본 1행 -->
          <tr>
            <td>
              <select class="form-select form-select-sm sl-type" required>
                <option value="">선택</option>
                <option value="MEMBERSHIP">회원권</option>
                <option value="PT">PT</option>
                <option value="PRODUCT">상품</option>
                <option value="ETC">기타</option>
              </select>
            </td>
            <td><input type="number" class="form-control form-control-sm sl-amt text-end" min="0" step="1" required /></td>
            <td><input type="date" class="form-control form-control-sm sl-date" required /></td>
            <td><input type="text" class="form-control form-control-sm sl-memo" maxlength="200" /></td>
            <td class="text-center">
              <button type="button" class="btn btn-outline-danger btn-sm btnDelRow">삭제</button>
            </td>
          </tr>
        </tbody>
      </table>

      
    </div>
  </div>

</div>

<script>
(function() {
  const tbody = document.querySelector("#salesTable tbody");
  const btnAdd = document.getElementById("btnAddSalesRow");
  const totalEl = document.getElementById("salesTotal");
  const jsonEl  = document.getElementById("salesItemsJson");

  function recalc() {
    const rows = Array.from(tbody.querySelectorAll("tr"));
    let total = 0;

    const items = rows.map(r => {
      const type   = r.querySelector(".sl-type").value || "";
      const amount = Number(r.querySelector(".sl-amt").value || 0);
      const date   = r.querySelector(".sl-date").value || "";
      const memo   = (r.querySelector(".sl-memo").value || "").trim();

      total += amount;
      return { type, amount, date, memo };
    });

    totalEl.value = total;
    jsonEl.value = JSON.stringify(items);
  }

  btnAdd.addEventListener("click", () => {
    const tr = document.createElement("tr");
    tr.innerHTML = `
      <td>
        <select class="form-select form-select-sm sl-type" required>
          <option value="">선택</option>
          <option value="MEMBERSHIP">회원권</option>
          <option value="PT">PT</option>
          <option value="PRODUCT">상품</option>
          <option value="ETC">기타</option>
        </select>
      </td>
      <td><input type="number" class="form-control form-control-sm sl-amt text-end" min="0" step="1" required /></td>
      <td><input type="date" class="form-control form-control-sm sl-date" required /></td>
      <td><input type="text" class="form-control form-control-sm sl-memo" maxlength="200" /></td>
      <td class="text-center"><button type="button" class="btn btn-outline-danger btn-sm btnDelRow">삭제</button></td>
    `;
    tbody.appendChild(tr);
    recalc();
  });

  tbody.addEventListener("input", recalc);
  tbody.addEventListener("change", recalc);

  tbody.addEventListener("click", (e) => {
    if (!e.target.classList.contains("btnDelRow")) return;

    const rows = tbody.querySelectorAll("tr");
    if (rows.length <= 1) return; // 최소 1행 유지
    e.target.closest("tr").remove();
    recalc();
  });

  recalc();
})();
</script>
