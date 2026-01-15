<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
 <a class="btn btn-sm btn-outline-dark" href="/approval/detail?docVerId=${docVerId}">돌아가기</a>
<div class="print-wrap ${param.preview == '1' ? 'preview' : ''}">

<%@ include file="_print_base.jspf" %>

