<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<%-- doc가 null이거나 typeCode가 null인 경우도 있으니 방어 --%>
<c:set var="t" value="${empty doc or empty doc.typeCode ? '' : doc.typeCode}" />

<%-- 기본값(절대 null 방지) --%>
<c:set var="bgImageUrl" value="${ctx}/approval/formPng/leave.png" />
<c:set var="fieldsJspf" value="/WEB-INF/views/approval/print/_fields_common.jspf" />

<c:choose>
  <c:when test="${t eq 'AT001'}">
    <c:set var="bgImageUrl" value="${ctx}/approval/formPng/expense.png" />
    <c:set var="fieldsJspf" value="/WEB-INF/views/approval/print/_fields_expense.jspf" />
  </c:when>

  <c:when test="${t eq 'AT002'}">
    <c:set var="bgImageUrl" value="${ctx}/approval/formPng/settlement.png" />
    <c:set var="fieldsJspf" value="/WEB-INF/views/approval/print/_fields_settlement.jspf" />
  </c:when>

  <c:when test="${t eq 'AT003'}">
    <c:set var="bgImageUrl" value="${ctx}/approval/formPng/sales.jpg" />
    <c:set var="fieldsJspf" value="/WEB-INF/views/approval/print/_fields_sales.jspf" />
  </c:when>

  <c:when test="${t eq 'AT004'}">
    <%-- 재고조정 배경이 settlement로 되어있어서 혼동되면 나중에 inventory 전용 배경으로 교체 추천 --%>
    <c:set var="bgImageUrl" value="${ctx}/approval/formPng/settlement.png" />
    <c:set var="fieldsJspf" value="/WEB-INF/views/approval/print/_fields_inventory.jspf" />
  </c:when>

  <c:when test="${t eq 'AT005'}">
    <c:set var="bgImageUrl" value="${ctx}/approval/formPng/purchase_request.jpg" />
    <c:set var="fieldsJspf" value="/WEB-INF/views/approval/print/_fields_purchase.jspf" />
  </c:when>

  <c:when test="${t eq 'AT006'}">
    <c:set var="bgImageUrl" value="${ctx}/approval/formPng/purchase_order.png" />
    <c:set var="fieldsJspf" value="/WEB-INF/views/approval/print/_fields_order.jspf" />
  </c:when>

  <c:when test="${t eq 'AT009'}">
    <c:set var="bgImageUrl" value="${ctx}/approval/formPng/leave.png" />
    <c:set var="fieldsJspf" value="/WEB-INF/views/approval/print/_fields_vacation.jspf" />
  </c:when>
</c:choose>

<style>
  .back-btn{display:inline-flex;align-items:center;gap:6px;padding:6px 12px;border:1.5px solid #cbd5e1;border-radius:999px;background:#fff;color:#334155;font-size:13px;font-weight:600;text-decoration:none;box-shadow:0 1px 2px rgba(0,0,0,.08);transition:all .15s ease;}
  .back-btn:hover{background:#f8fafc;border-color:#94a3b8;transform:translateY(-1px);}
  .back-btn:active{transform:translateY(0);box-shadow:none;}

  /* 디버그 바(렌더링 확인용) */
  .preview-debug{
    position: fixed; top: 8px; left: 8px; z-index: 9999;
    background: rgba(255, 241, 118, .95);
    border: 1px solid #e2e8f0; border-radius: 10px;
    padding: 8px 10px; font-size: 12px; color: #0f172a;
    box-shadow: 0 2px 10px rgba(0,0,0,.12);
    max-width: calc(100vw - 16px);
  }
  .preview-debug code{font-family: ui-monospace, SFMono-Regular, Menlo, monospace;}
  .print-page{
    position: relative;   /* absolute 기준 */
  }

  /* 배경 */
  .print-bg{
    position: relative;
    z-index: 1;
    display: block;
    width: 100%;
    height: auto;
  }

  /* 필드 레이어 */
  .overlay{
    position: absolute;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    z-index: 2;           /* 배경 위 */
    pointer-events: none;
  }

</style>

<c:if test="${param.preview ne '1'}">
  <div class="d-flex justify-content-end mb-2">
    <a class="back-btn" href="${ctx}/approval/detail?docVerId=${docVerId}">← 돌아가기</a>
  </div>
</c:if>

<%@ include file="_print_base.jspf" %>
