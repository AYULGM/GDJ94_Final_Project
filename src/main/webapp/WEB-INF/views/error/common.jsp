<%@ page contentType="text/html; charset=UTF-8" %>

<style>
.error-wrap {
    max-width: 500px;
    margin: 120px auto;
    padding: 40px 30px;
    text-align: center;
    border-radius: 12px;
    background: #ffffff;
    box-shadow: 0 10px 25px rgba(0,0,0,0.08);
    font-family: 'Pretendard', sans-serif;
}

.error-icon {
    font-size: 60px;
    margin-bottom: 10px;
}

.error-title {
    font-size: 24px;
    font-weight: 700;
    margin-bottom: 8px;
}

.error-desc {
    color: #666;
    margin-bottom: 25px;
}

.error-btn {
    display: inline-block;
    padding: 10px 18px;
    border-radius: 6px;
    background: #007bff;
    color: #fff;
    text-decoration: none;
    border: none;
    cursor: pointer;
    font-size: 14px;
    transition: .2s;
}

.error-btn:hover {
    background: #0056b3;
}

.detail-box {
    display: none;
    margin-top: 20px;
    text-align: left;
    background: #f8f9fa;
    padding: 15px;
    border-radius: 6px;
    font-size: 13px;
    color: #333;
    max-height: 200px;
    overflow: auto;
}
</style>

<div class="error-wrap">

    <div class="error-icon">⚠️</div>

    <div class="error-title">
        잘못된 요청입니다
    </div>

    <div class="error-desc">
        요청하신 작업을 처리할 수 없습니다.<br>
        잠시 후 다시 시도해주세요.
    </div>

    <button class="error-btn" onclick="toggleDetail()">
        상세 오류 보기
    </button>

    <div id="detailBox" class="detail-box">
        <pre>${detail}</pre>
    </div>

    <hr style="margin:30px 0">

    <a href="/" class="error-btn"
       style="background:#6c757d;">
        메인으로
    </a>

</div>

<script>
function toggleDetail() {
    const box = document.getElementById("detailBox");

    if (box.style.display === "block") {
        box.style.display = "none";
    } else {
        box.style.display = "block";
    }
}
</script>
