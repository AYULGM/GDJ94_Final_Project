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
    
        <style>
            /* 요약 카드 스타일 (대시보드와 유사하게) */
            .summary-card .small-box {
                height: 140px;
                margin-bottom: 1rem;
            }
            .summary-card .small-box .inner {
                padding: 10px;
            }
            .summary-card .small-box .inner h3 {
                font-size: 2.2rem;
                font-weight: bold;
            }
            .summary-card .small-box .inner p {
                font-size: 1rem;
            }
            .summary-card .small-box .inner small {
                font-size: 0.8rem;
            }
        </style>

        <!-- 필터 영역 -->
        <div class="row mb-4">
            <div class="col-12">
                <div class="card">
                    <div class="card-body">
                        <form id="filterForm" class="row g-3">
                            <div class="col-md-3">
                                <label for="branchId" class="form-label">지점 <span class="text-danger">*</span></label>
                                <select class="form-select" id="branchId" name="branchId" required>
                                    <option value="0" selected>전체</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label for="startDate" class="form-label">시작일 <span class="text-danger">*</span></label>
                                <input type="date" class="form-control" id="startDate" name="startDate" required>
                            </div>
                            <div class="col-md-3">
                                <label for="endDate" class="form-label">종료일 <span class="text-danger">*</span></label>
                                <input type="date" class="form-control" id="endDate" name="endDate" required>
                            </div>
                            <div class="col-md-3 d-flex align-items-end">
                                <button type="submit" class="btn btn-primary w-100">
                                    <i class="bi bi-search"></i> 조회
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <!-- 요약 정보 -->
        <div class="row mb-4" id="summarySection" style="display: none;">
            <!-- 총 매출 -->
            <div class="col-md-4 summary-card">
                <div class="small-box text-bg-primary">
                    <div class="inner">
                        <h3 id="totalSales">0원</h3>
                        <p>총 매출</p>
                        <small id="salesCount">0건</small>
                    </div>
                </div>
            </div>
            <!-- 총 지출 -->
            <div class="col-md-4 summary-card">
                <div class="small-box text-bg-danger">
                    <div class="inner">
                        <h3 id="totalExpenses">0원</h3>
                        <p>총 지출</p>
                        <small id="expensesCount">0건</small>
                    </div>
                </div>
            </div>
            <!-- 추정 손익 -->
            <div class="col-md-4 summary-card">
                <div class="small-box text-bg-success">
                    <div class="inner">
                        <h3 id="totalProfit">0원</h3>
                        <p>추정 손익</p>
                        <small style="visibility: hidden;">0건</small>
                    </div>
                </div>
            </div>
        </div>

        <!-- 정산 대상 매출 목록 -->
        <div class="row">
            <div class="col-12">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">정산 대상 매출 목록</h3>
                    </div>

                    <div class="card-body p-0">
                        <table class="table table-striped table-sm">
                            <thead>
                                <tr>
                                    <th style="width: 60px">번호</th>
                                    <th>매출번호</th>
                                    <th>지점</th>
                                    <th>판매일시</th>
                                    <th>카테고리</th>
                                    <th class="text-end">금액</th>
                                    <th style="width: 80px">상태</th>
                                    <th style="width: 100px">정산여부</th>
                                </tr>
                            </thead>
                            <tbody id="salesTableBody">
                                <tr>
                                    <td colspan="8" class="text-center text-muted">조회 조건을 입력하고 조회 버튼을 눌러주세요.</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

    </div>
</div>

<jsp:include page="../includes/admin_footer.jsp" />

<script>
let currentSalesData = [];
let currentExpensesData = [];

// 권한 정보 (hidden input에서 읽어옴)
const userPermissions = {
    branchId: document.getElementById('userBranchId')?.value || '0',
    isCaptain: document.getElementById('isCaptain')?.value === 'true'
};

// 페이지 로드
document.addEventListener('DOMContentLoaded', async function() {
    // 기본 날짜 설정 (이번 달)
    const today = new Date();
    const firstDay = new Date(today.getFullYear(), today.getMonth(), 1);
    document.getElementById('startDate').value = formatDate(firstDay);
    document.getElementById('endDate').value = formatDate(today);

    // 지점 목록 로드 - await로 완료 대기
    await loadBranchOptions();

    // 초기 데이터 로드
    loadUnsettledSales();

    // 폼 제출 이벤트
    document.getElementById('filterForm').addEventListener('submit', function(e) {
        e.preventDefault();
        loadUnsettledSales();
    });
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

// 정산 대상 매출 조회
async function loadUnsettledSales() {
    const formData = new FormData(document.getElementById('filterForm'));
    const params = new URLSearchParams(formData);

    try {
        const tbody = document.getElementById('salesTableBody');
        tbody.innerHTML = '<tr><td colspan="8" class="text-center"><div class="spinner-border spinner-border-sm"></div></td></tr>';

        const response = await fetch('/statistics/api/unsettled-sales?' + params.toString());
        currentSalesData = await response.json();

        // 지출 데이터도 조회 (손익 계산용)
        const expensesResponse = await fetch(`/statistics/api/expenses/by-period?${params.toString()}&groupBy=monthly`);
        currentExpensesData = await expensesResponse.json();

        renderSalesTable(currentSalesData);
        updateSummary(currentSalesData, currentExpensesData);

        document.getElementById('summarySection').style.display = 'flex';

    } catch (error) {
        console.error('데이터 로드 실패:', error);
        document.getElementById('salesTableBody').innerHTML =
            '<tr><td colspan="8" class="text-center text-danger">데이터를 불러오는데 실패했습니다.</td></tr>';
    }
}

// 테이블 렌더링
function renderSalesTable(sales) {
    const tbody = document.getElementById('salesTableBody');

    if (!sales || sales.length === 0) {
        tbody.innerHTML = '<tr><td colspan="8" class="text-center">정산 대상 매출이 없습니다.</td></tr>';
        return;
    }

    tbody.innerHTML = sales.map(sale =>
        '<tr>' +
            '<td>' + sale.saleId + '</td>' +
            '<td>' + (sale.saleNo || '-') + '</td>' +
            '<td>' + (sale.branchName || '-') + '</td>' +
            '<td>' + formatDateTime(sale.soldAt) + '</td>' +
            '<td>' + getCategoryName(sale.categoryCode) + '</td>' +
            '<td class="text-end">' + formatCurrency(sale.totalAmount || 0) + '</td>' +
            '<td>' +
                '<span class="badge ' + getStatusBadgeClass(sale.statusCode) + '">' +
                    getStatusName(sale.statusCode) +
                '</span>' +
            '</td>' +
            '<td>' +
                '<span class="badge ' + (sale.settled ? 'bg-secondary' : 'bg-warning') + '">' +
                    (sale.settled ? '정산됨' : '미정산') +
                '</span>' +
            '</td>' +
        '</tr>'
    ).join('');
}

// 요약 정보 업데이트
function updateSummary(sales, expenses) {
    const totalSalesAmount = sales.reduce((sum, sale) => sum + (sale.totalAmount || 0), 0);
    const totalExpensesAmount = expenses.reduce((sum, expense) => sum + (expense.totalAmount || 0), 0);
    const totalProfit = totalSalesAmount - totalExpensesAmount;

    document.getElementById('totalSales').textContent = formatCurrency(totalSalesAmount);
    document.getElementById('salesCount').textContent = sales.length + '건';

    document.getElementById('totalExpenses').textContent = formatCurrency(totalExpensesAmount);
    document.getElementById('expensesCount').textContent = expenses.reduce((sum, e) => sum + (e.expenseCount || 0), 0) + '건';

    const profitElement = document.getElementById('totalProfit');
    profitElement.textContent = formatCurrency(totalProfit);
    profitElement.parentElement.parentElement.className = totalProfit >= 0 ? 'small-box text-bg-success' : 'small-box text-bg-danger';
}

// 정산 생성
async function createSettlement() {
    if (currentSalesData.length === 0) {
        alert('정산 대상 매출이 없습니다.');
        return;
    }

    if (!confirm('정산을 생성하시겠습니까?')) {
        return;
    }

    const requestData = {
        branchId: parseInt(document.getElementById('branchId').value) || null,
        fromDate: document.getElementById('startDate').value,
        toDate: document.getElementById('endDate').value
    };

    try {
        const response = await fetch('/settlements/api', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(requestData)
        });

        if (response.ok) {
            const result = await response.json();
            alert(result.message);
            window.location.href = `/settlements/${result.settlementId}`;
        } else {
            throw new Error('정산 생성 실패');
        }
    } catch (error) {
        console.error('정산 생성 실패:', error);
        alert('정산 생성에 실패했습니다.');
    }
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

// 날짜 포맷
function formatDate(date) {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
}

// 날짜/시간 포맷
function formatDateTime(dateString) {
    if (!dateString) return '-';
    const date = new Date(dateString);
    return date.toLocaleString('ko-KR');
}

// 금액 포맷
function formatCurrency(value) {
    return new Intl.NumberFormat('ko-KR', {
        style: 'currency',
        currency: 'KRW'
    }).format(value);
}
</script>
