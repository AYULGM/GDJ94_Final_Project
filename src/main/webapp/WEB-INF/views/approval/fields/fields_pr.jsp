<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<div class="row g-2">
  <div class="col-md-4">
    <label class="form-label">거래처</label>
    <input type="text" class="form-control" name="po_vendor" maxlength="100" />
  </div>
  <div class="col-md-4">
    <label class="form-label">발주 품목</label>
    <input type="text" class="form-control" name="po_item_name" maxlength="100" />
  </div>
  <div class="col-md-2">
    <label class="form-label">수량</label>
    <input type="number" class="form-control" name="po_qty" min="1" step="1" />
  </div>
  <div class="col-md-2">
    <label class="form-label">단가(선택)</label>
    <input type="number" class="form-control" name="po_unit_price" min="0" step="1" />
  </div>

  <div class="col-md-4">
    <label class="form-label mt-2">납기일(선택)</label>
    <input type="date" class="form-control" name="po_due_date" />
  </div>
  <div class="col-md-8">
    <label class="form-label mt-2">비고(선택)</label>
    <input type="text" class="form-control" name="po_note" maxlength="200" />
  </div>
</div>
