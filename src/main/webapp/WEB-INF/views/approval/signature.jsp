<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>내 서명</title>
</head>
<body>
<jsp:include page="../includes/admin_header.jsp" />

<div class="container-fluid py-3">
  <div class="d-flex align-items-center justify-content-between mb-3">
    <div>
      <h3 class="mb-0">내 서명</h3>
      <div class="text-body-secondary small">서명을 등록하고 대표 서명을 지정할 수 있습니다.</div>
    </div>
    <button type="button" id="btnOpenSignModal" class="btn btn-primary">추가하기</button>
  </div>

  <!-- 카드 목록 -->
  <div id="signList" class="row g-3 d-flex justify-content-center"></div>
</div>

<!-- Bootstrap Modal -->
<div class="modal fade" id="signModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">서명 추가</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="닫기"></button>
      </div>

      <div class="modal-body">
        <div class="border rounded-3 p-2 bg-body">
          <canvas id="signCanvas" class="w-100"></canvas>
        </div>
        <div class="text-body-secondary small mt-2">마우스/터치로 서명을 입력하세요.</div>
      </div>

      <div class="modal-footer">
        <button type="button" id="btnSignClear" class="btn btn-outline-secondary">지우기</button>
        <button type="button" id="btnSignSave" class="btn btn-primary">저장</button>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/signature_pad@5.1.3/dist/signature_pad.umd.min.js"></script>

<script>
(function () {
  // JSP EL은 여기서만 사용
  var CTX = '${pageContext.request.contextPath}' || '';

  var modalEl = document.getElementById('signModal');
  var btnOpen = document.getElementById('btnOpenSignModal');
  var btnClear = document.getElementById('btnSignClear');
  var btnSave = document.getElementById('btnSignSave');

  var canvas = document.getElementById('signCanvas');
  var signListEl = document.getElementById('signList');

  var signaturePad = null;
  var bsModal = null;

  function ensurePad() {
    if (signaturePad) return;

    if (typeof SignaturePad === 'undefined') {
      alert('SignaturePad 라이브러리가 로드되지 않았습니다.');
      return;
    }

    signaturePad = new SignaturePad(canvas, {
      minWidth: 2.0,
      maxWidth: 6.0,
      penColor: "black",
      backgroundColor: "rgba(0,0,0,0)"
    });

    window.addEventListener('resize', resizeCanvas);
  }

  function resizeCanvas() {
    var ratio = Math.max(window.devicePixelRatio || 1, 1);

    canvas.style.width = '100%';
    canvas.style.height = '220px';
    canvas.style.touchAction = 'none';

    var rect = canvas.getBoundingClientRect();
    canvas.width = rect.width * ratio;
    canvas.height = rect.height * ratio;

    var ctx2d = canvas.getContext('2d');
    ctx2d.setTransform(ratio, 0, 0, ratio, 0, 0);

    if (signaturePad) signaturePad.clear();
  }

  function openModal() {
    if (typeof bootstrap === 'undefined' || !bootstrap.Modal) {
      alert('Bootstrap JS가 로드되지 않았습니다. (bootstrap.Modal 없음)');
      return;
    }

    if (!bsModal) {
      bsModal = new bootstrap.Modal(modalEl, { backdrop: 'static' });
      modalEl.addEventListener('shown.bs.modal', function () {
        ensurePad();
        resizeCanvas();
      });
    }
    bsModal.show();
  }

  function normalizeImgUrl(item) {
    if (item.imageUrl && String(item.imageUrl).trim()) {
      var u = String(item.imageUrl).trim();
      if (/^(https?:|data:|blob:)/i.test(u)) return u;
      if (u.indexOf('/') === 0) return CTX + u;
      return CTX + '/' + u;
    }
    if (item.fileId) return CTX + '/files/preview/' + item.fileId;
    return '';
  }

  async function fetchList() {
    var res = await fetch(CTX + '/approval/signature/api/list', { method: 'GET' });
    if (!res.ok) throw new Error('list failed');
    return await res.json();
  }

  function renderList(list) {
    if (!list || list.length === 0) {
      signListEl.innerHTML =
        '<div class="col-12">' +
          '<div class="card">' +
            '<div class="card-body text-body-secondary">등록된 서명이 없습니다.</div>' +
          '</div>' +
        '</div>';
      return;
    }

    var html = '';

    for (var i = 0; i < list.length; i++) {
      var item = list[i];
      var isPrimary = !!item.isPrimary;

      var badge = isPrimary
        ? '<span class="badge text-bg-success">대표</span>'
        : '<span class="badge text-bg-secondary">일반</span>';

      var primaryCardClass = isPrimary ? 'border border-2 border-success' : '';
      var imgSrc = normalizeImgUrl(item);

      var primaryBtnAttrs = isPrimary ? 'disabled aria-disabled="true"' : '';
      var primaryMsg = isPrimary
        ? '<div class="text-success small mt-2">현재 대표 서명입니다.</div>'
        : '';

      html +=
        '<div style="width:250px;">' +
          '<div class="card h-100 ' + primaryCardClass + '">' +
            '<div class="card-body">' +
              '<div class="row g-1 align-items-center">' +

                '<div class="col-12">' +
                  '<div class="border rounded-3 p-1 bg-body">' +
                    '<img ' +
                      'src="' + imgSrc + '" ' +
                      'class="img-fluid d-block mx-auto object-fit-contain" ' +
                      'style="height:100px; width:100%;" ' +
                      'alt="서명 이미지" ' +
                      'onerror="this.onerror=null; this.removeAttribute(\'src\'); this.closest(\'.border\').innerHTML=\\\'<div class=&quot;text-body-secondary small py-4 text-center&quot;>이미지 로드 실패</div>\\\';"' +
                    '/>' +
                  '</div>' +
                '</div>' +

                '<div class="col-12">' +
                  '<div class="d-flex align-items-center gap-2 flex-wrap mb-2">' +
                    badge +
                    '<span class="text-body-secondary small">ID: ' + item.signatureId + '</span>' +
                  '</div>' +

                  '<div class="d-flex gap-2 flex-wrap">' +
                    '<button type="button" ' +
                            'class="btn btn-outline-primary btn-sm" ' +
                            'data-action="primary" ' +
                            'data-id="' + item.signatureId + '" ' +
                            primaryBtnAttrs +
                    '>대표로 설정</button>' +

                    '<button type="button" ' +
                            'class="btn btn-outline-danger btn-sm" ' +
                            'data-action="delete" ' +
                            'data-id="' + item.signatureId + '"' +
                    '>삭제</button>' +
                  '</div>' +

                  primaryMsg +
                '</div>' +

              '</div>' +
            '</div>' +
          '</div>' +
        '</div>';
    }

    signListEl.innerHTML = html;

    // 이벤트 바인딩
    var primaryBtns = signListEl.querySelectorAll('button[data-action="primary"]');
    primaryBtns.forEach(function (btn) {
      btn.addEventListener('click', async function () {
        if (btn.disabled) return;
        var id = Number(btn.getAttribute('data-id'));
        await setPrimary(id);
      });
    });

    var deleteBtns = signListEl.querySelectorAll('button[data-action="delete"]');
    deleteBtns.forEach(function (btn) {
      btn.addEventListener('click', async function () {
        var id = Number(btn.getAttribute('data-id'));
        await softDelete(id);
      });
    });
  }

  async function loadAndRender() {
    try {
      var list = await fetchList();
      renderList(list);
    } catch (e) {
      signListEl.innerHTML =
        '<div class="col-12">' +
          '<div class="alert alert-danger mb-0" role="alert">목록 조회 실패</div>' +
        '</div>';
    }
  }

  async function setPrimary(signatureId) {
    var res = await fetch(CTX + '/approval/signature/api/primary', {
      method: 'POST',
      headers: {'Content-Type':'application/json'},
      body: JSON.stringify({ signatureId: signatureId })
    });
    if (!res.ok) {
      alert('대표 변경 실패');
      return;
    }
    await loadAndRender();
  }

  async function softDelete(signatureId) {
    if (!confirm('서명을 삭제할까요?')) return;

    var res = await fetch(CTX + '/approval/signature/api/' + signatureId, { method: 'DELETE' });
    if (!res.ok) {
      alert('서명 삭제 실패');
      return;
    }
    await loadAndRender();
  }

  btnOpen.addEventListener('click', openModal);
  btnClear.addEventListener('click', function () {
    if (signaturePad) signaturePad.clear();
  });

  btnSave.addEventListener('click', async function () {
    if (!signaturePad || signaturePad.isEmpty()) {
      alert('서명을 입력하세요.');
      return;
    }

    var dataUrl = signaturePad.toDataURL('image/png');

    var res = await fetch(CTX + '/approval/signature/api/save', {
      method: 'POST',
      headers: {'Content-Type':'application/json'},
      body: JSON.stringify({ signBase64: dataUrl })
    });

    if (!res.ok) {
      alert('서명 저장 실패');
      return;
    }

    if (bsModal) bsModal.hide();
    await loadAndRender();
  });

  loadAndRender();
})();
</script>

<jsp:include page="../includes/admin_footer.jsp" />
</body>
</html>
