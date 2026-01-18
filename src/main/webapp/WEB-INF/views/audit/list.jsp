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
                <form method="get" action="<c:url value='/audit'/>"
                      class="row g-3 align-items-end mb-3">

                    <div class="col-md-2">
                        <label class="form-label">기간(From)</label>
                        <input type="date" name="from" class="form-control" value="${from}">
                    </div>

                    <div class="col-md-2">
                        <label class="form-label">기간(To)</label>
                        <input type="date" name="to" class="form-control" value="${to}">
                    </div>

                    <div class="col-md-2">
                        <label class="form-label">상태</label>
                        <select name="actionType" class="form-select">
                            <option value="">전체</option>
                            <option value="THRESHOLD_UPDATE"
                                    <c:if test="${actionType == 'THRESHOLD_UPDATE'}">selected</c:if>>
                                기준수량 변경
                            </option>
                            <option value="INVENTORY_ADJUST"
                                    <c:if test="${actionType == 'INVENTORY_ADJUST'}">selected</c:if>>
                                재고 조정
                            </option>
                        </select>
                    </div>

                    <div class="col-md-2">
                        <label class="form-label">지점</label>
                        <select name="branchId" class="form-select">
                            <option value="">전체</option>
                            <c:forEach var="b" items="${branches}">
                                <option value="${b.id}"
                                        <c:if test="${branchId == b.id}">selected</c:if>>
                                        ${b.name}
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="col-md-2">
                        <label class="form-label">상품</label>
                        <select name="productId" class="form-select">
                            <option value="">전체</option>
                            <c:forEach var="p" items="${products}">
                                <option value="${p.id}"
                                        <c:if test="${productId == p.id}">selected</c:if>>
                                        ${p.name}
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="col-md-2">
                        <label class="form-label">키워드</label>
                        <input type="text" name="keyword" class="form-control"
                               value="${keyword}" placeholder="사유/지점/상품">
                    </div>

                    <div class="col-12 text-end">
                        <button type="submit" class="btn btn-primary">조회</button>
                        <a href="<c:url value='/audit'/>" class="btn btn-outline-secondary">초기화</a>
                    </div>
                </form>

                <!-- 결과 테이블 -->
                <div class="table-responsive">
                    <table class="table table-bordered table-hover align-middle mb-0">
                        <thead class="table-light">
                        <tr>
                            <th class="text-center" style="width: 180px;">시간</th>
                            <th class="text-center" style="width: 140px;">상태</th>
                            <th class="text-center">지점</th>
                            <th class="text-center">상품</th>
                            <th class="text-center" style="width: 100px;">변경 전</th>
                            <th class="text-center" style="width: 100px;">변경 후</th>
                            <th class="text-center" style="width: 200px;">사유</th>
                            <th class="text-center" style="width: 100px;">사용자</th>
                        </tr>
                        </thead>

                        <tbody>
                        <c:if test="${empty logs}">
                            <tr>
                                <td colspan="8"
                                    class="text-center text-muted py-4">
                                    조회 결과가 없습니다.
                                </td>
                            </tr>
                        </c:if>

                        <c:forEach var="l" items="${logs}">
                            <tr>

                                <!-- ✅ 실제 시간 그대로 출력 -->
                                <td class="text-center align-middle">
                                        ${l.createdAt}
                                </td>

                                <td class="text-start align-middle">
                                    <c:choose>
                                        <c:when test="${l.reason eq 'low_stock_threshold 변경'}">
                                            기준 수량 변경
                                        </c:when>
                                        <c:when test="${l.reason eq 'low_stock_threshold'}">
                                            기준 수량 변경
                                        </c:when>
                                        <c:when test="${empty l.reason}">
                                            -
                                        </c:when>
                                        <c:otherwise>
                                            ${l.reason}
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <!-- 지점 (ID 제거) -->
                                <td class="text-start align-middle">
                                    <c:choose>
                                        <c:when test="${not empty l.branchName}">
                                            ${l.branchName}
                                        </c:when>
                                        <c:otherwise>-</c:otherwise>
                                    </c:choose>
                                </td>

                                <!-- 상품 (ID 제거) -->
                                <td class="text-start align-middle">
                                    <c:choose>
                                        <c:when test="${not empty l.productName}">
                                            ${l.productName}
                                        </c:when>
                                        <c:otherwise>-</c:otherwise>
                                    </c:choose>
                                </td>

                                <td class="text-end align-middle">${l.beforeValue}</td>
                                <td class="text-end align-middle">${l.afterValue}</td>

                                <!-- 사유 (하단 대상 문구 없음) -->
                                <td class="text-start align-middle">
                                        ${l.reason}
                                </td>

                                <td class="text-center align-middle">
                                        ${l.actorUserId}
                                </td>

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
