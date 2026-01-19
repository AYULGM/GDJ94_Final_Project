<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!-- 다건 내역 JSON 저장 -->
<input type="hidden" name="extTxt6" id="expenseItemsJson" />

<div class="row g-3">

  <!-- 지점 -->
  <div class="col-md-6">
    <label class="form-label required-label">지점</label>
    <select class="form-select" name="extNo1" id="branchId" required>
      <option value="">지점 선택</option>
      <c:forEach var="b" items="${branches}">
        <option value="${b.branchId}">
          <c:out value="${b.branchName}"/>
        </option>
      </c:forEach>
    </select>
  </div>

  <!-- 합계금액(자동) : extNo2 사용 -->
  <div class="col-md-6">
    <label class="form-label">합계금액</label>
    <input type="number" class="form-control bg-secondary-subtle" name="extNo2" id="expenseTotal" readonly />
  </div>



  <!-- 지출 내역(다건) -->
  <div class="col-12">
    <div class="d-flex justify-content-between align-items-center">
      <label class="form-label mb-0">지출 내역</label>
      <button type="button" class="btn btn-outline-secondary btn-sm" id="btnAddExpenseRow">+ 행 추가</button>
    </div>

    <div class="table-responsive mt-2">
      <table class="table table-sm table-bordered align-middle" id="expenseTable">
        <thead class="table-light">
          <tr>
            <th class="required-label">지출 항목</th>
            <th style="width: 140px;" class="required-label">지출금액</th>
            <th style="width: 150px;" class="required-label">지출 일자</th>
            <th>비고</th>
            <th style="width: 80px;"></th>
          </tr>
        </thead>
        <tbody>
          <!-- 기본 1행 -->
          <tr>
			  <td>
			    <select class="form-select form-select-sm ex-item" required>
			      <option value="">선택</option>
			      <option value="SALARY">급여</option>
			      <option value="RENT">임대료</option>
			      <option value="UTILITY">공과금</option>
			      <option value="SUPPLIES">비품</option>
			      <option value="ETC">기타</option>
			    </select>
			
			    <!-- 기타 선택 시만 입력 활성화 -->
			    <input type="text" class="form-control form-control-sm ex-item-etc mt-1 d-none"
			           maxlength="200" placeholder="기타 항목 입력" />
			  </td>
			
			  <td><input type="number" class="form-control form-control-sm ex-amt text-end" min="0" step="1" required /></td>
			  <td><input type="date" class="form-control form-control-sm ex-date" required /></td>
			  <td><input type="text" class="form-control form-control-sm ex-memo" maxlength="200" /></td>
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
  const tbody = document.querySelector("#expenseTable tbody");
  const btnAdd = document.getElementById("btnAddExpenseRow");
  const totalEl = document.getElementById("expenseTotal");
  const jsonEl  = document.getElementById("expenseItemsJson");

  function recalc() {
	  const rows = Array.from(tbody.querySelectorAll("tr"));
	  let total = 0;

	  const items = rows.map(r => {
	    const itemCode = (r.querySelector(".ex-item").value || "").trim();
	    const etcEl = r.querySelector(".ex-item-etc");
	    const itemEtc = (etcEl?.value || "").trim();

	    // 표시용 이름(원하시면 서버에서 코드로 처리해도 됨)
	    const itemNameMap = {
	      SALARY: "급여",
	      RENT: "임대료",
	      UTILITY: "공과금",
	      SUPPLIES: "비품",
	      ETC: "기타"
	    };
	    function toggleEtcInput(tr) {
	    	  const sel = tr.querySelector(".ex-item");
	    	  const etc = tr.querySelector(".ex-item-etc");
	    	  if (!sel || !etc) return;

	    	  if (sel.value === "ETC") {
	    	    etc.classList.remove("d-none");
	    	  } else {
	    	    etc.value = "";
	    	    etc.classList.add("d-none");
	    	  }
	    	}

	    	tbody.addEventListener("change", (e) => {
	    	  const tr = e.target.closest("tr");
	    	  if (!tr) return;

	    	  if (e.target.classList.contains("ex-item")) {
	    	    toggleEtcInput(tr);
	    	  }
	    	  recalc();
	    	});
	    	

	    const amount = Number(r.querySelector(".ex-amt").value || 0);
	    const date  = r.querySelector(".ex-date").value || "";
	    const memo  = (r.querySelector(".ex-memo").value || "").trim();

	    total += amount;

	    return {
	      itemCode,                               // 코드 저장(추천)
	      itemName: itemNameMap[itemCode] || "",  // 라벨 저장(선택)
	      itemEtc: itemCode === "ETC" ? itemEtc : "",
	      amount, date, memo
	    };
	  });

	  totalEl.value = total;
	  jsonEl.value = JSON.stringify(items);
	}


  btnAdd.addEventListener("click", () => {
    const tr = document.createElement("tr");
    tr.innerHTML = `
    	  <td>
    	    <select class="form-select form-select-sm ex-item" required>
    	      <option value="">선택</option>
    	      <option value="SALARY">급여</option>
    	      <option value="RENT">임대료</option>
    	      <option value="UTILITY">공과금</option>
    	      <option value="SUPPLIES">비품</option>
    	      <option value="ETC">기타</option>
    	    </select>
    	    <input type="text" class="form-control form-control-sm ex-item-etc mt-1 d-none"
    	           maxlength="200" placeholder="기타 항목 입력" />
    	  </td>
    	  <td><input type="number" class="form-control form-control-sm ex-amt text-end" min="0" step="1" required /></td>
    	  <td><input type="date" class="form-control form-control-sm ex-date" required /></td>
    	  <td><input type="text" class="form-control form-control-sm ex-memo" maxlength="200" /></td>
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
