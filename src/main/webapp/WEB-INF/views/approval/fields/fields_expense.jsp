<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<div class="row g-2">
  <div class="col-md-3">
    <label class="form-label">지출일자</label>
    <input type="date" class="form-control" name="exp_date" />
  </div>
  <div class="col-md-3">
    <label class="form-label">금액</label>
    <input type="number" class="form-control" name="exp_amount" min="0" step="1" />
  </div>
  <div class="col-md-3">
    <label class="form-label">결제수단(선택)</label>
    <select class="form-select" name="exp_payment_method">
      <option value="">선택</option>
      <option value="CARD">카드</option>
      <option value="CASH">현금</option>
      <option value="TRANSFER">계좌이체</option>
      <option value="ETC">기타</option>
    </select>
  </div>
  <div class="col-md-3">
    <label class="form-label">거래처(선택)</label>
    <input type="text" class="form-control" name="exp_vendor" maxlength="100" />
  </div>

  <div class="col-12">
    <label class="form-label mt-2">사용 내역</label>
    <input type="text" class="form-control" name="exp_desc" maxlength="200" />
  </div>
</div>
