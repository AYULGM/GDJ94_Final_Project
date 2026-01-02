<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<div class="row g-2">
  <div class="col-md-3">
    <label class="form-label">휴가 시작일</label>
    <input type="date" class="form-control" name="leave_start_date" />
  </div>
  <div class="col-md-3">
    <label class="form-label">휴가 종료일</label>
    <input type="date" class="form-control" name="leave_end_date" />
  </div>
  <div class="col-md-3">
    <label class="form-label">휴가 구분</label>
    <select class="form-select" name="leave_type">
      <option value="">선택</option>
      <option value="ANNUAL">연차</option>
      <option value="HALF_AM">반차(오전)</option>
      <option value="HALF_PM">반차(오후)</option>
      <option value="SICK">병가</option>
      <option value="EVENT">경조</option>
      <option value="ETC">기타</option>
    </select>
  </div>
  <div class="col-md-3">
    <label class="form-label">대체 근무자(선택)</label>
    <input type="text" class="form-control" name="leave_cover_person" maxlength="50" />
  </div>

  <div class="col-12">
    <label class="form-label mt-2">사유</label>
    <input type="text" class="form-control" name="leave_reason" maxlength="200" />
  </div>
</div>
