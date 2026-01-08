<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<jsp:include page="../includes/admin_header.jsp" />

<!-- Main content -->
<div class="app-content-header">
    <div class="container-fluid">
        <div class="row">
            <div class="col-sm-6">
                <h3 class="mb-0">정산 내역 조회</h3>
            </div>
            <div class="col-sm-6">
                <ol class="breadcrumb float-sm-end">
                    <li class="breadcrumb-item"><a href="<c:url value='/'/>">Home</a></li>
                    <li class="breadcrumb-item active">정산 내역 조회</li>
                </ol>
            </div>
        </div>
    </div>
</div>

<div class="app-content">
    <div class="container-fluid">

        <!-- 검색 필터 -->
        <div class="row mb-3">
            <div class="col-12">
                <div class="card">
                    <div class="card-body">
                        <form id="searchForm" class="row g-3">
                            <div class="col-md-2">
                                <label class="form-label">지점</label>
                                <select class="form-select" id="branchId" name="branchId">
                                    <option value="0">전체</option>
                                </select>
                            </div>
                            <div class="col-md-2">
                                <label class="form-label">상태</label>
                                <select class="form-select" id="statusCode" name="statusCode">
                                    <option value="">전체</option>
                                    <option value="PENDING">대기</option>
                                    <option value="CONFIRMED">확정</option>
                                    <option value="CANCELLED">취소</option>
                                </select>
                            </div>
                            <div class="col-md-2">
                                <label class="form-label">시작일</label>
                                <input type="date" class="form-control" id="startDate" name="startDate">
                            </div>
                            <div class="col-md-2">
                                <label class="form-label">종료일</label>
                                <input type="date" class="form-control" id="endDate" name="endDate">
                            </div>
                            <div class="col-md-2 d-flex align-items-end">
                                <button type="submit" class="btn btn-primary w-100">
                                    <i class="bi bi-search"></i> 검색
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <!-- 목록 -->
        <div class="row">
            <div class="col-12">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">정산 목록</h3>
                    </div>

                    <div class="card-body p-0">
                        <table class="table table-striped">
                            <thead>
                                <tr>
                                    <th style="width: 80px">번호</th>
                                    <th>정산번호</th>
                                    <th>지점</th>
                                    <th>정산기간</th>
                                    <th class="text-end">매출</th>
                                    <th class="text-end">지출</th>
                                    <th class="text-end">손익</th>
                                    <th style="width: 100px">상태</th>
                                    <th style="width: 80px">상세</th>
                                </tr>
                            </thead>
                            <tbody id="settlementTableBody">
                                <tr>
                                    <td colspan="9" class="text-center">
                                        <div class="spinner-border" role="status">
                                            <span class="visually-hidden">Loading...</span>
                                        </div>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                    <!-- 페이징 -->
                    <div class="card-footer clearfix">
                        <ul class="pagination pagination-sm m-0 float-end" id="pagination">
                        </ul>
                    </div>
                </div>
            </div>
        </div>

    </div>
</div>

<jsp:include page="../includes/admin_footer.jsp" />

<script>
let currentPage = 1;
const pageSize = 10;

// 페이지 로드
document.addEventListener('DOMContentLoaded', function() {
    // 지점 목록 로드
    loadBranchOptions();

    // 검색 폼 이벤트
    document.getElementById('searchForm').addEventListener('submit', function(e) {
        e.preventDefault();
        currentPage = 1;
        loadSettlementList();
    });

    // 초기 데이터 로드
    loadSettlementList();
});

// 지점 옵션 로드
async function loadBranchOptions() {
    try {
        const response = await fetch('/sales/api/options/branches');
        const branches = await response.json();

        const select = document.getElementById('branchId');
        branches.forEach(branch => {
            const option = document.createElement('option');
            option.value = branch.value;
            option.textContent = branch.label;
            select.appendChild(option);
        });
    } catch (error) {
        console.error('지점 목록 로드 실패:', error);
    }
}

// 정산 목록 로드
async function loadSettlementList() {
    const formData = new FormData(document.getElementById('searchForm'));
    const params = new URLSearchParams(formData);
    params.append('page', currentPage);
    params.append('pageSize', pageSize);

    try {
        const response = await fetch('/settlements/api/list?' + params.toString());
        const data = await response.json();

        renderSettlementTable(data.list);
        renderPagination(data.currentPage, data.totalPages);
    } catch (error) {
        console.error('목록 로드 실패:', error);
        document.getElementById('settlementTableBody').innerHTML =
            '<tr><td colspan="9" class="text-center text-danger">데이터를 불러오는데 실패했습니다.</td></tr>';
    }
}

// 테이블 렌더링
function renderSettlementTable(list) {
    const tbody = document.getElementById('settlementTableBody');

    if (!list || list.length === 0) {
        tbody.innerHTML = '<tr><td colspan="9" class="text-center">등록된 정산이 없습니다.</td></tr>';
        return;
    }

    tbody.innerHTML = list.map(settlement => {
        const profitClass = (settlement.profitAmount || 0) >= 0 ? 'text-success' : 'text-danger';

        return '<tr>' +
            '<td>' + settlement.settlementId + '</td>' +
            '<td>' + (settlement.settlementNo || '-') + '</td>' +
            '<td>' + (settlement.branchName || '-') + '</td>' +
            '<td>' + formatDate(settlement.fromDate) + ' ~ ' + formatDate(settlement.toDate) + '</td>' +
            '<td class="text-end">' + formatCurrency(settlement.salesAmount || 0) + '</td>' +
            '<td class="text-end">' + formatCurrency(settlement.expenseAmount || 0) + '</td>' +
            '<td class="text-end ' + profitClass + '">' + formatCurrency(settlement.profitAmount || 0) + '</td>' +
            '<td>' +
                '<span class="badge ' + getStatusBadgeClass(settlement.statusCode) + '">' +
                    getStatusName(settlement.statusCode) +
                '</span>' +
            '</td>' +
            '<td>' +
                '<a href="/settlements/' + settlement.settlementId + '" class="btn btn-sm btn-info">' +
                    '<i class="bi bi-eye"></i>' +
                '</a>' +
            '</td>' +
        '</tr>';
    }).join('');
}

// 페이징 렌더링
function renderPagination(current, total) {
    const pagination = document.getElementById('pagination');

    if (total <= 1) {
        pagination.innerHTML = '';
        return;
    }

    let html = '';

    // 이전 버튼
    if (current > 1) {
        html += `<li class="page-item"><a class="page-link" href="#" onclick="goToPage(${current - 1}); return false;">«</a></li>`;
    }

    // 페이지 번호
    const startPage = Math.max(1, current - 2);
    const endPage = Math.min(total, current + 2);

    for (let i = startPage; i <= endPage; i++) {
        html += `<li class="page-item ${i === current ? 'active' : ''}">
            <a class="page-link" href="#" onclick="goToPage(${i}); return false;">${i}</a>
        </li>`;
    }

    // 다음 버튼
    if (current < total) {
        html += `<li class="page-item"><a class="page-link" href="#" onclick="goToPage(${current + 1}); return false;">»</a></li>`;
    }

    pagination.innerHTML = html;
}

// 페이지 이동
function goToPage(page) {
    currentPage = page;
    loadSettlementList();
}

// 상태 이름
function getStatusName(code) {
    const statuses = {
        'PENDING': '대기',
        'CONFIRMED': '확정',
        'CANCELLED': '취소'
    };
    return statuses[code] || code;
}

// 상태 뱃지 클래스
function getStatusBadgeClass(code) {
    const classes = {
        'PENDING': 'bg-warning',
        'CONFIRMED': 'bg-success',
        'CANCELLED': 'bg-secondary'
    };
    return classes[code] || 'bg-secondary';
}

// 날짜 포맷
function formatDate(dateString) {
    if (!dateString) return '-';
    const date = new Date(dateString);
    return date.toLocaleDateString('ko-KR');
}

// 금액 포맷
function formatCurrency(value) {
    return new Intl.NumberFormat('ko-KR', {
        style: 'currency',
        currency: 'KRW'
    }).format(value);
}
</script>
