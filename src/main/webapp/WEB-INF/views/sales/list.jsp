<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>

<jsp:include page="../includes/admin_header.jsp" />

<!-- 권한 정보를 JavaScript에서 사용하기 위한 숨김 필드 -->
<sec:authorize access="isAuthenticated()">
    <sec:authentication property="principal" var="loginUser"/>
    <input type="hidden" id="userBranchId" value="${loginUser.branchId}"/>
    <input type="hidden" id="isCaptain" value="${loginUser.captain}"/>
</sec:authorize>


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
                                <label class="form-label">카테고리</label>
                                <select class="form-select" id="categoryCode" name="categoryCode">
                                    <option value="">전체</option>
                                    <option value="MEMBERSHIP">회원권</option>
                                    <option value="PT">PT</option>
                                    <option value="GOODS">용품</option>
                                    <option value="ETC">기타</option>
                                </select>
                            </div>
                            <div class="col-md-2">
                                <label class="form-label">정산 여부</label>
                                <select class="form-select" id="settlementFlag" name="settlementFlag">
                                    <option value="">전체</option>
                                    <option value="true">정산됨</option>
                                    <option value="false">미정산</option>
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
                        <h3 class="card-title">매출 목록</h3>
                    </div>

                    <div class="card-body p-0">
                        <table class="table table-striped">
                            <thead>
                                <tr>
                                    <th style="width: 80px">번호</th>
                                    <th>지점</th>
                                    <th style="width: 120px">판매일시</th>
                                    <th>카테고리</th>
                                    <th class="text-end">금액</th>
                                    <th>내용</th>
                                    <th>담당자</th>
                                    <th style="width: 100px">정산여부</th>
                                    <th style="width: 80px">상세</th>
                                </tr>
                            </thead>
                            <tbody id="saleTableBody">
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

// 권한 정보 (hidden input에서 읽어옴)
const userPermissions = {
    branchId: document.getElementById('userBranchId')?.value || '0',
    isCaptain: document.getElementById('isCaptain')?.value === 'true'
};

// 페이지 로드
document.addEventListener('DOMContentLoaded', function() {
    // 지점 목록 로드
    loadBranchOptions();

    // 검색 폼 이벤트
    document.getElementById('searchForm').addEventListener('submit', function(e) {
        e.preventDefault();
        currentPage = 1;
        loadSaleList();
    });

    // 초기 데이터 로드
    loadSaleList();
});

// 지점 옵션 로드
async function loadBranchOptions() {
    const select = document.getElementById('branchId');
    if (!select) return;

    // 캡틴인 경우: 본인 지점만 선택 가능
    if (userPermissions.isCaptain && userPermissions.branchId && userPermissions.branchId !== '0') {
        try {
            const response = await fetch('/sales/api/options/branches');
            const branches = await response.json();

            select.innerHTML = '';
            const myBranch = branches.find(b => b && b.id && b.id.toString() === userPermissions.branchId);
            if (myBranch) {
                const option = document.createElement('option');
                option.value = myBranch.id;
                option.textContent = myBranch.name || '미지정';
                option.selected = true;
                select.appendChild(option);
            }
            select.disabled = true;
            select.classList.add('bg-light');
            select.title = '본인 소속 지점만 조회 가능합니다';
        } catch (error) {
            console.error('지점 목록 로드 실패:', error);
        }
        return;
    }

    // 관리자 이상: 전체 지점 선택 가능
    try {
        const response = await fetch('/sales/api/options/branches');
        const branches = await response.json();

        branches.filter(branch => branch != null && branch.id != null).forEach(branch => {
            const option = document.createElement('option');
            option.value = branch.id;
            option.textContent = branch.name || '미지정';
            select.appendChild(option);
        });
    } catch (error) {
        console.error('지점 목록 로드 실패:', error);
    }
}

// 매출 목록 로드
async function loadSaleList() {
    const formData = new FormData(document.getElementById('searchForm'));
    const params = new URLSearchParams(formData);
    params.append('page', currentPage);
    params.append('pageSize', pageSize);

    try {
        const response = await fetch('/sales/api/list?' + params.toString());
        const data = await response.json();

        renderSaleTable(data.list);
        renderPagination(data.currentPage, data.totalPages);
    } catch (error) {
        console.error('목록 로드 실패:', error);
        document.getElementById('saleTableBody').innerHTML =
            '<tr><td colspan="9" class="text-center text-danger">데이터를 불러오는데 실패했습니다.</td></tr>';
    }
}

// 테이블 렌더링
function renderSaleTable(list) {
    const tbody = document.getElementById('saleTableBody');

    if (!list || list.length === 0) {
        tbody.innerHTML = '<tr><td colspan="9" class="text-center">등록된 매출이 없습니다.</td></tr>';
        return;
    }

    tbody.innerHTML = list.map(sale =>
        '<tr>' +
            '<td>' + sale.saleId + '</td>' +
            '<td>' + (sale.branchName || '-') + '</td>' +
            '<td>' + formatDateTime(sale.soldAt) + '</td>' +
            '<td>' + getCategoryName(sale.categoryCode) + '</td>' +
            '<td class="text-end">' + formatCurrency(sale.totalAmount) + '</td>' +
            '<td>' + (sale.memo || '-') + '</td>' +
            '<td>' + (sale.createUserName || '-') + '</td>' +
            '<td>' +
                '<span class="badge ' + (sale.settled ? 'bg-success' : 'bg-warning') + '">' +
                    (sale.settled ? '정산됨' : '미정산') +
                '</span>' +
            '</td>' +
            '<td>' +
                '<a href="/sales/' + sale.saleId + '" class="btn btn-sm btn-info">' +
                    '<i class="bi bi-eye"></i>' +
                '</a>' +
            '</td>' +
        '</tr>'
    ).join('');
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
        html += '<li class="page-item"><a class="page-link" href="#" onclick="goToPage(' + (current - 1) + '); return false;">«</a></li>';
    }

    // 페이지 번호
    const startPage = Math.max(1, current - 2);
    const endPage = Math.min(total, current + 2);

    for (let i = startPage; i <= endPage; i++) {
        html += '<li class="page-item ' + (i === current ? 'active' : '') + '">' +
            '<a class="page-link" href="#" onclick="goToPage(' + i + '); return false;">' + i + '</a>' +
        '</li>';
    }

    // 다음 버튼
    if (current < total) {
        html += '<li class="page-item"><a class="page-link" href="#" onclick="goToPage(' + (current + 1) + '); return false;">»</a></li>';
    }

    pagination.innerHTML = html;
}

// 페이지 이동
function goToPage(page) {
    currentPage = page;
    loadSaleList();
}

// 카테고리 이름
function getCategoryName(code) {
    const categories = {
        'MEMBERSHIP': '회원권',
        'PT': 'PT',
        'GOODS': '용품',
        'ETC': '기타'
    };
    return categories[code] || code;
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

// 날짜/시간 포맷
function formatDateTime(dateString) {
    if (!dateString) return '-';
    const date = new Date(dateString);
    if (isNaN(date.getTime())) { // Check if date is valid
        return '-'; // Return '-' for invalid dates
    }
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
