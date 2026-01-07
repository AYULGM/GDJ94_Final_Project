<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<jsp:include page="../includes/admin_header.jsp" />

<div class="row">
    <div class="col-12">

        <c:if test="${not empty message}">
            <div class="alert alert-success">${message}</div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert alert-danger">${error}</div>
        </c:if>

        <c:if test="${detail == null}">
            <div class="card">
                <div class="card-body">
                    <p class="text-muted mb-0">발주 정보를 찾을 수 없습니다.</p>
                    <a class="btn btn-outline-secondary mt-2" href="<c:url value='/purchase'/>">목록으로</a>
                </div>
            </div>
        </c:if>

        <c:if test="${detail != null}">
            <div class="card mb-3">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h3 class="card-title mb-0">발주 상세</h3>
                    <a class="btn btn-sm btn-outline-secondary" href="<c:url value='/purchase'/>">목록</a>
                </div>

                <div class="card-body">
                    <div class="row mb-2">
                        <div class="col-md-4"><b>발주번호</b> : ${detail.purchaseNo}</div>
                        <div class="col-md-4"><b>지점</b> : ${detail.branchName}</div>
                        <div class="col-md-4">
                            <b>상태</b> :
                            <c:choose>
                                <c:when test="${detail.statusCode == 'REQUESTED'}"><span class="badge bg-warning">요청</span></c:when>
                                <c:when test="${detail.statusCode == 'APPROVED'}"><span class="badge bg-success">승인</span></c:when>
                                <c:otherwise><span class="badge bg-danger">반려</span></c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <div class="mb-2"><b>요청일시</b> : ${detail.requestedAt}</div>
                    <div class="mb-2"><b>메모</b> : ${detail.memo}</div>

                    <c:if test="${detail.statusCode == 'REJECTED'}">
                        <div class="alert alert-danger mt-2">
                            <b>반려 사유</b> : ${detail.rejectReason}
                        </div>
                    </c:if>

                    <hr/>

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

                    <c:if test="${detail.statusCode == 'REQUESTED'}">
                        <div class="d-flex gap-2 mt-3">
                            <form method="post" action="<c:url value='/purchase/${detail.purchaseId}/approve'/>">
                                <button class="btn btn-success" type="submit">승인(재고반영)</button>
                            </form>

                            <form method="post" action="<c:url value='/purchase/${detail.purchaseId}/reject'/>" class="d-flex gap-2">
                                <input class="form-control" type="text" name="rejectReason" placeholder="반려 사유" required />
                                <button class="btn btn-danger" type="submit">반려</button>
                            </form>
                        </div>
                    </c:if>

                </div>
            </div>
        </c:if>

    </div>
</div>

<jsp:include page="../includes/admin_footer.jsp" />
