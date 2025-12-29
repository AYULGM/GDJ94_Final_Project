<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
	<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<jsp:include page="../includes/admin_header.jsp" />

<!-- Main content for notice list -->
<div class="row">
    <div class="col-12">
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">공지사항 목록</h3>
            </div>
            <div class="card-body">
                <p>이곳에 공지사항 목록 테이블이 표시됩니다.</p>
                <!-- Example Table -->
                <table class="table table-bordered">
                    <thead>
                        <tr>
                            <th style="width: 10px">#</th>
                            <th>제목</th>
                            <th>작성자</th>
                            <th>작성일</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>1.</td>
                            <td>서버 점검 안내</td>
                            <td>관리자</td>
                            <td>2025-12-24</td>
                        </tr>
                        <tr>
                            <td>2.</td>
                            <td>신규 기능 업데이트</td>
                            <td>관리자</td>
                            <td>2025-12-23</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../includes/admin_footer.jsp" />
