<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

<jsp:include page="../includes/admin_header.jsp" />

<div class="row">
  <div class="col-12">

    <div class="card mb-3">
      <div class="card-header">
        <h3 class="card-title">재고 상세</h3>
      </div>

      <div class="card-body">

        <c:if test="${detail == null}">
          <div class="alert alert-warning">
            상세 정보를 찾을 수 없습니다.
          </div>
          <a class="btn btn-secondary" href="<c:url value='/inventory'/>">목록으로</a>
        </c:if>

        <c:if test="${detail != null}">

          <!-- 기본 정보 -->
          <table class="table table-bordered mb-4">
            <tbody>
            <tr>
              <th style="width: 180px;">지점</th>
              <!--  (ID: xx) 제거 -->
              <td>${detail.branchName}</td>
            </tr>
            <tr>
              <th>상품</th>
              <!--  (ID: xx) 제거 -->
              <td>${detail.productName}</td>
            </tr>
            <tr>
              <th>현재 수량</th>
              <td>${detail.quantity}</td>
            </tr>
            <tr>
              <th>기준 수량</th>
              <td>${detail.standardQuantity}</td>
            </tr>
            <tr>
              <th>부족 여부</th>
              <td>
                <c:choose>
                  <c:when test="${detail.lowStock == 1}">
                    <span class="badge bg-danger">부족</span>
                  </c:when>
                  <c:otherwise>
                    <span class="badge bg-success">정상</span>
                  </c:otherwise>
                </c:choose>
              </td>
            </tr>
            </tbody>
          </table>

          <a class="btn btn-secondary mb-4" href="<c:url value='/inventory'/>">목록으로</a>

          <!--  기준 수량 설정 : 본사 Admin / Master / Grandmaster만 노출 -->
          <sec:authorize access="hasAnyRole('GRANDMASTER','MASTER','ADMIN')">
            <div class="card mb-4">
              <div class="card-header">
                <h4 class="card-title mb-0">기준 수량 설정</h4>
              </div>
              <div class="card-body">

                <c:if test="${not empty thresholdSuccess}">
                  <div class="alert alert-success">${thresholdSuccess}</div>
                </c:if>
                <c:if test="${not empty thresholdError}">
                  <div class="alert alert-danger">${thresholdError}</div>
                </c:if>

                <form method="post" action="<c:url value='/inventory/threshold'/>" class="row g-3">
                  <input type="hidden" name="branchId" value="${detail.branchId}"/>
                  <input type="hidden" name="productId" value="${detail.productId}"/>

                  <div class="col-md-4">
                    <label class="form-label">지점 기준 수량 (0이면 상품 기본값 사용)</label>
                    <input type="number" name="lowStockThreshold" min="0"
                           class="form-control"
                           value="<c:out value='${detail.lowStockThreshold}'/>"
                           placeholder="예: 10 (0이면 기본값)"/>
                  </div>

                  <div class="col-md-8 d-flex align-items-end">
                    <div class="text-muted">
                      현재 적용 기준: <strong>${detail.standardQuantity}</strong>
                      <!--  '(상품 기본 reorder_point)' 삭제 -->
                      <c:choose>
                        <c:when test="${detail.lowStockThreshold != null and detail.lowStockThreshold > 0}">
                          지점별 기준
                        </c:when>
                        <c:otherwise>
                          상품 기본값
                        </c:otherwise>
                      </c:choose>
                    </div>
                  </div>

                  <div class="col-12 text-end">
                    <button type="submit" class="btn btn-primary">저장</button>
                  </div>
                </form>
              </div>
            </div>
          </sec:authorize>

          <!--  재고 조정 UI 제거 (전자결재로 이관) -->
          <%-- 재고 조정은 전자결재(재고조정요청서)로 처리 예정이므로 화면에서 제거 --%>

          <!--  이력 -->
          <div class="card">
            <div class="card-header">
              <h4 class="card-title mb-0">재고 변동 이력</h4>
            </div>

            <div class="card-body p-0">
              <table class="table table-bordered mb-0">
                <thead>
                <tr>
                  <th class="text-center" style="width: 180px;">일시</th>
                  <th class="text-center" style="width: 120px;">유형</th>
                  <th class="text-center" style="width: 90px;">수량</th>
                  <th class="text-center">사유</th>
                  <th class="text-center" style="width: 140px;">연결 문서</th>
                  <th class="text-center" style="width: 110px;">문서 ID</th>
                  <th class="text-center" style="width: 110px;">작성자</th>
                </tr>
                </thead>

                <tbody>
                <c:if test="${empty history}">
                  <tr>
                    <td colspan="7" class="text-center text-muted">이력이 없습니다.</td>
                  </tr>
                </c:if>

                <c:forEach var="h" items="${history}">
                  <tr>
                    <td class="text-center align-middle">${fn:replace(h.createDate, 'T', ' ')}</td>

                    <td class="text-center align-middle">
                      <c:choose>
                        <c:when test="${h.moveTypeCode eq 'IN'}">입고</c:when>
                        <c:when test="${h.moveTypeCode eq 'OUT'}">출고</c:when>
                        <c:when test="${h.moveTypeCode eq 'ADJUST'}">조정</c:when>
                        <c:otherwise>${h.moveTypeCode}</c:otherwise>
                      </c:choose>
                    </td>

                    <td class="text-end align-middle">${h.quantity}</td>

                    <!--  사유: 글씨 정렬(좌측 + 세로 가운데) -->
                    <td class="text-start align-middle">${h.reason}</td>

                    <td class="text-center align-middle">
                      <c:choose>
                        <c:when test="${empty h.refType}">-</c:when>
                        <c:when test="${h.refType eq 'PURCHASE_REQUEST'}">구매요청서</c:when>
                        <c:when test="${h.refType eq 'PURCHASE_ORDER'}">발주서</c:when>
                        <c:when test="${h.refType eq 'INBOUND_REQUEST'}">입고요청서</c:when>
                        <c:when test="${h.refType eq 'INBOUND'}">입고</c:when>
                        <c:when test="${h.refType eq 'OUTBOUND'}">출고</c:when>
                        <c:when test="${h.refType eq 'INVENTORY_ADJUST'}">재고조정</c:when>
                        <c:otherwise>${h.refType}</c:otherwise>
                      </c:choose>
                    </td>

                    <td class="text-center align-middle">
                      <c:choose>
                        <c:when test="${h.refId == null}">-</c:when>
                        <c:otherwise>${h.refId}</c:otherwise>
                      </c:choose>
                    </td>

                    <td class="text-center align-middle">${h.createUser}</td>
                  </tr>
                </c:forEach>
                </tbody>
              </table>
            </div>
          </div>

        </c:if>

      </div>
    </div>

  </div>
</div>

<jsp:include page="../includes/admin_footer.jsp" />
