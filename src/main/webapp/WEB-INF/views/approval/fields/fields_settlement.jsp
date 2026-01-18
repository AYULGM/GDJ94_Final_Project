<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<div class="row g-3">

  <!-- 정산 기간 -->
  <div class="col-md-6">
    <label class="form-label required-label">정산 시작일</label>
    <input type="date" class="form-control" name="extDt1" id="AT002_startDate" required />
  </div>

  <div class="col-md-6">
    <label class="form-label required-label">정산 종료일</label>
    <input type="date" class="form-control" name="extDt2" id="AT002_endDate" required />
  </div>

  <!-- 지점 선택 -->
  <div class="col-md-6">
    <label class="form-label required-label">지점</label>
    <select class="form-select" name="extNo4" id="AT002_branchId" required>
      <option value="">지점 선택</option>
      <c:forEach items="${branches}" var="b">
        <option value="${b.branchId}"><c:out value="${b.branchName}"/></option>
      </c:forEach>
    </select>
  </div>

  <!-- 조회 버튼 -->
  <div class="col-md-6 d-flex align-items-end">
    <button type="button" class="btn btn-outline-primary w-100" id="AT002_btnFetch">
      <i class="bi bi-search"></i> 매출/지출 자동 조회
    </button>
  </div>

  <!-- 총 매출액 -->
  <div class="col-md-6">
    <label class="form-label required-label">총 매출액</label>
    <input type="number" class="form-control" name="extNo1" id="AT002_totalSales" min="0" step="1" required />
    <small class="text-muted">※ 조회 결과를 참고하여 입력하거나 직접 수정 가능</small>
  </div>

  <!-- 총 지출액 -->
  <div class="col-md-6">
    <label class="form-label required-label">총 지출액</label>
    <input type="number" class="form-control" name="extNo2" id="AT002_totalExpense" min="0" step="1" required />
    <small class="text-muted">※ 조회 결과를 참고하여 입력하거나 직접 수정 가능</small>
  </div>

  <!-- 손익 금액(자동) -->
  <div class="col-md-6">
    <label class="form-label">손익 금액</label>
    <input type="number" class="form-control bg-secondary-subtle" name="extNo3" id="AT002_profit" step="1" readonly required />
  </div>

  <!-- 조회 결과 정보 -->
  <div class="col-md-6">
    <label class="form-label">조회 정보</label>
    <div id="AT002_fetchInfo" class="form-control bg-light" style="height: auto; min-height: 38px; font-size: 0.875rem;">
      기간과 지점을 선택 후 조회 버튼을 클릭하세요.
    </div>
  </div>

</div>

<script>
(function(){
  const startDateEl = document.getElementById('AT002_startDate');
  const endDateEl = document.getElementById('AT002_endDate');
  const branchEl = document.getElementById('AT002_branchId');
  const salesEl = document.getElementById('AT002_totalSales');
  const expEl = document.getElementById('AT002_totalExpense');
  const profEl = document.getElementById('AT002_profit');
  const btnFetch = document.getElementById('AT002_btnFetch');
  const fetchInfo = document.getElementById('AT002_fetchInfo');

  if (!salesEl || !expEl || !profEl) return;

  // 손익 자동 계산
  function recalc(){
    const sales = Number(salesEl.value || 0);
    const exp = Number(expEl.value || 0);
    profEl.value = sales - exp;
  }

  salesEl.addEventListener('input', recalc);
  expEl.addEventListener('input', recalc);
  recalc();

  // 매출/지출 자동 조회
  if (btnFetch) {
    btnFetch.addEventListener('click', async function() {
      const startDate = startDateEl.value;
      const endDate = endDateEl.value;
      const branchId = branchEl.value;

      if (!startDate || !endDate) {
        alert('정산 기간을 선택해주세요.');
        startDateEl.focus();
        return;
      }

      if (!branchId) {
        alert('지점을 선택해주세요.');
        branchEl.focus();
        return;
      }

      // 로딩 표시
      btnFetch.disabled = true;
      btnFetch.innerHTML = '<span class="spinner-border spinner-border-sm"></span> 조회 중...';
      fetchInfo.innerHTML = '조회 중...';

      try {
        const params = new URLSearchParams({
          startDate: startDate,
          endDate: endDate,
          branchId: branchId
        });

        const response = await fetch('/statistics/api/settlement-summary?' + params.toString());

        if (!response.ok) {
          throw new Error('조회 실패: ' + response.status);
        }

        const data = await response.json();

        // 조회 결과 적용
        salesEl.value = data.totalSales || 0;
        expEl.value = data.totalExpenses || 0;
        recalc();

        // 조회 정보 표시
        const formatCurrency = (val) => new Intl.NumberFormat('ko-KR').format(val) + '원';
        fetchInfo.innerHTML =
          '<strong>조회 완료</strong><br>' +
          '매출: ' + formatCurrency(data.totalSales) + '<br>' +
          '지출: ' + formatCurrency(data.totalExpenses) + '<br>' +
          '손익: ' + formatCurrency(data.profit);

        fetchInfo.classList.remove('text-danger');
        fetchInfo.classList.add('text-success');

      } catch (error) {
        console.error('매출/지출 조회 실패:', error);
        fetchInfo.innerHTML = '조회 실패: ' + error.message;
        fetchInfo.classList.remove('text-success');
        fetchInfo.classList.add('text-danger');
      } finally {
        btnFetch.disabled = false;
        btnFetch.innerHTML = '<i class="bi bi-search"></i> 매출/지출 자동 조회';
      }
    });
  }
})();
</script>
