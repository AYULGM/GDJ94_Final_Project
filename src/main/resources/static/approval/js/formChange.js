(function () {
    const typeSelect = document.getElementById('approvalTypeCode');
    const extras = document.querySelectorAll('.doc-extra');

    function showExtras(typeCode) {
      let matched = false;

      extras.forEach(el => {
        const t = el.getAttribute('data-type');
        const on = (t === typeCode);
        el.style.display = on ? '' : 'none';
        if (on) matched = true;
      });

      if (!matched) {
        extras.forEach(el => {
          if (el.getAttribute('data-type') === '__DEFAULT__') el.style.display = '';
        });
      }
    }

    typeSelect.addEventListener('change', function () {
      showExtras(typeSelect.value);
    });

    showExtras(typeSelect.value);
  })();

  function submitTemp() {
    document.getElementById('tempYn').value = 'Y';
    document.getElementById('approvalForm').submit();
  }