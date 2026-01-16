<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<input type="hidden" name="extTxt6" id="prItemsJson" />

<div class="row g-2">
  <div class="col-md-4">
    <label class="form-label required-label">희망 납기일</label>
    <input type="date" class="form-control" name="extDt1" />
  </div>

  <div class="col-md-4">
    <label class="form-label">거래처</label>
    <input type="text" class="form-control" name="extTxt1" maxlength="100" />
  </div>

  <div class="col-md-4">
    <label class="form-label">예상 합계</label>
    <input type="number" class="form-control bg-secondary-subtle" name="extNo1" id="prTotal" readonly />
  </div>

  <div class="col-12 mt-2">
    <div class="d-flex justify-content-between align-items-center">
      <label class="form-label mb-0">구매 품목</label>
      <button type="button" class="btn btn-outline-secondary btn-sm" id="btnAddPrRow">+ 행 추가</button>
    </div>



    <div class="table-responsive mt-2">
      <table class="table table-sm table-bordered align-middle" id="prTable">
        <thead class="table-light">
          <tr>
            <th class="required-label">품목명</th>
            <th style="width: 110px;" class="required-label">수량</th>
            <th style="width: 140px;">예상단가</th>
            <th style="width: 140px;">금액</th>
            <th style="width: 80px;"></th>
          </tr>
        </thead>
        <tbody>
        
		  <tr>
		    <td>
		      <select class="form-select form-select-sm pr-product">
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
		      <input type="number" class="form-control form-control-sm pr-qty text-end"
		             min="1" step="1" value="1" />
		    </td>
		    <td>
		      <input type="number" class="form-control form-control-sm pr-unit text-end" readonly />
		    </td>
		    <td>
		      <input type="number" class="form-control form-control-sm pr-amt text-end bg-secondary-subtle" readonly />
		    </td>
		    <td class="text-center">
		      <button type="button" class="btn btn-outline-danger btn-sm btnDelRow">삭제</button>
		    </td>
		  </tr>
		</tbody>

      </table>
    </div>
  </div>

  <div class="col-12">
    <label class="form-label mt-2">비고</label>
    <input type="text" class="form-control" name="extTxt3" maxlength="200" />
  </div>
</div>
<script>
(function () {
  const tbody = document.querySelector("#prTable tbody");
  const btnAdd = document.getElementById("btnAddPrRow");
  const totalEl = document.getElementById("prTotal");
  const jsonEl  = document.getElementById("prItemsJson");

  function recalc() {
    let total = 0;
    const items = [];

    tbody.querySelectorAll("tr").forEach(r => {
      const sel = r.querySelector(".pr-product");
      if (!sel || !sel.value) return;

      const opt = sel.selectedOptions[0];
      const qty = Number(r.querySelector(".pr-qty").value || 0);
      const unitPrice = Number(opt.dataset.price || 0);
      const amt = qty * unitPrice;

      r.querySelector(".pr-unit").value = unitPrice;
      r.querySelector(".pr-amt").value  = amt;

      total += amt;

      items.push({
        productId: Number(sel.value),
        productName: opt.dataset.name,
        qty,
        unitPrice,
        amount: amt
      });
    });

    totalEl.value = total;
    jsonEl.value  = JSON.stringify(items);
  }

  // ✅ 핵심 수정 포인트
  btnAdd.addEventListener("click", () => {
    const firstSelect = tbody.querySelector(".pr-product");

    const tr = document.createElement("tr");
    tr.innerHTML = `
      <td></td>
      <td>
        <input type="number" class="form-control form-control-sm pr-qty text-end"
               min="1" step="1" value="1" />
      </td>
      <td>
        <input type="number" class="form-control form-control-sm pr-unit text-end" readonly />
      </td>
      <td>
        <input type="number" class="form-control form-control-sm pr-amt text-end bg-secondary-subtle" readonly />
      </td>
      <td class="text-center">
        <button type="button" class="btn btn-outline-danger btn-sm btnDelRow">삭제</button>
      </td>
    `;

    // 🔑 최초 행의 select를 그대로 복제
    const clonedSelect = firstSelect.cloneNode(true);
    clonedSelect.value = ""; // 선택 초기화
    tr.querySelector("td").appendChild(clonedSelect);

    tbody.appendChild(tr);
  });

  tbody.addEventListener("change", recalc);
  tbody.addEventListener("input", recalc);

  tbody.addEventListener("click", e => {
    if (e.target.classList.contains("btnDelRow")) {
      e.target.closest("tr").remove();
      recalc();
    }
  });

})();
</script>
