<%@ page contentType="text/html; charset=UTF-8" %>
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
        <a href="/branch/edit?branchId=${branch.branchId}"
           class="btn btn-primary">수정</a>
      </div>
    </div>
  </div>
</div>

<jsp:include page="../includes/admin_footer.jsp" />
