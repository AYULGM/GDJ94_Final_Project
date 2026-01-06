<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<jsp:include page="../includes/admin_header.jsp" />

<div class="row">
    <div class="col-12">
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">발주 요청</h3>
            </div>

            <div class="card-body">

                <c:if test="${not empty message}">
                    <div class="alert alert-success">${message}</div>
                </c:if>
                <c:if test="${not empty error}">
                    <div class="alert alert-danger">${error}</div>
                </c:if>

                <form method="post" action="<c:url value='/purchase'/>">

                    <div class="mb-3">
                        <label class="form-label">지점</label>
                        <select class="form-select" name="branchId" required>
                            <option value="">지점 선택</option>
                            <c:forEach var="b" items="${branches}">
                                <option value="${b.id}">${b.name}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">메모</label>
                        <input class="form-control" type="text" name="memo" placeholder="요청 메모(선택)" />
                    </div>

                    <hr/>

                    <h5 class="mb-2">발주 품목</h5>

                    <!-- 단순 버전: 3줄 고정 (원하면 JS로 행 추가 가능) -->
                    <c:forEach var="i" begin="0" end="2">
                        <div class="row g-2 mb-2">
                            <div class="col-md-6">
                                <select class="form-select" name="items[${i}].productId">
                                    <option value="">상품 선택</option>
                                    <c:forEach var="p" items="${products}">
                                        <option value="${p.id}">${p.name}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <input class="form-control" type="number" name="items[${i}].quantity" min="1" placeholder="수량" />
                            </div>
                            <div class="col-md-3">
                                <input class="form-control" type="number" name="items[${i}].unitPrice" min="0" placeholder="단가" />
                            </div>
                        </div>
                    </c:forEach>

                    <div class="mt-3 d-flex gap-2">
                        <button class="btn btn-primary" type="submit">발주 요청 등록</button>
                        <a class="btn btn-outline-secondary" href="<c:url value='/purchase'/>">발주 목록</a>
                    </div>

                </form>

            </div>
        </div>
    </div>
</div>

<jsp:include page="../includes/admin_footer.jsp" />
