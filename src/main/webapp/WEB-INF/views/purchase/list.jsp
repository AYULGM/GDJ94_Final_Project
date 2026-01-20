<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

<jsp:include page="../includes/admin_header.jsp" />

<div class="row">
    <div class="col-12">
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h3 class="card-title">구매/발주 목록</h3>
            </div>

            <div class="card-body">

                <!--  FIX: redirect로 파라미터 날리는 문제 방지 -->
                <form method="get" action="<c:url value='/purchase/orders'/>" class="row g-2 mb-3">
                    <div class="col-md-3">
                        <select class="form-select" name="branchId">
                            <option value="">전체 지점</option>
                            <c:forEach var="b" items="${branches}">
                                <option value="${b.id}" <c:if test="${not empty branchId and branchId == b.id}">selected</c:if>>
                                        ${b.name}
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="col-md-3">
                        <select class="form-select" name="statusCode">
                            <option value="">전체 상태</option>
                            <option value="REQUESTED" <c:if test="${statusCode == 'REQUESTED'}">selected</c:if>>요청</option>
                            <option value="APPROVED"  <c:if test="${statusCode == 'APPROVED'}">selected</c:if>>승인</option>
                            <option value="REJECTED"  <c:if test="${statusCode == 'REJECTED'}">selected</c:if>>반려</option>
                            <option value="FULFILLED" <c:if test="${statusCode == 'FULFILLED'}">selected</c:if>>입고완료</option>
                        </select>
                    </div>

                    <div class="col-md-4">
                        <input class="form-control" type="text" name="keyword" value="${keyword}" placeholder="발주번호/지점/상품 검색" />
                    </div>

                    <div class="col-md-2 d-flex gap-2">
                        <button class="btn btn-primary flex-grow-1" type="submit">조회</button>

                        <!--  지점만 노출 -->
                        <sec:authorize access="hasAnyRole('CAPTAIN','CREW')">
                            <a class="btn btn-outline-primary flex-grow-1" href="<c:url value='/purchase/new'/>">발주 요청</a>
                        </sec:authorize>
                    </div>
                </form>

                <table class="table table-bordered table-hover">
                    <thead>
                    <tr>
                        <th style="width: 90px;">ID</th>
                        <th style="width: 160px;">발주번호</th>
                        <th style="width: 120px;">지점</th>
                        <th style="width: 110px;">상태</th>
                        <th style="width: 160px;">요청일시</th>
                        <th class="text-end" style="width: 110px;">총수량</th>
                        <th class="text-end" style="width: 140px;">총금액</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:choose>
                        <c:when test="${empty list}">
                            <tr>
                                <td colspan="7" class="text-center text-muted">조회 결과가 없습니다.</td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="row" items="${list}">
                                <tr>
                                    <td>${row.purchaseId}</td>
                                    <td>
                                        <!--  /purchase/{id} 상세로 이동 -->
                                        <a href="<c:url value='/purchase/${row.purchaseId}'/>">${row.purchaseNo}</a>
                                    </td>
                                    <td>${row.branchName}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${row.statusCode == 'REQUESTED'}"><span class="badge bg-warning">요청</span></c:when>
                                            <c:when test="${row.statusCode == 'APPROVED'}"><span class="badge bg-success">승인</span></c:when>
                                            <c:when test="${row.statusCode == 'REJECTED'}"><span class="badge bg-danger">반려</span></c:when>
                                            <c:when test="${row.statusCode == 'FULFILLED'}"><span class="badge bg-primary">입고완료</span></c:when>
                                            <c:otherwise><span class="badge bg-secondary">${row.statusCode}</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>${fn:replace(row.requestedAt, 'T', ' ')}</td>
                                    <td class="text-end">${row.totalQuantity}</td>
                                    <td class="text-end">${row.totalAmount}</td>
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
