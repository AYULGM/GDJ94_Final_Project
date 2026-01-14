<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<jsp:include page="../includes/admin_header.jsp" />

<div class="row">
  <div class="col-12">
    <div class="card">

      <div class="card-header d-flex align-items-center justify-content-between">
        <h3 class="card-title mb-0 col-10">공지사항 목록</h3>

        <div class="d-flex gap-2 ">
          <c:if test="${isAdmin}">
            <a class="btn btn-outline-primary btn-sm" href="<c:url value='/notices/admin'/>">관리자 목록</a>
            <a class="btn btn-primary btn-sm" href="<c:url value='/notices/new'/>">공지 등록</a>
          </c:if>
        </div>
      </div>

      <div class="card-body">
        <c:choose>
          <c:when test="${empty list}">
            <div class="alert alert-secondary mb-0">등록된 공지사항이 없습니다.</div>
          </c:when>

          <c:otherwise>
            <table class="table table-bordered table-hover align-middle">
              <thead>
                <tr>
                  <th style="width:80px;">ID</th>
                  <th>제목</th>
                  <th style="width:120px;">유형</th>
                  <th style="width:120px;">대상</th>
                  <th style="width:120px;">상태</th>
                  <th style="width:90px;">조회수</th>
                  <th style="width:170px;">작성일</th>
                  <th style="width:220px;">게시기간</th>
                </tr>
              </thead>

              <tbody>
                <c:forEach items="${list}" var="n">
                  <tr>
                    <td><c:out value="${n.noticeId}" /></td>

                    <td>
                      <c:if test="${n.isPinned}">
                        <span class="badge bg-warning text-dark me-1">고정</span>
                      </c:if>
                      <a href="<c:url value='/notices/${n.noticeId}'/>" class="text-decoration-none">
                        <c:out value="${n.title}" />
                      </a>
                    </td>

                    <td><c:out value="${noticeTypeMap[n.noticeType]}" /></td>
                    <td><c:out value="${targetTypeMap[n.targetType]}" /></td>
                    <td><c:out value="${statusMap[n.status]}" /></td>

                    <td class="text-end"><c:out value="${n.viewCount}" /></td>

                    <td>
                      <c:choose>
                        <c:when test="${not empty n.createDate}">
                          <c:out value="${n.createDate}" />
                        </c:when>
                        <c:otherwise>-</c:otherwise>
                      </c:choose>
                    </td>

                    <td>
                      <c:choose>
                        <c:when test="${empty n.publishStartDate && empty n.publishEndDate}">
                          <div>시작: 즉시</div>
                          <div>종료: 무기한</div>
                        </c:when>
                        <c:otherwise>
                          <div>
                            시작:
                            <c:choose>
                              <c:when test="${not empty n.publishStartDate}">
                                <c:out value="${n.publishStartDateOnly} ${n.publishStartTimeOnly}" />
                              </c:when>
                              <c:otherwise>즉시</c:otherwise>
                            </c:choose>
                          </div>
                          <div>
                            종료:
                            <c:choose>
                              <c:when test="${not empty n.publishEndDate}">
                                <c:out value="${n.publishEndDate}" />
                              </c:when>
                              <c:otherwise>무기한</c:otherwise>
                            </c:choose>
                          </div>
                        </c:otherwise>
                      </c:choose>
                    </td>

                  </tr>
                </c:forEach>
              </tbody>
            </table>
          </c:otherwise>
        </c:choose>
      </div>

    </div>
  </div>
</div>

<jsp:include page="../includes/admin_footer.jsp" />
