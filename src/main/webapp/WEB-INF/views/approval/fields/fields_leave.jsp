<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<div class="row g-2">
  <div class="col-md-3">
    <label class="form-label">휴가 시작일</label>
    <input type="date"
           class="form-control"
           name="extDt1"
           required
           value="<c:out value='${draft.extDt1}'/>" />
  </div>

  <div class="col-md-3">
    <label class="form-label">휴가 종료일</label>
    <input type="date"
           class="form-control"
           name="extDt2"
           required
           value="<c:out value='${draft.extDt2}'/>" />
  </div>

  <div class="col-md-3">
    <label class="form-label">휴가 구분</label>
    <select class="form-select" name="extCode1" required>
      <option value="">선택</option>
      <option value="연차"      <c:if test="${draft.extCode1 == '연차'}">selected</c:if>>연차</option>
      <option value="반차(오전)" <c:if test="${draft.extCode1 == '반차(오전)'}">selected</c:if>>반차(오전)</option>
      <option value="반차(오후)" <c:if test="${draft.extCode1 == '반차(오후)'}">selected</c:if>>반차(오후)</option>
      <option value="병가"      <c:if test="${draft.extCode1 == '병가'}">selected</c:if>>병가</option>
      <option value="경조"      <c:if test="${draft.extCode1 == '경조'}">selected</c:if>>경조</option>
      <option value="기타"      <c:if test="${draft.extCode1 == '기타'}">selected</c:if>>기타</option>
    </select>
  </div>

  <div class="col-md-3">
    <label class="form-label">사용 일수(정수)</label>
    <input type="number"
           class="form-control"
           name="extNo1"
           min="0"
           step="1"
           placeholder="예: 1"
           value="<c:out value='${draft.extNo1}'/>" />
    <div class="form-text">BIGINT라서 소수(0.5)는 별도 규칙 필요</div>
  </div>

  <div class="col-md-6">
    <label class="form-label mt-2">인수인계자(선택)</label>
    <input type="text"
           class="form-control"
           name="extTxt1"
           maxlength="50"
           value="<c:out value='${draft.extTxt1}'/>" />
  </div>

  <div class="col-12">
    <label class="form-label mt-2">휴가 사유</label>
    <textarea class="form-control"
              name="extTxt2"
              rows="3"
              maxlength="500"
              required><c:out value="${draft.extTxt2}" /></textarea>
  </div>

  <div class="col-12">
    <label class="form-label mt-2">인수인계 내용(선택)</label>
    <textarea class="form-control"
              name="extTxt3"
              rows="3"
              maxlength="800"><c:out value="${draft.extTxt3}" /></textarea>
  </div>
</div>
