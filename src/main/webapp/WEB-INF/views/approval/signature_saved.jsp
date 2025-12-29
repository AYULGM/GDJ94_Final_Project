<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
	<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<jsp:include page="../includes/admin_header.jsp" />

<!-- Main content for approval list -->
<div class="row">
    <div class="col-12">
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">결재 문서 목록/// 조건으로 임심 저장도 같이 만들기</h3>
            </div>
            <div class="card-body">
                <p>이곳에 결재 문서 목록 테이블이 표시됩니다.</p>
                <!-- Example Table -->
                <table class="table table-bordered">
                    <thead>
                        <tr>
                            <th style="width: 10px">#</th>
                            <th>문서 제목</th>
                            <th>기안자</th>
                            <th>상태</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>1.</td>
                            <td>[품의] 2026년 워크샵 장소 선정</td>
                            <td>김대리</td>
                            <td><span class="badge bg-warning">진행중</span></td>
                        </tr>
                        <tr>
                            <td>2.</td>
                            <td>[휴가] 2025-12-29</td>
                            <td>이주임</td>
                            <td><span class="badge bg-success">승인</span></td>
                        </tr>
                        <tr>
                            <td>3.</td>
                            <td>[지출] 사무용품 구매</td>
                            <td>박사원</td>
                            <td><span class="badge bg-danger">반려</span></td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../includes/admin_footer.jsp" />
