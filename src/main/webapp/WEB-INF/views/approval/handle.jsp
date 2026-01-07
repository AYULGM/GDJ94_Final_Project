<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>결재 처리</title>
</head>

<body>

<jsp:include page="../includes/admin_header.jsp" />

<div class="container my-4">

  <!-- =====================
       문서 기본 정보
       ===================== -->
  <div class="card mb-3">
    <div class="card-body">
      <h5 class="card-title mb-2">결재 처리</h5>
      <p class="mb-1">문서번호: <strong>${doc.docNo}</strong></p>
      <p class="mb-1">양식: ${doc.formCode}</p>
      <p class="mb-1">상태: ${doc.statusCode}</p>
      <p class="mb-0">기안자: ${doc.drafterName} (${doc.drafterBranchName})</p>
    </div>
  </div>

  <!-- =====================
       결재선
       ===================== -->
  <div class="card mb-3">
    <div class="card-body">
      <h6 class="card-title mb-2">결재선</h6>

      <table class="table table-sm align-middle mb-0">
        <thead>
          <tr>
            <th style="width:60px;">순번</th>
            <th style="width:120px;">구분</th>
            <th>결재자</th>
            <th style="width:120px;">상태</th>
            <th style="width:160px;">결재일</th>
          </tr>
        </thead>
        <tbody>
        <c:forEach var="l" items="${doc.lines}">
          <tr>
            <td>${l.lineNo}</td>
            <td>${l.role}</td>
            <td>${l.userName}</td>
            <td>${l.decisionCode}</td>
            <td>${l.decidedDate}</td>
          </tr>
        </c:forEach>
        </tbody>
      </table>
    </div>
  </div>

  <!-- =====================
       보고서 본문
       ===================== -->
  <div class="card mb-3">
    <div class="card-body">
      <h6 class="card-title mb-2">보고서 내용</h6>

      <div class="border rounded mb-3">
		  <iframe
		    src="${pageContext.request.contextPath}/approval/view?docVerId=${doc.docVerId}"
		    style="width:100%; height:1100px; border:0;">
		  </iframe>
		</div>

    </div>
  </div>

  <!-- =====================
       결재 처리
       ===================== -->
  <div class="card mb-4">
    <div class="card-body">
      <h6 class="card-title mb-2">결재 처리</h6>

      <form action="${pageContext.request.contextPath}/approval/handle" method="post">
        <input type="hidden" name="docVerId" value="${doc.docVerId}" />

        <div class="mb-3">
          <label class="form-label">코멘트</label>
          <textarea name="comment" class="form-control" rows="4"
                    placeholder="승인/반려 사유 또는 코멘트를 입력하세요."></textarea>
        </div>

        <div class="d-flex gap-2">
          <button class="btn btn-primary flex-fill" type="submit" name="action" value="APPROVE">
            승인
          </button>
          <button class="btn btn-danger flex-fill" type="submit" name="action" value="REJECT">
            반려
          </button>
          <a class="btn btn-outline-secondary flex-fill"
             href="${pageContext.request.contextPath}/approval/inbox">
            목록
          </a>
        </div>
      </form>
    </div>
  </div>

</div>

<jsp:include page="../includes/admin_footer.jsp" />

</body>
</html>
