<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<div class="row g-2">
  <div class="col-md-3">
    <label class="form-label">구분</label>
    <select class="form-select" name="att_type">
      <option value="">선택</option>
      <option value="LATE">지각</option>
      <option value="EARLY">조퇴</option>
      <option value="OUT">외출</option>
      <option value="OT">연장근무</option>
      <option value="SHIFT">근무변경</option>
      <option value="ETC">기타</option>
    </select>
  </div>
  <div class="col-md-3">
    <label class="form-label">일자</label>
    <input type="date" class="form-control" name="att_date" />
  </div>
  <div class="col-md-3">
    <label class="form-label">시작 시간(선택)</label>
    <input type="time" class="form-control" name="att_start_time" />
  </div>
  <div class="col-md-3">
    <label class="form-label">종료 시간(선택)</label>
    <input type="time" class="form-control" name="att_end_time" />
  </div>

  <div class="col-12">
    <label class="form-label mt-2">사유</label>
    <input type="text" class="form-control" name="att_reason" maxlength="200" />
  </div>
</div>
