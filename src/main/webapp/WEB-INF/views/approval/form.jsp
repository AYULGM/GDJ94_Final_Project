<%@ page contentType="text/html; charset=UTF-8" %>

<html>
<head>
    <title>결재 작성</title>
</head>
<body>

<h2>전자결재 작성</h2>

<form method="post" action="#">
    <!-- 문서 기본 -->
    <div>
        <label>결재유형</label>
        <select name="approvalType">
            <option value="REPORT">업무보고</option>
            <option value="ATTENDANCE">근태</option>
            <option value="EXPENSE">비용</option>
            <option value="TASK">업무</option>
        </select>
    </div>

    <div>
        <label>제목</label>
        <input type="text" name="title" style="width:400px;">
    </div>

    <div>
        <label>내용</label><br>
        <textarea name="content" rows="10" cols="80"></textarea>
    </div>

    <!-- 버튼 영역 -->
    <div style="margin-top:20px;">
        <button type="button">임시저장</button>
        <button type="button">상신</button>
        <button type="button" onclick="location.href='/approval/list'">목록</button>
    </div>
</form>

</body>
</html>
