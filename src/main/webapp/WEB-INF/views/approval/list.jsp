<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>

<jsp:include page="../includes/admin_header.jsp" />

<div class="row">
  <div class="col-12">

    <div class="d-flex align-items-center justify-content-between mb-3">
      <div class="text-muted small"></div>
      <a class="btn btn-primary" href="<c:url value='/approval/form?entry=approval'/>">결재 작성</a>
    </div>

    <div class="card">
      <div class="card-body p-0">
        <div class="table-responsive">
          <table class="table table-hover table-striped align-middle mb-0">
            <thead class="table-light">
              <tr>
                <th class="text-nowrap">문서번호</th>
                <th class="text-nowrap">결재유형</th>
                <th>제목</th>
                <th class="text-nowrap">상태</th>
                <th class="text-nowrap">현재결재자</th>
                <th class="text-nowrap">작성일</th>
              </tr>
            </thead>

            <tbody>
              <c:forEach var="row" items="${list}">
                <tr>
                  <td class="text-nowrap">${row.docNo}</td>

                  <td class="text-nowrap">
                    <c:choose>
                      <c:when test="${not empty row.formName}">
                        <c:out value="${row.formName}" />
                      </c:when>
                      <c:otherwise>${row.formCode}</c:otherwise>
                    </c:choose>
                  </td>

                  <td>
                    <a class="link-primary text-decoration-none fw-semibold"
                       href="<c:url value='/approval/detail?docVerId=${row.docVerId}'/>">
                      <c:out value="${row.title}" />
                    </a>
                  </td>

                  <td class="text-nowrap">
                    <c:choose>
                      <c:when test="${row.docStatusCode == 'AS001'}"><span class="badge text-bg-secondary">${not empty row.docStatusName ? row.docStatusName : '임시저장'}</span></c:when>
                      <c:when test="${row.docStatusCode == 'AS002'}"><span class="badge text-bg-primary">${not empty row.docStatusName ? row.docStatusName : '결재중'}</span></c:when>
                      <c:when test="${row.docStatusCode == 'AS003'}"><span class="badge text-bg-success">${not empty row.docStatusName ? row.docStatusName : '결재완료'}</span></c:when>
                      <c:when test="${row.docStatusCode == 'AS004'}"><span class="badge text-bg-danger">${not empty row.docStatusName ? row.docStatusName : '반려'}</span></c:when>
                      <c:otherwise><span class="badge text-bg-dark">${not empty row.docStatusName ? row.docStatusName : row.docStatusCode}</span></c:otherwise>
                    </c:choose>
                  </td>

                  <td class="text-nowrap">
                    <c:choose>
                      <c:when test="${empty row.currentApproverName}"><span class="text-muted">-</span></c:when>
                      <c:otherwise><c:out value="${row.currentApproverName}" /></c:otherwise>
                    </c:choose>
                  </td>

                  <td class="text-nowrap">
                    <c:out value="${fn:replace(row.createDate, 'T', ' ')}" />
                  </td>
                </tr>
              </c:forEach>

              <c:if test="${empty list}">
                <tr>
                  <td colspan="6" class="text-center py-5 text-muted">조회된 문서가 없습니다.</td>
                </tr>
              </c:if>
            </tbody>

          </table>
        </div>
      </div>
    </div>

  </div>
</div>

<jsp:include page="../includes/admin_footer.jsp" />
