<html>
<head>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
    <title>title 작성</title>
</head>
<body>
<jsp:include page="../includes/admin_header.jsp" />

<h2></h2>
<!-- main Content -->
<div>
  <h3>내 서명</h3>

  <div style="margin-bottom:8px;">
    <img id="mySignPreview" src="" alt="서명 미리보기"
         style="display:none; border:1px solid #ddd; width:220px; height:110px; object-fit:contain;" />
    <div id="noSignText">등록된 서명이 없습니다.</div>
  </div>

  <button type="button" id="btnOpenSignModal">등록/수정</button>
  <button type="button" id="btnDeleteSign">삭제</button>
</div>

<!-- 모달(간단 버전) -->
<div id="signModal" style="display:none; position:fixed; left:0; top:0; right:0; bottom:0; background:rgba(0,0,0,0.4);">
  <div style="background:#fff; width:520px; margin:80px auto; padding:16px; border-radius:8px;">
    <h3>서명 등록/수정</h3>

    <canvas id="signCanvas" style="border:1px solid #ccc; width:480px; height:200px; touch-action:none;"></canvas>

    <div style="margin-top:10px;">
      <button type="button" id="btnSignClear">지우기</button>
      <button type="button" id="btnSignSave">저장</button>
      <button type="button" id="btnSignClose">닫기</button>
    </div>
  </div>
</div>
<script>
(function () {
  const modal = document.getElementById('signModal');
  const btnOpen = document.getElementById('btnOpenSignModal');
  const btnClose = document.getElementById('btnSignClose');
  const btnClear = document.getElementById('btnSignClear');
  const btnSave = document.getElementById('btnSignSave');
  const btnDelete = document.getElementById('btnDeleteSign');

  const canvas = document.getElementById('signCanvas');
  const preview = document.getElementById('mySignPreview');
  const noSignText = document.getElementById('noSignText');

  let signaturePad = null;

  function resizeCanvas() {
    const ratio = Math.max(window.devicePixelRatio || 1, 1);
    const rect = canvas.getBoundingClientRect();
    canvas.width = rect.width * ratio;
    canvas.height = rect.height * ratio;
    canvas.getContext('2d').scale(ratio, ratio);
    if (signaturePad) signaturePad.clear();
  }

  function openModal() {
    modal.style.display = 'block';

    if (!signaturePad) {
      signaturePad = new SignaturePad(canvas, {
        minWidth: 0.7,
        maxWidth: 2.5,
        penColor: "black",
        backgroundColor: "rgba(0,0,0,0)"
      });
      window.addEventListener('resize', resizeCanvas);
    }
    resizeCanvas();

  }

  function closeModal() {
    modal.style.display = 'none';
  }

  btnOpen.addEventListener('click', openModal);
  btnClose.addEventListener('click', closeModal);

  btnClear.addEventListener('click', function () {
    if (signaturePad) signaturePad.clear();
  });

  btnSave.addEventListener('click', async function () {
    if (!signaturePad || signaturePad.isEmpty()) {
      alert('서명을 입력하세요.');
      return;
    }
    const dataUrl = signaturePad.toDataURL('image/png');

    const res = await fetch('/approval/signature', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ signBase64: dataUrl })
    });

    if (!res.ok) {
      alert('서명 저장 실패');
      return;
    }

    closeModal();
    await loadMySignature();
  });

  btnDelete.addEventListener('click', async function () {
    if (!confirm('서명을 삭제할까요?')) return;

    const res = await fetch('/approval/signature', { method: 'DELETE' });
    if (!res.ok) {
      alert('서명 삭제 실패');
      return;
    }
    await loadMySignature();
  });

  // 페이지 로드 시 미리보기 세팅
  loadMySignature();
})();
</script>

<jsp:include page="../includes/admin_footer.jsp" />
<script src="https://cdn.jsdelivr.net/npm/signature_pad@5.1.3/dist/signature_pad.umd.min.js"></script>

</body>
</html>
