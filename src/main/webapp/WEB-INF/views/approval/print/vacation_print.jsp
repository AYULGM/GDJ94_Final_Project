<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<%--
  vacation_print.jsp (DF009)
  - 컨트롤러에서 model로 doc 내려옴: model.addAttribute("doc", dto);
--%>

<%
  request.setAttribute("bgImageUrl", "/assets/forms/leave.png");
  request.setAttribute("fieldsJspf", "/WEB-INF/views/approval/print/_fields_vacation.jspf");
%>

<jsp:include page="/WEB-INF/views/approval/print/_print_base.jspf" />
