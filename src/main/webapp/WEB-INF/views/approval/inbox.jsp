<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>내 결재함</title>
</head>
<body>
<jsp:include page="../includes/admin_header.jsp" />

<div class="container-fluid py-3">

  <div class="d-flex align-items-center justify-content-between mb-3">
    <div>
      <h3 class="mb-0">내 결재함</h3>
      <div class="text-body-secondary small">현재 내 차례(PENDING=ALS002)인 문서 목록</div>
    </div>
  </div>

  <div class="card shadow-sm">
    <div class="card-header bg-white">
      <div class="fw-semibold">대기 중 결재</div>
    </div>

    <div class="card-body p-0">
      <div class="table-responsive">
        <table class="table table-hover mb-0 align-middle">
          <thead class="table-light">
            <tr>
              <th style="width:170px;">문서번호</th>
              <th style="width:120px;">유형</th>
              <th style="width:120px;">양식</th>
              <th style="width:90px;">내 순번</th>
              <th style="width:120px;">요청일</th>
              <th style="width:110px;"></th>
            </tr>
          </thead>

          <tbody>
            <c:if test="${empty list}">
              <tr>
                <td colspan="6" class="text-center text-body-secondary py-4">
                  현재 처리할 결재 문서가 없습니다.
                </td>
              </tr>
            </c:if>

            <c:forEach var="row" items="${list}">
              <tr>
                <td><c:out value="${row.docNo}"/></td>
                <td><c:out value="${row.typeCode}"/></td>
                <td><c:out value="${row.formCode}"/></td>
                <td><span class="badge text-bg-secondary"><c:out value="${row.mySeq}"/></span></td>
				<td>${row.submittedAt.toString().replace('T',' ')}</td>
                <td class="text-end">
                  <a class="btn btn-sm btn-primary" href="${pageContext.request.contextPath}/approval/handle?docVerId=${row.docVerId}">
                    결재하기
                  </a>
                </td>
              </tr>
            </c:forEach>

          </tbody>
        </table>
      </div>
    </div>

    <div class="card-footer bg-white text-body-secondary small">
      ‘결재하기’를 누르면 문서 상세/승인/반려 화면으로 이동합니다.
    </div>
  </div>

</div>

<jsp:include page="../includes/admin_footer.jsp" />
</body>
</html>
