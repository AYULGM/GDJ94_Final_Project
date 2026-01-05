<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>결재선 설정</title>

  <style>
    .tree-group-title { font-weight:700; margin-top:10px; }
    .tree-sub-title { font-weight:600; margin-top:8px; color:#374151; }
    .tree-item { cursor:pointer; padding:6px 8px; border-radius:8px; }
    .tree-item:hover { background:#f5f5f5; }
    .tree-muted { color:#6b7280; font-size:12px; }
  </style>
</head>
<body>
<jsp:include page="../includes/admin_header.jsp" />

<div class="container-fluid py-3">

  <div class="d-flex align-items-center justify-content-between mb-3">
    <div>
      <h3 class="mb-0">결재선 설정</h3>
      <div class="text-body-secondary small">
        임시저장된 문서 버전(docVerId)에 결재선을 등록합니다.
      </div>
    </div>
    <div class="d-flex gap-2">
      <a href="/approval/form" class="btn btn-outline-secondary">문서로 돌아가기</a>
      <button type="button" class="btn btn-primary" id="btnSaveLines">저장</button>
    </div>
  </div>

  <!-- docVerId: 컨트롤러에서 model로 내려줘야 함 -->
  <input type="hidden" id="docVerId" value="${docVerId}" />

  <c:if test="${empty docVerId}">
    <div class="alert alert-warning">
      docVerId가 없습니다. 임시저장 후 결재선 페이지로 이동하세요.
    </div>
  </c:if>

  <div class="row g-3">

    <!-- 좌: 결재자 트리 -->
    <div class="col-12 col-lg-5">
      <div class="card shadow-sm">
        <div class="card-header bg-white">
          <div class="fw-semibold">결재자 추가</div>
          <div class="text-body-secondary small">본사/지점 트리에서 사용자 클릭 → 결재선에 추가</div>
        </div>

        <div class="card-body">
          <div class="d-flex gap-2 mb-2">
            <input type="text" class="form-control" id="inpTreeKeyword" placeholder="이름 검색" />
            <button type="button" class="btn btn-outline-secondary" id="btnReloadTree">새로고침</button>
          </div>

          <div id="approverTree" class="border rounded p-2" style="height:420px; overflow:auto;">
            <div class="text-body-secondary">불러오는 중...</div>
          </div>

          <div class="alert alert-info mt-3 mb-0 small">
            트리에서 사용자를 클릭하면 우측 결재선 목록에 추가됩니다.
            (기본 역할: 결재 AR003)
          </div>
        </div>
      </div>
    </div>

    <!-- 우: 결재선 목록 -->
    <div class="col-12 col-lg-7">
      <div class="card shadow-sm">
        <div class="card-header bg-white d-flex justify-content-between align-items-center">
          <div>
            <div class="fw-semibold">결재선 목록</div>
            <div class="text-body-secondary small">행 클릭 후 위/아래 이동 및 삭제 가능</div>
          </div>
          <div class="d-flex gap-2">
            <button type="button" class="btn btn-outline-secondary btn-sm" id="btnMoveUp">위로</button>
            <button type="button" class="btn btn-outline-secondary btn-sm" id="btnMoveDown">아래로</button>
            <button type="button" class="btn btn-outline-danger btn-sm" id="btnRemove">삭제</button>
          </div>
        </div>

        <div class="card-body p-0">
          <div class="table-responsive">
            <table class="table table-hover mb-0" id="lineTable">
              <thead class="table-light">
                <tr>
                  <th style="width:80px;">순번</th>
                  <th style="width:220px;">역할</th>
                  <th>결재자(userId)</th>
                </tr>
              </thead>
              <tbody id="lineTbody">
                <!-- JS 렌더링 -->
              </tbody>
            </table>
          </div>
        </div>

        <div class="card-footer bg-white">
          <div class="text-body-secondary small" id="msg"></div>
        </div>
      </div>
    </div>

  </div>
</div>

<script>
  // ===== 상태 =====
  let lines = []; // [{seq, approverId, lineRoleCode}]
  let selectedIndex = -1;

  // 트리 데이터 캐시(검색 시 재호출 방지)
  let approverTreeCache = null;

  const docVerId = document.getElementById('docVerId')?.value || "";
  const tbody = document.getElementById('lineTbody');
  const msgEl = document.getElementById('msg');

  function showMsg(text) {
    msgEl.textContent = text || '';
  }

  function roleText(code) {
    switch (code) {
      case 'AR002': return '검토';
      case 'AR003': return '결재';
      case 'AR004': return '합의';
      default: return code || '';
    }
  }

  function deptName(code) {
    const map = {
      "DP001":"시스템관리팀",
      "DP002":"지점운영팀",
      "DP003":"회원관리팀",
      "DP004":"구매·발주팀",
      "DP005":"정산·회계팀",
      "DP006":"기획·공지팀",
      "DP007":"일정관리팀",
      "DP000":"기타"
    };
    return map[code] || code || '기타';
  }

  function roleName(code) {
    const map = {
      "RL001":"대표/사장",
      "RL002":"본사 인사팀",
      "RL003":"본사 관리자",
      "RL004":"지점 관리자",
      "RL005":"직원"
    };
    return map[code] || code || '';
  }

  function normalizeSeq() {
    lines = lines.map((l, i) => ({...l, seq: i + 1}));
  }

  function render() {
    normalizeSeq();
    tbody.innerHTML = '';

    if (lines.length === 0) {
      const tr = document.createElement('tr');
      tr.innerHTML = `<td colspan="3" class="text-center text-body-secondary py-4">등록된 결재선이 없습니다.</td>`;
      tbody.appendChild(tr);
      return;
    }

    lines.forEach((l, idx) => {
      const tr = document.createElement('tr');
      if (idx === selectedIndex) tr.classList.add('table-primary');

      tr.style.cursor = 'pointer';
      tr.addEventListener('click', () => {
        selectedIndex = idx;
        render();
      });

      tr.innerHTML = `
        <td>${idx + 1}</td>
        <td>${roleText(l.lineRoleCode)} <span class="text-body-secondary">(${l.lineRoleCode})</span></td>
        <td>${l.approverId}</td>
      `;
      tbody.appendChild(tr);
    });
  }

  // ===== 초기 로딩: 기존 결재선 조회 =====
  async function loadLines() {
    if (!docVerId) {
      showMsg('docVerId가 없습니다. 임시저장 후 접근하세요.');
      render();
      return;
    }

    try {
      const res = await fetch(`/approval/linesForm?docVerId=${encodeURIComponent(docVerId)}`, {
        method: 'GET',
        headers: { 'Accept': 'application/json' }
      });

      if (!res.ok) {
        showMsg('결재선 조회 실패: ' + res.status);
        render();
        return;
      }

      const data = await res.json();
      lines = (data || [])
        .map(x => ({
          seq: x.seq,
          approverId: x.approverId,
          lineRoleCode: x.lineRoleCode
        }))
        .sort((a,b) => (a.seq||0) - (b.seq||0));

      selectedIndex = -1;
      render();
      showMsg('기존 결재선을 불러왔습니다.');
    } catch (e) {
      showMsg('조회 중 오류: ' + e);
      render();
    }
  }

  // ===== 트리 로딩 =====
  async function loadApproverTree() {
    const treeEl = document.getElementById('approverTree');
    treeEl.innerHTML = '<div class="text-body-secondary">불러오는 중...</div>';

    try {
      const res = await fetch('/api/approval/approvers/tree', {
        method: 'GET',
        headers: { 'Accept': 'application/json' }
      });

      if (!res.ok) {
        treeEl.innerHTML = `<div class="text-danger">트리 조회 실패: ${res.status}</div>`;
        return;
      }

      const data = await res.json();
      approverTreeCache = data;
      renderApproverTree();

    } catch (e) {
      treeEl.innerHTML = `<div class="text-danger">트리 오류: ${e}</div>`;
    }
  }

  function renderApproverTree() {
    const data = approverTreeCache;
    const treeEl = document.getElementById('approverTree');
    const keyword = (document.getElementById('inpTreeKeyword')?.value || '').trim().toLowerCase();

    if (!data) {
      treeEl.innerHTML = '<div class="text-body-secondary">데이터가 없습니다.</div>';
      return;
    }

    treeEl.innerHTML = '';

    const matches = (name) => {
      if (!keyword) return true;
      return String(name || '').toLowerCase().includes(keyword);
    };

    const addUserToLine = (u) => {
      if (!docVerId) { showMsg('docVerId가 없습니다.'); return; }

      if (lines.some(x => String(x.approverId) === String(u.userId))) {
        showMsg('이미 추가된 결재자입니다.');
        return;
      }

      // 기본 역할: 결재(AR003)
      lines.push({
        seq: lines.length + 1,
        approverId: Number(u.userId),
        lineRoleCode: 'AR003'
      });

      selectedIndex = lines.length - 1;
      render();
      showMsg('결재자를 추가했습니다.');
    };

    // 1) 본사
    const hoTitle = document.createElement('div');
    hoTitle.className = 'tree-group-title';
    hoTitle.textContent = '본사';
    treeEl.appendChild(hoTitle);

    const ho = data.headOfficeByDept || {};
    Object.keys(ho).forEach(deptCode => {
      const sub = document.createElement('div');
      sub.className = 'tree-sub-title';
      sub.textContent = deptName(deptCode);
      treeEl.appendChild(sub);

      (ho[deptCode] || [])
        .filter(u => matches(u.name))
        .forEach(u => {
          const item = document.createElement('div');
          item.className = 'tree-item d-flex justify-content-between align-items-center';
          item.innerHTML = `
            <div>
              <div>${u.name}</div>
              <div class="tree-muted">${roleName(u.roleCode)} · ${deptCode}</div>
            </div>
            <span class="badge text-bg-light">추가</span>
          `;
          item.addEventListener('click', () => addUserToLine(u));
          treeEl.appendChild(item);
        });
    });

    treeEl.appendChild(document.createElement('hr'));

    // 2) 지점
    const brTitle = document.createElement('div');
    brTitle.className = 'tree-group-title';
    brTitle.textContent = '지점';
    treeEl.appendChild(brTitle);

    const branches = data.branches || {};
    Object.keys(branches).forEach(branchId => {
      const node = branches[branchId];

      const sub = document.createElement('div');
      sub.className = 'tree-sub-title';
      sub.textContent = node.branchName || ('지점 ' + branchId);
      treeEl.appendChild(sub);

      (node.users || [])
        .filter(u => matches(u.name))
        .forEach(u => {
          const item = document.createElement('div');
          item.className = 'tree-item d-flex justify-content-between align-items-center';
          item.innerHTML = `
            <div>
              <div>${u.name}</div>
              <div class="tree-muted">${roleName(u.roleCode)} · branchId=${u.branchId}</div>
            </div>
            <span class="badge text-bg-light">추가</span>
          `;
          item.addEventListener('click', () => addUserToLine(u));
          treeEl.appendChild(item);
        });
    });

    // 아무것도 표시 안되면 안내
    if (!treeEl.childElementCount) {
      treeEl.innerHTML = '<div class="text-body-secondary">표시할 데이터가 없습니다.</div>';
    }
  }

  // ===== 위/아래 =====
  document.getElementById('btnMoveUp')?.addEventListener('click', () => {
    if (selectedIndex <= 0) return;
    const tmp = lines[selectedIndex - 1];
    lines[selectedIndex - 1] = lines[selectedIndex];
    lines[selectedIndex] = tmp;
    selectedIndex--;
    render();
  });

  document.getElementById('btnMoveDown')?.addEventListener('click', () => {
    if (selectedIndex < 0 || selectedIndex >= lines.length - 1) return;
    const tmp = lines[selectedIndex + 1];
    lines[selectedIndex + 1] = lines[selectedIndex];
    lines[selectedIndex] = tmp;
    selectedIndex++;
    render();
  });

  // ===== 삭제 =====
  document.getElementById('btnRemove')?.addEventListener('click', () => {
    if (selectedIndex < 0) {
      showMsg('삭제할 항목을 선택하세요.');
      return;
    }
    lines.splice(selectedIndex, 1);
    selectedIndex = -1;
    render();
    showMsg('삭제했습니다.');
  });

  // ===== 저장: form-urlencoded =====
  document.getElementById('btnSaveLines')?.addEventListener('click', async () => {
    if (!docVerId) { showMsg('docVerId가 없습니다.'); return; }
    if (lines.length === 0) { showMsg('결재선을 1명 이상 추가하세요.'); return; }

    const form = new URLSearchParams();
    form.append('docVerId', docVerId);

    lines.forEach(l => {
      form.append('approverIds', String(l.approverId));
      form.append('lineRoleCodes', String(l.lineRoleCode));
    });

    try {
      const res = await fetch('/approval/saveLinesForm', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
        body: form.toString()
      });

      if (!res.ok) {
        showMsg('저장 실패: ' + res.status);
        return;
      }

      const text = await res.text(); // "OK"
      showMsg('저장 완료: ' + text);

      // 저장 후 다시 조회 (DB 기준 확정)
      await loadLines();

    } catch (e) {
      showMsg('저장 중 오류: ' + e);
    }
  });

  // ===== 트리 검색/새로고침 =====
  document.getElementById('btnReloadTree')?.addEventListener('click', loadApproverTree);
  document.getElementById('inpTreeKeyword')?.addEventListener('input', () => {
    // 캐시 기반 즉시 필터
    renderApproverTree();
  });

  // 최초 실행
  loadLines();
  loadApproverTree();
</script>

<jsp:include page="../includes/admin_footer.jsp" />
</body>
</html>
