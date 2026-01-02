<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html>
<head>
    <title>회원가입</title>
</head>
<body>

<h2>회원가입</h2>

<form action="<c:url value='/users/joinProc'/>" method="post">
    아이디: <input type="text" name="loginId" required><br>
    비밀번호: <input type="password" name="password" required><br>
    이름: <input type="text" name="name" required><br>
    이메일: <input type="email" name="email"><br>
    전화번호: <input type="text" name="phone"><br>
	우편번호: <input type="text" name="postNo" required><br>
	기본주소: <input type="text" name="baseAddress" required><br>
	상세주소: <input type="text" name="detailAddress"><br>
    <button type="submit">가입하기</button>
</form>

</body>
</html>
