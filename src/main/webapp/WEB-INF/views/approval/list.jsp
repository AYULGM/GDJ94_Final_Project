<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>전자결재 목록</title>

  <!-- Bootstrap 5.3 (CDN) -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

  <jsp:include page="../includes/admin_header.jsp" />

  <main class="container py-4">

    <div class="d-flex align-items-center justify-content-between mb-3">
      <div>
        <div class="text-muted small"></div>
      </div>

      <a class="btn btn-primary" href="/approval/form">결재 작성</a>
    </div>

    <div class="card shadow-sm">
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

                  <!-- 결재유형: 공통코드 설명(formName) 우선 -->
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
                       href="/approval/detail?docVerId=${row.docVerId}">
                       <%-- 상세 화면 만들면 아래로 변경 권장:
                       href="/approval/detail?docVerId=${row.docVerId}"
                       --%>
                      <c:out value="${row.title}" />
                    </a>
                  </td>

                  <!-- 상태: 배지 색상은 코드로, 텍스트는 공통코드 설명(docStatusName) 우선 -->
                  <td class="text-nowrap">
                    <c:choose>
                      <c:when test="${row.docStatusCode == 'AS001'}">
                        <span class="badge text-bg-secondary">
                          <c:choose>
                            <c:when test="${not empty row.docStatusName}">
                              <c:out value="${row.docStatusName}" />
                            </c:when>
                            <c:otherwise>임시저장</c:otherwise>
                          </c:choose>
                        </span>
                      </c:when>

                      <c:when test="${row.docStatusCode == 'AS002'}">
                        <span class="badge text-bg-primary">
                          <c:choose>
                            <c:when test="${not empty row.docStatusName}">
                              <c:out value="${row.docStatusName}" />
                            </c:when>
                            <c:otherwise>결재중</c:otherwise>
                          </c:choose>
                        </span>
                      </c:when>

                      <c:when test="${row.docStatusCode == 'AS003'}">
                        <span class="badge text-bg-success">
                          <c:choose>
                            <c:when test="${not empty row.docStatusName}">
                              <c:out value="${row.docStatusName}" />
                            </c:when>
                            <c:otherwise>결재완료</c:otherwise>
                          </c:choose>
                        </span>
                      </c:when>

                      <c:when test="${row.docStatusCode == 'AS004'}">
                        <span class="badge text-bg-danger">
                          <c:choose>
                            <c:when test="${not empty row.docStatusName}">
                              <c:out value="${row.docStatusName}" />
                            </c:when>
                            <c:otherwise>반려</c:otherwise>
                          </c:choose>
                        </span>
                      </c:when>

                      <c:otherwise>
                        <span class="badge text-bg-dark">
                          <c:choose>
                            <c:when test="${not empty row.docStatusName}">
                              <c:out value="${row.docStatusName}" />
                            </c:when>
                            <c:otherwise>${row.docStatusCode}</c:otherwise>
                          </c:choose>
                        </span>
                      </c:otherwise>
                    </c:choose>
                  </td>

                  <td class="text-nowrap">
                    <c:choose>
                      <c:when test="${empty row.currentApproverName}">
                        <span class="text-muted">-</span>
                      </c:when>
                      <c:otherwise>
                        <c:out value="${row.currentApproverName}" />
                      </c:otherwise>
                    </c:choose>
                  </td>

                  <td class="text-nowrap">
					  <c:out value="${fn:replace(row.createDate, 'T', ' ')}" />
					</td>

                </tr>
              </c:forEach>

              <c:if test="${empty list}">
                <tr>
                  <td colspan="6" class="text-center py-5 text-muted">
                    조회된 문서가 없습니다.
                  </td>
                </tr>
              </c:if>
            </tbody>

          </table>
        </div>
      </div>
    </div>

  </main>

  <jsp:include page="../includes/admin_footer.jsp" />

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
