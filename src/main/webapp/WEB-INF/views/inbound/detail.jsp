<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../includes/admin_header.jsp" />

<div class="container-fluid py-3">

    <div class="d-flex justify-content-between align-items-center mb-3">
        <h3 class="mb-0">입고요청(구매요청서) 상세</h3>
        <div class="d-flex gap-2">
            <a class="btn btn-outline-secondary" href="<c:url value='/inbound'/>">목록</a>

            <!-- 임시 테스트 버튼(승인 훅 붙기 전까지 확인용) -->
            <form method="post" action="<c:url value='/inbound/apply'/>" class="m-0">
                <input type="hidden" name="inboundRequestId" value="${header.inboundRequestId}" />
                <button type="submit" class="btn btn-outline-danger"
                        onclick="return confirm('테스트용으로 재고 반영을 실행합니다. 진행할까요?');">
                    (테스트) 승인처리/재고반영
                </button>
            </form>
        </div>
    </div>

    <c:if test="${header == null}">
        <div class="alert alert-warning">상세 정보를 찾을 수 없습니다.</div>
    </c:if>

    <c:if test="${header != null}">
        <div class="card mb-3">
            <div class="card-header">기본 정보</div>
            <div class="card-body">

                <div class="row g-2">
                    <div class="col-md-3">
                        <div class="text-muted">ID</div>
                        <div><b>${header.inboundRequestId}</b></div>
                    </div>
                    <div class="col-md-3">
                        <div class="text-muted">요청서 번호</div>
                        <div><b>${header.inboundRequestNo}</b></div>
                    </div>
                    <div class="col-md-3">
                        <div class="text-muted">상태</div>
                        <div><b>${header.statusCode}</b></div>
                    </div>
                    <div class="col-md-3">
                        <div class="text-muted">요청일시</div>
                        <div><b>${header.requestedAt}</b></div>
                    </div>

                    <div class="col-md-6 mt-2">
                        <div class="text-muted">공급처</div>
                        <div><b>${header.vendorName}</b></div>
                    </div>
                    <div class="col-md-6 mt-2">
                        <div class="text-muted">제목</div>
                        <div><b>${header.title}</b></div>
                    </div>

                    <div class="col-12 mt-2">
                        <div class="text-muted">비고</div>
                        <div>${header.memo}</div>
                    </div>

                    <div class="col-md-6 mt-2">
                        <div class="text-muted">결재 문서 버전ID</div>
                        <div><b>${header.approvalDocVerId}</b></div>
                    </div>
                    <div class="col-md-6 mt-2">
                        <div class="text-muted">ref_type/ref_id</div>
                        <div><b>${header.refType}</b> / <b>${header.refId}</b></div>
                    </div>
                </div>

            </div>
        </div>

        <div class="card">
            <div class="card-header">요청 품목</div>
            <div class="card-body">

                <table class="table table-bordered align-middle">
                    <thead>
                    <tr>
                        <th style="width: 10%;">품목ID</th>
                        <th>상품</th>
                        <th style="width: 12%;">수량</th>
                        <th style="width: 12%;">단가</th>
                        <th>비고</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="it" items="${items}">
                        <tr>
                            <td>${it.inboundRequestItemId}</td>
                            <td>${it.productName} (ID:${it.productId})</td>
                            <td>${it.quantity}</td>
                            <td>${it.unitPrice}</td>
                            <td>${it.lineMemo}</td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty items}">
                        <tr>
                            <td colspan="5" class="text-center text-muted">품목이 없습니다.</td>
                        </tr>
                    </c:if>
                    </tbody>
                </table>

            </div>
        </div>

    </c:if>

</div>

<jsp:include page="../includes/admin_footer.jsp" />
