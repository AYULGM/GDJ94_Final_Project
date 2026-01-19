<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<c:when test="${doc.typeCode eq 'AT005'}">
  <div style="position:fixed; top:40px; left:0; z-index:999999; background:yellow; border:2px solid #000; padding:8px;">
    AT005 branch reached -> include purchase_order_print.jsp
  </div>
  <jsp:include page="print/purchase_order_print.jsp" />
</c:when>

<c:choose>
  <c:when test="${print.typeCode eq 'AT001'}">
    <jsp:include page="print/expense_print.jsp" />
  </c:when>
  <c:when test="${print.typeCode eq 'AT002'}">
    <jsp:include page="print/settlement_print.jsp" />
  </c:when>
  <c:when test="${print.typeCode eq 'AT003'}">
    <jsp:include page="print/sales_print.jsp" />
  </c:when>
  <c:when test="${print.typeCode eq 'AT004'}">
    <jsp:include page="print/purchase_print.jsp" />
  </c:when>
  <c:when test="${print.typeCode eq 'AT005'}">
    <jsp:include page="print/purchase_order_print.jsp" />
  </c:when>
  <c:otherwise>
    <div style="padding:20px;">
      지원하지 않는 문서 타입입니다: <c:out value="${print.typeCode}"/>
    </div>
  </c:otherwise>
</c:choose>
