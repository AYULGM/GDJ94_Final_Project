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
                <form method="get" action="<c:url value='/audit'/>" class="row g-2 align-items-end mb-3">

                    <div class="col-md-2">
                        <label class="form-label">From</label>
                        <input type="date" name="from" class="form-control" value="${from}" />
                    </div>

                    <div class="col-md-2">
                        <label class="form-label">To</label>
                        <input type="date" name="to" class="form-control" value="${to}" />
                    </div>

                    <div class="col-md-2">
                        <label class="form-label">Action</label>
                        <select name="actionType" class="form-select">
                            <option value="">전체</option>
                            <option value="THRESHOLD_UPDATE" <c:if test="${actionType == 'THRESHOLD_UPDATE'}">selected</c:if>>
                                기준수량 변경(THRESHOLD_UPDATE)
                            </option>
                            <option value="INVENTORY_ADJUST" <c:if test="${actionType == 'INVENTORY_ADJUST'}">selected</c:if>>
                                재고 조정(INVENTORY_ADJUST)
                            </option>
                        </select>
                    </div>

                    <div class="col-md-2">
                        <label class="form-label">Branch ID</label>
                        <input type="number" name="branchId" min="0" class="form-control" value="${branchId}" placeholder="0 또는 비움"/>
                    </div>

                    <div class="col-md-2">
                        <label class="form-label">Product ID</label>
                        <input type="number" name="productId" min="0" class="form-control" value="${productId}" placeholder="0 또는 비움"/>
                    </div>

                    <div class="col-md-2">
                        <label class="form-label">Keyword</label>
                        <input type="text" name="keyword" class="form-control" value="${keyword}" placeholder="사유/지점/상품/값" />
                    </div>

                    <div class="col-12 text-end">
                        <button type="submit" class="btn btn-primary">조회</button>
                        <a class="btn btn-outline-secondary" href="<c:url value='/audit'/>">초기화</a>
                    </div>
                </form>

                <!-- 결과 테이블 -->
                <div class="table-responsive">
                    <table class="table table-bordered table-hover align-middle mb-0">
                        <thead>
                        <tr>
                            <th style="width: 155px;">시간</th>
                            <th style="width: 190px;">Action</th>
                            <th style="width: 140px;">지점</th>
                            <th style="width: 180px;">상품</th>
                            <th style="width: 110px;" class="text-end">Before</th>
                            <th style="width: 110px;" class="text-end">After</th>
                            <th>Reason</th>
                            <th style="width: 90px;" class="text-end">Actor</th>
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
                                            <span class="badge bg-warning text-dark">THRESHOLD_UPDATE</span>
                                        </c:when>
                                        <c:when test="${l.actionType == 'INVENTORY_ADJUST'}">
                                            <span class="badge bg-info text-dark">INVENTORY_ADJUST</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-secondary">${l.actionType}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <td>
                                    <div>${l.branchName}</div>
                                    <div class="text-muted" style="font-size: 12px;">ID: ${l.branchId}</div>
                                </td>

                                <td>
                                    <div>${l.productName}</div>
                                    <div class="text-muted" style="font-size: 12px;">ID: ${l.productId}</div>
                                </td>

                                <td class="text-end">${l.beforeValue}</td>
                                <td class="text-end">${l.afterValue}</td>

                                <td>
                                    <div>${l.reason}</div>
                                    <div class="text-muted" style="font-size: 12px;">
                                        target: ${l.targetType} / ${l.targetId}
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
