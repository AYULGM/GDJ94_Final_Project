<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>

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
                  <th style="width:50px;" class="text-center">ID</th>
                  <th>제목</th>
                  <th style="width:110px;">유형</th>
                  <th style="width:120px;">작성자</th>
                  <th style="width:90px;" class="text-center">조회수</th>
                  <th style="width:170px;">작성일</th>
                  <th style="width:220px;">게시기간</th>
                </tr>
              </thead>

              <tbody>
                <c:forEach items="${list}" var="n">
                  <tr>
                    <td class="text-center"><c:out value="${n.noticeId}" /></td>

                    <td>
                      <c:if test="${n.isPinned}">
                        <span class="badge bg-warning text-dark me-1">고정</span>
                      </c:if>
                      <a href="<c:url value='/notices/${n.noticeId}'/>" class="text-decoration-none">
                        <c:out value="${n.title}" />
                      </a>
                    </td>
					<td><c:out value="${noticeTypeMap[n.noticeType]}" /></td>
                    <td><c:out value="${n.writerName}" /></td>

                    <td class="text-center"><c:out value="${n.viewCount}" /></td>

                    <td>
					  <c:choose>
					    <c:when test="${not empty n.createDate}">
					      <c:out value="${fn:replace(n.createDate, 'T', ' ')}" />
					    </c:when>
					    <c:otherwise>-</c:otherwise>
					  </c:choose>
					</td>


                    <td>
					  <c:choose>
					    <c:when test="${empty n.publishStartDate && empty n.publishEndDate}">
					      <div class="small text-muted">시작: <span class="text-dark">즉시</span></div>
					      <div class="small text-muted">종료: <span class="text-dark">무기한</span></div>
					    </c:when>
					
					    <c:otherwise>
					      <div class="small text-muted">
					        시작:
					        <span class="text-dark">
					          <c:choose>
					            <c:when test="${not empty n.publishStartDateOnly}">
					              <c:out value="${n.publishStartDateOnly}" />
					              <c:if test="${not empty n.publishStartTimeOnly}">
					                <c:out value=" ${n.publishStartTimeOnly}" />
					              </c:if>
					            </c:when>
					
					            <c:when test="${not empty n.publishStartDate}">
					              <c:out value="${fn:replace(n.publishStartDate, 'T', ' ')}" />
					            </c:when>
					
					            <c:otherwise>즉시</c:otherwise>
					          </c:choose>
					        </span>
					      </div>
					
					      <div class="small text-muted">
					        종료:
					        <span class="text-dark">
					          <c:choose>
					            <c:when test="${not empty n.publishEndDateOnly}">
					              <c:out value="${n.publishEndDateOnly}" />
					              <c:if test="${not empty n.publishEndTimeOnly}">
					                <c:out value=" ${n.publishEndTimeOnly}" />
					              </c:if>
					            </c:when>
					
					            <c:when test="${not empty n.publishEndDate}">
					              <c:out value="${fn:replace(n.publishEndDate, 'T', ' ')}" />
					            </c:when>
					
					            <c:otherwise>무기한</c:otherwise>
					          </c:choose>
					        </span>
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
<c:if test="${totalPages > 1}">
  <nav aria-label="공지사항 페이지네이션" class="mt-3">
    <ul class="pagination justify-content-center">

      <!-- Prev -->
      <li class="page-item ${page <= 1 ? 'disabled' : ''}">
        <a class="page-link"
           href="<c:url value='/notices'>
                    <c:param name='branchId' value='${branchId}'/>
                    <c:param name='page' value='${page-1}'/>
                    <c:param name='size' value='${size}'/>
                 </c:url>">이전</a>
      </li>

      <!-- Pages -->
      <c:forEach begin="1" end="${totalPages}" var="p">
        <li class="page-item ${p == page ? 'active' : ''}">
          <a class="page-link"
             href="<c:url value='/notices'>
                      <c:param name='branchId' value='${branchId}'/>
                      <c:param name='page' value='${p}'/>
                      <c:param name='size' value='${size}'/>
                   </c:url>">${p}</a>
        </li>
      </c:forEach>

      <!-- Next -->
      <li class="page-item ${page >= totalPages ? 'disabled' : ''}">
        <a class="page-link"
           href="<c:url value='/notices'>
                    <c:param name='branchId' value='${branchId}'/>
                    <c:param name='page' value='${page+1}'/>
                    <c:param name='size' value='${size}'/>
                 </c:url>">다음</a>
      </li>

    </ul>
  </nav>
</c:if>

<jsp:include page="../includes/admin_footer.jsp" />
