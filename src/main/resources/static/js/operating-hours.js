/* 오픈시간과 닫는시간을 합치는 js */
document.querySelector("form").addEventListener("submit", function () {
    const open = document.getElementById("openTime").value;
    const close = document.getElementById("closeTime").value;

    if (open && close) {
        document.getElementById("operatingHours").value =
            open + "~" + close;
    }
});
