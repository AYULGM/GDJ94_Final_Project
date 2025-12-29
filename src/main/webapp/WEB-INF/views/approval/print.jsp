<html>
<head>
<%@ page contentType="text/html; charset=UTF-8" %>

    <title>결재 문서</title>
</head>
<body>
<jsp:include page="../includes/admin_header.jsp" />

<h2>전자결재 문서</h2>

<table border="1" width="100%">
    <tr>
        <th width="20%">결재유형</th>
        <td>업무보고</td>
    </tr>
    <tr>
        <th>제목</th>
        <td>업무 보고서</td>
    </tr>
    <tr>
        <th>작성자</th>
        <td>홍길동</td>
    </tr>
    <tr>
        <th>작성일</th>
        <td>2025-01-01</td>
    </tr>
    <tr>
        <th>내용</th>
        <td style="height:200px; vertical-align:top;">
            업무 보고 내용입니다.
        </td>
    </tr>
</table>

<div style="margin-top:20px;">
    <button onclick="location.href='/approval/list'">목록</button>
    <button onclick="location.href='/approval/form'">수정</button>
</div>

</body>
</html>
