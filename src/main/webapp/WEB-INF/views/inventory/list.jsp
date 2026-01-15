<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="../includes/admin_header.jsp" />

<div class="row">
    <div class="col-12">
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">재고 현황</h3>
            </div>

            <div class="card-body">

                <%-- 디버그용: 필요 시 사용 --%>
                <%-- <div style="color:red;">listSize=${fn:length(list)}</div> --%>

                <!-- 검색/필터 폼 -->
                <form method="get" action="<c:url value='/inventory'/>" class="row g-2 mb-3">

                    <!-- 지점 선택 -->
                    <div class="col-md-3">
                        <label class="form-label">지점</label>
                        <select name="branchId" class="form-select">
                            <option value="">전체</option>

                            <c:forEach var="branch" items="${branches}">
                                <option value="${branch.id}"
                                        <c:if test="${not empty branchId and branchId == branch.id}">selected</c:if>>
                                        ${branch.name}
                                </option>
                            </c:forEach>

                        </select>
                    </div>

                    <!-- 상품명 키워드 -->
                    <div class="col-md-4">
                        <label class="form-label">상품명</label>
                        <input type="text" name="keyword" class="form-control"
                               value="${keyword}" placeholder="상품명 검색" />
                    </div>

                    <!-- 부족재고만 -->
                    <div class="col-md-3 d-flex align-items-end">
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox"
                                   id="onlyLowStock" name="onlyLowStock" value="true"
                                   <c:if test="${onlyLowStock == true}">checked</c:if>>
                            <label class="form-check-label" for="onlyLowStock">
                                부족재고만 보기
                            </label>
                        </div>
                    </div>

                    <!-- 조회 버튼 -->
                    <div class="col-md-2 d-flex align-items-end">
                        <button class="btn btn-primary w-100" type="submit">조회</button>
                    </div>

                </form>

                <!-- 결과 테이블 -->
                <table class="table table-bordered table-hover align-middle inventory-table">
                    <thead>
                    <tr>
                        <th>지점</th>
                        <th>상품</th>
                        <th class="text-end qty-col">현재수량</th>
                        <th class="text-end qty-col">기준수량</th>
                        <th class="text-center status-col">부족여부</th>
                        <th class="text-center action-col">상세</th>
                    </tr>
                    </thead>

                    <tbody>
                    <c:choose>
                        <c:when test="${empty list}">
                            <tr>
                                <td colspan="6" class="text-center text-muted">
                                    조회 결과가 없습니다.
                                </td>
                            </tr>
                        </c:when>

                        <c:otherwise>
                            <c:forEach var="row" items="${list}">
                                <!-- 링크는 var로 먼저 만들고 href에는 변수만 넣는다(깨짐 방지) -->
                                <c:url var="detailUrl" value="/inventory/detail">
                                    <c:param name="branchId" value="${row.branchId}"/>
                                    <c:param name="productId" value="${row.productId}"/>
                                </c:url>

                                <tr>
                                    <td class="text-truncate" style="max-width: 240px;">${row.branchName}</td>
                                    <td class="text-truncate" style="max-width: 360px;">${row.productName}</td>

                                    <!-- 숫자는 무조건 오른쪽 정렬 -->
                                    <td class="text-end">${row.quantity}</td>
                                    <td class="text-end">${row.thresholdValue}</td>

                                    <!-- 상태는 가운데 정렬 -->
                                    <td class="text-center">
                                        <c:choose>
                                            <c:when test="${row.lowStock == 1}">
                                                <span class="badge bg-danger status-badge">부족</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-success status-badge">정상</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <!-- 버튼도 가운데 정렬 -->
                                    <td class="text-center">
                                        <a class="btn btn-sm btn-outline-secondary" href="${detailUrl}">
                                            보기
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                    </tbody>
                </table>

                <!-- 혹시 다른 CSS가 table 정렬을 덮어써도 깨지지 않게 보강 -->
                <style>
                    .inventory-table .qty-col { width: 110px; }
                    .inventory-table .status-col { width: 110px; }
                    .inventory-table .action-col { width: 110px; }

                    .inventory-table th.text-end,
                    .inventory-table td.text-end { text-align: right !important; }

                    .inventory-table th.text-center,
                    .inventory-table td.text-center { text-align: center !important; }

                    .inventory-table .status-badge { min-width: 44px; display: inline-block; }
                </style>

            </div>
        </div>
    </div>
</div>

<jsp:include page="../includes/admin_footer.jsp" />
