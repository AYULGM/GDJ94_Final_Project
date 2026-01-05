function execDaumPostcode() {
    new daum.Postcode({
        oncomplete: function(data) {
            document.getElementById('postNo').value = data.zonecode;
            document.getElementById('baseAddress').value = data.address;
            document.getElementById('detailAddress').focus();
        }
    }).open();
}