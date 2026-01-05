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

  /* dropdown(접기/펼치기) */
  .tree-details { border:1px solid #e5e7eb; border-radius:10px; margin:8px 0; background:#fff; }
  .tree-summary { list-style:none; cursor:pointer; padding:10px 12px; font-weight:600; display:flex; align-items:center; justify-content:space-between; }
  .tree-summary::-webkit-details-marker { display:none; }
  .tree-summary:hover { background:#f9fafb; }
  .tree-children { padding:8px 10px 10px 10px; }
  .tree-pill { font-size:12px; color:#6b7280; }
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
	  <button type="button" class="btn btn-success" id="btnSubmit">결재요청</button>

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

          <div id="approverTree" class="border rounded p-2" style="height:420px; overflow:auto;">
            <div class="text-body-secondary">불러오는 중...</div>
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
                  <th>결재자</th>
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
      tr.innerHTML = '<td colspan="3" class="text-center text-body-secondary py-4">등록된 결재선이 없습니다.</td>';
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

      tr.innerHTML =
    	  '<td>' + (idx + 1) + '</td>' +
    	  '<td>' + roleText(l.lineRoleCode) + ' <span class="text-body-secondary">(' + l.lineRoleCode + ')</span></td>' +
    	  '<td>' + (l.approverName || ('ID:' + l.approverId)) + '</td>';


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
      const url = '/approval/linesForm?docVerId=' + encodeURIComponent(docVerId);
      const res = await fetch(url, {
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
          approverName: x.approverName || x.name || null,
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
      const res = await fetch('/approval/approvers/tree', {
        method: 'GET',
        headers: { 'Accept': 'application/json' }
      });

      if (!res.ok) {
        treeEl.innerHTML = '<div class="text-danger">트리 조회 실패: ' + res.status + '</div>';
        return;
      }

      const data = await res.json();
      console.log('TREE DATA =', data);

      approverTreeCache = data;
      renderApproverTree();
    } catch (e) {
      treeEl.innerHTML = '<div class="text-danger">트리 오류: ' + e + '</div>';
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

	  // ===== 서버 필드명 호환 레이어 =====
	  const pickName = (u) => (u?.name ?? u?.userName ?? u?.username ?? u?.user_name ?? '');
	  const pickUserId = (u) => (u?.userId ?? u?.id ?? u?.user_id ?? u?.user_no ?? null);
	  const pickRoleCode = (u) => (u?.roleCode ?? u?.role_code ?? u?.role ?? '');
	  const pickBranchId = (u) => (u?.branchId ?? u?.branch_id ?? null);
	  const pickDeptCode = (u) => (u?.deptCode ?? u?.departmentCode ?? u?.department_code ?? u?.department_code ?? u?.department ?? '');

	  const matches = (name) => {
	    if (!keyword) return true;
	    return String(name || '').toLowerCase().includes(keyword);
	  };

	  const addUserToLine = (u) => {
		  
	    if (!docVerId) { showMsg('docVerId가 없습니다.'); return; }

	    const uid = pickUserId(u);
	    if (!uid) { showMsg('userId를 찾을 수 없습니다.'); return; }

	    if (lines.some(x => String(x.approverId) === String(uid))) {
	      showMsg('이미 추가된 결재자입니다.');
	      return;
	    }

	    lines.push({
	      seq: lines.length + 1,
	      approverId: Number(uid),
	      approverName: name,
	      lineRoleCode: 'AR003'
	    });

	    selectedIndex = lines.length - 1;
	    render();
	    showMsg('결재자를 추가했습니다.');
	  };

	  // 렌더 유틸: details(드롭다운) 하나 만들기
	  const makeDetails = (title, badgeText, defaultOpen) => {
	    const details = document.createElement('details');
	    details.className = 'tree-details';
	    if (defaultOpen) details.open = true;

	    const summary = document.createElement('summary');
	    summary.className = 'tree-summary';
	    summary.innerHTML =
	      '<span>' + title + '</span>' +
	      '<span class="tree-pill">' + (badgeText || '') + '</span>';

	    const children = document.createElement('div');
	    children.className = 'tree-children';

	    details.appendChild(summary);
	    details.appendChild(children);
	    return { details, children };
	  };

	  const addUserItem = (container, u, metaText) => {
	    const nm = pickName(u);
	    if (!matches(nm)) return false;

	    const rc = pickRoleCode(u);

	    const item = document.createElement('div');
	    item.className = 'tree-item d-flex justify-content-between align-items-center';
	    item.innerHTML =
	      '<div>' +
	        '<div>' + (nm || '(이름없음)') + '</div>' +
	        '<div class="tree-muted">' + roleName(rc) + (metaText ? (' · ' + metaText) : '') + '</div>' +
	      '</div>' +
	      '<span class="badge text-bg-light">추가</span>';

	    item.addEventListener('click', () => addUserToLine(u));
	    container.appendChild(item);
	    return true;
	  };

	  treeEl.innerHTML = '';
	  let totalUserCount = 0;

	  // =========================
	  // 2) 지점 (지점별 dropdown)
	  // =========================
	  const brTitle = document.createElement('div');
	  brTitle.className = 'tree-group-title';
	  brTitle.textContent = '지점';
	  treeEl.appendChild(brTitle);

	  const branches = data.branches || {};
	  const branchIds = Object.keys(branches);

	  if (branchIds.length === 0) {
	    const empty = document.createElement('div');
	    empty.className = 'text-body-secondary';
	    empty.textContent = '지점 데이터가 없습니다.';
	    treeEl.appendChild(empty);
	  } else {
	    branchIds.forEach(branchId => {
	      const node = branches[branchId] || {};
	      const users = node.users || [];

	      const title = node.branchName || ('지점 ' + branchId);
	      const { details, children } = makeDetails(title, `총 ${users.length}명`, false);

	      let localCount = 0;
	      users.forEach(u => {
	        const bid = pickBranchId(u) ?? branchId;
	        const ok = addUserItem(children, u, 'branchId=' + bid);
	        if (ok) { localCount++; totalUserCount++; }
	      });

	      if (localCount === 0) {
	        if (keyword) return; // 검색 중이면 숨김
	        const msg = document.createElement('div');
	        msg.className = 'text-body-secondary';
	        msg.textContent = '사용자가 없습니다.';
	        children.appendChild(msg);
	      }

	      if (keyword && localCount > 0) details.open = true;

	      treeEl.appendChild(details);
	    });
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

      // 저장 후 다시 조회
      await loadLines();
    } catch (e) {
      showMsg('저장 중 오류: ' + e);
    }
  });

  // ===== 트리 검색/새로고침 =====
  document.getElementById('btnReloadTree')?.addEventListener('click', loadApproverTree);
  document.getElementById('inpTreeKeyword')?.addEventListener('input', () => {
    renderApproverTree();
  });

  // 최초 실행
  loadLines();
  loadApproverTree();
</script>

<jsp:include page="../includes/admin_footer.jsp" />
</body>
</html>
