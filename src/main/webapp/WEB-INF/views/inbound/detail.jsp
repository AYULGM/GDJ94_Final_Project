<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../includes/admin_header.jsp" />

<div class="container-fluid py-3">

    <!-- 상단 타이틀 + 액션 -->
    <div class="d-flex justify-content-between align-items-center mb-3">
        <div>
            <h3 class="mb-1">입고요청서 상세</h3>
            <div class="text-muted" style="font-size: 13px;">
                지점이 본사에 입고(보충)를 요청하는 문서입니다.
            </div>
        </div>

        <div class="d-flex gap-2">
            <a class="btn btn-outline-secondary" href="<c:url value='/inbound'/>">목록</a>

            <!-- 상태별 버튼 분기 -->
            <c:if test="${header != null}">
                <c:choose>

                    <!-- 요청(결재 진행중) -->
                    <c:when test="${header.statusCode eq 'IR_REQ' or header.statusCode eq 'REQUESTED'}">
                        <button type="button" class="btn btn-outline-primary" disabled>
                            결재 진행중
                        </button>
                    </c:when>

                    <!-- 승인완료 → 처리완료(입고반영) -->
                    <c:when test="${header.statusCode eq 'IR_APPROVED' or header.statusCode eq 'APPROVED'}">
                        <form method="post"
                              action="<c:url value='/inbound/${header.inboundRequestId}/process'/>"
                              class="m-0">
                            <button type="submit"
                                    class="btn btn-primary"
                                    onclick="return confirm('승인된 입고요청을 처리완료로 변경하고, 요청 지점 재고에 입고 반영합니다. 진행할까요?');">
                                처리완료(입고 반영)
                            </button>
                        </form>
                    </c:when>

                    <!-- 처리완료 -->
                    <c:when test="${header.statusCode eq 'IR_DONE' or header.statusCode eq 'DONE'}">
                        <button type="button" class="btn btn-success" disabled>
                            처리완료
                        </button>
                    </c:when>

                    <!-- 그 외 -->
                    <c:otherwise>
                        <button type="button" class="btn btn-outline-secondary" disabled>
                            상태 확인 필요
                        </button>
                    </c:otherwise>

                </c:choose>
            </c:if>
        </div>
    </div>

    <!-- 플래시 메시지 -->
    <c:if test="${not empty message}">
        <div class="alert alert-success">${message}</div>
    </c:if>
    <c:if test="${not empty error}">
        <div class="alert alert-danger">${error}</div>
    </c:if>

    <!-- 데이터 없을 때 -->
    <c:if test="${header == null}">
        <div class="alert alert-warning">상세 정보를 찾을 수 없습니다.</div>
    </c:if>

    <c:if test="${header != null}">

        <!-- 기본 정보 -->
        <div class="card mb-3">
            <div class="card-header d-flex justify-content-between align-items-center">
                <span>기본 정보</span>

                <!-- 상태 뱃지(한글 느낌) -->
                <c:choose>
                    <c:when test="${header.statusCode eq 'IR_REQ' or header.statusCode eq 'REQUESTED'}">
                        <span class="badge bg-secondary">요청</span>
                    </c:when>
                    <c:when test="${header.statusCode eq 'IR_APPROVED' or header.statusCode eq 'APPROVED'}">
                        <span class="badge bg-primary">승인</span>
                    </c:when>
                    <c:when test="${header.statusCode eq 'IR_DONE' or header.statusCode eq 'DONE'}">
                        <span class="badge bg-success">처리완료</span>
                    </c:when>
                    <c:otherwise>
                        <span class="badge bg-dark">${header.statusCode}</span>
                    </c:otherwise>
                </c:choose>
            </div>

            <div class="card-body">
                <div class="row g-3">

                    <div class="col-md-3">
                        <div class="text-muted">요청서 번호</div>
                        <div class="fw-semibold">${header.inboundRequestNo}</div>
                    </div>

                    <div class="col-md-3">
                        <div class="text-muted">요청일시</div>
                        <div class="fw-semibold">${header.requestedAt}</div>
                    </div>

                    <div class="col-md-3">
                        <div class="text-muted">상태</div>
                        <div class="fw-semibold">${header.statusCode}</div>
                    </div>

                    <div class="col-md-3">
                        <div class="text-muted">결재번호</div>
                        <div class="fw-semibold">
                            <c:choose>
                                <c:when test="${empty header.approvalDocVerId}">-</c:when>
                                <c:otherwise>${header.approvalDocVerId}</c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <!-- ✅ 입고요청서는 공급처보다 '요청 지점'이 핵심 -->
                    <div class="col-md-6">
                        <div class="text-muted">요청 지점</div>
                        <div class="fw-semibold">
                            <c:choose>
                                <!-- header에 branchName이 있으면 그걸 쓰고, 없으면 ID만이라도 -->
                                <c:when test="${not empty header.requestBranchName}">
                                    ${header.requestBranchName}
                                </c:when>
                                <c:when test="${not empty header.requestBranchId}">
                                    지점 ID: ${header.requestBranchId}
                                </c:when>
                                <c:otherwise>
                                    -
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="text-muted">제목</div>
                        <div class="fw-semibold">${header.title}</div>
                    </div>

                    <div class="col-12">
                        <div class="text-muted">비고</div>
                        <div>${header.memo}</div>
                    </div>

                    <!-- ✅ 개발자용 ref_type/ref_id 숨김(시연/실무 UI에서 어색함) -->
                        <%--
                        <div class="col-md-6">
                            <div class="text-muted">ref_type / ref_id</div>
                            <div><b>${header.refType}</b> / <b>${header.refId}</b></div>
                        </div>
                        --%>

                </div>
            </div>
        </div>

        <!-- 요청 품목 -->
        <div class="card">
            <div class="card-header">요청 품목</div>
            <div class="card-body">

                <table class="table table-bordered align-middle">
                    <thead>
                    <tr>
                        <!-- ✅ 품목ID 컬럼 제거 -->
                        <th>상품</th>
                        <th class="text-end" style="width: 12%;">수량</th>
                        <th class="text-end" style="width: 12%;">단가</th>
                        <th>비고</th>
                    </tr>
                    </thead>

                    <tbody>
                    <c:forEach var="it" items="${items}">
                        <tr>
                            <!-- ✅ (ID:xx) 제거 -->
                            <td class="text-start">${it.productName}</td>
                            <td class="text-end">${it.quantity}</td>
                            <td class="text-end">${it.unitPrice}</td>
                            <td class="text-start">${it.lineMemo}</td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty items}">
                        <tr>
                            <td colspan="4" class="text-center text-muted">품목이 없습니다.</td>
                        </tr>
                    </c:if>
                    </tbody>
                </table>

                <!-- 안내 문구 -->
                <c:if test="${header.statusCode eq 'IR_APPROVED' or header.statusCode eq 'APPROVED'}">
                    <div class="alert alert-info mb-0">
                        본사 승인 완료 상태입니다. 상단의 <b>처리완료(입고 반영)</b> 버튼을 누르면
                        요청 지점 재고에 입고가 반영되고 상태가 <b>처리완료</b>로 변경됩니다.
                    </div>
                </c:if>

                <c:if test="${header.statusCode eq 'IR_DONE' or header.statusCode eq 'DONE'}">
                    <div class="alert alert-success mb-0">
                        처리 완료된 문서입니다. 입고 반영이 완료되었습니다.
                    </div>
                </c:if>

            </div>
        </div>

    </c:if>
</div>

<jsp:include page="../includes/admin_footer.jsp" />
