<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<input type="hidden" name="extTxt6" id="poItemsJson" />

<div class="row g-2">
  <div class="col-md-4">
    <label class="form-label"><span style="color:red; font-weight: normal;">*</span>거래처명</label>
    <input type="text" class="form-control" name="extTxt1" maxlength="100" required />
  </div>

  <div class="col-md-4">
    <label class="form-label">담당자</label>
    <input type="text" class="form-control" name="extTxt4" maxlength="100" placeholder="담당자명" />
  </div>

  <div class="col-md-4">
    <label class="form-label"><span style="color:red; font-weight: normal;">*</span>납기일</label>
    <input type="date" class="form-control" name="extDt1" required />
  </div>

  <div class="col-md-8">
    <label class="form-label mt-2">결제조건</label>
    <input type="text" class="form-control" name="extTxt3" maxlength="200" placeholder="예: 납품 후 30일 이내" />
  </div>

  <div class="col-md-4">
    <label class="form-label mt-2">총액</label>
    <input type="number" class="form-control bg-secondary-subtle" name="extNo1" id="poTotal" readonly />
  </div>

  <div class="col-12 mt-2">
    <div class="d-flex justify-content-between align-items-center">
      <label class="form-label mb-0">발주 품목</label>
      <button type="button" class="btn btn-outline-secondary btn-sm" id="btnAddPoRow">+ 행 추가</button>
    </div>

    <div class="table-responsive mt-2">
      <!-- ✅ id를 poTable로 통일 -->
      <table class="table table-sm table-bordered align-middle" id="poTable">
        <thead class="table-light">
          <tr>
            <th><span style="color:red; font-weight: normal;">*</span>품목명</th>
            <th style="width: 110px;"><span style="color:red; font-weight: normal;">*</span>수량</th>
            <th style="width: 140px;">예상단가</th>
            <th style="width: 140px;">금액</th>
            <th style="width: 80px;"></th>
          </tr>
        </thead>

        <tbody>
          <tr>
            <td>
              <!-- ✅ class를 po-product로 통일 -->
              <select class="form-select form-select-sm po-product">
                <option value="">상품 선택</option>
                <c:forEach items="${products}" var="p">
                  <option value="${p.productId}"
                          data-name="${p.productName}"
                          data-price="${p.price}">
                    ${p.productName}
                  </option>
                </c:forEach>
              </select>
            </td>

            <td>
              <input type="number" class="form-control form-control-sm po-qty text-end"
                     min="1" step="1" value="1" />
            </td>
            <td>
              <input type="number" class="form-control form-control-sm po-unit text-end"
                     min="0" step="1" />
            </td>
            <td>
              <input type="number" class="form-control form-control-sm po-amt text-end bg-secondary-subtle" readonly />
            </td>
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
  const tbody  = document.querySelector("#poTable tbody");
  const btnAdd = document.getElementById("btnAddPoRow");
  const totalEl = document.getElementById("poTotal");
  const jsonEl  = document.getElementById("poItemsJson");

  if (!tbody || !btnAdd || !totalEl || !jsonEl) {
    console.error("PO 요소 탐색 실패", { tbody, btnAdd, totalEl, jsonEl });
    return;
  }

  function recalc() {
    let total = 0;
    const items = [];

    tbody.querySelectorAll("tr").forEach(r => {
      const sel = r.querySelector(".po-product");
      if (!sel || !sel.value) return;

      const opt = sel.selectedOptions[0];

      const qty = Number(r.querySelector(".po-qty")?.value || 0);

      // 단가: 사용자가 입력하면 입력값 우선, 아니면 옵션 price
      const unitInput = r.querySelector(".po-unit");
      const basePrice = Number(opt?.dataset?.price || 0);
      const typedUnit = Number(unitInput?.value || 0);
      const unitPrice = typedUnit > 0 ? typedUnit : basePrice;

      if (unitInput) unitInput.value = unitPrice;

      const amt = qty * unitPrice;
      const amtEl = r.querySelector(".po-amt");
      if (amtEl) amtEl.value = amt;

      total += amt;

      items.push({
        productId: Number(sel.value),
        productName: opt?.dataset?.name || opt?.textContent?.trim() || "",
        qty,
        unitPrice,
        amount: amt
      });
    });

    totalEl.value = total;
    jsonEl.value  = JSON.stringify(items);
  }

  btnAdd.addEventListener("click", (e) => {
    e.preventDefault();

    const firstSelect = tbody.querySelector(".po-product");
    if (!firstSelect) return;

    const tr = document.createElement("tr");
    tr.innerHTML = `
      <td></td>
      <td><input type="number" class="form-control form-control-sm po-qty text-end" min="1" step="1" value="1" /></td>
      <td><input type="number" class="form-control form-control-sm po-unit text-end" min="0" step="1" /></td>
      <td><input type="number" class="form-control form-control-sm po-amt text-end bg-secondary-subtle" readonly /></td>
      <td class="text-center"><button type="button" class="btn btn-outline-danger btn-sm btnDelRow">삭제</button></td>
    `;

    // 첫 행의 상품 select 그대로 복제
    const clonedSelect = firstSelect.cloneNode(true);
    clonedSelect.value = "";
    tr.querySelector("td").appendChild(clonedSelect);

    tbody.appendChild(tr);
    recalc();
  });

  tbody.addEventListener("change", recalc);
  tbody.addEventListener("input", recalc);

  tbody.addEventListener("click", (e) => {
    if (e.target.classList.contains("btnDelRow")) {
      e.preventDefault();
      e.target.closest("tr").remove();
      recalc();
    }
  });

  recalc();
})();
</script>
