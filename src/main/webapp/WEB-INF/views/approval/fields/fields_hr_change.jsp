<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<div class="row g-2">
  <div class="col-md-4">
    <label class="form-label">대상자</label>
    <input type="text" class="form-control" name="hr_target_name" maxlength="50" />
  </div>
  <div class="col-md-4">
    <label class="form-label">변경 유형</label>
    <select class="form-select" name="hr_change_type">
      <option value="">선택</option>
      <option value="TRANSFER">전보</option>
      <option value="PROMOTION">승진</option>
      <option value="ROLE_CHANGE">직무 변경</option>
      <option value="ETC">기타</option>
    </select>
  </div>
  <div class="col-md-4">
    <label class="form-label">발령일(선택)</label>
    <input type="date" class="form-control" name="hr_effective_date" />
  </div>

  <div class="col-12">
    <label class="form-label mt-2">사유/근거</label>
    <input type="text" class="form-control" name="hr_reason" maxlength="200" />
  </div>
</div>
