<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<div class="row g-3">

  <!-- 정산 기간 -->
  <div class="col-md-6">
    <label class="form-label required-label">정산 시작일</label>
    <input type="date" class="form-control" name="extDt1" required />
  </div>

  <div class="col-md-6">
    <label class="form-label required-label">정산 종료일</label>
    <input type="date" class="form-control" name="extDt2" required />
  </div>

  <!-- 지점 선택 -->
  <div class="col-md-6">
    <label class="form-label required-label">지점</label>
    <select class="form-select" name="extNo4" required>
      <option value="">지점 선택</option>
      <c:forEach items="${branches}" var="b">
        <option value="${b.branchId}"><c:out value="${b.branchName}"/></option>
      </c:forEach>
    </select>
  </div>

  <!-- 총 매출액 -->
  <div class="col-md-6">
    <label class="form-label required-label">총 매출액</label>
    <input type="number" class="form-control" name="extNo1" id="AT002_totalSales" min="0" step="1" required />
  </div>

  <!-- 총 지출액 -->
  <div class="col-md-6">
    <label class="form-label required-label">총 지출액</label>
    <input type="number" class="form-control" name="extNo2" id="AT002_totalExpense" min="0" step="1" required />
  </div>

  <!-- 손익 금액(자동) -->
  <div class="col-md-6">
    <label class="form-label">손익 금액</label>
    <input type="number" class="form-control bg-secondary-subtle" name="extNo3" id="AT002_profit" step="1" readonly required />
  </div>

</div> <!-- ✅ row 닫힘 꼭 필요 -->

<script>
(function(){
  // ✅ AT002에서만 동작하도록 id를 고유하게 변경(중복 방지)
  const salesEl = document.getElementById('AT002_totalSales');
  const expEl   = document.getElementById('AT002_totalExpense');
  const profEl  = document.getElementById('AT002_profit');

  if (!salesEl || !expEl || !profEl) return;

  function recalc(){
    const sales = Number(salesEl.value || 0);
    const exp   = Number(expEl.value || 0);
    profEl.value = sales - exp;
  }

  salesEl.addEventListener('input', recalc);
  expEl.addEventListener('input', recalc);
  recalc();
})();
</script>
