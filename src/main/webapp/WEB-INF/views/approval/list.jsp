<%@ page contentType="text/html; charset=UTF-8" %>
	<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<html>
<head>
    <title>전자결재 목록</title>
</head>
<body>

<h2>전자결재 목록</h2>

<div>
    <a href="/approval/form">결재 작성</a>
</div>

<table border="1" width="100%">
    <thead>
        <tr>
            <th>문서번호</th>
            <th>결재유형</th>
            <th>제목</th>
            <th>상태</th>
            <th>작성자</th>
            <th>작성일</th>
        </tr>
    </thead>
    <tbody>
        <!-- 나중에 DB 연결 시 forEach -->
        <tr>
            <td>1</td>
            <td>업무보고</td>
            <td>
                <a href="/approval/print?docId=1">업무 보고서</a>
            </td>
            <td>임시저장</td>
            <td>홍길동</td>
            <td>2025-01-01</td>
        </tr>
    </tbody>
</table>

</body>
</html>
