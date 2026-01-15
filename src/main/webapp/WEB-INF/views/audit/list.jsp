<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../includes/admin_header.jsp" />

<div class="row">
    <div class="col-12">

        <div class="card">
            <div class="card-header">
                <h3 class="card-title">감사 로그</h3>
            </div>

            <div class="card-body">

                <!-- 검색/필터 -->
                <form method="get" action="<c:url value='/audit'/>" class="row g-3 align-items-end mb-3">

                    <div class="col-12 col-md-2">
                        <label class="form-label">기간(From)</label>
                        <input type="date" name="from" class="form-control" value="${from}" />
                    </div>

                    <div class="col-12 col-md-2">
                        <label class="form-label">기간(To)</label>
                        <input type="date" name="to" class="form-control" value="${to}" />
                    </div>

                    <div class="col-12 col-md-2">
                        <label class="form-label">액션</label>
                        <select name="actionType" class="form-select">
                            <option value="">전체</option>
                            <option value="THRESHOLD_UPDATE" <c:if test="${actionType == 'THRESHOLD_UPDATE'}">selected</c:if>>
                                기준수량 변경
                            </option>
                            <option value="INVENTORY_ADJUST" <c:if test="${actionType == 'INVENTORY_ADJUST'}">selected</c:if>>
                                재고 조정
                            </option>
                        </select>
                    </div>

                    <div class="col-12 col-md-2">
                        <label class="form-label">지점</label>
                        <select name="branchId" class="form-select" onchange="this.form.submit()">
                            <option value="">전체</option>
                            <c:forEach var="b" items="${branches}">
                                <option value="${b.id}" <c:if test="${branchId == b.id}">selected</c:if>>
                                        ${b.name}
                                </option>
                            </c:forEach>
                        </select>
                        <div class="form-text">지점 선택 시 상품 목록이 필터링됩니다.</div>
                    </div>

                    <div class="col-12 col-md-2">
                        <label class="form-label">상품</label>
                        <select name="productId" class="form-select">
                            <option value="">전체</option>
                            <c:forEach var="p" items="${products}">
                                <option value="${p.id}" <c:if test="${productId == p.id}">selected</c:if>>
                                        ${p.name}
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="col-12 col-md-2">
                        <label class="form-label">키워드</label>
                        <input type="text" name="keyword" class="form-control" value="${keyword}" placeholder="사유/값/지점/상품" />
                    </div>

                    <div class="col-12 d-flex justify-content-end gap-2">
                        <button type="submit" class="btn btn-primary">조회</button>
                        <a class="btn btn-outline-secondary" href="<c:url value='/audit'/>">초기화</a>
                    </div>
                </form>

                <!-- 결과 테이블 -->
                <div class="table-responsive">
                    <table class="table table-bordered table-hover align-middle mb-0">
                        <thead class="table-light">
                        <tr>
                            <%-- 컬럼 폭/정렬 조정으로 가독성 개선 --%>
                            <th style="width: 160px;">시간</th>
                            <th style="width: 140px;">액션</th>
                            <th style="width: 170px;">지점</th>
                            <th style="width: 200px;">상품</th>
                            <th style="width: 100px;" class="text-end">변경 전</th>
                            <th style="width: 100px;" class="text-end">변경 후</th>
                            <th>사유</th>
                            <th style="width: 90px;" class="text-end">사용자</th>
                        </tr>
                        </thead>

                        <tbody>
                        <c:if test="${empty logs}">
                            <tr>
                                <td colspan="8" class="text-center text-muted py-4">조회 결과가 없습니다.</td>
                            </tr>
                        </c:if>

                        <c:forEach var="l" items="${logs}">
                            <tr>
                                <td>${l.createdAt}</td>

                                <td>
                                    <c:choose>
                                        <c:when test="${l.actionType == 'THRESHOLD_UPDATE'}">
                                            <span class="badge bg-warning text-dark">기준수량 변경</span>
                                        </c:when>
                                        <c:when test="${l.actionType == 'INVENTORY_ADJUST'}">
                                            <span class="badge bg-info text-dark">재고 조정</span>
                                        </c:when>
                                        <c:otherwise>
                                            <%-- 모르는 액션(예: TEST)은 회색 뱃지로 통일 --%>
                                            <span class="badge bg-secondary">${l.actionType}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <td>
                                        <%-- 로그에 지점명이 없을 때 깔끔하게 '-' 처리 --%>
                                    <c:choose>
                                        <c:when test="${not empty l.branchName}">
                                            <div class="fw-semibold">${l.branchName}</div>
                                            <div class="text-muted" style="font-size: 12px;">ID: ${l.branchId}</div>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-muted">-</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <td>
                                        <%-- 로그에 상품명이 없을 때 깔끔하게 '-' 처리 --%>
                                    <c:choose>
                                        <c:when test="${not empty l.productName}">
                                            <div class="fw-semibold">${l.productName}</div>
                                            <div class="text-muted" style="font-size: 12px;">ID: ${l.productId}</div>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-muted">-</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <td class="text-end">${l.beforeValue}</td>
                                <td class="text-end">${l.afterValue}</td>

                                <td>
                                    <div>${l.reason}</div>
                                        <%-- target 정보는 작은 글씨로 분리해 깔끔하게 유지 --%>
                                    <div class="text-muted" style="font-size: 12px;">
                                        대상: ${l.targetType} / ${l.targetId}
                                    </div>
                                </td>

                                <td class="text-end">${l.actorUserId}</td>
                            </tr>
                        </c:forEach>
                        </tbody>

                    </table>
                </div>

                <div class="text-muted mt-2" style="font-size: 12px;">
                    ※ 감사로그는 최근 300건까지 표시됩니다.
                </div>

            </div>
        </div>

    </div>
</div>

<jsp:include page="../includes/admin_footer.jsp" />
