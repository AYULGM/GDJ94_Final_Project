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
/* 좌측 미리보기 박스만 스크롤 */
.preview-box{
  height: 82vh;
  overflow: auto;     /* ⭐ 스크롤은 여기서만 */
  background: #f8f9fa;
}

/* iframe은 스크롤 제거 + 큰 캔버스 + 축소 */
.preview-iframe{
  width: 1250px;      /* 출력 문서 폭(필요시 조정) */
  height: 2000px;     /* ⭐ 문서 전체가 들어갈 만큼 크게 (넉넉히) */
  border: 0;

  overflow: hidden;   /* 내부 스크롤 방지 */
  display: block;

  transform: scale(0.7);
  transform-origin: top left;
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

    
  </div>

  <div class="row g-3">
    <!-- 좌측: 문서 미리보기 -->
    <div class="col-12 col-lg-7">
      <div class="card shadow-sm">
        <div class="card-header bg-white d-flex justify-content-between align-items-center">
          <div class="fw-semibold">문서 미리보기</div>
          <div class="text-muted small">docVerId: ${docVerId}</div>
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

    <!-- 우측: 결재 정보 / 결재라인 / 액션 -->
    <div class="col-12 col-lg-4">

      <!-- 문서 정보 -->
      <div class="card shadow-sm mb-3">
        <div class="card-header bg-white fw-semibold">문서 정보</div>
        <div class="card-body">
          <div class="mb-2">
            <div class="text-muted small">문서번호</div>
            <div class="fw-semibold">${page.doc.docNo}</div>
          </div>

          <div class="mb-2">
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

          <div class="mb-2">
            <div class="text-muted small">기안자</div>
            <div><c:out value="${page.doc.drafterName}" /></div>
          </div>

          <div class="mb-2">
            <div class="text-muted small">현재결재자</div>
            <div>
              <c:choose>
                <c:when test="${empty page.doc.currentApproverName}">
                  <span class="text-muted">-</span>
                </c:when>
                <c:otherwise><c:out value="${page.doc.currentApproverName}" /></c:otherwise>
              </c:choose>
            </div>
          </div>

          <div class="mb-2">
            <div class="text-muted small">상태</div>
            <div>
              <c:choose>
                <c:when test="${page.doc.docStatusCode == 'AS001'}"><span class="badge text-bg-secondary">
                  <c:out value="${empty page.doc.docStatusName ? '임시저장' : page.doc.docStatusName}" /></span></c:when>
                <c:when test="${page.doc.docStatusCode == 'AS002'}"><span class="badge text-bg-primary">
                  <c:out value="${empty page.doc.docStatusName ? '결재중' : page.doc.docStatusName}" /></span></c:when>
                <c:when test="${page.doc.docStatusCode == 'AS003'}"><span class="badge text-bg-success">
                  <c:out value="${empty page.doc.docStatusName ? '결재완료' : page.doc.docStatusName}" /></span></c:when>
                <c:when test="${page.doc.docStatusCode == 'AS004'}"><span class="badge text-bg-danger">
                  <c:out value="${empty page.doc.docStatusName ? '반려' : page.doc.docStatusName}" /></span></c:when>
                <c:otherwise><span class="badge text-bg-dark">
                  <c:out value="${empty page.doc.docStatusName ? page.doc.docStatusCode : page.doc.docStatusName}" /></span></c:otherwise>
              </c:choose>
            </div>
          </div>

          <div class="row g-2">
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
      </div>

      <!-- 결재라인 -->
      <div class="card shadow-sm mb-3">
        <div class="card-header bg-white fw-semibold">결재라인</div>
        <div class="card-body p-0">
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
                        <c:when test="${l.lineStatusCode == 'ALS002'}">
                          <span class="badge text-bg-primary">
                            <c:out value="${empty l.lineStatusName ? '대기' : l.lineStatusName}" />
                          </span>
                        </c:when>
                        <c:when test="${l.lineStatusCode == 'ALS003'}">
                          <span class="badge text-bg-success">
                            <c:out value="${empty l.lineStatusName ? '승인' : l.lineStatusName}" />
                          </span>
                        </c:when>
                        <c:when test="${l.lineStatusCode == 'ALS004'}">
                          <span class="badge text-bg-danger">
                            <c:out value="${empty l.lineStatusName ? '반려' : l.lineStatusName}" />
                          </span>
                        </c:when>
                        <c:otherwise>
                          <span class="badge text-bg-secondary">
                            <c:out value="${empty l.lineStatusName ? l.lineStatusCode : l.lineStatusName}" />
                          </span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                  </tr>
                  <c:if test="${not empty l.comment}">
                    <tr>
                      <td colspan="3" class="small text-muted">
                        코멘트: <c:out value="${l.comment}" />
                      </td>
                    </tr>
                  </c:if>
                </c:forEach>

                <c:if test="${empty page.lines}">
                  <tr>
                    <td colspan="3" class="text-center py-4 text-muted">결재라인 정보가 없습니다.</td>
                  </tr>
                </c:if>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- 액션 버튼 -->
      <div class="card shadow-sm">
        <div class="card-header bg-white fw-semibold">작업</div>
        <div class="card-body">
          <div class="d-grid gap-2">

            <!-- 상신 취소(회수): 기안자 + 1차 처리 전 -->
            <c:if test="${page.canRecall}">
              <form method="post" action="/approval/recall">
                <input type="hidden" name="docVerId" value="${docVerId}" />
                <button type="submit" class="btn btn-warning">상신 취소</button>
              </form>
            </c:if>
<c:if test="${not empty msg}">
  <div class="alert alert-warning alert-dismissible fade show" role="alert">
    <c:out value="${msg}" />
    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
  </div>
</c:if>

            <!-- 수정: 정책에 맞게 (임시/회수) -->
            <c:if test="${page.canEdit}">
              <a class="btn btn-secondary" href="/approval/form?docVerId=${docVerId}">수정</a>
            </c:if>
			<c:if test="${page.canEdit}">
  <!-- 결재선 재설정 화면으로 이동 -->
  <a class="btn btn-secondary" href="/approval/line?docVerId=${docVerId}">결재선 수정</a>

  <!-- 재상신(실제 submit) -->
  <form method="post" action="/approval/resubmit" class="mt-2">
    <input type="hidden" name="docVerId" value="${docVerId}" />
    <c:if test="${not empty _csrf}">
      <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
    </c:if>
    <button type="submit" class="btn btn-primary">재상신</button>
  </form>
</c:if>
			
            <a class="btn btn-outline-dark" href="/approval/view?docVerId=${docVerId}">출력/미리보기</a>
            <a class="btn btn-outline-secondary" href="/approval/list">목록</a>

          </div>

          <div class="text-muted small mt-3">
            * “상신 취소”는 1차 결재자가 승인/반려하기 전까지만 가능합니다.
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
