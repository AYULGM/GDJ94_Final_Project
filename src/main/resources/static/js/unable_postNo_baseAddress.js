/* 우편번호와 기본주소를 직접 입력하지못하게 */
document.addEventListener("DOMContentLoaded", function () {

    document.getElementById("postNo")
        .addEventListener("keydown", e => e.preventDefault());

    document.getElementById("baseAddress")
        .addEventListener("keydown", e => e.preventDefault());

});