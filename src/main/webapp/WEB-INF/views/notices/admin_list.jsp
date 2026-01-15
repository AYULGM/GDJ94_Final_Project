<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>

<jsp:include page="../includes/admin_header.jsp" />

<style>
  /* 제목 칸이 길면 행 높이 커지는 것 방지 */
  .td-title a { display:inline-block; max-width:520px; }
  @media (max-width: 1200px) { .td-title a { max-width:360px; } }
  @media (max-width: 992px)  { .td-title a { max-width:260px; } }

  /* 게시기간 2줄을 더 얇게 */
  .period-line { font-size:.90rem; line-height:1.25; margin:0; }
</style>

<div class="row">
  <div class="col-12">
    <div class="card">

      <div class="card-header d-flex align-items-center justify-content-between">
        <h3 class="card-title mb-0 col-10">공지사항 관리자 목록</h3>

        <div class="d-flex gap-2">
          <a class="btn btn-outline-secondary btn-sm" href="<c:url value='/notices'/>">사용자 목록</a>
          <a class="btn btn-primary btn-sm" href="<c:url value='/notices/new'/>">공지 등록</a>
        </div>
      </div>

      <div class="card-body">
        <c:choose>
          <c:when test="${empty list}">
            <div class="alert alert-secondary mb-0">등록된 공지사항이 없습니다.</div>
          </c:when>

          <c:otherwise>
            <div class="table-responsive">
              <table class="table table-sm table-bordered table-hover align-middle mb-0">
                <thead class="table-light">
                  <tr>
                    <th style="width:50px;" class="text-center">ID</th>
                    <th class="text-center">제목</th>
                    <th style="width:110px;" class="text-center">유형</th>
                    <th style="width:130px;" class="text-center">작성자</th>
                    <th style="width:120px;" class="text-center">대상</th>
                    <th style="width:90px;" class="text-center">상태</th>
                    <th style="width:100px;" class="text-center">카테고리</th>
                    <th style="width:80px;" class="text-center">조회수</th>
                    <th style="width:140px;" class="text-center">작성일</th>
                    <th style="width:200px;" class="text-center">게시기간</th>
                    <th style="width:120px;" class="text-center">관리</th>
                  </tr>
                </thead>

                <tbody>
                  <c:forEach items="${list}" var="n">
                    <tr>
                      <td class="text-center"><c:out value="${n.noticeId}" /></td>

                      <td class="td-title">
                        <div class="d-flex align-items-center gap-2">
                          <c:if test="${n.isPinned}">
                            <!-- Bootstrap 기본 배지 -->
                            <span class="badge text-bg-warning">고정</span>
                          </c:if>

                          <a href="<c:url value='/notices/${n.noticeId}'/>"
                             class="text-truncate text-decoration-none"
                             style="color:#2563eb;">
                            <c:out value="${n.title}" />
                          </a>
                        </div>
                      </td>

                      <!-- 유형 (NT001~NT003) -->
                      <td class="text-center">
                        <c:set var="ntClass" value="text-bg-secondary"/>
                        <c:choose>
                          <c:when test="${n.noticeType == 'NT001'}">
                            <c:set var="ntClass" value="text-bg-danger"/>
                          </c:when>
                          <c:when test="${n.noticeType == 'NT002'}">
                            <c:set var="ntClass" value="text-bg-primary"/>
                          </c:when>
                          <c:when test="${n.noticeType == 'NT003'}">
                            <c:set var="ntClass" value="text-bg-success"/>
                          </c:when>
                        </c:choose>

                        <span class="badge ${ntClass}">
                          <c:out value="${noticeTypeMap[n.noticeType]}" />
                        </span>
                      </td>

                      <td class="text-center"><c:out value="${n.writerName}" /></td>

                      <!-- 대상 (TT001~TT002) -->
                      <td class="text-center">
                        <c:set var="ttClass" value="text-bg-secondary"/>
                        <c:choose>
                          <c:when test="${n.targetType == 'TT001'}">
                            <c:set var="ttClass" value="text-bg-dark"/>
                          </c:when>
                          <c:when test="${n.targetType == 'TT002'}">
                            <c:set var="ttClass" value="text-bg-info"/>
                          </c:when>
                        </c:choose>

                        <span class="badge ${ttClass}">
                          <c:out value="${targetTypeMap[n.targetType]}" />
                        </span>
                      </td>

                      <!-- 상태 (NS001~NS003) -->
                      <td class="text-center">
                        <c:set var="nsClass" value="text-bg-secondary"/>
                        <c:choose>
                          <c:when test="${n.status == 'NS001'}">
                            <c:set var="nsClass" value="text-bg-success"/>
                          </c:when>
                          <c:when test="${n.status == 'NS002'}">
                            <c:set var="nsClass" value="text-bg-warning"/>
                          </c:when>
                          <c:when test="${n.status == 'NS003'}">
                            <c:set var="nsClass" value="text-bg-danger"/>
                          </c:when>
                        </c:choose>

                        <span class="badge ${nsClass}">
                          <c:out value="${statusMap[n.status]}" />
                        </span>
                      </td>

                      <!-- 카테고리 (CAT001~CAT003) -->
                      <td class="text-center">
                        <c:set var="catClass" value="text-bg-secondary"/>
                        <c:choose>
                          <c:when test="${n.categoryCode == 'CAT001'}">
                            <c:set var="catClass" value="text-bg-secondary"/>
                          </c:when>
                          <c:when test="${n.categoryCode == 'CAT002'}">
                            <c:set var="catClass" value="text-bg-primary"/>
                          </c:when>
                          <c:when test="${n.categoryCode == 'CAT003'}">
                            <c:set var="catClass" value="text-bg-success"/>
                          </c:when>
                        </c:choose>

                        <span class="badge ${catClass}">
                          <c:out value="${categoryMap[n.categoryCode]}" />
                        </span>
                      </td>

                      <td class="text-center"><c:out value="${n.viewCount}" /></td>

                      <td class="text-center">
                        <c:choose>
                          <c:when test="${not empty n.createDate}">
                            <c:out value="${fn:replace(n.createDate, 'T', ' ')}" />
                          </c:when>
                          <c:otherwise>-</c:otherwise>
                        </c:choose>
                      </td>

                      <!-- 게시기간 -->
                      <td>
                        <c:choose>
                          <c:when test="${empty n.publishStartDate && empty n.publishEndDate}">
                            <p class="period-line text-muted">즉시 ~ 무기한</p>
                          </c:when>

                          <c:otherwise>
                            <p class="period-line text-muted">
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
                            </p>

                            <p class="period-line text-muted mb-0">
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
                            </p>
                          </c:otherwise>
                        </c:choose>
                      </td>

                      <td class="text-center align-middle">
                        <div class="d-flex gap-2 justify-content-center">
                          <a class="btn btn-outline-secondary btn-sm"
                             href="<c:url value='/notices/${n.noticeId}/edit'/>">수정</a>

                          <form method="post"
                                action="<c:url value='/notices/${n.noticeId}/delete'/>"
                                onsubmit="return confirm('삭제하시겠습니까?');">
                            <button type="submit" class="btn btn-outline-danger btn-sm">삭제</button>
                          </form>
                        </div>
                      </td>

                    </tr>
                  </c:forEach>
                </tbody>
              </table>
            </div>
          </c:otherwise>
        </c:choose>
      </div>

    </div>
  </div>
</div>

<c:if test="${totalPages > 1}">
  <nav class="mt-3">
    <ul class="pagination justify-content-center mb-0">

      <li class="page-item ${page <= 1 ? 'disabled' : ''}">
        <a class="page-link"
           href="<c:url value='/notices/admin'>
                    <c:param name='branchId' value='${branchId}'/>
                    <c:param name='status' value='${status}'/>
                    <c:param name='targetType' value='${targetType}'/>
                    <c:param name='page' value='${page-1}'/>
                    <c:param name='size' value='${size}'/>
                 </c:url>">이전</a>
      </li>

      <c:forEach begin="1" end="${totalPages}" var="p">
        <li class="page-item ${p == page ? 'active' : ''}">
          <a class="page-link"
             href="<c:url value='/notices/admin'>
                      <c:param name='branchId' value='${branchId}'/>
                      <c:param name='status' value='${status}'/>
                      <c:param name='targetType' value='${targetType}'/>
                      <c:param name='page' value='${p}'/>
                      <c:param name='size' value='${size}'/>
                   </c:url>">${p}</a>
        </li>
      </c:forEach>

      <li class="page-item ${page >= totalPages ? 'disabled' : ''}">
        <a class="page-link"
           href="<c:url value='/notices/admin'>
                    <c:param name='branchId' value='${branchId}'/>
                    <c:param name='status' value='${status}'/>
                    <c:param name='targetType' value='${targetType}'/>
                    <c:param name='page' value='${page+1}'/>
                    <c:param name='size' value='${size}'/>
                 </c:url>">다음</a>
      </li>

    </ul>
  </nav>
</c:if>

<jsp:include page="../includes/admin_footer.jsp" />
