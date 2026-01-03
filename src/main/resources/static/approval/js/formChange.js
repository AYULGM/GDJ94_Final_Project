(function () {
  const typeSelect = document.getElementById('approvalTypeCode');
  const extras = document.querySelectorAll('.doc-extra');
  const formCodeInput = document.getElementById('formCode');

  // AT -> DF 매핑
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
    // "AT012": "DF??"  // 너희 DF 정의가 없어서 정책 필요
  };

  function syncFormCode(typeCode) {
    if (!formCodeInput) return;
    formCodeInput.value = typeToForm[typeCode] || "";
  }

  function setEnabled(container, enabled) {
    const fields = container.querySelectorAll('input, select, textarea, button');
    fields.forEach(f => {
      f.disabled = !enabled;
    });
  }

  function showExtras(typeCode) {
    let matched = false;

    extras.forEach(el => {
      const t = el.getAttribute('data-type');
      const on = (t === typeCode);

      el.style.display = on ? '' : 'none';
      setEnabled(el, on);

      if (on) matched = true;
    });

    if (!matched) {
      extras.forEach(el => {
        if (el.getAttribute('data-type') === '__DEFAULT__') {
          el.style.display = '';
          setEnabled(el, true);
        }
      });
    }
  }

  typeSelect.addEventListener('change', function () {
    const typeCode = typeSelect.value;
    syncFormCode(typeCode);   // ✅ 추가
    showExtras(typeCode);
  });

  // 초기 1회
  syncFormCode(typeSelect.value); // ✅ 추가
  showExtras(typeSelect.value);
})();
