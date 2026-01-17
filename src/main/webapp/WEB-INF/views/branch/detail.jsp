<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<jsp:include page="../includes/admin_header.jsp" />

<div class="row">
  <div class="col-12">

    <!-- ================= 지점 상세 카드 ================= -->
    <div class="card">
      <div class="card-header">
        <h3 class="card-title">지점 상세 정보</h3>
      </div>

      <div class="card-body">
        <table class="table table-bordered">
          <tr>
            <th style="width: 20%">지점명</th>
            <td>${branch.branchName}</td>
          </tr>
          <tr>
            <th>주소</th>
            <td>(${branch.postNo}) ${branch.baseAddress} ${branch.detailAddress}</td>
          </tr>
          <tr>
            <th>담당자</th>
            <td>${branch.managerName}</td>
          </tr>
          <tr>
            <th>연락처</th>
            <td>${branch.managerPhone}</td>
          </tr>
          <tr>
            <th>운영시간</th>
            <td>${branch.operatingHours}</td>
          </tr>
          <tr>
            <th>상태</th>
            <td>
				<c:choose>
				    <c:when test="${branch.statusCode eq 'BS001'}">
				        <span class="badge bg-success">${branch.statusName}</span>
				    </c:when>
				
				    <c:when test="${branch.statusCode eq 'BS002'}">
				        <span class="badge bg-danger">${branch.statusName}</span>
				    </c:when>
				
				    <c:when test="${branch.statusCode eq 'BS003'}">
				        <span class="badge bg-warning">${branch.statusName}</span>
				    </c:when>
				
				    <c:otherwise>
				        <span class="badge bg-secondary">${branch.statusName}</span>
				    </c:otherwise>
				</c:choose>
            </td>
          </tr>
        </table>
      </div>

      <div class="card-footer text-end">
        <a href="/branch/list" class="btn btn-secondary">목록</a>

        <a href="/branch/update?branchId=${branch.branchId}"
           class="btn btn-warning">
          수정
        </a>

        <button type="button"
                class="btn btn-danger"
                data-bs-toggle="modal"
                data-bs-target="#statusModal">
          상태 변경
        </button>
      </div>
    </div>

    <!-- ================= 변경 이력 카드 ================= -->
    <div class="card mt-4">
      <div class="card-header">
        <h3 class="card-title">변경 이력</h3>
      </div>

      <div class="card-body p-0">
        <table class="table table-hover table-bordered mb-0">
          <thead class="table-light">
            <tr>
              <th style="width: 15%">변경일시</th>
              <th style="width: 12%">구분</th>
              <th>변경 내용</th>
              <th style="width: 20%">사유</th>
              <th style="width: 12%">처리자</th>
            </tr>
          </thead>
          <tbody>

            <c:forEach var="h" items="${historyList}">
              <tr>
                <td>${h.createDate}</td>

                <td>
                  <c:choose>
                    <c:when test="${h.historyType eq 'STATUS_CHANGE'}">
                      <span class="badge bg-danger">상태변경</span>
                    </c:when>
                    <c:otherwise>
                      <span class="badge bg-warning text-dark">정보수정</span>
                    </c:otherwise>
                  </c:choose>
                </td>

                <td>
                  <strong>${h.changeField}</strong> :
                  ${h.beforeValue} → ${h.afterValue}
                </td>

                <td>${h.reason}</td>
                <td>${h.createUserName}</td>
              </tr>
            </c:forEach>

            <c:if test="${empty historyList}">
              <tr>
                <td colspan="5" class="text-center text-muted">
                  변경 이력이 없습니다.
                </td>
              </tr>
            </c:if>

          </tbody>
        </table>
      </div>
    </div>

  </div>
</div>

<!-- ================= 지점 상태 변경 모달 ================= -->
<div class="modal fade" id="statusModal" tabindex="-1">
  <div class="modal-dialog">
    <form action="/branch/status" method="post">
      <input type="hidden" name="branchId" value="${branch.branchId}" />

      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">지점 상태 변경</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>

        <div class="modal-body">

          <div class="mb-3">
            <label class="form-label">변경할 상태</label>
            <select name="statusCode" class="form-select" required>
              <option value="">선택</option>
              <option value="BS001">운영중</option>
              <option value="BS002">폐점</option>
              <option value="BS003">영업중지</option>
            </select>
          </div>

          <div class="mb-3">
            <label class="form-label">변경 사유</label>
            <textarea name="reason"
                      class="form-control"
                      rows="3"
                      required></textarea>
          </div>

        </div>

        <div class="modal-footer">
          <button type="submit" class="btn btn-primary">변경</button>
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
        </div>
      </div>
    </form>
  </div>
</div>

<jsp:include page="../includes/admin_footer.jsp" />
