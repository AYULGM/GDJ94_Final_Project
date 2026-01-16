<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

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
              <td>${detail.branchName} (ID: ${detail.branchId})</td>
            </tr>
            <tr>
              <th>상품</th>
              <td>${detail.productName} (ID: ${detail.productId})</td>
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

          <!-- 기준 수량 설정 -->
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
                    현재 적용 기준:
                    <strong>${detail.standardQuantity}</strong>
                    <c:choose>
                      <c:when test="${detail.lowStockThreshold != null and detail.lowStockThreshold > 0}">
                        (지점별 기준)
                      </c:when>
                      <c:otherwise>
                        (상품 기본 reorder_point)
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

          <!-- 재고 조정 -->
          <div class="card mb-4">
            <div class="card-header">
              <h4 class="card-title mb-0">재고 조정</h4>
            </div>
            <div class="card-body">

              <c:if test="${not empty adjustSuccess}">
                <div class="alert alert-success">${adjustSuccess}</div>
              </c:if>
              <c:if test="${not empty adjustError}">
                <div class="alert alert-danger">${adjustError}</div>
              </c:if>

              <form method="post" action="<c:url value='/inventory/adjust'/>" class="row g-3">
                <input type="hidden" name="branchId" value="${detail.branchId}"/>
                <input type="hidden" name="productId" value="${detail.productId}"/>

                <div class="col-md-3">
                  <label class="form-label">유형</label>
                  <select name="moveTypeCode" class="form-select" required>
                    <option value="IN">입고(IN)</option>
                    <option value="OUT">출고(OUT)</option>
                    <option value="ADJUST">조정(ADJUST)</option>
                  </select>
                </div>

                <div class="col-md-3">
                  <label class="form-label">수량</label>
                  <input type="number" name="quantity" min="1" class="form-control" required/>
                </div>

                <div class="col-md-6">
                  <label class="form-label">사유</label>
                  <input type="text" name="reason" maxlength="200" class="form-control" required/>
                </div>

                <div class="col-12 text-end">
                  <button type="submit" class="btn btn-primary">반영</button>
                </div>
              </form>

            </div>
          </div>

          <!-- 이력 -->
          <div class="card">
            <div class="card-header">
              <h4 class="card-title mb-0">재고 변동 이력</h4>
            </div>
            <div class="card-body p-0">
              <table class="table table-bordered mb-0">
                <thead>
                <tr>
                  <th>일시</th>
                  <th>유형</th>
                  <th class="text-end">수량</th>
                  <th>사유</th>
                  <th>ref_type</th>
                  <th>ref_id</th>
                  <th>작성자</th>
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
                    <td>${h.createDate}</td>
                    <td>${h.moveTypeCode}</td>
                    <td class="text-end">${h.quantity}</td>
                    <td>${h.reason}</td>
                    <td>${h.refType}</td>
                    <td>${h.refId}</td>
                    <td>${h.createUser}</td>
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
