<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<!-- 조정내역 JSON: extTxt6 -->
<input type="hidden" name="extTxt6" id="invItemsJson" />

<div class="row g-2">
  <div class="col-md-8">
    <label class="form-label">지점</label>
    <select class="form-select" name="extNo1" id="branchId" required>
      <option value="">지점 선택</option>
      <c:forEach var="b" items="${branches}">
        <option value="${b.branchId}"><c:out value="${b.branchName}"/></option>
      </c:forEach>
    </select>
    <div class="form-text">extNo1 = branchId</div>
  </div>

  <div class="col-md-4">
    <label class="form-label">작성일</label>
    <input type="date" class="form-control" name="extDt1" required />
    <div class="form-text">extDt1 = 작성일</div>
  </div>

  <div class="col-md-8">
    <label class="form-label mt-2">상품</label>
    <select class="form-select" name="extNo2" id="productId" required>
      <option value="">상품 선택</option>
      <c:forEach var="p" items="${products}">
        <option value="${p.productId}"
                data-price="${p.price}">
          <c:out value="${p.productName}"/>
          <c:if test="${not empty p.productDesc}">
            - <c:out value="${p.productDesc}"/>
          </c:if>
        </option>
      </c:forEach>
    </select>
    <div class="form-text">extNo2 = productId</div>
  </div>

  <div class="col-md-4">
    <label class="form-label mt-2">조정 유형</label>
    <div class="d-flex gap-3 align-items-center" style="height: 38px;">
      <label class="form-check mb-0">
        <input class="form-check-input" type="radio" name="extCode1" value="INCREASE" checked>
        <span class="form-check-label">증가</span>
      </label>
      <label class="form-check mb-0">
        <input class="form-check-input" type="radio" name="extCode1" value="DECREASE">
        <span class="form-check-label">감소</span>
      </label>
    </div>
    <div class="form-text">extCode1 = 조정유형</div>
  </div>

  <div class="col-md-4">
    <label class="form-label mt-2">조정 수량(절대값)</label>
    <input type="number" class="form-control" name="extNo3" id="adjustQty" min="1" step="1" required />
    <div class="form-text">extNo3 = 조정수량</div>
  </div>


  <div class="col-12 mt-2">
    <label class="form-label">조정 사유</label>
    <div class="d-flex flex-wrap gap-3">
      <label class="form-check mb-0"><input class="form-check-input" type="radio" name="extCode2" value="DAMAGED" checked> <span class="form-check-label">파손</span></label>
      <label class="form-check mb-0"><input class="form-check-input" type="radio" name="extCode2" value="LOST"> <span class="form-check-label">분실</span></label>
      <label class="form-check mb-0"><input class="form-check-input" type="radio" name="extCode2" value="MISINPUT"> <span class="form-check-label">오입력</span></label>
      <label class="form-check mb-0"><input class="form-check-input" type="radio" name="extCode2" value="ETC"> <span class="form-check-label">기타</span></label>
    </div>
    <div class="form-text">extCode2 = 조정사유</div>
  </div>

  <div class="col-12 mt-2">
    <label class="form-label">조정 내역</label>

    <!-- ✅ 추가/삭제 버튼 -->
    <div class="d-flex gap-2 mb-2">
      <button type="button" class="btn btn-sm btn-outline-primary" id="btnInvAdd">추가하기</button>
      <button type="button" class="btn btn-sm btn-outline-danger" id="btnInvDelete">선택삭제</button>
    </div>

    <div class="table-responsive">
      <table class="table table-sm table-bordered align-middle" id="invTable">
        <thead class="table-light">
          <tr>
            <th style="width:40px;" class="text-center">
              <input type="checkbox" id="invCheckAll" />
            </th>
            <th>조정 물품</th>
            <th style="width:120px;" class="text-center">유형</th>
            <th style="width:120px;" class="text-end">수량</th>
            <th style="width:180px;">조정 직원</th>
            <th>비고</th>
          </tr>
        </thead>

        <!-- ✅ 입력행 -->
        <tbody id="invInputTbody">
          <tr id="invInputRow">
            <td class="text-center">-</td>
            <td><input type="text" class="form-control form-control-sm inv-item" /></td>
            <td class="text-center"><input type="text" class="form-control form-control-sm inv-type text-center" readonly /></td>
            <td><input type="number" class="form-control form-control-sm inv-qty text-end" readonly /></td>
            <td><input type="text" class="form-control form-control-sm inv-operator" maxlength="50" /></td>
            <td><input type="text" class="form-control form-control-sm inv-remark" maxlength="100" /></td>
          </tr>
        </tbody>

        <!-- ✅ 누적행 -->
        <tbody id="invListTbody">
          <!-- JS로 누적 추가 -->
        </tbody>
      </table>
    </div>
  </div>
</div>

<script>
(function() {
  const branchSel  = document.getElementById("branchId");
  const productSel = document.getElementById("productId");
  const qtyEl      = document.getElementById("adjustQty");
  const jsonEl     = document.getElementById("invItemsJson");

  const inputRow    = document.getElementById("invInputRow");
  const invItem     = inputRow.querySelector(".inv-item");
  const invType     = inputRow.querySelector(".inv-type");
  const invQty      = inputRow.querySelector(".inv-qty");
  const invOperator = inputRow.querySelector(".inv-operator");
  const invRemark   = inputRow.querySelector(".inv-remark");

  const listTbody  = document.getElementById("invListTbody");

  const btnAdd     = document.getElementById("btnInvAdd");
  const btnDel     = document.getElementById("btnInvDelete");
  const chkAll     = document.getElementById("invCheckAll");

  function getAdjustType() {
    return document.querySelector("input[name='extCode1']:checked")?.value || "INCREASE";
  }
  function setAdjustType(value) {
    const r = document.querySelector(`input[name='extCode1'][value='${value}']`);
    if (r) r.checked = true;
  }
  function toInt(v) {
    const n = Number(v);
    if (!Number.isFinite(n)) return 0;
    return Math.max(0, Math.trunc(n));
  }

  function selectedProductText() {
    const opt = productSel.options[productSel.selectedIndex];
    return (opt?.text || "").trim();
  }
  function selectedPrice() {
    const opt = productSel.options[productSel.selectedIndex];
    const p = Number(opt?.dataset?.price);
    return Number.isFinite(p) ? p : null;
  }

  // ✅ 상단 입력만 초기화(지점/작성일/사유는 유지)
  function resetInputOnly() {
    productSel.value = "";
    qtyEl.value = "";
    setAdjustType("INCREASE");

    invItem.value = "";
    invType.value = "";
    invQty.value = "";
    invOperator.value = "";
    invRemark.value = "";

    if (chkAll) chkAll.checked = false;
  }

  // ✅ 누적 목록까지 초기화 (지점 변경 시 사용하는 정책)
  function resetAllRowsAndJson() {
    listTbody.innerHTML = "";
    jsonEl.value = "";
    resetInputOnly();
  }

  // ✅ product select 옵션 재구성 (DTO: productId, productName, productDesc, price)
  function rebuildProductOptions(products) {
    productSel.innerHTML = `<option value="">상품 선택</option>`;
    const frag = document.createDocumentFragment();

    (products || []).forEach(p => {
      const opt = document.createElement("option");
      opt.value = p.productId;
      if (p.price != null) opt.dataset.price = p.price;

      const label = (p.productName || "")
        + (p.productDesc ? ` - ${p.productDesc}` : "");
      opt.textContent = label;

      frag.appendChild(opt);
    });

    productSel.appendChild(frag);
  }

  // ✅ 지점 선택 시 해당 지점 상품 목록 로드
  async function loadProductsByBranch(branchId) {
  rebuildProductOptions([]);
  resetAllRowsAndJson();
  if (!branchId) return;

  try {
    const res = await fetch(`${pageContext.request.contextPath}/approval/products?branchId=` + encodeURIComponent(branchId), {
      headers: { "Accept": "application/json" }
    });
    if (!res.ok) throw new Error("HTTP " + res.status);

    const products = await res.json();
    rebuildProductOptions(products);
  } catch (e) {
    console.error(e);
    alert("상품 목록을 불러오지 못했습니다.");
    rebuildProductOptions([]);
  }
}

  

  // 입력행 미리보기 갱신(유형/수량 + 물품명 자동세팅)
  function recalcPreview() {
    const type = getAdjustType();
    const adj  = toInt(qtyEl.value);

    tr.innerHTML = `
    	  <td>\${type == "DECREASE" ? "감소" : "증가"}</td>
    	`;

    invQty.value  = adj ? String(adj) : "";

    if (productSel.value && !invItem.value.trim()) {
      invItem.value = selectedProductText();
    }
  }

  // 누적행 -> JSON 재생성(extTxt6)
  function rebuildJson() {
    const rows = Array.from(listTbody.querySelectorAll("tr.inv-row"));
    const items = rows.map(tr => ({
      branchId: toInt(branchSel.value),
      productId: Number(tr.dataset.productId),
      productName: (tr.querySelector(".col-name")?.textContent || "").trim(),
      adjustType: tr.dataset.adjustType || "INCREASE",
      adjustQty: Number(tr.dataset.adjustQty),
      signedQty: Number(tr.dataset.signedQty), // 증가:+, 감소:-
      operator: (tr.querySelector(".col-operator")?.textContent || "").trim(),
      remark: (tr.querySelector(".col-remark")?.textContent || "").trim(),
      price: tr.dataset.price ? Number(tr.dataset.price) : null
    })).filter(x => x.productId);

    jsonEl.value = items.length ? JSON.stringify(items) : "";
  }

  function addItem() {
    const branchId = toInt(branchSel.value);
    if (!branchId) {
      alert("지점을 선택하세요.");
      return;
    }

    const productId = toInt(productSel.value);
    if (!productId) {
      alert("상품을 선택하세요.");
      return;
    }

    const adj = toInt(qtyEl.value);
    if (adj <= 0) {
      alert("조정 수량을 입력하세요.");
      return;
    }

    const type = getAdjustType(); // INCREASE / DECREASE
    const signedQty = (type === "DECREASE") ? -adj : adj;

    const name = (invItem.value || "").trim() || selectedProductText();
    const operator = (invOperator.value || "").trim();
    const remark   = (invRemark.value || "").trim();
    const price    = selectedPrice();

    // ✅ 누적행 추가
    const tr = document.createElement("tr");
    tr.className = "inv-row";
    tr.dataset.productId = String(productId);
    tr.dataset.adjustType = type;
    tr.dataset.adjustQty  = String(adj);
    tr.dataset.signedQty  = String(signedQty);
    if (price != null) tr.dataset.price = String(price);

    tr.innerHTML = `
      <td class="text-center"><input type="checkbox" class="inv-chk" /></td>
      <td class="col-name"></td>
      <td class="text-center">${type == "DECREASE" ? "감소" : "증가"}</td>
      <td class="text-end">${adj}</td>
      <td class="col-operator"></td>
      <td class="col-remark"></td>
    `;

    tr.querySelector(".col-name").textContent = name;
    tr.querySelector(".col-operator").textContent = operator;
    tr.querySelector(".col-remark").textContent = remark;

    listTbody.appendChild(tr);
    rebuildJson();

    // ✅ 입력값 초기화(지점/작성일/사유는 그대로)
    resetInputOnly();
    productSel.focus();
  }

  function deleteChecked() {
    const checked = Array.from(listTbody.querySelectorAll(".inv-chk:checked"));
    checked.forEach(chk => chk.closest("tr")?.remove());
    if (chkAll) chkAll.checked = false;
    rebuildJson();
  }

  // 이벤트
  btnAdd.addEventListener("click", addItem);
  btnDel.addEventListener("click", deleteChecked);

  chkAll.addEventListener("change", () => {
    const on = chkAll.checked;
    listTbody.querySelectorAll(".inv-chk").forEach(c => c.checked = on);
  });

  // ✅ 지점 변경: 상품 재로딩
  branchSel.addEventListener("change", () => {
    loadProductsByBranch(branchSel.value);
  });

  // 상품 변경 시 물품명 자동세팅 + 미리보기 갱신
  productSel.addEventListener("change", () => {
    if (!productSel.value) {
      invItem.value = "";
      recalcPreview();
      return;
    }
    invItem.value = selectedProductText();
    recalcPreview();
  });

  document.querySelectorAll("input[name='extCode1']")
    .forEach(r => r.addEventListener("change", recalcPreview));

  qtyEl.addEventListener("input", recalcPreview);
  [invItem, invOperator, invRemark].forEach(el => el.addEventListener("input", recalcPreview));

  // 초기
  if (branchSel.value) {
    loadProductsByBranch(branchSel.value);
  } else {
    rebuildProductOptions([]); // 상품 목록 비움
    resetAllRowsAndJson();
  }
})();
</script>
