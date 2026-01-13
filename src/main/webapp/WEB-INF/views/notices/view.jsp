<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<jsp:include page="../includes/admin_header.jsp" />

<div class="row">
  <div class="col-12">
    <div class="card">

      <div class="card-header d-flex align-items-center justify-content-between">
        <h3 class="card-title mb-0">공지 상세</h3>
        <div class="d-flex gap-2">
          <a class="btn btn-outline-secondary btn-sm" href="<c:url value='/notices'/>">목록</a>
        </div>
      </div>

      <div class="card-body">

        <h4 class="mb-3">
          <c:if test="${notice.isPinned}">
            <span class="badge bg-warning text-dark me-2">고정</span>
          </c:if>
          <c:out value="${notice.title}" />
        </h4>

        <div class="row g-3 mb-4">
          <div class="col-md-3">
            <div class="border rounded p-3 h-100">
              <div class="text-muted small mb-1">유형</div>
              <div class="fw-semibold">
                <c:out value="${noticeTypeMap[notice.noticeType]}" />
              </div>
            </div>
          </div>

          <div class="col-md-3">
            <div class="border rounded p-3 h-100">
              <div class="text-muted small mb-1">대상</div>
              <div class="fw-semibold">
                <c:out value="${targetTypeMap[notice.targetType]}" />
              </div>
            </div>
          </div>

          <div class="col-md-3">
            <div class="border rounded p-3 h-100">
              <div class="text-muted small mb-1">상태</div>
              <div class="fw-semibold">
                <c:out value="${statusMap[notice.status]}" />
              </div>
            </div>
          </div>

          <div class="col-md-3">
            <div class="border rounded p-3 h-100">
              <div class="text-muted small mb-1">카테고리</div>
              <div class="fw-semibold">
                <c:out value="${categoryMap[notice.categoryCode]}" />
              </div>
            </div>
          </div>
        </div>

        <!-- 게시기간: 두 줄 -->
        <div class="border rounded p-3 mb-4">
          <div class="text-muted small mb-2">게시기간</div>
          <c:choose>
            <c:when test="${empty notice.publishStartDate && empty notice.publishEndDate}">
              <div>시작: 즉시</div>
              <div>종료: 무기한</div>
            </c:when>
            <c:otherwise>
              <div>
                시작:
                <c:choose>
                  <c:when test="${not empty notice.publishStartDate}">
                    <c:out value="${notice.publishStartDate}" />
                  </c:when>
                  <c:otherwise>즉시</c:otherwise>
                </c:choose>
              </div>
              <div>
                종료:
                <c:choose>
                  <c:when test="${not empty notice.publishEndDate}">
                    <c:out value="${notice.publishEndDate}" />
                  </c:when>
                  <c:otherwise>무기한</c:otherwise>
                </c:choose>
              </div>
            </c:otherwise>
          </c:choose>
        </div>

        <!-- 지점 대상이면 대상지점 표시 -->
        <c:if test="${notice.targetType eq 'TT002'}">
          <div class="border rounded p-3 mb-4">
            <div class="text-muted small mb-2">대상 지점</div>
            <c:choose>
              <c:when test="${empty targets}">
                <div class="text-muted">선택된 지점이 없습니다.</div>
              </c:when>
              <c:otherwise>
                <div class="d-flex flex-wrap gap-2">
                  <c:forEach items="${targets}" var="b">
                    <span class="badge bg-light text-dark border">
                      <c:out value="${b.branchName}" />
                    </span>
                  </c:forEach>
                </div>
              </c:otherwise>
            </c:choose>
          </div>
        </c:if>

        <!-- 본문 -->
        <div class="border rounded p-3">
          <div class="text-muted small mb-2">내용</div>
          <div style="white-space: pre-wrap;">
            <c:out value="${notice.content}" />
          </div>
        </div>

      </div>
    </div>
  </div>
</div>

<jsp:include page="../includes/admin_footer.jsp" />
