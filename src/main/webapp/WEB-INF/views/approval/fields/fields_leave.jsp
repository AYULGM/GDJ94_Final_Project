<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<div class="row g-2">
  <div class="col-md-4">
    <label class="form-label">출장지</label>
    <input type="text" class="form-control" name="trip_location" maxlength="100" />
  </div>
  <div class="col-md-4">
    <label class="form-label">출장 시작일</label>
    <input type="date" class="form-control" name="trip_start_date" />
  </div>
  <div class="col-md-4">
    <label class="form-label">출장 종료일</label>
    <input type="date" class="form-control" name="trip_end_date" />
  </div>

  <div class="col-md-6">
    <label class="form-label mt-2">목적</label>
    <input type="text" class="form-control" name="trip_purpose" maxlength="200" />
  </div>
  <div class="col-md-6">
    <label class="form-label mt-2">예상 비용(선택)</label>
    <input type="number" class="form-control" name="trip_estimated_cost" min="0" step="1" />
  </div>
</div>
