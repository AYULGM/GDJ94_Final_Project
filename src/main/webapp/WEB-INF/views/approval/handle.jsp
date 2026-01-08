<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>결재 처리</title>

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

  <style>
    /* 좌측 미리보기 박스만 스크롤 */
    .preview-box{
      height: 82vh;
      overflow: auto;          /* 스크롤은 여기서만 */
      background: #f8f9fa;
    }

    /* iframe은 스크롤 제거 + 큰 캔버스 + 축소 */
    .preview-iframe{
      width: 1250px;           /* 출력 문서 폭(필요시 조정) */
      height: 2000px;          /* 문서 전체가 들어갈 만큼 크게 */
      border: 0;

      overflow: hidden;
      display: block;

      transform: scale(0.7);   /* 축소 비율 */
      transform-origin: top left;
    }
  </style>
</head>

<body class="bg-light">

<jsp:include page="../includes/admin_header.jsp" />

<main class="container-fluid py-3 px-3">

  <!-- 상단 타이틀 -->
  <div class="d-flex align-items-center justify-content-between mb-3">
    <div>
      <h2 class="h5 mb-1">결재 처리</h2>
      <div class="text-muted small">
        문서번호: <strong>${doc.docNo}</strong>
      </div>
    </div>
    <div class="d-flex gap-2">
      <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/approval/inbox">목록</a>
      <a class="btn btn-outline-dark" href="${pageContext.request.contextPath}/approval/view?docVerId=${doc.docVerId}">
        출력/미리보기
      </a>
    </div>
  </div>

  <div class="row g-3">
    <!-- =======================
         좌측: 문서 미리보기
         ======================= -->
    <div class="col-12 col-lg-7">
      <div class="card shadow-sm">
        <div class="card-header bg-white d-flex justify-content-between align-items-center">
          <div class="fw-semibold">문서 미리보기</div>
          <div class="text-muted small">docVerId: ${doc.docVerId}</div>
        </div>
        <div class="card-body p-0">
          <div class="preview-box">
            <iframe
              src="${pageContext.request.contextPath}/approval/view?docVerId=${doc.docVerId}&preview=1"
              class="preview-iframe"
              scrolling="no"
              title="문서 미리보기"></iframe>
          </div>
        </div>
      </div>
    </div>

    <!-- =======================
         우측: 문서정보 / 결재라인 / 결재처리
         ======================= -->
    <div class="col-12 col-lg-5">

      <!-- 문서 정보 -->
      <div class="card shadow-sm mb-3">
        <div class="card-header bg-white fw-semibold">문서 정보</div>
        <div class="card-body">

          <div class="mb-2">
            <div class="text-muted small">문서번호</div>
            <div class="fw-semibold">${doc.docNo}</div>
          </div>

          <div class="mb-2">
            <div class="text-muted small">양식</div>
            <div>${doc.formCode}</div>
          </div>

          <div class="mb-2">
            <div class="text-muted small">상태</div>
            <div>
              <span class="badge text-bg-primary">${doc.statusCode}</span>
            </div>
          </div>

          <div class="mb-2">
            <div class="text-muted small">기안자</div>
            <div>
              <c:out value="${doc.drafterName}" />
              <c:if test="${not empty doc.drafterBranchName}">
                (<c:out value="${doc.drafterBranchName}" />)
              </c:if>
            </div>
          </div>

        </div>
      </div>

      <!-- 결재선 -->
      <div class="card shadow-sm mb-3">
        <div class="card-header bg-white fw-semibold">결재선</div>
        <div class="card-body p-0">
          <div class="table-responsive">
            <table class="table table-sm align-middle mb-0">
              <thead class="table-light">
                <tr>
                  <th class="text-nowrap" style="width:60px;">순번</th>
                  <th class="text-nowrap" style="width:120px;">구분</th>
                  <th class="text-nowrap">결재자</th>
                  <th class="text-nowrap" style="width:120px;">상태</th>
                  <th class="text-nowrap" style="width:160px;">결재일</th>
                </tr>
              </thead>
              <tbody>
              <c:forEach var="l" items="${doc.lines}">
                <tr>
                  <td class="text-nowrap">${l.lineNo}</td>
                  <td class="text-nowrap">${l.role}</td>
                  <td class="text-nowrap">${l.userName}</td>
                  <td class="text-nowrap">
                    <span class="badge text-bg-secondary">${l.decisionCode}</span>
                  </td>
                  <td class="text-nowrap">${l.decidedDate}</td>
                </tr>
              </c:forEach>

              <c:if test="${empty doc.lines}">
                <tr>
                  <td colspan="5" class="text-center py-4 text-muted">결재선 정보가 없습니다.</td>
                </tr>
              </c:if>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- 결재 처리 -->
      <div class="card shadow-sm">
        <div class="card-header bg-white fw-semibold">결재 처리</div>
        <div class="card-body">

          <form action="${pageContext.request.contextPath}/approval/handle" method="post">
            <input type="hidden" name="docVerId" value="${doc.docVerId}" />

            <div class="mb-3">
              <label class="form-label">코멘트</label>
              <textarea name="comment" class="form-control" rows="4"
                        placeholder="승인/반려 사유 또는 코멘트를 입력하세요."></textarea>
            </div>

            <div class="d-grid gap-2">
              <div class="d-flex gap-2">
                <button class="btn btn-primary flex-fill" type="submit" name="action" value="APPROVE">
                  승인
                </button>
                <button class="btn btn-danger flex-fill" type="submit" name="action" value="REJECT">
                  반려
                </button>
              </div>

              <a class="btn btn-outline-secondary"
                 href="${pageContext.request.contextPath}/approval/inbox">
                목록
              </a>
            </div>
          </form>

          <div class="text-muted small mt-3">
            * 승인/반려는 본인 차례일 때만 처리되도록 서버에서 검증하는 것을 권장합니다.
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
