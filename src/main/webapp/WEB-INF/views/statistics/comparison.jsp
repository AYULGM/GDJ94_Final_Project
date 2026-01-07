<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<jsp:include page="../includes/admin_header.jsp" />

<!-- Main content -->
<div class="app-content-header">
    <div class="container-fluid">
        <div class="row">
            <div class="col-sm-6">
                <h3 class="mb-0">손익 비교</h3>
            </div>
            <div class="col-sm-6">
                <ol class="breadcrumb float-sm-end">
                    <li class="breadcrumb-item"><a href="<c:url value='/'/>">Home</a></li>
                    <li class="breadcrumb-item"><a href="<c:url value='/statistics'/>">정산·통계</a></li>
                    <li class="breadcrumb-item active">손익 비교</li>
                </ol>
            </div>
        </div>
    </div>
</div>

<div class="app-content">
    <div class="container-fluid">

        <!-- 필터 영역 -->
        <div class="row mb-4">
            <div class="col-12">
                <div class="card">
                    <div class="card-body">
                        <form id="filterForm" class="row g-3">
                            <div class="col-md-3">
                                <label for="branchId" class="form-label">지점</label>
                                <select class="form-select" id="branchId" name="branchId">
                                    <option value="0" selected>전체</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label for="startDate" class="form-label">시작일</label>
                                <input type="date" class="form-control" id="startDate" name="startDate" required>
                            </div>
                            <div class="col-md-3">
                                <label for="endDate" class="form-label">종료일</label>
                                <input type="date" class="form-control" id="endDate" name="endDate" required>
                            </div>
                            <div class="col-md-3">
                                <label for="groupBy" class="form-label">집계 단위</label>
                                <select class="form-select" id="groupBy" name="groupBy">
                                    <option value="monthly" selected>월별</option>
                                    <option value="quarterly">분기별</option>
                                    <option value="yearly">연도별</option>
                                </select>
                            </div>
                            <div class="col-md-12 d-flex justify-content-end">
                                <button type="submit" class="btn btn-primary">
                                    <i class="bi bi-search"></i> 조회
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <!-- 차트 영역 -->
        <div class="row mb-4">
            <div class="col-12">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">
                            <i class="bi bi-bar-chart-fill"></i>
                            손익 비교 차트
                        </h3>
                    </div>
                    <div class="card-body">
                        <div id="comparisonChart" style="height: 400px;"></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- 테이블 영역 -->
        <div class="row">
            <div class="col-12">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">
                            <i class="bi bi-table"></i>
                            손익 비교 목록
                        </h3>
                    </div>
                    <div class="card-body p-0">
                        <table class="table table-striped">
                            <thead>
                                <tr>
                                    <th>기간</th>
                                    <th>지점</th>
                                    <th class="text-end">매출 건수</th>
                                    <th class="text-end">총 매출</th>
                                    <th class="text-end">지출 건수</th>
                                    <th class="text-end">총 지출</th>
                                    <th class="text-end">손익</th>
                                    <th class="text-end">수익률</th>
                                    <th>상태</th>
                                </tr>
                            </thead>
                            <tbody id="tableBody">
                                <tr>
                                    <td colspan="9" class="text-center">
                                        <div class="spinner-border" role="status">
                                            <span class="visually-hidden">Loading...</span>
                                        </div>
                                    </td>
                                </tr>
                            </tbody>
                            <tfoot id="tableFoot">
                            </tfoot>
                        </table>
                    </div>
                </div>
            </div>
        </div>

    </div>
</div>

<jsp:include page="../includes/admin_footer.jsp" />

<!-- ApexCharts -->
<script src="https://cdn.jsdelivr.net/npm/apexcharts@3.37.1/dist/apexcharts.min.js"></script>

<script>
let comparisonChart;

// 페이지 로드 시 초기화
document.addEventListener('DOMContentLoaded', function() {
    // 기본 날짜 설정 (이번 달)
    const today = new Date();
    const firstDay = new Date(today.getFullYear(), today.getMonth(), 1);
    document.getElementById('startDate').value = formatDate(firstDay);
    document.getElementById('endDate').value = formatDate(today);

    // 지점 목록 로드
    loadBranchOptions();

    // 차트 초기화
    initChart();

    // 데이터 로드
    loadComparisonData();

    // 폼 제출 이벤트
    document.getElementById('filterForm').addEventListener('submit', function(e) {
        e.preventDefault();
        loadComparisonData();
    });
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

// 손익 비교 데이터 로드
async function loadComparisonData() {
    const formData = new FormData(document.getElementById('filterForm'));
    const params = new URLSearchParams(formData);

    try {
        const response = await fetch('/statistics/api/comparison?' + params.toString());
        const data = await response.json();

        updateChart(data);
        updateTable(data);
    } catch (error) {
        console.error('데이터 로드 실패:', error);
        document.getElementById('tableBody').innerHTML =
            '<tr><td colspan="9" class="text-center text-danger">데이터를 불러오는데 실패했습니다.</td></tr>';
    }
}

// 차트 초기화
function initChart() {
    const options = {
        series: [{
            name: '매출',
            data: []
        }, {
            name: '지출',
            data: []
        }, {
            name: '손익',
            data: []
        }],
        chart: {
            type: 'bar',
            height: 400
        },
        colors: ['#0d6efd', '#dc3545', '#198754'],
        plotOptions: {
            bar: {
                horizontal: false,
                columnWidth: '70%',
                endingShape: 'rounded'
            }
        },
        dataLabels: { enabled: false },
        xaxis: {
            categories: []
        },
        yaxis: {
            labels: {
                formatter: function(val) {
                    return formatCurrency(val);
                }
            }
        },
        tooltip: {
            y: {
                formatter: function(val) {
                    return formatCurrency(val);
                }
            }
        }
    };

    comparisonChart = new ApexCharts(document.querySelector("#comparisonChart"), options);
    comparisonChart.render();
}

// 차트 업데이트
function updateChart(data) {
    const categories = data.map(item => item.periodLabel || item.period);
    const salesValues = data.map(item => item.salesAmount || 0);
    const expenseValues = data.map(item => item.expenseAmount || 0);
    const profitValues = data.map(item => item.profitAmount || 0);

    comparisonChart.updateOptions({
        xaxis: { categories: categories },
        series: [{
            name: '매출',
            data: salesValues
        }, {
            name: '지출',
            data: expenseValues
        }, {
            name: '손익',
            data: profitValues
        }]
    });
}

// 테이블 업데이트
function updateTable(data) {
    const tbody = document.getElementById('tableBody');

    if (!data || data.length === 0) {
        tbody.innerHTML = '<tr><td colspan="9" class="text-center">데이터가 없습니다.</td></tr>';
        document.getElementById('tableFoot').innerHTML = '';
        return;
    }

    // 테이블 바디
    tbody.innerHTML = data.map(item => {
        const profitClass = getProfitClass(item.profitStatus);

        return `
            <tr>
                <td>${item.periodLabel || item.period}</td>
                <td>${item.branchName || '전체'}</td>
                <td class="text-end">${formatNumber(item.salesCount || 0)}</td>
                <td class="text-end">${formatCurrency(item.salesAmount || 0)}</td>
                <td class="text-end">${formatNumber(item.expenseCount || 0)}</td>
                <td class="text-end">${formatCurrency(item.expenseAmount || 0)}</td>
                <td class="text-end ${profitClass}">${formatCurrency(item.profitAmount || 0)}</td>
                <td class="text-end ${profitClass}">${(item.profitRate || 0).toFixed(1)}%</td>
                <td>
                    <span class="badge ${getProfitBadgeClass(item.profitStatus)}">
                        ${getProfitStatusName(item.profitStatus)}
                    </span>
                </td>
            </tr>
        `;
    }).join('');

    // 합계 행
    const totalSales = data.reduce((sum, item) => sum + (item.salesAmount || 0), 0);
    const totalExpenses = data.reduce((sum, item) => sum + (item.expenseAmount || 0), 0);
    const totalProfit = totalSales - totalExpenses;
    const totalRate = totalSales > 0 ? ((totalProfit / totalSales) * 100) : 0;
    const totalSalesCount = data.reduce((sum, item) => sum + (item.salesCount || 0), 0);
    const totalExpenseCount = data.reduce((sum, item) => sum + (item.expenseCount || 0), 0);

    const profitClass = totalProfit >= 0 ? 'text-success' : 'text-danger';

    document.getElementById('tableFoot').innerHTML = `
        <tr class="table-active fw-bold">
            <td colspan="2">합계</td>
            <td class="text-end">${formatNumber(totalSalesCount)}</td>
            <td class="text-end">${formatCurrency(totalSales)}</td>
            <td class="text-end">${formatNumber(totalExpenseCount)}</td>
            <td class="text-end">${formatCurrency(totalExpenses)}</td>
            <td class="text-end ${profitClass}">${formatCurrency(totalProfit)}</td>
            <td class="text-end ${profitClass}">${totalRate.toFixed(1)}%</td>
            <td>-</td>
        </tr>
    `;
}

// 손익 상태별 클래스
function getProfitClass(status) {
    if (status === 'PROFIT') return 'text-success';
    if (status === 'LOSS') return 'text-danger';
    return 'text-warning';
}

function getProfitBadgeClass(status) {
    if (status === 'PROFIT') return 'bg-success';
    if (status === 'LOSS') return 'bg-danger';
    return 'bg-warning';
}

function getProfitStatusName(status) {
    if (status === 'PROFIT') return '흑자';
    if (status === 'LOSS') return '적자';
    return '손익분기';
}

// 유틸리티 함수
function formatCurrency(value) {
    return new Intl.NumberFormat('ko-KR', {
        style: 'currency',
        currency: 'KRW'
    }).format(value);
}

function formatNumber(value) {
    return new Intl.NumberFormat('ko-KR').format(value);
}

function formatDate(date) {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
}
</script>
