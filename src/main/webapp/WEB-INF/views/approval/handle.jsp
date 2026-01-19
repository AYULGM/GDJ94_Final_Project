<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>

<jsp:include page="../includes/admin_header.jsp" />

<style>
  /* 좌측 미리보기 박스만 스크롤 */
  .preview-box{
    height: 82vh;
    overflow: auto;
    background: #f8f9fa;
  }

  /* iframe은 스크롤 제거 + 큰 캔버스 + 축소 */
  .preview-iframe{
    width: 1250px;
    height: 2000px;
    border: 0;
    overflow: hidden;
    display: block;
    transform: scale(0.7);
    transform-origin: top left;
  }
</style>

<!-- admin_header.jsp 안에서 이미 main/app-content 컨테이너를 열어두는 구조라면
     여기서 main/container를 또 만들지 말고 "내용만" 넣는 게 안전합니다.
     (만약 header가 main을 안 열면 아래 main 블록은 유지해도 됩니다.) -->

<div class="container-fluid py-3 px-3">

  <!-- 상단 타이틀 -->
  <div class="d-flex align-items-center justify-content-between mb-3">
    <div>
      <div class="text-muted small">
        문서번호: <strong>${doc.docNo}</strong>
      </div>
    </div>
    <div class="d-flex gap-2">
      <a class="btn btn-outline-secondary" href="<c:url value='/approval/inbox'/>">목록</a>
      <a class="btn btn-outline-dark" href="<c:url value='/approval/view?docVerId=${doc.docVerId}'/>">
        출력/미리보기
      </a>
    </div>
  </div>

  <div class="row g-3">
    <!-- 좌측: 문서 미리보기 -->
    <div class="col-12 col-lg-7">
      <div class="card shadow-sm">
        <div class="card-header bg-white d-flex justify-content-between align-items-center">
          <div class="fw-semibold">문서 미리보기</div>
        </div>
        <div class="card-body p-0">
          <div class="preview-box">
            <iframe
              src="<c:url value='/approval/view?docVerId=${doc.docVerId}&preview=1'/>"
              class="preview-iframe"
              scrolling="no"
              title="문서 미리보기"></iframe>
          </div>
        </div>
      </div>
    </div>

    <!-- 우측: 문서정보 / 결재라인 / 결재처리 -->
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
				<div>
				  <c:choose>
				    <c:when test="${doc.formCode == 'DF009'}">휴가요청서</c:when>
				    <c:when test="${doc.formCode == 'DF006'}">발주서</c:when>
				    <c:when test="${doc.formCode == 'DF005'}">구매요청서</c:when>
				    <c:when test="${doc.formCode == 'DF004'}">재고조정</c:when>
				    <c:when test="${doc.formCode == 'DF003'}">매출보고</c:when>
				    <c:when test="${doc.formCode == 'DF002'}">정산보고</c:when>
				    <c:when test="${doc.formCode == 'DF001'}">지출결의</c:when>
				    <c:otherwise>${doc.formCode}</c:otherwise>
				  </c:choose>
				</div>
            
          </div>

          <div class="mb-2">
            <div class="text-muted small">상태</div>
            <c:choose>
              <c:when test="${doc.statusCode == 'AS001'}"><span class="badge text-bg-secondary">임시저장</span></c:when>
              <c:when test="${doc.statusCode == 'AS002'}"><span class="badge text-bg-primary">결재중</span></c:when>
              <c:when test="${doc.statusCode == 'AS003'}"><span class="badge text-bg-success">결재완료</span></c:when>
              <c:when test="${doc.statusCode == 'AS004'}"><span class="badge text-bg-danger">반려</span></c:when>
              <c:otherwise><span class="badge text-bg-dark">대기</span></c:otherwise>
            </c:choose>
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
                  <th class="text-nowrap" style="width:100px;">순번</th>
                  <th class="text-nowrap">결재자</th>
                  <th class="text-nowrap" style="width:120px;">상태</th>
                  <th class="text-nowrap" style="width:160px;">결재일</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="l" items="${doc.lines}">
                  <tr>
                    <td class="text-nowrap">${l.lineNo}</td>
                    <td class="text-nowrap">${l.userName}</td>

                    <td class="text-nowrap">
                      <c:choose>
                        <c:when test="${l.decisionCode == 'ALS002'}"><span class="badge text-bg-primary">진행</span></c:when>
                        <c:when test="${l.decisionCode == 'ALS003'}"><span class="badge text-bg-success">승인</span></c:when>
                        <c:when test="${l.decisionCode == 'ALS004'}"><span class="badge text-bg-danger">반려</span></c:when>
                        <c:otherwise><span class="badge text-bg-secondary">대기</span></c:otherwise>
                      </c:choose>
                    </td>

                    <td class="text-nowrap">
                      <c:choose>
                        <c:when test="${empty l.decidedDate}">
                          <span class="text-muted">-</span>
                        </c:when>
                        <c:otherwise>
                          ${fn:replace(l.decidedDate, 'T', ' ')}
                        </c:otherwise>
                      </c:choose>
                    </td>
                  </tr>
                </c:forEach>

                <c:if test="${empty doc.lines}">
                  <tr>
                    <td colspan="4" class="text-center py-4 text-muted">결재선 정보가 없습니다.</td>
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

          <form action="<c:url value='/approval/handle'/>" method="post">
            <input type="hidden" name="docVerId" value="${doc.docVerId}" />

            <div class="mb-3">
              <label class="form-label">코멘트</label>
              <textarea name="comment" class="form-control" rows="4"
                        placeholder="승인/반려 사유 또는 코멘트를 입력하세요."></textarea>
            </div>

            <div class="d-grid gap-2">
              <div class="d-flex gap-2">
                <button class="btn btn-primary flex-fill" type="submit" name="action" value="APPROVE">승인</button>
                <button class="btn btn-danger flex-fill" type="submit" name="action" value="REJECT">반려</button>
              </div>

              <a class="btn btn-outline-secondary" href="<c:url value='/approval/inbox'/>">목록</a>
            </div>
          </form>

          <div class="text-muted small mt-3">
            * 승인/반려는 본인 차례일 때만 처리되도록 서버에서 검증하는 것을 권장합니다.
          </div>
        </div>
      </div>

    </div>
  </div>

</div>

<jsp:include page="../includes/admin_footer.jsp" />
