<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<style>
  .back-btn {
    display:inline-flex;
    align-items:center;
    gap:6px;
    padding:6px 12px;
    border:1.5px solid #cbd5e1;
    border-radius:999px;
    background:#fff;
    color:#334155;
    font-size:13px;
    font-weight:600;
    text-decoration:none;      /* 밑줄 제거 */
    box-shadow:0 1px 2px rgba(0,0,0,.08);
    transition:all .15s ease;
  }
  .back-btn:hover {
    background:#f8fafc;
    border-color:#94a3b8;
    transform:translateY(-1px);
  }
  .back-btn:active {
    transform:translateY(0);
    box-shadow:none;
  }
</style>

<c:if test="${param.preview ne '1'}">
  <div class="d-flex justify-content-end mb-2">
    <a class="back-btn"
       href="${pageContext.request.contextPath}/approval/detail?docVerId=${docVerId}">
      ← 돌아가기
    </a>
  </div>
</c:if>


<div class="print-wrap ${param.preview == '1' ? 'preview' : ''}">

<%@ include file="_print_base.jspf" %>

