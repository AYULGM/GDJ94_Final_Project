<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<c:set var="doc" value="${print}" />

<jsp:include page="_print_base.jspf">
  <jsp:param name="bg" value="/approval/formPng/purchase_request.jpg"/>
</jsp:include>

<jsp:include page="_fields_common.jspf"/>
<jsp:include page="_fields_purchase.jspf"/>

  </div>
</div>
