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
            <!-- 미정산 매출 -->
            <div class="col-md-4 summary-card">
                <div class="small-box text-bg-primary">
                    <div class="inner">
                        <h3 id="totalSales">0원</h3>
                        <p>미정산 매출</p>
                        <small id="salesCount">0건</small>
                    </div>
                </div>
            </div>
            <!-- 미정산 지출 -->
            <div class="col-md-4 summary-card">
                <div class="small-box text-bg-danger">
                    <div class="inner">
                        <h3 id="totalExpenses">0원</h3>
                        <p>미정산 지출</p>
                        <small id="expensesCount">0건</small>
                    </div>
                </div>
            </div>
            <!-- 미정산 손익 -->
            <div class="col-md-4 summary-card">
                <div class="small-box text-bg-success">
                    <div class="inner">
                        <h3 id="totalProfit">0원</h3>
                        <p>미정산 손익</p>
                        <small style="visibility: hidden;">0건</small>
                    </div>
                </div>
            </div>
        </div>

        <!-- 정산 대상 매출 목록 -->
        <div class="row mb-4">
            <div class="col-12">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">매출 목록</h3>
                        <div class="card-tools">
                            <span class="badge bg-primary" id="salesTotalCount">0건</span>
                        </div>
                    </div>

                    <div class="card-body p-0">
                        <table class="table table-striped table-sm table-hover">
                            <thead>
                                <tr>
                                    <th style="width: 40px"><input type="checkbox" id="salesCheckAll" class="form-check-input"></th>
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
                                    <td colspan="9" class="text-center text-muted">조회 조건을 입력하고 조회 버튼을 눌러주세요.</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <div class="card-footer clearfix">
                        <ul class="pagination pagination-sm m-0 float-end" id="salesPagination"></ul>
                    </div>
                </div>
            </div>
        </div>

        <!-- 정산 대상 지출 목록 -->
        <div class="row mb-4">
            <div class="col-12">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">지출 목록</h3>
                        <div class="card-tools">
                            <span class="badge bg-danger" id="expensesTotalCount">0건</span>
                        </div>
                    </div>

                    <div class="card-body p-0">
                        <table class="table table-striped table-sm table-hover">
                            <thead>
                                <tr>
                                    <th style="width: 40px"><input type="checkbox" id="expensesCheckAll" class="form-check-input"></th>
                                    <th style="width: 60px">번호</th>
                                    <th>지점</th>
                                    <th>지출일시</th>
                                    <th>카테고리</th>
                                    <th>내용</th>
                                    <th class="text-end">금액</th>
                                    <th style="width: 100px">정산여부</th>
                                </tr>
                            </thead>
                            <tbody id="expensesTableBody">
                                <tr>
                                    <td colspan="8" class="text-center text-muted">조회 조건을 입력하고 조회 버튼을 눌러주세요.</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <div class="card-footer clearfix">
                        <ul class="pagination pagination-sm m-0 float-end" id="expensesPagination"></ul>
                    </div>
                </div>
            </div>
        </div>

        <!-- 정산 버튼 영역 -->
        <div class="row">
            <div class="col-12 text-end">
                <span id="selectedInfo" class="me-3 text-muted" style="display: none;">
                    선택: 매출 <strong id="selectedSalesCount">0</strong>건, 지출 <strong id="selectedExpensesCount">0</strong>건
                    (합계: <strong id="selectedTotalAmount">₩0</strong>)
                </span>
                <button type="button" class="btn btn-primary btn-lg me-2" id="btnSelectedSettlement" style="display: none;">
                    <i class="bi bi-check2-square"></i> 선택 정산
                </button>
                <button type="button" class="btn btn-success btn-lg" id="btnCreateSettlement" style="display: none;">
                    <i class="bi bi-check-circle"></i> 전체 정산
                </button>
            </div>
        </div>

    </div>
</div>

<!-- 매출 상세 모달 -->
<div class="modal fade" id="saleDetailModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="bi bi-receipt"></i> 매출 상세</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="modalSaleId">
                <table class="table table-bordered">
                    <tr>
                        <th style="width: 120px; background: #f8f9fa;">매출번호</th>
                        <td id="modalSaleNo"></td>
                        <th style="width: 120px; background: #f8f9fa;">지점</th>
                        <td id="modalSaleBranch"></td>
                    </tr>
                    <tr>
                        <th style="background: #f8f9fa;">판매일시</th>
                        <td id="modalSaleDate"></td>
                        <th style="background: #f8f9fa;">카테고리</th>
                        <td id="modalSaleCategory"></td>
                    </tr>
                    <tr>
                        <th style="background: #f8f9fa;">금액</th>
                        <td id="modalSaleAmount" class="text-primary fw-bold"></td>
                        <th style="background: #f8f9fa;">상태</th>
                        <td id="modalSaleStatus"></td>
                    </tr>
                    <tr>
                        <th style="background: #f8f9fa;">정산여부</th>
                        <td colspan="3" id="modalSaleSettled"></td>
                    </tr>
                </table>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">닫기</button>
                <button type="button" class="btn btn-success" id="btnSettleSale" style="display: none;">
                    <i class="bi bi-check-circle"></i> 개별 정산
                </button>
            </div>
        </div>
    </div>
</div>

<!-- 지출 상세 모달 -->
<div class="modal fade" id="expenseDetailModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="bi bi-cash-stack"></i> 지출 상세</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="modalExpenseId">
                <table class="table table-bordered">
                    <tr>
                        <th style="width: 120px; background: #f8f9fa;">지출번호</th>
                        <td id="modalExpenseNo"></td>
                        <th style="width: 120px; background: #f8f9fa;">지점</th>
                        <td id="modalExpenseBranch"></td>
                    </tr>
                    <tr>
                        <th style="background: #f8f9fa;">지출일시</th>
                        <td id="modalExpenseDate"></td>
                        <th style="background: #f8f9fa;">카테고리</th>
                        <td id="modalExpenseCategory"></td>
                    </tr>
                    <tr>
                        <th style="background: #f8f9fa;">금액</th>
                        <td id="modalExpenseAmount" class="text-danger fw-bold"></td>
                        <th style="background: #f8f9fa;">정산여부</th>
                        <td id="modalExpenseSettled"></td>
                    </tr>
                    <tr>
                        <th style="background: #f8f9fa;">내용</th>
                        <td colspan="3" id="modalExpenseDescription"></td>
                    </tr>
                </table>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">닫기</button>
                <button type="button" class="btn btn-success" id="btnSettleExpense" style="display: none;">
                    <i class="bi bi-check-circle"></i> 개별 정산
                </button>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../includes/admin_footer.jsp" />

<script>
let currentSalesData = [];
let currentExpensesData = [];
let salesPage = 1;
let expensesPage = 1;
const pageSize = 10;

// 선택된 항목 관리
let selectedSales = new Set();
let selectedExpenses = new Set();

// 모달 인스턴스
let saleDetailModal;
let expenseDetailModal;

// 권한 정보 (hidden input에서 읽어옴)
const userPermissions = {
    branchId: document.getElementById('userBranchId')?.value || '0',
    isCaptain: document.getElementById('isCaptain')?.value === 'true'
};

// 페이지 로드
document.addEventListener('DOMContentLoaded', async function() {
    // 모달 초기화
    saleDetailModal = new bootstrap.Modal(document.getElementById('saleDetailModal'));
    expenseDetailModal = new bootstrap.Modal(document.getElementById('expenseDetailModal'));

    // 기본 날짜 설정 (이번 달)
    const today = new Date();
    const firstDay = new Date(today.getFullYear(), today.getMonth(), 1);
    document.getElementById('startDate').value = formatDate(firstDay);
    document.getElementById('endDate').value = formatDate(today);

    // 지점 목록 로드 - await로 완료 대기
    await loadBranchOptions();

    // 초기 데이터 로드
    loadData();

    // 폼 제출 이벤트
    document.getElementById('filterForm').addEventListener('submit', function(e) {
        e.preventDefault();
        salesPage = 1;
        expensesPage = 1;
        selectedSales.clear();
        selectedExpenses.clear();
        loadData();
    });

    // 전체 정산 버튼 이벤트
    document.getElementById('btnCreateSettlement').addEventListener('click', createSettlement);

    // 선택 정산 버튼 이벤트
    document.getElementById('btnSelectedSettlement').addEventListener('click', createSelectedSettlement);

    // 개별 정산 버튼 이벤트
    document.getElementById('btnSettleSale').addEventListener('click', settleSingleSale);
    document.getElementById('btnSettleExpense').addEventListener('click', settleSingleExpense);

    // 전체 선택 체크박스 이벤트
    document.getElementById('salesCheckAll').addEventListener('change', function() {
        toggleAllSales(this.checked);
    });
    document.getElementById('expensesCheckAll').addEventListener('change', function() {
        toggleAllExpenses(this.checked);
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

// 데이터 로드 (매출 + 지출)
async function loadData() {
    const formData = new FormData(document.getElementById('filterForm'));
    const params = new URLSearchParams(formData);

    // 로딩 표시
    document.getElementById('salesTableBody').innerHTML = '<tr><td colspan="8" class="text-center"><div class="spinner-border spinner-border-sm"></div></td></tr>';
    document.getElementById('expensesTableBody').innerHTML = '<tr><td colspan="7" class="text-center"><div class="spinner-border spinner-border-sm"></div></td></tr>';

    try {
        // 매출 데이터 조회
        const salesResponse = await fetch('/statistics/api/unsettled-sales?' + params.toString());
        currentSalesData = await salesResponse.json();

        // 지출 데이터 조회
        const expensesResponse = await fetch('/statistics/api/unsettled-expenses?' + params.toString());
        currentExpensesData = await expensesResponse.json();

        // 테이블 렌더링
        renderSalesTable();
        renderExpensesTable();

        // 요약 정보 업데이트
        updateSummary();

        // 요약 섹션 및 정산 생성 버튼 표시
        document.getElementById('summarySection').style.display = 'flex';
        document.getElementById('btnCreateSettlement').style.display = 'inline-block';

    } catch (error) {
        console.error('데이터 로드 실패:', error);
        document.getElementById('salesTableBody').innerHTML = '<tr><td colspan="8" class="text-center text-danger">데이터를 불러오는데 실패했습니다.</td></tr>';
        document.getElementById('expensesTableBody').innerHTML = '<tr><td colspan="7" class="text-center text-danger">데이터를 불러오는데 실패했습니다.</td></tr>';
    }
}

// 매출 테이블 렌더링
function renderSalesTable() {
    const tbody = document.getElementById('salesTableBody');
    const totalCount = currentSalesData.length;

    document.getElementById('salesTotalCount').textContent = totalCount + '건';

    if (totalCount === 0) {
        tbody.innerHTML = '<tr><td colspan="9" class="text-center">매출 데이터가 없습니다.</td></tr>';
        document.getElementById('salesPagination').innerHTML = '';
        return;
    }

    // 페이징 처리
    const startIdx = (salesPage - 1) * pageSize;
    const endIdx = Math.min(startIdx + pageSize, totalCount);
    const pageData = currentSalesData.slice(startIdx, endIdx);

    tbody.innerHTML = pageData.map(sale => {
        const isChecked = selectedSales.has(sale.saleId);
        const isSettled = sale.settled;
        return '<tr class="' + (isSettled ? 'table-secondary' : '') + '" style="cursor: pointer;">' +
            '<td onclick="event.stopPropagation();">' +
                '<input type="checkbox" class="form-check-input sale-checkbox" data-id="' + sale.saleId + '" ' +
                (isChecked ? 'checked' : '') + ' ' + (isSettled ? 'disabled' : '') + '>' +
            '</td>' +
            '<td class="sale-row" data-id="' + sale.saleId + '">' + sale.saleId + '</td>' +
            '<td class="sale-row" data-id="' + sale.saleId + '">' + (sale.saleNo || '-') + '</td>' +
            '<td class="sale-row" data-id="' + sale.saleId + '">' + (sale.branchName || '-') + '</td>' +
            '<td class="sale-row" data-id="' + sale.saleId + '">' + formatDateTime(sale.soldAt) + '</td>' +
            '<td class="sale-row" data-id="' + sale.saleId + '">' + getCategoryName(sale.categoryCode) + '</td>' +
            '<td class="sale-row text-end" data-id="' + sale.saleId + '">' + formatCurrency(sale.totalAmount || 0) + '</td>' +
            '<td class="sale-row" data-id="' + sale.saleId + '"><span class="badge ' + getStatusBadgeClass(sale.statusCode) + '">' + getStatusName(sale.statusCode) + '</span></td>' +
            '<td class="sale-row" data-id="' + sale.saleId + '"><span class="badge ' + (isSettled ? 'bg-secondary' : 'bg-warning') + '">' + (isSettled ? '정산됨' : '미정산') + '</span></td>' +
        '</tr>';
    }).join('');

    // 체크박스 이벤트 바인딩
    tbody.querySelectorAll('.sale-checkbox').forEach(function(checkbox) {
        checkbox.addEventListener('change', function() {
            const saleId = parseInt(this.dataset.id);
            if (this.checked) {
                selectedSales.add(saleId);
            } else {
                selectedSales.delete(saleId);
            }
            updateSelectedInfo();
        });
    });

    // 행 클릭 이벤트 바인딩
    tbody.querySelectorAll('.sale-row').forEach(function(cell) {
        cell.addEventListener('click', function() {
            const saleId = parseInt(this.dataset.id);
            openSaleDetailModal(saleId);
        });
    });

    // 페이지네이션 렌더링
    renderPagination('salesPagination', totalCount, salesPage, function(page) {
        salesPage = page;
        renderSalesTable();
    });

    // 전체 선택 체크박스 상태 업데이트
    updateSalesCheckAll();
}

// 지출 테이블 렌더링
function renderExpensesTable() {
    const tbody = document.getElementById('expensesTableBody');
    const totalCount = currentExpensesData.length;

    document.getElementById('expensesTotalCount').textContent = totalCount + '건';

    if (totalCount === 0) {
        tbody.innerHTML = '<tr><td colspan="8" class="text-center">지출 데이터가 없습니다.</td></tr>';
        document.getElementById('expensesPagination').innerHTML = '';
        return;
    }

    // 페이징 처리
    const startIdx = (expensesPage - 1) * pageSize;
    const endIdx = Math.min(startIdx + pageSize, totalCount);
    const pageData = currentExpensesData.slice(startIdx, endIdx);

    tbody.innerHTML = pageData.map(expense => {
        const isChecked = selectedExpenses.has(expense.expenseId);
        const isSettled = expense.settled;
        return '<tr class="' + (isSettled ? 'table-secondary' : '') + '" style="cursor: pointer;">' +
            '<td onclick="event.stopPropagation();">' +
                '<input type="checkbox" class="form-check-input expense-checkbox" data-id="' + expense.expenseId + '" ' +
                (isChecked ? 'checked' : '') + ' ' + (isSettled ? 'disabled' : '') + '>' +
            '</td>' +
            '<td class="expense-row" data-id="' + expense.expenseId + '">' + expense.expenseId + '</td>' +
            '<td class="expense-row" data-id="' + expense.expenseId + '">' + (expense.branchName || '-') + '</td>' +
            '<td class="expense-row" data-id="' + expense.expenseId + '">' + formatDateTime(expense.expenseAt) + '</td>' +
            '<td class="expense-row" data-id="' + expense.expenseId + '">' + getExpenseCategoryName(expense.categoryCode) + '</td>' +
            '<td class="expense-row" data-id="' + expense.expenseId + '">' + (expense.description || '-') + '</td>' +
            '<td class="expense-row text-end" data-id="' + expense.expenseId + '">' + formatCurrency(expense.amount || 0) + '</td>' +
            '<td class="expense-row" data-id="' + expense.expenseId + '"><span class="badge ' + (isSettled ? 'bg-secondary' : 'bg-warning') + '">' + (isSettled ? '정산됨' : '미정산') + '</span></td>' +
        '</tr>';
    }).join('');

    // 체크박스 이벤트 바인딩
    tbody.querySelectorAll('.expense-checkbox').forEach(function(checkbox) {
        checkbox.addEventListener('change', function() {
            const expenseId = parseInt(this.dataset.id);
            if (this.checked) {
                selectedExpenses.add(expenseId);
            } else {
                selectedExpenses.delete(expenseId);
            }
            updateSelectedInfo();
        });
    });

    // 행 클릭 이벤트 바인딩
    tbody.querySelectorAll('.expense-row').forEach(function(cell) {
        cell.addEventListener('click', function() {
            const expenseId = parseInt(this.dataset.id);
            openExpenseDetailModal(expenseId);
        });
    });

    // 페이지네이션 렌더링
    renderPagination('expensesPagination', totalCount, expensesPage, function(page) {
        expensesPage = page;
        renderExpensesTable();
    });

    // 전체 선택 체크박스 상태 업데이트
    updateExpensesCheckAll();
}

// 페이지네이션 렌더링
function renderPagination(elementId, totalCount, currentPage, onPageChange) {
    const totalPages = Math.ceil(totalCount / pageSize);
    const pagination = document.getElementById(elementId);

    if (totalPages <= 1) {
        pagination.innerHTML = '';
        return;
    }

    let html = '';

    // 이전 버튼
    html += '<li class="page-item ' + (currentPage === 1 ? 'disabled' : '') + '">';
    html += '<a class="page-link" href="#" data-page="' + (currentPage - 1) + '">&laquo;</a></li>';

    // 페이지 번호
    const startPage = Math.max(1, currentPage - 2);
    const endPage = Math.min(totalPages, startPage + 4);

    for (let i = startPage; i <= endPage; i++) {
        html += '<li class="page-item ' + (i === currentPage ? 'active' : '') + '">';
        html += '<a class="page-link" href="#" data-page="' + i + '">' + i + '</a></li>';
    }

    // 다음 버튼
    html += '<li class="page-item ' + (currentPage === totalPages ? 'disabled' : '') + '">';
    html += '<a class="page-link" href="#" data-page="' + (currentPage + 1) + '">&raquo;</a></li>';

    pagination.innerHTML = html;

    // 이벤트 바인딩
    pagination.querySelectorAll('.page-link').forEach(function(link) {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            const page = parseInt(this.dataset.page);
            if (page >= 1 && page <= totalPages) {
                onPageChange(page);
            }
        });
    });
}

// 요약 정보 업데이트 (미정산 항목만)
function updateSummary() {
    // 미정산 매출만 필터링
    const unsettledSales = currentSalesData.filter(function(sale) { return !sale.settled; });
    const totalSalesAmount = unsettledSales.reduce(function(sum, sale) { return sum + (parseFloat(sale.totalAmount) || 0); }, 0);

    // 미정산 지출만 필터링
    const unsettledExpenses = currentExpensesData.filter(function(expense) { return !expense.settled; });
    const totalExpensesAmount = unsettledExpenses.reduce(function(sum, expense) { return sum + (parseFloat(expense.amount) || 0); }, 0);

    const totalProfit = totalSalesAmount - totalExpensesAmount;

    document.getElementById('totalSales').textContent = formatCurrency(totalSalesAmount);
    document.getElementById('salesCount').textContent = unsettledSales.length + '건';

    document.getElementById('totalExpenses').textContent = formatCurrency(totalExpensesAmount);
    document.getElementById('expensesCount').textContent = unsettledExpenses.length + '건';

    const profitElement = document.getElementById('totalProfit');
    profitElement.textContent = formatCurrency(totalProfit);
    profitElement.parentElement.parentElement.className = totalProfit >= 0 ? 'small-box text-bg-success' : 'small-box text-bg-danger';
}

// 정산 생성
async function createSettlement() {
    if (currentSalesData.length === 0 && currentExpensesData.length === 0) {
        alert('정산 대상 데이터가 없습니다.');
        return;
    }

    if (!confirm('정산을 생성하시겠습니까?')) {
        return;
    }

    const branchValue = document.getElementById('branchId').value;
    const requestData = {
        branchId: branchValue === '0' ? null : parseInt(branchValue),
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
            alert(result.message || '정산이 생성되었습니다.');
            window.location.href = '/settlements/' + result.settlementId;
        } else {
            const error = await response.json();
            throw new Error(error.message || '정산 생성 실패');
        }
    } catch (error) {
        console.error('정산 생성 실패:', error);
        alert('정산 생성에 실패했습니다: ' + error.message);
    }
}

// 매출 카테고리 이름
function getCategoryName(code) {
    const categories = {
        'MEMBERSHIP': '회원권',
        'PT': 'PT',
        'GOODS': '용품',
        'PRODUCT': '상품',
        'ETC': '기타'
    };
    return categories[code] || code || '-';
}

// 지출 카테고리 이름
function getExpenseCategoryName(code) {
    const categories = {
        'SALARY': '급여',
        'RENT': '임대료',
        'UTILITY': '공과금',
        'SUPPLY': '비품',
        'ETC': '기타'
    };
    return categories[code] || code || '-';
}

// 상태 이름
function getStatusName(code) {
    const statuses = {
        'PENDING': '대기',
        'COMPLETED': '완료',
        'CONFIRMED': '확정',
        'CANCELLED': '취소'
    };
    return statuses[code] || code || '-';
}

// 상태 뱃지 클래스
function getStatusBadgeClass(code) {
    const classes = {
        'PENDING': 'bg-warning',
        'COMPLETED': 'bg-success',
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
    return year + '-' + month + '-' + day;
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

// ===== 체크박스 관련 함수 =====

// 매출 전체 선택/해제
function toggleAllSales(checked) {
    currentSalesData.forEach(function(sale) {
        if (!sale.settled) {
            if (checked) {
                selectedSales.add(sale.saleId);
            } else {
                selectedSales.delete(sale.saleId);
            }
        }
    });
    renderSalesTable();
    updateSelectedInfo();
}

// 지출 전체 선택/해제
function toggleAllExpenses(checked) {
    currentExpensesData.forEach(function(expense) {
        if (!expense.settled) {
            if (checked) {
                selectedExpenses.add(expense.expenseId);
            } else {
                selectedExpenses.delete(expense.expenseId);
            }
        }
    });
    renderExpensesTable();
    updateSelectedInfo();
}

// 매출 전체 선택 체크박스 상태 업데이트
function updateSalesCheckAll() {
    const unsettledSales = currentSalesData.filter(function(s) { return !s.settled; });
    const allChecked = unsettledSales.length > 0 && unsettledSales.every(function(s) { return selectedSales.has(s.saleId); });
    document.getElementById('salesCheckAll').checked = allChecked;
}

// 지출 전체 선택 체크박스 상태 업데이트
function updateExpensesCheckAll() {
    const unsettledExpenses = currentExpensesData.filter(function(e) { return !e.settled; });
    const allChecked = unsettledExpenses.length > 0 && unsettledExpenses.every(function(e) { return selectedExpenses.has(e.expenseId); });
    document.getElementById('expensesCheckAll').checked = allChecked;
}

// 선택 정보 업데이트
function updateSelectedInfo() {
    const salesCount = selectedSales.size;
    const expensesCount = selectedExpenses.size;

    // 선택된 매출 합계
    let salesTotal = 0;
    currentSalesData.forEach(function(sale) {
        if (selectedSales.has(sale.saleId)) {
            salesTotal += parseFloat(sale.totalAmount) || 0;
        }
    });

    // 선택된 지출 합계
    let expensesTotal = 0;
    currentExpensesData.forEach(function(expense) {
        if (selectedExpenses.has(expense.expenseId)) {
            expensesTotal += parseFloat(expense.amount) || 0;
        }
    });

    const netTotal = salesTotal - expensesTotal;

    document.getElementById('selectedSalesCount').textContent = salesCount;
    document.getElementById('selectedExpensesCount').textContent = expensesCount;
    document.getElementById('selectedTotalAmount').textContent = formatCurrency(netTotal);

    // 선택 정보 및 버튼 표시/숨김
    if (salesCount > 0 || expensesCount > 0) {
        document.getElementById('selectedInfo').style.display = 'inline';
        document.getElementById('btnSelectedSettlement').style.display = 'inline-block';
    } else {
        document.getElementById('selectedInfo').style.display = 'none';
        document.getElementById('btnSelectedSettlement').style.display = 'none';
    }
}

// ===== 모달 관련 함수 =====

// 매출 상세 모달 열기
function openSaleDetailModal(saleId) {
    const sale = currentSalesData.find(function(s) { return s.saleId === saleId; });
    if (!sale) return;

    document.getElementById('modalSaleId').value = sale.saleId;
    document.getElementById('modalSaleNo').textContent = sale.saleNo || '-';
    document.getElementById('modalSaleBranch').textContent = sale.branchName || '-';
    document.getElementById('modalSaleDate').textContent = formatDateTime(sale.soldAt);
    document.getElementById('modalSaleCategory').textContent = getCategoryName(sale.categoryCode);
    document.getElementById('modalSaleAmount').textContent = formatCurrency(sale.totalAmount || 0);
    document.getElementById('modalSaleStatus').innerHTML = '<span class="badge ' + getStatusBadgeClass(sale.statusCode) + '">' + getStatusName(sale.statusCode) + '</span>';
    document.getElementById('modalSaleSettled').innerHTML = '<span class="badge ' + (sale.settled ? 'bg-secondary' : 'bg-warning') + '">' + (sale.settled ? '정산됨' : '미정산') + '</span>';

    // 미정산인 경우 개별 정산 버튼 표시
    document.getElementById('btnSettleSale').style.display = sale.settled ? 'none' : 'inline-block';

    saleDetailModal.show();
}

// 지출 상세 모달 열기
function openExpenseDetailModal(expenseId) {
    const expense = currentExpensesData.find(function(e) { return e.expenseId === expenseId; });
    if (!expense) return;

    document.getElementById('modalExpenseId').value = expense.expenseId;
    document.getElementById('modalExpenseNo').textContent = expense.expenseId;
    document.getElementById('modalExpenseBranch').textContent = expense.branchName || '-';
    document.getElementById('modalExpenseDate').textContent = formatDateTime(expense.expenseAt);
    document.getElementById('modalExpenseCategory').textContent = getExpenseCategoryName(expense.categoryCode);
    document.getElementById('modalExpenseAmount').textContent = formatCurrency(expense.amount || 0);
    document.getElementById('modalExpenseSettled').innerHTML = '<span class="badge ' + (expense.settled ? 'bg-secondary' : 'bg-warning') + '">' + (expense.settled ? '정산됨' : '미정산') + '</span>';
    document.getElementById('modalExpenseDescription').textContent = expense.description || '-';

    // 미정산인 경우 개별 정산 버튼 표시
    document.getElementById('btnSettleExpense').style.display = expense.settled ? 'none' : 'inline-block';

    expenseDetailModal.show();
}

// ===== 정산 처리 함수 =====

// 선택 정산 생성
async function createSelectedSettlement() {
    if (selectedSales.size === 0 && selectedExpenses.size === 0) {
        alert('정산할 항목을 선택해주세요.');
        return;
    }

    if (!confirm('선택한 ' + selectedSales.size + '건의 매출과 ' + selectedExpenses.size + '건의 지출을 정산하시겠습니까?')) {
        return;
    }

    const requestData = {
        saleIds: Array.from(selectedSales),
        expenseIds: Array.from(selectedExpenses),
        branchId: document.getElementById('branchId').value === '0' ? null : parseInt(document.getElementById('branchId').value),
        fromDate: document.getElementById('startDate').value,
        toDate: document.getElementById('endDate').value
    };

    try {
        const response = await fetch('/settlements/api/selected', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(requestData)
        });

        if (response.ok) {
            const result = await response.json();
            alert(result.message || '정산이 생성되었습니다.');
            window.location.href = '/settlements/' + result.settlementId;
        } else {
            const error = await response.json();
            throw new Error(error.message || '정산 생성 실패');
        }
    } catch (error) {
        console.error('정산 생성 실패:', error);
        alert('정산 생성에 실패했습니다: ' + error.message);
    }
}

// 개별 매출 정산
async function settleSingleSale() {
    const saleId = document.getElementById('modalSaleId').value;
    if (!saleId) return;

    if (!confirm('이 매출을 정산하시겠습니까?')) {
        return;
    }

    const requestData = {
        saleIds: [parseInt(saleId)],
        expenseIds: [],
        branchId: document.getElementById('branchId').value === '0' ? null : parseInt(document.getElementById('branchId').value),
        fromDate: document.getElementById('startDate').value,
        toDate: document.getElementById('endDate').value
    };

    try {
        const response = await fetch('/settlements/api/selected', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(requestData)
        });

        if (response.ok) {
            const result = await response.json();
            alert(result.message || '정산이 생성되었습니다.');
            saleDetailModal.hide();
            loadData(); // 데이터 새로고침
        } else {
            const error = await response.json();
            throw new Error(error.message || '정산 생성 실패');
        }
    } catch (error) {
        console.error('정산 생성 실패:', error);
        alert('정산 생성에 실패했습니다: ' + error.message);
    }
}

// 개별 지출 정산
async function settleSingleExpense() {
    const expenseId = document.getElementById('modalExpenseId').value;
    if (!expenseId) return;

    if (!confirm('이 지출을 정산하시겠습니까?')) {
        return;
    }

    const requestData = {
        saleIds: [],
        expenseIds: [parseInt(expenseId)],
        branchId: document.getElementById('branchId').value === '0' ? null : parseInt(document.getElementById('branchId').value),
        fromDate: document.getElementById('startDate').value,
        toDate: document.getElementById('endDate').value
    };

    try {
        const response = await fetch('/settlements/api/selected', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(requestData)
        });

        if (response.ok) {
            const result = await response.json();
            alert(result.message || '정산이 생성되었습니다.');
            expenseDetailModal.hide();
            loadData(); // 데이터 새로고침
        } else {
            const error = await response.json();
            throw new Error(error.message || '정산 생성 실패');
        }
    } catch (error) {
        console.error('정산 생성 실패:', error);
        alert('정산 생성에 실패했습니다: ' + error.message);
    }
}
</script>
