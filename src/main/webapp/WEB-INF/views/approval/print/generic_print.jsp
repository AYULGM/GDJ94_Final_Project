<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<%--
  비휴가(AT001~AT006 등) 공통 출력용.
  기존처럼 배경 이미지 오버레이 방식이 완성되지 않은 타입이 있어,
  결재자가 내용 확인/승인할 수 있도록 텍스트 기반으로 최소 출력한다.
--%>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>문서 출력</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <style>
    .kv dt{ width: 160px; }
    .pre-box{ white-space: pre-wrap; word-break: break-word; }
  </style>
</head>

<body class="bg-light">

<c:set var="ext" value="${doc.form}" />

<main class="container py-4">

  <c:if test="${param.preview ne '1'}">
    <div class="d-flex justify-content-end mb-3">
      <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/approval/detail?docVerId=${docVerId}">돌아가기</a>
    </div>
  </c:if>

  <div class="card shadow-sm">
    <div class="card-header bg-white">
      <div class="d-flex justify-content-between align-items-center">
        <div>
          <div class="fw-semibold">전자결재 문서</div>
          <div class="text-muted small">문서번호: <strong><c:out value="${doc.docNo}"/></strong></div>
        </div>
        <span class="badge text-bg-primary"><c:out value="${doc.statusCode}"/></span>
      </div>
    </div>

    <div class="card-body">
      <dl class="row kv mb-0">
        <dt class="col-sm-3 text-muted">문서 타입</dt>
        <dd class="col-sm-9"><c:out value="${doc.typeCode}"/></dd>

        <dt class="col-sm-3 text-muted">양식</dt>
        <dd class="col-sm-9"><c:out value="${doc.formCode}"/></dd>

        <dt class="col-sm-3 text-muted">기안자</dt>
        <dd class="col-sm-9">
          <c:out value="${doc.drafterName}"/>
          <c:if test="${not empty doc.drafterBranchName}">(<c:out value="${doc.drafterBranchName}"/>)</c:if>
        </dd>

        <dt class="col-sm-3 text-muted">부서/직급</dt>
        <dd class="col-sm-9">
          <c:out value="${doc.drafterDeptName}"/> /
          <c:out value="${doc.drafterPosition}"/>
        </dd>

        <dt class="col-sm-3 text-muted">작성일</dt>
        <dd class="col-sm-9"><c:out value="${ext.writtenDateStr}"/></dd>
      </dl>

      <hr/>

      <h6 class="fw-semibold">확장 필드</h6>
      <dl class="row kv mb-0">
        <dt class="col-sm-3 text-muted">extDt1</dt>
        <dd class="col-sm-9"><c:out value="${ext.extDt1}"/></dd>

        <dt class="col-sm-3 text-muted">extDt2</dt>
        <dd class="col-sm-9"><c:out value="${ext.extDt2}"/></dd>

        <dt class="col-sm-3 text-muted">extNo1</dt>
        <dd class="col-sm-9"><c:out value="${ext.extNo1}"/></dd>

        <dt class="col-sm-3 text-muted">extNo2</dt>
        <dd class="col-sm-9"><c:out value="${ext.extNo2}"/></dd>

        <dt class="col-sm-3 text-muted">extNo3</dt>
        <dd class="col-sm-9"><c:out value="${ext.extNo3}"/></dd>

        <dt class="col-sm-3 text-muted">extTxt1</dt>
        <dd class="col-sm-9"><c:out value="${ext.extTxt1}"/></dd>

        <dt class="col-sm-3 text-muted">extTxt2</dt>
        <dd class="col-sm-9"><c:out value="${ext.extTxt2}"/></dd>

        <dt class="col-sm-3 text-muted">extTxt3</dt>
        <dd class="col-sm-9"><c:out value="${ext.extTxt3}"/></dd>

        <dt class="col-sm-3 text-muted">extTxt4</dt>
        <dd class="col-sm-9"><c:out value="${ext.extTxt4}"/></dd>

        <dt class="col-sm-3 text-muted">extCode1</dt>
        <dd class="col-sm-9"><c:out value="${ext.extCode1}"/></dd>

        <dt class="col-sm-3 text-muted">extTxt6(JSON)</dt>
        <dd class="col-sm-9"><div class="border rounded p-2 bg-white pre-box"><c:out value="${ext.extTxt6}"/></div></dd>
      </dl>
    </div>
  </div>

</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
