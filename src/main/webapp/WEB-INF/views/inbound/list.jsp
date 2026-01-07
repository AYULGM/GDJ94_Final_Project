<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../includes/admin_header.jsp" />

<div class="container-fluid py-3">

    <div class="d-flex justify-content-between align-items-center mb-3">
        <h3 class="mb-0">입고요청(구매요청서) 목록</h3>
        <div class="d-flex gap-2">
            <a class="btn btn-primary" href="<c:url value='/inbound/new'/>">+ 신규 등록</a>
        </div>
    </div>

    <c:if test="${not empty message}">
        <div class="alert alert-success">${message}</div>
    </c:if>

    <form class="row g-2 mb-3" method="get" action="<c:url value='/inbound'/>">
        <div class="col-md-3">
            <label class="form-label">상태코드</label>
            <input type="text" class="form-control" name="statusCode" value="${statusCode}" placeholder="예: IR_REQ, IR_APPROVED" />
        </div>
        <div class="col-md-2 d-flex align-items-end">
            <button class="btn btn-outline-secondary" type="submit">검색</button>
        </div>
    </form>

    <div class="card">
        <div class="card-body">

            <table class="table table-striped table-bordered align-middle">
                <thead>
                <tr>
                    <th style="width: 10%;">ID</th>
                    <th style="width: 18%;">요청서 번호</th>
                    <th>제목</th>
                    <th style="width: 18%;">공급처</th>
                    <th style="width: 12%;">상태</th>
                    <th style="width: 12%;">요청일시</th>
                    <th style="width: 10%;">상세</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="row" items="${list}">
                    <tr>
                        <td>${row.inboundRequestId}</td>
                        <td>${row.inboundRequestNo}</td>
                        <td>${row.title}</td>
                        <td>${row.vendorName}</td>
                        <td>${row.statusCode}</td>
                        <td>${row.requestedAt}</td>
                        <td class="text-center">
                            <a class="btn btn-sm btn-outline-primary"
                               href="<c:url value='/inbound/detail?inboundRequestId=${row.inboundRequestId}'/>">
                                보기
                            </a>
                        </td>
                    </tr>
                </c:forEach>

                <c:if test="${empty list}">
                    <tr>
                        <td colspan="7" class="text-center text-muted">데이터가 없습니다.</td>
                    </tr>
                </c:if>
                </tbody>
            </table>

        </div>
    </div>

</div>

<jsp:include page="../includes/admin_footer.jsp" />
