<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<input type="hidden" name="extTxt6" id="poItemsJson" />

<div class="row g-2">

  <div class="col-md-4">
    <label class="form-label">담당자</label>
    <input type="text" class="form-control bg-secondary-subtle" name="extTxt4" maxlength="100"
           value='${loginUser.name}' readonly />
  </div>

  <div class="col-md-4">
    <label class="form-label required-label">납기일</label>
    <input type="date" class="form-control" name="extDt1" required />
  </div>

  <div class="col-md-4">
    <label class="form-label">총액</label>
    <input type="number" class="form-control bg-secondary-subtle" name="extNo1" id="poTotal" readonly />
  </div>

  <div class="col-12 mt-2">
    <div class="d-flex justify-content-between align-items-center">
      <label class="form-label mb-0">발주 품목</label>
      <button type="button" class="btn btn-outline-secondary btn-sm" id="btnAddPoRow">+ 행 추가</button>
    </div>

    <div class="table-responsive mt-2">
      <table class="table table-sm table-bordered align-middle" id="poTable">
        <thead class="table-light">
          <tr>
            <th class="required-label">품목명</th>
            <th style="width:110px;">본사 수량</th>
            <th style="width:110px;" class="required-label">수량</th>
            <th style="width:140px;">예상단가</th>
            <th style="width:140px;">금액</th>
            <th style="width:80px;"></th>
          </tr>
        </thead>

        <tbody>
          <tr>
            <td>
              <select class="form-select form-select-sm po-product">
                <option value="">상품 선택</option>
                <c:forEach items="${poProducts}" var="p">
                  <option value="${p.productId}"
                          data-name="${p.productName}"
                          data-price="${p.price}"
                          data-stock="${p.stockQty}">
                    ${p.productName}
                  </option>
                </c:forEach>
              </select>
            </td>

            <td>
              <input type="number"
                     class="form-control form-control-sm po-hqstock text-end bg-secondary-subtle"
                     value="0" readonly />
            </td>

            <td>
              <input type="number"
                     class="form-control form-control-sm po-qty text-end"
                     min="1" step="1" value="1" />
            </td>

            <td>
              <input type="number"
                     class="form-control form-control-sm po-unit text-end bg-secondary-subtle"
                     readonly min="0" step="1" />
            </td>

            <td>
              <input type="number"
                     class="form-control form-control-sm po-amt text-end bg-secondary-subtle"
                     readonly />
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
  const tbody   = document.querySelector("#poTable tbody");
  const btnAdd  = document.getElementById("btnAddPoRow");
  const totalEl = document.getElementById("poTotal");
  const jsonEl  = document.getElementById("poItemsJson");

  if (!tbody || !btnAdd || !totalEl || !jsonEl) {
    console.error("PO 요소 탐색 실패", { tbody, btnAdd, totalEl, jsonEl });
    return;
  }

  /** 선택된 상품의 본사재고(stock) 읽기 */
  function getHqStock(sel) {
    const opt = sel?.selectedOptions?.[0];
    return Number(opt?.dataset?.stock || 0);
  }

  /** 행 단위로 본사 수량 표시 + qty max 동기화 + (필요 시) 값 보정 */
  function syncRow(r, clampQty) {
    const sel   = r.querySelector(".po-product");
    const hqEl  = r.querySelector(".po-hqstock");
    const qtyEl = r.querySelector(".po-qty");

    if (!sel || !hqEl || !qtyEl) return;

    if (!sel.value) {
      hqEl.value = 0;
      qtyEl.disabled = false;
      qtyEl.removeAttribute("max");
      if (clampQty) {
        // 상품 미선택이면 qty는 기본 1 유지(원하면 빈값 처리 가능)
        if (!qtyEl.value) qtyEl.value = "1";
      }
      return;
    }

    const hqStock = getHqStock(sel);

    // 본사 수량 표시
    hqEl.value = String(hqStock);

    // max 동기화(브라우저 기본 검증용)
    qtyEl.max = String(hqStock);

    // 본사재고 0이면 입력 막기
    if (hqStock <= 0) {
      qtyEl.value = "";
      qtyEl.disabled = true;
      return;
    }

    qtyEl.disabled = false;

    if (clampQty) {
      let v = Number(qtyEl.value || 0);
      if (v < 1) v = 1;
      if (v > hqStock) v = hqStock;
      qtyEl.value = String(v);
    }
  }

  /** 전체 합계/JSON 계산 */
  function recalc() {
    let total = 0;
    const items = [];

    tbody.querySelectorAll("tr").forEach(r => {
      const sel = r.querySelector(".po-product");
      const qtyEl = r.querySelector(".po-qty");
      const unitEl = r.querySelector(".po-unit");
      const amtEl = r.querySelector(".po-amt");
      if (!sel || !qtyEl || !unitEl || !amtEl) return;

      if (!sel.value) {
        // 선택 안 된 행은 금액 초기화만(원하면 공란)
        amtEl.value = "";
        unitEl.value = "";
        return;
      }

      const opt = sel.selectedOptions[0];
      const qty = Number(qtyEl.value || 0);

      const basePrice = Number(opt?.dataset?.price || 0);
      const unitPrice = basePrice; // po-unit이 readonly라 basePrice만 사용
      unitEl.value = String(unitPrice);

      const amt = qty * unitPrice;
      amtEl.value = String(amt);

      total += amt;

      items.push({
        productId: Number(sel.value),
        productName: opt?.dataset?.name || opt?.textContent?.trim() || "",
        qty,
        unitPrice,
        amount: amt
      });
    });

    totalEl.value = String(total);
    jsonEl.value  = JSON.stringify(items);
  }

  /** 행 추가 */
  btnAdd.addEventListener("click", (e) => {
    e.preventDefault();

    const firstSelect = tbody.querySelector(".po-product");
    if (!firstSelect) return;

    const tr = document.createElement("tr");
    tr.innerHTML = `
      <td></td>
      <td>
        <input type="number"
               class="form-control form-control-sm po-hqstock text-end bg-secondary-subtle"
               value="0" readonly />
      </td>
      <td>
        <input type="number"
               class="form-control form-control-sm po-qty text-end"
               min="1" step="1" value="1" />
      </td>
      <td>
        <input type="number"
               class="form-control form-control-sm po-unit text-end bg-secondary-subtle"
               readonly min="0" step="1" />
      </td>
      <td>
        <input type="number"
               class="form-control form-control-sm po-amt text-end bg-secondary-subtle"
               readonly />
      </td>
      <td class="text-center">
        <button type="button" class="btn btn-outline-danger btn-sm btnDelRow">삭제</button>
      </td>
    `;

    const clonedSelect = firstSelect.cloneNode(true);
    clonedSelect.value = "";
    tr.querySelector("td").appendChild(clonedSelect);

    tbody.appendChild(tr);
    // 새 행은 아직 상품 미선택이므로 기본 표시만
    syncRow(tr, true);
    recalc();
  });

  /** 상품 선택 변경: 본사수량 표시/최대수량 동기화/값 보정 */
  tbody.addEventListener("change", (e) => {
    if (e.target.classList.contains("po-product")) {
      const r = e.target.closest("tr");
      syncRow(r, true);
      recalc();
      return;
    }
    recalc();
  });

  /** 수량 입력 시 즉시 최대 제한(본사재고 초과 불가) */
  tbody.addEventListener("input", (e) => {
    if (e.target.classList.contains("po-qty")) {
      const r = e.target.closest("tr");
      // 입력 즉시 clamp
      syncRow(r, true);
      recalc();
      return;
    }
    recalc();
  });

  /** 행 삭제 */
  tbody.addEventListener("click", (e) => {
    if (e.target.classList.contains("btnDelRow")) {
      e.preventDefault();
      e.target.closest("tr")?.remove();
      recalc();
    }
  });

  // 초기 1행도 동기화
  tbody.querySelectorAll("tr").forEach(r => syncRow(r, true));
  recalc();
})();
</script>
