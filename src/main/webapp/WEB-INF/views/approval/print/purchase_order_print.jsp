<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<c:set var="doc" value="${print}" />

<div style="position:relative; width:1250px; height:1800px;">

  <!-- 배경 -->
  <img src="${pageContext.request.contextPath}/approval/formPng/purchase_order.png"
       style="position:absolute; top:0; left:0; width:100%; height:auto;" />

  <!-- 필드 출력 -->
  <jsp:include page="_fields_purchase_order_po.jspf" />

</div>
