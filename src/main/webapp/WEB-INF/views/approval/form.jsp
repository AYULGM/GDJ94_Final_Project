<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <title>결재 작성</title>
</head>
<body>
<jsp:include page="../includes/admin_header.jsp" />

<h2>전자결재 작성</h2>

<form method="post" action="/approval/create">
  <!-- 문서 기본 -->
  <div>
    <label>결재유형</label>
    <select name="approvalType" id="approvalType">
      <option value="">선택</option>
      <option value="AT001">기획·보고</option>
      <option value="AT002">비용·재무</option>
      <option value="AT003">구매·발주</option>
      <option value="AT004">출장·근태</option>
      <option value="AT005">인사(HR)</option>
    </select>
  </div>

  <div style="margin-top:8px;">
    <label>문서양식</label>
    <select name="documentForm" id="documentForm" disabled>
      <option value="">결재유형을 선택하세요</option>
    </select>
  </div>

  <hr>

  <!-- 문서 메타(작성 단계에서는 자동 세팅/표시만) -->
  <h3>문서 정보</h3>
  <div>
    <span>기안자: </span><span>${loginUser.userName}</span>
  </div>
  <div>
    <span>작성일: </span><span>${today}</span>
  </div>

  <hr>

  <!-- 본문 -->
  <div>
    <label>제목</label><br/>
    <input type="text" name="title" style="width:400px;" required />
  </div>

  <div style="margin-top:12px;">
    <label>내용</label><br/>
    <textarea name="content" rows="10" cols="80" required></textarea>
  </div>

  <div style="margin-top:12px;">
    <label>파일 첨부</label><br/>
    <input type="file" name="files" multiple />
  </div>

  <!-- 버튼 영역 -->
  <div style="margin-top:20px;">
    <button type="button" id="btnTempSave">임시저장</button>
    <button type="button" id="btnPreview">미리보기</button>
    <button type="button" id="btnSubmit">상신</button>
    <button type="button" onclick="location.href='/approval/list'">목록</button>
  </div>
</form>
<script>
  document.getElementById('approvalType').addEventListener('change', async function () {
    const approvalType = this.value;
    const formSelect = document.getElementById('documentForm');

    formSelect.innerHTML = '';
    formSelect.disabled = true;

    if (!approvalType) {
      const opt = document.createElement('option');
      opt.value = '';
      opt.textContent = '결재유형을 선택하세요';
      formSelect.appendChild(opt);
      return;
    }

    try {
      const url = '/api/common-codes/document-forms?approvalType=' + encodeURIComponent(approvalType);
      const res = await fetch(url);

      if (!res.ok) throw new Error('Failed to load document forms');

      const data = await res.json();

      const defaultOpt = document.createElement('option');
      defaultOpt.value = '';
      defaultOpt.textContent = '선택';
      formSelect.appendChild(defaultOpt);

      for (const item of data) {
        const opt = document.createElement('option');
        opt.value = item.code;
        opt.textContent = item.label;
        formSelect.appendChild(opt);
      }

      formSelect.disabled = false;
    } catch (e) {
      const opt = document.createElement('option');
      opt.value = '';
      opt.textContent = '문서양식 로딩 실패';
      formSelect.appendChild(opt);
      console.error(e);
    }
  });
</script>

<jsp:include page="../includes/admin_footer.jsp" />
</body>
</html>
