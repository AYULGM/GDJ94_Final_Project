<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<h2>로그인</h2>

<form method="post" action="<c:url value='/auth/login'/>">
  <input type="text" value="admin" name="loginId" placeholder="아이디" required />
  <input type="password" value="1234" name="password" placeholder="비밀번호" required />
  <button type="submit">로그인</button>
</form>

<c:if test="${not empty error}">
  <p style="color:red">${error}</p>
</c:if>
