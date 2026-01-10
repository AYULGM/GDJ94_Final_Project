<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<c:set var="doc" value="${print}" />

<div style="position:fixed; top:0; left:0; z-index:999999;
            background:#fff; border:2px solid #000; padding:8px; font-size:14px;">
  hasPrint = ${print != null}
  / typeCode = <c:out value="${doc.typeCode}" />
  / docVerId = <c:out value="${doc.docVerId}" />
  / route =
  <c:choose>
    <c:when test="${doc.typeCode eq 'AT009'}">vacation_print.jsp</c:when>
    <c:otherwise>ext_common_router.jsp</c:otherwise>
  </c:choose>
</div>
