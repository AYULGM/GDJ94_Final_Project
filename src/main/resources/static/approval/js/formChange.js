(function () {
  const typeSelect = document.getElementById('approvalTypeCode');
  const extras = document.querySelectorAll('.doc-extra');
  const formCodeInput = document.getElementById('formCode');
  const modeInput = document.getElementById('mode'); // ✅ edit/new 판단

  if (!typeSelect) return;

  const typeToForm = {
    "AT001": "DF001",
    "AT002": "DF002",
    "AT003": "DF003",
    "AT004": "DF004",
    "AT005": "DF005",
    "AT006": "DF006",
    "AT007": "DF007",
    "AT008": "DF008",
    "AT009": "DF009",
    "AT010": "DF010",
    "AT011": "DF011",
    "AT012": "DF012"
  };

  function isEditMode() {
    return modeInput && modeInput.value === 'edit';
  }

  function setEnabled(container, enabled) {
    const fields = container.querySelectorAll('input, select, textarea, button');
    fields.forEach(f => { f.disabled = !enabled; });
  }

  function hideAll() {
    extras.forEach(el => {
      el.style.display = 'none';
      setEnabled(el, false);
    });
  }

  // ✅ 기본(__DEFAULT__)은 항상 보여주는 정책
  function showDefault() {
    extras.forEach(el => {
      if (el.getAttribute('data-type') === '__DEFAULT__') {
        el.style.display = '';
        setEnabled(el, true);
      }
    });
  }

  function showSelected(typeCode) {
    if (!typeCode) return;

    extras.forEach(el => {
      const t = el.getAttribute('data-type');
      if (t === typeCode) {
        el.style.display = '';
        setEnabled(el, true);
      }
    });
  }

  // ✅ 신규: typeCode 기반으로 항상 갱신
  // ✅ 수정: 기존 formCode가 있으면 유지, 비어있을 때만 채움
  function syncFormCode(typeCode) {
    if (!formCodeInput) return;

    const mapped = typeToForm[typeCode] || "";

    if (isEditMode()) {
      if (!formCodeInput.value) formCodeInput.value = mapped; // 빈값일 때만
    } else {
      formCodeInput.value = mapped; // 신규는 항상 반영
    }
  }

  function apply() {
    const typeCode = typeSelect.value;

    syncFormCode(typeCode);

    hideAll();
    showDefault();
    showSelected(typeCode);
  }

  typeSelect.addEventListener('change', apply);

  // 초기 1회
  apply();
})();
