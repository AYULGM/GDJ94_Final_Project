<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<jsp:include page="../includes/admin_header.jsp" />

<div class="row">
    <div class="col-12">
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">재고 현황</h3>
            </div>

            <div class="card-body">

                <!-- 검색/필터 -->
                <form method="get" action="<c:url value='/inventory'/>" class="row g-2 mb-3">
                    <div class="col-md-3">
                        <select class="form-select" name="branchId">
                            <option value="">전체 지점</option>
                            <c:forEach var="branch" items="${branches}">
                                <option value="${branch.branchId}"
                                        <c:if test="${not empty branchId and branchId == branch.branchId}">selected</c:if>>
                                        ${branch.branchName}
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="col-md-4">
                        <input class="form-control" type="text" name="keyword" value="${keyword}" placeholder="상품명/지점명 검색" />
                    </div>

                    <div class="col-md-3 d-flex align-items-center">
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" id="onlyLowStock" name="onlyLowStock" value="true"
                                   <c:if test="${onlyLowStock}">checked</c:if>>
                            <label class="form-check-label" for="onlyLowStock">부족 재고만</label>
                        </div>
                    </div>

                    <div class="col-md-2">
                        <button class="btn btn-primary w-100" type="submit">조회</button>
                    </div>
                </form>

                <!-- 목록 테이블 -->
                <table class="table table-bordered table-hover">
                    <thead>
                    <tr>
                        <th style="width: 90px;">지점</th>
                        <th>상품</th>
                        <th style="width: 120px;" class="text-end">현재 수량</th>
                        <th style="width: 140px;" class="text-end">기준 수량</th>
                        <th style="width: 110px;" class="text-center">부족 여부</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:choose>
                        <!--  inventoryList -> list 로 변경 -->
                        <c:when test="${empty list}">
                            <tr>
                                <td colspan="5" class="text-center text-muted">조회 결과가 없습니다.</td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="row" items="${list}">
                                <tr>
                                    <td>${row.branchName}</td>

                                    <!--  상품명 클릭 시 상세로 이동 -->
                                    <td>
                                        <a href="<c:url value='/inventory/detail'/>?branchId=${row.branchId}&productId=${row.productId}">
                                                ${row.productName}
                                        </a>
                                    </td>

                                    <td class="text-end">${row.quantity}</td>
                                    <td class="text-end">${row.thresholdValue}</td>

                                    <td class="text-center">
                                        <c:choose>
                                            <c:when test="${row.lowStock == 1}">
                                                <span class="badge bg-danger">부족</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-success">정상</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                    </tbody>
                </table>

            </div>
        </div>
    </div>
</div>

<jsp:include page="../includes/admin_footer.jsp" />
