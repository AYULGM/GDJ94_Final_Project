<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>

<jsp:include page="../includes/admin_header.jsp" />

<style>
  .page-wrap { background:#f7f8fb; }
	.notice-content {
	  white-space: pre-wrap;
	  line-height: 1.8;
	  text-align: left !important; /* ✅ 강제 */
	  margin: 0;
	}

  /* Card tone */
  .soft-card { border:1px solid rgba(0,0,0,.06); border-radius:14px; }
  .meta { color:#6c757d; font-size:.875rem; }
  .pill { border-radius:999px; }

  /* Typography */
  .kv-title { color:#6c757d; font-size:.85rem; }
  .kv-value { font-weight:700; }
  .notice-content { white-space:pre-wrap; line-height:1.8; }

  /* Icons */
  .mini-icon{
    width:40px; height:40px; border-radius:12px;
    display:flex; align-items:center; justify-content:center;
    background:#eef3ff; color:#2f6bff;
    flex: 0 0 40px;
  }

  /* Layout tuning */
  .top-actions .btn { padding:.35rem .65rem; }
  .title-row { gap:.5rem; }
  .meta-row span { display:inline-block; margin-right:.75rem; }
  .meta-row span:last-child { margin-right:0; }

  /* Slim section cards (기간/대상지점/내용) */
  .section-card { border:1px solid rgba(0,0,0,.06); border-radius:14px; background:#fff; }
  .section-head{
    display:flex; align-items:center; justify-content:space-between;
    padding:.65rem 1rem;
    border-bottom:1px solid rgba(0,0,0,.06);
  }
  .section-title{ font-weight:800; letter-spacing:-0.01em; }
  .section-body{ padding:.75rem 1rem; }

  /* Reduce spacing */
  .mb-tight { margin-bottom:.75rem !important; }
  .mt-tight { margin-top:.75rem !important; }

  /* Summary cards */
  .summary-card .card-body{ padding:.85rem 1rem; }  /* 기존보다 얇게 */
  .summary-card .kv-value{ font-size:1.05rem; }
  .notice-content p {
  margin: 0 0 8px 0;
}

.notice-content ul {
  margin: 0 0 8px 16px;
  padding: 0;
}

.notice-content li {
  margin: 0 0 4px 0;
}
  
</style>

<div class="page-wrap p-3">
  <div class="container-fluid">

    <!-- 상단 액션 -->
    <div class="d-flex justify-content-end gap-2 mb-3 top-actions">
      <a class="btn btn-outline-secondary btn-sm" href="<c:url value='/notices'/>">목록</a>
      <c:if test="${isAdmin}">
        <a class="btn btn-outline-primary btn-sm" href="<c:url value='/notices/admin'/>">관리자 목록</a>
        <a class="btn btn-primary btn-sm" href="<c:url value='/notices/${notice.noticeId}/edit'/>">수정</a>
      </c:if>
    </div>

    <!-- 메인 카드 -->
    <div class="card soft-card shadow-sm">
      <div class="card-body p-4">

        <!-- 상태/고정 -->
        <div class="d-flex align-items-center justify-content-between flex-wrap mb-2">
          <div class="d-flex align-items-center gap-2">
            <c:if test="${notice.isPinned}">
              <span class="badge text-bg-warning pill">고정</span>
            </c:if>
            <span class="badge text-bg-light border pill">
              상태: <c:out value="${statusMap[notice.status]}"/>
            </span>
          </div>
        </div>

        <!-- 메타 -->
        <div class="meta meta-row">
          <span>ID: <c:out value="${notice.noticeId}"/></span>
          <span>조회수: <c:out value="${notice.viewCount}"/></span>

          <span>
            작성일:
            <c:choose>
              <c:when test="${not empty notice.createDate}">
                <c:out value="${fn:replace(notice.createDate, 'T', ' ')}"/>
              </c:when>
              <c:otherwise>-</c:otherwise>
            </c:choose>
          </span>

          <span>
            작성자:
            <c:choose>
              <c:when test="${not empty notice.writerName}">
                <c:out value="${notice.writerName}"/>
              </c:when>
              <c:otherwise>-</c:otherwise>
            </c:choose>
          </span>
        </div>

        <!-- 상단 보조 배지 -->
        <div class="d-flex flex-wrap gap-2 mt-2 mb-3">
          <span class="badge text-primary bg-primary-subtle border border-primary-subtle pill">
            <c:out value="${noticeTypeMap[notice.noticeType]}"/>
          </span>
          <span class="badge text-success bg-success-subtle border border-success-subtle pill">
            <c:out value="${targetTypeMap[notice.targetType]}"/>
          </span>
          <span class="badge text-dark bg-dark-subtle border border-dark-subtle pill">
            <c:out value="${categoryMap[notice.categoryCode]}"/>
          </span>
        </div>

        <!-- 게시기간 (슬림) -->
        <div class="section-card mb-3">
          <div class="section-head">
            <div class="section-title">게시기간</div>
            <span class="badge text-bg-light border pill" style="padding:.25rem .55rem; font-size:.75rem;">
              <i class="bi bi-calendar-event me-1"></i> 기간
            </span>
          </div>

          <div class="section-body">
            <div class="meta" style="margin:0;">
              <c:choose>
                <c:when test="${empty notice.publishStartDate && empty notice.publishEndDate}">
                  시작 : <span class="kv-value text-dark">즉시</span>
                  &nbsp;&nbsp; 종료 : <span class="kv-value text-dark">무기한</span>
                </c:when>
                <c:otherwise>
                  시작 :
                  <span class="kv-value text-dark">
                    <c:choose>
                      <c:when test="${not empty notice.publishStartDateOnly}">
                        <c:out value="${notice.publishStartDateOnly}"/> <c:out value="${notice.publishStartTimeOnly}"/>
                      </c:when>
                      <c:when test="${not empty notice.publishStartDate}">
                        <c:out value="${fn:replace(notice.publishStartDate, 'T', ' ')}"/>
                      </c:when>
                      <c:otherwise>즉시</c:otherwise>
                    </c:choose>
                  </span>
                  &nbsp;&nbsp;
                  종료 :
                  <span class="kv-value text-dark">
                    <c:choose>
                      <c:when test="${not empty notice.publishEndDateOnly}">
                        <c:out value="${notice.publishEndDateOnly}"/> <c:out value="${notice.publishEndTimeOnly}"/>
                      </c:when>
                      <c:when test="${not empty notice.publishEndDate}">
                        <c:out value="${fn:replace(notice.publishEndDate, 'T', ' ')}"/>
                      </c:when>
                      <c:otherwise>무기한</c:otherwise>
                    </c:choose>
                  </span>
                </c:otherwise>
              </c:choose>
            </div>
          </div>
        </div>

        <!-- 대상 지점 (특정지점 공지일 때만, 슬림) -->
        <c:if test="${notice.targetType eq 'TT002'}">
          <div class="section-card mb-3">
            <div class="section-head">
              <div class="section-title">대상 지점</div>
              <span class="badge text-bg-light border pill" style="padding:.25rem .55rem; font-size:.75rem;">
                <i class="bi bi-geo-alt me-1"></i> 지점
              </span>
            </div>

            <div class="section-body">
              <c:choose>
                <c:when test="${empty targets}">
                  <div class="text-muted">선택된 지점이 없습니다.</div>
                </c:when>
                <c:otherwise>
                  <div class="d-flex flex-wrap gap-2">
                    <c:forEach items="${targets}" var="b">
                      <span class="badge text-bg-light border pill">
                        <i class="bi bi-building me-1"></i>
                        <c:out value="${b.branchName}"/>
                      </span>
                    </c:forEach>
                  </div>
                </c:otherwise>
              </c:choose>
            </div>
          </div>
        </c:if>
        <!-- 내용 (슬림 헤더 + 본문 영역만 넉넉히) -->
        <div class="section-card">
          <div class="section-head">
            <div class="section-title"><c:out value="${notice.title}" /></div>
            <span class="badge text-bg-light border pill" style="padding:.25rem .55rem; font-size:.75rem;">
              <i class="bi bi-card-text me-1"></i> 본문
            </span>
          </div>

          <div class="section-body">
            <div class="notice-content">
              <c:out value="${notice.content}" escapeXml="false"/>
            </div>
          </div>
        </div>
		<!-- 첨부파일 -->
		        <c:if test="${not empty attachments}">
		          <div class="section-card mb-3">
		            <div class="section-head">
		              <div class="section-title">첨부파일</div>
		              <span class="badge text-bg-light border pill" style="padding:.25rem .55rem; font-size:.75rem;">
		                <i class="bi bi-paperclip me-1"></i> 파일
		              </span>
		            </div>
		            <div class="section-body">
		              <ul class="mb-0">
		                <c:forEach items="${attachments}" var="f">
		                  <li class="mb-1">
		                    <a href="<c:url value='/files/download/${f.fileId}'/>">
		                      <c:out value="${f.originalName}"/>
		                    </a>
		                    <c:if test="${not empty f.contentType && fn:startsWith(f.contentType, 'image/')}">
		                      <span class="meta">&nbsp;|&nbsp;</span>
		                      <a class="meta" target="_blank" href="<c:url value='/files/preview/${f.fileId}'/>">미리보기</a>
		                    </c:if>
		                  </li>
		                </c:forEach>
		              </ul>
		            </div>
		          </div>
		        </c:if>
      </div>
    </div>

  </div>
</div>

<jsp:include page="../includes/admin_footer.jsp" />
