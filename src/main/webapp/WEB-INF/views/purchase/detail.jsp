<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="../includes/admin_header.jsp" />

<style>
    /* 메모가 HTML(p, br 등)로 들어오는 경우 자연스럽게 보이도록 */
    .memo-box { white-space: normal; line-height: 1.6; }
    .memo-box p { margin: 0 0 .35rem 0; }
    .memo-box p:last-child { margin-bottom: 0; }
</style>

<div class="container-fluid py-3">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h3 class="mb-0">발주 상세</h3>
        <a class="btn btn-outline-secondary" href="<c:url value='/purchase/orders'/>">목록</a>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-danger">${error}</div>
    </c:if>

    <div class="card">
        <div class="card-header">발주 정보</div>
        <div class="card-body">

            <c:if test="${detail == null}">
                <div class="alert alert-warning">발주 정보를 찾을 수 없습니다.</div>
            </c:if>

            <c:if test="${detail != null}">
                <div class="row g-3">
                    <div class="col-md-6 col-lg-3">
                        <div class="text-muted small">발주번호</div>
                        <div class="fs-6 fw-semibold">${detail.purchaseNo}</div>
                    </div>

                    <div class="col-md-6 col-lg-3">
                        <div class="text-muted small">지점</div>
                        <div class="fs-6 fw-semibold">${detail.branchName}</div>
                    </div>

                    <div class="col-md-6 col-lg-3">
                        <div class="text-muted small">상태</div>
                        <div>
                            <c:choose>
                                <c:when test="${detail.statusCode == 'REQUESTED'}"><span class="badge bg-warning">요청</span></c:when>
                                <c:when test="${detail.statusCode == 'APPROVED'}"><span class="badge bg-success">승인</span></c:when>
                                <c:when test="${detail.statusCode == 'REJECTED'}"><span class="badge bg-danger">반려</span></c:when>
                                <c:when test="${detail.statusCode == 'FULFILLED'}"><span class="badge bg-primary">입고 완료</span></c:when>
                                <c:otherwise><span class="badge bg-secondary">${detail.statusCode}</span></c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <div class="col-md-6 col-lg-3">
                        <div class="text-muted small">요청일</div>
                        <div class="fs-6 fw-semibold">
                                ${fn:replace(detail.requestedAt, 'T', ' ')}
                        </div>
                    </div>

                    <c:set var="memoRaw" value="${detail.memo}" />

                    <c:set var="dueDate"
                           value="${fn:substringBefore(fn:substringAfter(memoRaw, '희망납기일:'), '요청사유:')}" />

                    <c:set var="requestReason"
                           value="${fn:substringBefore(fn:substringAfter(memoRaw, '요청사유:'), '본문:')}" />

                    <c:set var="memoBody"
                           value="${fn:substringAfter(memoRaw, '본문:')}" />

                    <div class="col-12">
                        <div class="text-muted small mb-2">메모</div>

                        <div class="border rounded p-3 bg-light">

                            <!-- 희망 납기일 -->
                            <c:if test="${not empty dueDate}">
                                <div class="mb-2">
                                    <span class="fw-semibold text-secondary">희망 납기일</span>
                                    <span class="ms-2">${fn:trim(dueDate)}</span>
                                </div>
                            </c:if>

                            <!-- 요청 사항 -->
                            <c:if test="${not empty requestReason}">
                                <div class="mb-2">
                                    <span class="fw-semibold text-secondary">요청 사항</span>
                                    <span class="ms-2">${fn:trim(requestReason)}</span>
                                </div>
                            </c:if>

                            <!-- 본문 -->
                            <c:if test="${not empty memoBody}">
                                <hr class="my-2"/>
                                <div class="fw-semibold text-secondary mb-1">상세 내용</div>
                                <div style="white-space: pre-wrap; line-height: 1.6;">
                                    <c:out value="${fn:trim(memoBody)}" escapeXml="false"/>
                                </div>
                            </c:if>

                        </div>
                    </div>

                <hr/>

                <h5 class="mb-2">발주 품목</h5>

                <c:set var="sumQty" value="0" />
                <c:set var="sumAmt" value="0" />

                <table class="table table-bordered align-middle">
                    <thead>
                    <tr>
                        <th>상품</th>
                        <th class="text-end" style="width:120px;">수량</th>
                        <th class="text-end" style="width:140px;">단가</th>
                        <th class="text-end" style="width:140px;">금액</th>
                    </tr>
                    </thead>

                    <tbody>
                    <c:forEach var="it" items="${detail.items}">
                        <c:set var="sumQty" value="${sumQty + it.quantity}" />
                        <c:set var="sumAmt" value="${sumAmt + it.amount}" />
                        <tr>
                            <td>${it.productName}</td>
                            <td class="text-end"><fmt:formatNumber value="${it.quantity}" pattern="#,##0"/></td>
                            <td class="text-end"><fmt:formatNumber value="${it.unitPrice}" pattern="#,##0"/></td>
                            <td class="text-end"><fmt:formatNumber value="${it.amount}" pattern="#,##0"/></td>
                        </tr>
                    </c:forEach>
                    </tbody>

                    <tfoot>
                    <!--  합계를 '상품' 컬럼(왼쪽 첫 칸)으로 이동 -->
                    <tr>
                        <th class="text-start">합계</th>
                        <th class="text-end"><fmt:formatNumber value="${sumQty}" pattern="#,##0"/></th>
                        <th class="text-end">-</th>
                        <th class="text-end"><fmt:formatNumber value="${sumAmt}" pattern="#,##0"/></th>
                    </tr>
                    </tfoot>
                </table>

            </c:if>

        </div>
    </div>
</div>

<jsp:include page="../includes/admin_footer.jsp" />
