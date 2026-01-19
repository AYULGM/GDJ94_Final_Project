<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         isErrorPage="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!doctype html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Preview Error</title>
  <style>
    body{font-family:system-ui,sans-serif;padding:16px;background:#f8fafc;}
    .box{border:1px solid #e2e8f0;background:#fff;padding:12px;border-radius:12px;}
    pre{white-space:pre-wrap;}
  </style>
</head>
<body>
  <div class="box">
    <h3>미리보기 로딩 실패</h3>

    <div>docVerId: <c:out value="${docVerId}"/></div>

    <c:if test="${not empty errMsg}">
      <div style="margin-top:10px;">컨트롤러 메시지: <b><c:out value="${errMsg}"/></b></div>
    </c:if>

    <c:if test="${empty errMsg}">
      <div style="margin-top:10px;">JSP 렌더링 예외:</div>
      <pre><%= (exception == null ? "exception=null" : exception.toString()) %></pre>
    </c:if>

    <hr>
    <div>이제부터는 “빈 화면”이 아니라 실제 원인(예외)이 보일 것입니다.</div>
  </div>
</body>
</html>
