<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../includes/admin_header.jsp" />

<div class="container-fluid py-3">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h3 class="mb-0">발주 상세</h3>
        <a class="btn btn-outline-secondary" href="<c:url value='/purchase'/>">목록</a>
    </div>

    <c:if test="${not empty message}">
        <div class="alert alert-success">${message}</div>
    </c:if>
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
                <div class="row g-2">
                    <div class="col-md-3">
                        <div class="text-muted">발주번호</div>
                        <div><b>${detail.purchaseNo}</b></div>
                    </div>
                    <div class="col-md-3">
                        <div class="text-muted">지점</div>
                        <div><b>${detail.branchName}</b></div>
                    </div>
                    <div class="col-md-3">
                        <div class="text-muted">상태</div>
                        <div><b>${detail.statusCode}</b></div>
                    </div>
                    <div class="col-md-3">
                        <div class="text-muted">요청일</div>
                        <div><b>${detail.requestedAt}</b></div>
                    </div>

                    <div class="col-12 mt-2">
                        <div class="text-muted">메모</div>
                        <div>${detail.memo}</div>
                    </div>
                </div>

                <hr/>

                <h5 class="mb-2">발주 품목</h5>
                <table class="table table-bordered">
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
                        <tr>
                            <td>${it.productName}</td>
                            <td class="text-end">${it.quantity}</td>
                            <td class="text-end">${it.unitPrice}</td>
                            <td class="text-end">${it.amount}</td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>

                <!-- 1) REQUESTED -> APPROVED (결재 완료) -->
                <c:if test="${detail.statusCode == 'REQUESTED'}">
                    <div class="d-flex gap-2 mt-3">
                        <form method="post" action="<c:url value='/purchase/${detail.purchaseId}/approve'/>">
                            <button class="btn btn-success" type="submit">승인(결재완료)</button>
                        </form>

                        <form method="post" action="<c:url value='/purchase/${detail.purchaseId}/reject'/>" class="d-flex gap-2">
                            <input class="form-control" type="text" name="rejectReason" placeholder="반려 사유" required />
                            <button class="btn btn-danger" type="submit">반려</button>
                        </form>
                    </div>
                </c:if>

                <!-- 2) APPROVED -> FULFILLED (입고 처리 / 재고 반영) -->
                <c:if test="${detail.statusCode == 'APPROVED'}">
                    <div class="d-flex gap-2 mt-3">
                        <form method="post" action="<c:url value='/purchase/${detail.purchaseId}/fulfill'/>">
                            <button class="btn btn-primary" type="submit">입고 처리(재고반영)</button>
                        </form>
                        <a class="btn btn-outline-secondary" href="<c:url value='/purchase'/>">목록</a>
                    </div>
                </c:if>

                <!-- 그 외(입고완료/반려 등) -> 액션 버튼 없음 -->
                <c:if test="${detail.statusCode != 'REQUESTED' && detail.statusCode != 'APPROVED'}">
                    <div class="d-flex gap-2 mt-3">
                        <a class="btn btn-outline-secondary" href="<c:url value='/purchase'/>">목록</a>
                    </div>
                </c:if>

            </c:if>

        </div>
    </div>
</div>

<jsp:include page="../includes/admin_footer.jsp" />
