<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<jsp:include page="../includes/admin_header.jsp" />

<div class="row">
  <div class="col-12">
    <div class="card">
      <div class="card-header">
        <h3 class="card-title">지점 상세 정보</h3>
      </div>

      <div class="card-body">
        <table class="table table-bordered">
          <tr>
            <th>지점명</th>
            <td>${branch.branchName}</td>
          </tr>
          <tr>
            <th>주소</th>
            <td>
              (${branch.postNo}) ${branch.baseAddress} ${branch.detailAddress}
            </td>
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
            <td>${branch.statusCode}</td>
          </tr>
        </table>
      </div>

      <div class="card-footer">
         <a href="/branch/list" class="btn btn-secondary">목록</a>
<%--         <c:if test="${loginUser.roleCode eq 'RL001' || loginUser.roleCode eq 'RL002' || loginUser.roleCode eq 'RL003'}"> --%>	 	    
			<a href="/branch/update?branchId=${branch.branchId}"
		       class="btn btn-warning">
		        수정
		    </a>
		    
	        <button type="button"
		            class="btn btn-warning"
		            data-bs-toggle="modal"
		            data-bs-target="#statusModal">
		        상태 변경
		    </button>
<%-- 		</c:if>--%>      
		</div>
    </div>
  </div>
</div>

<!-- 지점 상태변경 모달 창 -->
<div class="modal fade" id="statusModal" tabindex="-1">
  <div class="modal-dialog">
    <form action="/branch/status" method="post">
      <input type="hidden" name="branchId" value="${branch.branchId}"/>

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
              <option value="BS003">영업중지</option>
              <option value="BS002">폐점</option>
            </select>
          </div>

          <div class="mb-3">
            <label class="form-label">변경 사유</label>
            <textarea name="reason"
                      class="form-control"
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
