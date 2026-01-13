<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>전자결재 상세</title>

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
/* 좌측 미리보기만 스크롤 */
.preview-box{
  height: calc(100vh - 140px);
  overflow: auto;
  background: #f8f9fa;
}

/* iframe 스크롤 제거 + 축소 */
.preview-iframe{
  width: 1250px;
  height: 2000px;
  border: 0;
  overflow: hidden;
  display: block;
  transform: scale(0.7);
  transform-origin: top left;
}

/* 우측 패널도 화면 높이에 맞추고 내부만 스크롤 */
.side-sticky{
  position: sticky;
  top: 88px; /* 헤더 높이에 맞춰 조정 */
}
.side-scroll{
  max-height: calc(100vh - 140px);
  overflow: auto;
}
</style>

</head>
<body class="bg-light">

<jsp:include page="../includes/admin_header.jsp" />

<main class="container-fluid py-3 px-3">

  <div class="d-flex align-items-center justify-content-between mb-3">
    <div>
      <h2 class="h5 mb-1">전자결재 상세</h2>
      <div class="text-muted small">
        <c:out value="${page.doc.title}" />
      </div>
    </div>
    <div class="text-muted small">
      docVerId: ${docVerId}
    </div>
  </div>

  <div class="row g-3">

    <!-- 좌측: 미리보기 -->
    <div class="col-12 col-xl-8">
      <div class="card shadow-sm">
        <div class="card-header bg-white d-flex justify-content-between align-items-center">
          <div class="fw-semibold">문서 미리보기</div>
          <div class="d-flex gap-2">
            <a class="btn btn-sm btn-outline-dark" href="/approval/view?docVerId=${docVerId}">출력/미리보기</a>
            <a class="btn btn-sm btn-outline-secondary" href="/approval/list">목록</a>
          </div>
        </div>
        <div class="card-body p-0">
          <div class="preview-box">
            <iframe
              src="/approval/view?docVerId=${docVerId}"
              class="preview-iframe"
              scrolling="no"
              title="문서 미리보기"></iframe>
          </div>
        </div>
      </div>
    </div>

    <!-- 우측: 정보 + 라인 + 코멘트 + 작업 -->
    <div class="col-12 col-xl-4">
      <div class="side-sticky">
        <div class="card shadow-sm side-scroll">

          <div class="card-body">

            <!-- 메시지(최상단 고정 느낌) -->
            <c:if test="${not empty msg}">
              <div class="alert alert-warning alert-dismissible fade show" role="alert">
                <c:out value="${msg}" />
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
              </div>
            </c:if>

            <!-- 문서 정보 -->
            <div class="mb-3">
              <div class="d-flex justify-content-between align-items-center mb-2">
                <div class="fw-semibold">문서 정보</div>
                <c:choose>
                  <c:when test="${page.doc.docStatusCode == 'AS001'}"><span class="badge text-bg-secondary">임시저장</span></c:when>
                  <c:when test="${page.doc.docStatusCode == 'AS002'}"><span class="badge text-bg-primary">결재중</span></c:when>
                  <c:when test="${page.doc.docStatusCode == 'AS003'}"><span class="badge text-bg-success">결재완료</span></c:when>
                  <c:when test="${page.doc.docStatusCode == 'AS004'}"><span class="badge text-bg-danger">반려</span></c:when>
                  <c:otherwise><span class="badge text-bg-dark"><c:out value="${page.doc.docStatusCode}" /></span></c:otherwise>
                </c:choose>
              </div>

              <div class="row g-2">
                <div class="col-12">
                  <div class="text-muted small">문서번호</div>
                  <div class="fw-semibold">${page.doc.docNo}</div>
                </div>

                <div class="col-12">
                  <div class="text-muted small">결재유형</div>
                  <div>
                    <c:choose>
                      <c:when test="${not empty page.doc.formName}">
                        <c:out value="${page.doc.formName}" />
                      </c:when>
                      <c:otherwise>${page.doc.formCode}</c:otherwise>
                    </c:choose>
                  </div>
                </div>

                <div class="col-6">
                  <div class="text-muted small">기안자</div>
                  <div class="text-nowrap"><c:out value="${page.doc.drafterName}" /></div>
                </div>

                <div class="col-6">
                  <div class="text-muted small">현재결재자</div>
                  <div class="text-nowrap">
                    <c:choose>
                      <c:when test="${empty page.doc.currentApproverName}">
                        <span class="text-muted">-</span>
                      </c:when>
                      <c:otherwise><c:out value="${page.doc.currentApproverName}" /></c:otherwise>
                    </c:choose>
                  </div>
                </div>

                <div class="col-6">
                  <div class="text-muted small">작성일</div>
                  <div class="text-nowrap">${page.doc.createDate}</div>
                </div>

                <div class="col-6">
                  <div class="text-muted small">수정일</div>
                  <div class="text-nowrap">${page.doc.updateDate}</div>
                </div>
              </div>
            </div>

            <hr class="my-3"/>

            <!-- 결재라인 -->
            <div class="mb-3">
              <div class="fw-semibold mb-2">결재라인</div>
              <div class="table-responsive">
                <table class="table table-sm align-middle mb-0">
                  <thead class="table-light">
                    <tr>
                      <th class="text-nowrap">순번</th>
                      <th class="text-nowrap">결재자</th>
                      <th class="text-nowrap">상태</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:forEach var="l" items="${page.lines}">
                      <tr>
                        <td class="text-nowrap">${l.seq}</td>
                        <td class="text-nowrap"><c:out value="${l.approverName}" /></td>
                        <td class="text-nowrap">
                          <c:choose>
                            <c:when test="${l.lineStatusCode == 'ALS002'}"><span class="badge text-bg-primary">대기</span></c:when>
                            <c:when test="${l.lineStatusCode == 'ALS003'}"><span class="badge text-bg-success">승인</span></c:when>
                            <c:when test="${l.lineStatusCode == 'ALS004'}"><span class="badge text-bg-danger">반려</span></c:when>
                            <c:otherwise><span class="badge text-bg-secondary"><c:out value="${l.lineStatusCode}" /></span></c:otherwise>
                          </c:choose>
                        </td>
                      </tr>
                    </c:forEach>

                    <c:if test="${empty page.lines}">
                      <tr>
                        <td colspan="3" class="text-center py-3 text-muted">결재라인 정보가 없습니다.</td>
                      </tr>
                    </c:if>

                  </tbody>
                </table>
              </div>
            </div>

            <hr class="my-3"/>

            <!-- 코멘트: 아코디언으로 접어서 필요할 때만 펼치기 -->
            <div class="accordion mb-3" id="commentAcc">
              <div class="accordion-item">
                <h2 class="accordion-header" id="commentHead">
                  <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#commentBody" aria-expanded="false" aria-controls="commentBody">
                    코멘트
                  </button>
                </h2>
                <div id="commentBody" class="accordion-collapse collapse" aria-labelledby="commentHead" data-bs-parent="#commentAcc">
                  <div class="accordion-body p-0">
                    <c:set var="hasComment" value="false" />
                    <c:forEach var="l" items="${page.lines}">
                      <c:if test="${not empty l.comment}">
                        <c:set var="hasComment" value="true" />
                      </c:if>
                    </c:forEach>

                    <c:choose>
                      <c:when test="${hasComment}">
                        <ul class="list-group list-group-flush">
                          <c:forEach var="l" items="${page.lines}">
                            <c:if test="${not empty l.comment}">
                              <li class="list-group-item">
                                <div class="fw-semibold">
                                  ${l.seq}차 · <c:out value="${l.approverName}" />
                                  <span class="text-muted small ms-1">
                                    (<c:choose>
                                      <c:when test="${l.lineStatusCode == 'ALS003'}">승인</c:when>
                                      <c:when test="${l.lineStatusCode == 'ALS004'}">반려</c:when>
                                      <c:otherwise>기타</c:otherwise>
                                    </c:choose>)
                                  </span>
                                </div>
                                <pre class="mb-0 small" style="white-space:pre-wrap;"><c:out value="${l.comment}" /></pre>
                              </li>
                            </c:if>
                          </c:forEach>
                        </ul>
                      </c:when>
                      <c:otherwise>
                        <div class="p-3 text-center text-muted">등록된 코멘트가 없습니다.</div>
                      </c:otherwise>
                    </c:choose>

                  </div>
                </div>
              </div>
            </div>

            <!-- 작업 -->
            <div class="d-grid gap-2">

              <c:if test="${page.canRecall}">
                <form method="post" action="/approval/recall">
                  <input type="hidden" name="docVerId" value="${docVerId}" />
                  <c:if test="${not empty _csrf}">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                  </c:if>
                  <button type="submit" class="btn btn-warning">상신 취소</button>
                </form>
              </c:if>

              <c:if test="${page.canEdit}">
                <a class="btn btn-secondary" href="/approval/form?docVerId=${docVerId}">수정</a>
                <a class="btn btn-outline-secondary" href="/approval/line?docVerId=${docVerId}">결재선 수정</a>

                <form method="post" action="/approval/resubmit">
                  <input type="hidden" name="docVerId" value="${docVerId}" />
                  <c:if test="${not empty _csrf}">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                  </c:if>
                  <button type="submit" class="btn btn-primary">재상신</button>
                </form>
              </c:if>

            </div>

            <div class="text-muted small mt-3">
              * “상신 취소”는 1차 결재자가 승인/반려하기 전까지만 가능합니다.
            </div>

          </div>
        </div>
      </div>
    </div>

  </div>

</main>

<jsp:include page="../includes/admin_footer.jsp" />

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
