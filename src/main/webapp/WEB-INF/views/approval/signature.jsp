<html>
<head>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<title>내 서명</title>
</head>
<body>
<jsp:include page="../includes/admin_header.jsp" />

<div>
  <h3>내 서명</h3>

  <div style="margin:10px 0;">
    <button type="button" id="btnOpenSignModal">추가하기</button>
  </div>

  <!-- 카드 목록 -->
  <div id="signList"></div>
</div>

<!-- 모달 -->
<div id="signModal" style="display:none; position:fixed; left:0; top:0; right:0; bottom:0; background:rgba(0,0,0,0.4);">
  <div style="background:#fff; width:520px; margin:80px auto; padding:16px; border-radius:8px;">
    <h3>서명 추가</h3>

    <canvas id="signCanvas" style="border:1px solid #ccc; width:480px; height:200px; touch-action:none;"></canvas>

    <div style="margin-top:10px;">
      <button type="button" id="btnSignClear">지우기</button>
      <button type="button" id="btnSignSave">저장</button>
      <button type="button" id="btnSignClose">닫기</button>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/signature_pad@5.1.3/dist/signature_pad.umd.min.js"></script>

<script>
(function () {
  const modal = document.getElementById('signModal');
  const btnOpen = document.getElementById('btnOpenSignModal');
  const btnClose = document.getElementById('btnSignClose');
  const btnClear = document.getElementById('btnSignClear');
  const btnSave = document.getElementById('btnSignSave');

  const canvas = document.getElementById('signCanvas');
  const signListEl = document.getElementById('signList');

  let signaturePad = null;

  function resizeCanvas() {
    const ratio = Math.max(window.devicePixelRatio || 1, 1);
    const rect = canvas.getBoundingClientRect();

    canvas.width = rect.width * ratio;
    canvas.height = rect.height * ratio;

    const ctx = canvas.getContext('2d');
    ctx.setTransform(ratio, 0, 0, ratio, 0, 0);

    if (signaturePad) signaturePad.clear();
  }

  function openModal() {
    modal.style.display = 'block';

    if (!signaturePad) {
      if (typeof SignaturePad === 'undefined') {
        alert('SignaturePad 라이브러리가 로드되지 않았습니다.');
        return;
      }
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

  async function fetchList() {
    const res = await fetch('/approval/signature/api/list', { method: 'GET' });
    if (!res.ok) throw new Error('list failed');
    return await res.json();
  }

  function renderList(list) {
    if (!list || list.length === 0) {
      signListEl.innerHTML = '<div style="color:#666;">등록된 서명이 없습니다.</div>';
      return;
    }

    signListEl.innerHTML = list.map(item => {
      const badge = item.isPrimary
        ? '<span style="display:inline-block; padding:2px 6px; border:1px solid #2e7d32; color:#2e7d32; border-radius:10px; font-size:12px;">대표</span>'
        : '';

      const imgSrc =
        (item.imageUrl && item.imageUrl.trim())
          ? item.imageUrl.trim()
          : (item.fileId ? (`/files/preview/${item.fileId}`) : '');

      return `
        <div style="display:flex; gap:12px; align-items:center; border:1px solid #eee; padding:12px; margin:10px 0; border-radius:10px;">
          <img src="\${imgSrc}"
               style="width:200px; height:90px; object-fit:contain; border:1px solid #ddd; border-radius:6px;" />
          <div style="flex:1;">
            <div style="display:flex; align-items:center; gap:8px;">
              \${badge}
              <span style="color:#999; font-size:12px;">ID: \${item.signatureId}</span>
            </div>
            <div style="margin-top:10px; display:flex; gap:8px;">
              <button type="button"
                      data-action="primary"
                      data-id="\${item.signatureId}"
                      \${item.isPrimary ? 'disabled' : ''}>
                대표로 설정
              </button>
              <button type="button"
                      data-action="delete"
                      data-id="\${item.signatureId}">
                삭제
              </button>
            </div>
          </div>
        </div>
      `;
    }).join('');

    // 대표 설정
    signListEl.querySelectorAll('button[data-action="primary"]').forEach(btn => {
      btn.addEventListener('click', async () => {
        const id = Number(btn.getAttribute('data-id'));
        await setPrimary(id);
      });
    });

    // 삭제
    signListEl.querySelectorAll('button[data-action="delete"]').forEach(btn => {
      btn.addEventListener('click', async () => {
        const id = Number(btn.getAttribute('data-id'));
        await softDelete(id);
      });
    });
  }

  async function loadAndRender() {
    try {
      const list = await fetchList();
      renderList(list);
    } catch (e) {
      signListEl.innerHTML = '<div style="color:#c00;">목록 조회 실패</div>';
    }
  }

  async function setPrimary(signatureId) {
    const res = await fetch('/approval/signature/api/primary', {
      method: 'POST',
      headers: {'Content-Type':'application/json'},
      body: JSON.stringify({ signatureId })
    });
    if (!res.ok) {
      alert('대표 변경 실패');
      return;
    }
    await loadAndRender();
  }

  async function softDelete(signatureId) {
    if (!confirm('서명을 삭제할까요?')) return;

    const res = await fetch('/approval/signature/api/' + signatureId, { method: 'DELETE' });
    if (!res.ok) {
      alert('서명 삭제 실패');
      return;
    }
    await loadAndRender();
  }

  btnOpen.addEventListener('click', openModal);
  btnClose.addEventListener('click', closeModal);
  btnClear.addEventListener('click', () => signaturePad && signaturePad.clear());

  btnSave.addEventListener('click', async () => {
    if (!signaturePad || signaturePad.isEmpty()) {
      alert('서명을 입력하세요.');
      return;
    }

    const dataUrl = signaturePad.toDataURL('image/png');

    const res = await fetch('/approval/signature/api/save', {
      method: 'POST',
      headers: {'Content-Type':'application/json'},
      body: JSON.stringify({ signBase64: dataUrl })
    });

    if (!res.ok) {
      alert('서명 저장 실패');
      return;
    }

    closeModal();
    await loadAndRender();
  });

  loadAndRender();
})();
</script>

<jsp:include page="../includes/admin_footer.jsp" />
</body>
</html>
