<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8" />
  <title>재고 상세</title>
</head>
<body>

<h2>재고 상세</h2>

<c:if test="${detail == null}">
  <p>상세 정보를 찾을 수 없습니다.</p>
  <p><a href="<c:url value='/inventory'/>">목록으로</a></p>
</c:if>

<c:if test="${detail != null}">
  <div style="border:1px solid #ddd; padding:12px; margin-bottom:16px;">
    <p><b>지점:</b> ${detail.branchName} (ID: ${detail.branchId})</p>
    <p><b>상품:</b> ${detail.productName} (ID: ${detail.productId})</p>
    <p><b>현재 수량:</b> ${detail.quantity}</p>
    <p><b>기준 수량:</b> ${detail.standardQuantity}</p>

    <p><b>부족 여부:</b>
      <c:choose>
        <c:when test="${detail.lowStock == 1}">Y</c:when>
        <c:otherwise>N</c:otherwise>
      </c:choose>
    </p>

    <p style="color:#666;">
      (low_stock_threshold: ${detail.lowStockThreshold}, reorder_point: ${detail.reorderPoint})
    </p>

    <p>
      <a href="<c:url value='/inventory'>
                 <c:param name='branchId' value='${detail.branchId}'/>
               </c:url>">목록으로</a>
    </p>
  </div>

  <!-- 재고 조정 폼 -->
  <h3>재고 조정</h3>

  <c:if test="${not empty error}">
    <div style="padding:10px; border:1px solid #f00; color:#900; margin-bottom:12px;">
        ${error}
    </div>
  </c:if>

  <form method="post" action="<c:url value='/inventory/adjust'/>"
        style="border:1px solid #ddd; padding:12px; margin-bottom:16px;">
    <input type="hidden" name="branchId" value="${detail.branchId}"/>
    <input type="hidden" name="productId" value="${detail.productId}"/>

    <label>유형</label>
    <select name="moveTypeCode" required>
      <option value="IN">입고(IN)</option>
      <option value="OUT">출고(OUT)</option>
      <option value="ADJUST">조정(ADJUST)</option>
    </select>

    <label style="margin-left:12px;">수량</label>
    <input type="number" name="quantity" min="1" required/>

    <label style="margin-left:12px;">사유</label>
    <input type="text" name="reason" maxlength="200" required style="width:320px;"/>

    <button type="submit" style="margin-left:12px;">반영</button>
  </form>

  <!-- 이력 -->
  <h3>재고 변동 이력</h3>
  <table border="1" cellspacing="0" cellpadding="8" style="width:100%; border-collapse:collapse;">
    <thead>
    <tr>
      <th>일시</th>
      <th>유형</th>
      <th>수량</th>
      <th>사유</th>
      <th>ref_type</th>
      <th>ref_id</th>
      <th>작성자</th>
    </tr>
    </thead>
    <tbody>
    <c:if test="${empty history}">
      <tr>
        <td colspan="7" style="text-align:center;">이력이 없습니다.</td>
      </tr>
    </c:if>

    <c:forEach var="h" items="${history}">
      <tr>
        <td>${h.createDate}</td>
        <td>${h.moveTypeCode}</td>
        <td>${h.quantity}</td>
        <td>${h.reason}</td>
        <td>${h.refType}</td>
        <td>${h.refId}</td>
        <td>${h.createUser}</td>
      </tr>
    </c:forEach>
    </tbody>
  </table>
</c:if>

</body>
</html>
