<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<jsp:include page="../includes/admin_header.jsp" />

<!-- Main content -->
<div class="app-content-header">
    <div class="container-fluid">
        <div class="row">
            <div class="col-sm-6">
                <h3 class="mb-0">정산·통계 대시보드</h3>
            </div>
            <div class="col-sm-6">
                <ol class="breadcrumb float-sm-end">
                    <li class="breadcrumb-item"><a href="<c:url value='/'/>">Home</a></li>
                    <li class="breadcrumb-item active" aria-current="page">정산·통계</li>
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
                                    <!-- 지점 목록은 API로 로드 -->
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

        <!-- 요약 카드 -->
        <div class="row mb-4">
            <!-- 총 매출 -->
            <div class="col-lg-3 col-6">
                <div class="small-box text-bg-primary">
                    <div class="inner">
                        <h3 id="totalSales">-</h3>
                        <p>총 매출</p>
                    </div>
                    <div class="small-box-footer link-light link-underline-opacity-0 link-underline-opacity-50-hover">
                        <i class="bi bi-graph-up-arrow"></i>
                        <span id="salesGrowth" class="ms-2">-</span>
                    </div>
                </div>
            </div>

            <!-- 총 지출 -->
            <div class="col-lg-3 col-6">
                <div class="small-box text-bg-danger">
                    <div class="inner">
                        <h3 id="totalExpenses">-</h3>
                        <p>총 지출</p>
                    </div>
                    <div class="small-box-footer link-light link-underline-opacity-0 link-underline-opacity-50-hover">
                        <i class="bi bi-graph-down-arrow"></i>
                        <span id="expensesGrowth" class="ms-2">-</span>
                    </div>
                </div>
            </div>

            <!-- 순이익 -->
            <div class="col-lg-3 col-6">
                <div class="small-box text-bg-success">
                    <div class="inner">
                        <h3 id="netProfit">-</h3>
                        <p>추정 순이익</p>
                    </div>
                    <div class="small-box-footer link-light link-underline-opacity-0 link-underline-opacity-50-hover">
                        <i class="bi bi-currency-dollar"></i>
                        <span id="profitGrowth" class="ms-2">-</span>
                    </div>
                </div>
            </div>

            <!-- 수익률 -->
            <div class="col-lg-3 col-6">
                <div class="small-box text-bg-warning">
                    <div class="inner">
                        <h3 id="profitRate">-</h3>
                        <p>수익률</p>
                    </div>
                    <div class="small-box-footer link-dark link-underline-opacity-0 link-underline-opacity-50-hover">
                        <i class="bi bi-percent"></i>
                        <span id="rateChange" class="ms-2">-</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- 차트 영역 -->
        <div class="row">
            <!-- 매출/지출 추이 차트 -->
            <div class="col-lg-8">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">
                            <i class="bi bi-bar-chart-fill"></i>
                            매출/지출 추이
                        </h3>
                        <div class="card-tools">
                            <button type="button" class="btn btn-tool" data-lte-toggle="card-collapse">
                                <i data-lte-icon="expand" class="bi bi-plus-lg"></i>
                                <i data-lte-icon="collapse" class="bi bi-dash-lg"></i>
                            </button>
                        </div>
                    </div>
                    <div class="card-body">
                        <div id="trendChart" style="height: 350px;"></div>
                    </div>
                </div>
            </div>

            <!-- 손익 상태 -->
            <div class="col-lg-4">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">
                            <i class="bi bi-pie-chart-fill"></i>
                            손익 상태
                        </h3>
                    </div>
                    <div class="card-body">
                        <div id="profitChart" style="height: 350px;"></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- 지점별 비교 -->
        <div class="row mt-4">
            <div class="col-12">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">
                            <i class="bi bi-building"></i>
                            지점별 매출/지출 비교
                        </h3>
                    </div>
                    <div class="card-body">
                        <div id="branchComparisonChart" style="height: 400px;"></div>
                    </div>
                </div>
            </div>
        </div>

    </div>
</div>

<jsp:include page="../includes/admin_footer.jsp" />

<!-- ApexCharts -->
<script src="https://cdn.jsdelivr.net/npm/apexcharts@3.37.1/dist/apexcharts.min.js"></script>

<!-- v1.1 - 캐시 무효화 -->
<script>
// 전역 변수
let trendChart, profitChart, branchChart;

// 페이지 로드 시 초기화
document.addEventListener('DOMContentLoaded', function() {
    // 기본 날짜 설정 (이번 달)
    const today = new Date();
    const firstDay = new Date(today.getFullYear(), today.getMonth(), 1);
    const startDateInput = document.getElementById('startDate');
    const endDateInput = document.getElementById('endDate');

    startDateInput.value = formatDate(firstDay);
    endDateInput.value = formatDate(today);

    // 지점 목록 로드
    loadBranchOptions();

    // 차트 초기화
    initCharts();

    // ✅ 날짜 설정 후 초기 데이터 자동 로드
    // requestAnimationFrame으로 DOM 업데이트 완료 후 실행
    requestAnimationFrame(() => {
        requestAnimationFrame(() => {
            // 날짜 값이 제대로 설정되었는지 확인 후 로드
            if (startDateInput.value && endDateInput.value) {
                loadDashboardData();
            }
        });
    });

    // 폼 제출 이벤트
    document.getElementById('filterForm').addEventListener('submit', function(e) {
        e.preventDefault();
        loadDashboardData();
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
            option.value = branch.id;    // ✅ value → id로 수정
            option.textContent = branch.name;  // ✅ label → name으로 수정
            select.appendChild(option);
        });
    } catch (error) {
        console.error('지점 목록 로드 실패:', error);
    }
}

// 대시보드 데이터 로드
async function loadDashboardData() {
    const branchId = document.getElementById('branchId').value || '0';
    let startDate = document.getElementById('startDate').value;
    let endDate = document.getElementById('endDate').value;

    // ✅ 날짜가 비어있으면 기본값으로 재설정 (DOM 업데이트 미완료 대비)
    if (!startDate || !endDate) {
        console.warn('[loadDashboardData] 날짜가 비어있어 기본값 사용');
        const today = new Date();
        const firstDay = new Date(today.getFullYear(), today.getMonth(), 1);
        startDate = formatDate(firstDay);
        endDate = formatDate(today);

        // input 필드에도 다시 설정
        document.getElementById('startDate').value = startDate;
        document.getElementById('endDate').value = endDate;
    }

    console.log('[loadDashboardData] 조회 조건:', { startDate, endDate, branchId });

    // ✅ fetch 직전에 다시 한번 확인
    console.log('[loadDashboardData] fetch 직전 날짜:', { startDate, endDate, branchId });

    try {
        // 병렬로 데이터 로드
        const [salesByPeriod, expensesByPeriod, salesByBranch, comparison] = await Promise.all([
            fetch('/statistics/api/sales/by-period?startDate=' + startDate + '&endDate=' + endDate + '&branchId=' + branchId + '&groupBy=monthly').then(r => r.json()),
            fetch('/statistics/api/expenses/by-period?startDate=' + startDate + '&endDate=' + endDate + '&branchId=' + branchId + '&groupBy=monthly').then(r => r.json()),
            fetch('/statistics/api/sales/by-branch?startDate=' + startDate + '&endDate=' + endDate).then(r => r.json()),
            fetch('/statistics/api/comparison?startDate=' + startDate + '&endDate=' + endDate + '&branchId=' + branchId + '&groupBy=monthly').then(r => r.json())
        ]);

        // 요약 카드 업데이트
        updateSummaryCards(salesByPeriod, expensesByPeriod);

        // 차트 업데이트
        updateTrendChart(salesByPeriod, expensesByPeriod);
        updateProfitChart(comparison);
        updateBranchChart(salesByBranch);

    } catch (error) {
        console.error('데이터 로드 실패:', error);
        alert('데이터를 불러오는데 실패했습니다.');
    }
}

// 요약 카드 업데이트
function updateSummaryCards(salesData, expensesData) {
    const totalSales = salesData.reduce((sum, item) => sum + (item.totalAmount || 0), 0);
    const totalExpenses = expensesData.reduce((sum, item) => sum + (item.totalAmount || 0), 0);
    const netProfit = totalSales - totalExpenses;
    const profitRate = totalSales > 0 ? ((netProfit / totalSales) * 100) : 0;

    document.getElementById('totalSales').textContent = formatCurrency(totalSales);
    document.getElementById('totalExpenses').textContent = formatCurrency(totalExpenses);
    document.getElementById('netProfit').textContent = formatCurrency(netProfit);
    document.getElementById('profitRate').textContent = profitRate.toFixed(1) + '%';

    // 증감률 표시 (임시로 0으로 설정, 실제로는 이전 기간 데이터와 비교 필요)
    document.getElementById('salesGrowth').textContent = '전월 대비 -';
    document.getElementById('expensesGrowth').textContent = '전월 대비 -';
    document.getElementById('profitGrowth').textContent = '전월 대비 -';
    document.getElementById('rateChange').textContent = '전월 대비 -';
}

// 매출/지출 추이 차트 초기화
function initCharts() {
    // 추이 차트
    const trendOptions = {
        series: [{
            name: '매출',
            data: []
        }, {
            name: '지출',
            data: []
        }],
        chart: {
            height: 350,
            type: 'line',
            toolbar: { show: true }
        },
        colors: ['#0d6efd', '#dc3545'],
        dataLabels: { enabled: false },
        stroke: { curve: 'smooth', width: 3 },
        xaxis: {
            type: 'category',
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
    trendChart = new ApexCharts(document.querySelector("#trendChart"), trendOptions);
    trendChart.render();

    // 손익 차트 (도넛)
    const profitOptions = {
        series: [],
        chart: {
            height: 350,
            type: 'donut'
        },
        labels: ['흑자', '적자'],
        colors: ['#198754', '#dc3545'],
        legend: { position: 'bottom' }
    };
    profitChart = new ApexCharts(document.querySelector("#profitChart"), profitOptions);
    profitChart.render();

    // 지점별 비교 차트
    const branchOptions = {
        series: [{
            name: '매출',
            data: []
        }, {
            name: '지출',
            data: []
        }],
        chart: {
            type: 'bar',
            height: 400
        },
        colors: ['#0d6efd', '#dc3545'],
        plotOptions: {
            bar: {
                horizontal: false,
                columnWidth: '55%',
                endingShape: 'rounded'
            }
        },
        dataLabels: { enabled: false },
        stroke: {
            show: true,
            width: 2,
            colors: ['transparent']
        },
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
        fill: { opacity: 1 },
        tooltip: {
            y: {
                formatter: function(val) {
                    return formatCurrency(val);
                }
            }
        }
    };
    branchChart = new ApexCharts(document.querySelector("#branchComparisonChart"), branchOptions);
    branchChart.render();
}

// 추이 차트 업데이트
function updateTrendChart(salesData, expensesData) {
    const categories = salesData.map(item => item.periodLabel || item.period);
    const salesValues = salesData.map(item => item.totalAmount || 0);
    const expensesValues = expensesData.map(item => item.totalAmount || 0);

    trendChart.updateOptions({
        xaxis: { categories: categories },
        series: [{
            name: '매출',
            data: salesValues
        }, {
            name: '지출',
            data: expensesValues
        }]
    });
}

// 손익 차트 업데이트
function updateProfitChart(comparisonData) {
    const profit = comparisonData.filter(item => item.profitStatus === 'PROFIT').length;
    const loss = comparisonData.filter(item => item.profitStatus === 'LOSS').length;

    profitChart.updateSeries([profit, loss]);
}

// 지점별 비교 차트 업데이트
function updateBranchChart(branchData) {
    const branchNames = branchData.map(item => item.branchName);
    const salesValues = branchData.map(item => item.totalAmount || 0);

    // 지출 데이터는 별도 API 호출 필요 (임시로 0으로 설정)
    const expensesValues = branchData.map(() => 0);

    branchChart.updateOptions({
        xaxis: { categories: branchNames },
        series: [{
            name: '매출',
            data: salesValues
        }, {
            name: '지출',
            data: expensesValues
        }]
    });
}

// 유틸리티 함수
function formatCurrency(value) {
    return new Intl.NumberFormat('ko-KR', {
        style: 'currency',
        currency: 'KRW'
    }).format(value);
}

function formatDate(date) {
    console.log('[formatDate] 입력:', date);
    console.log('[formatDate] 타입:', typeof date);
    console.log('[formatDate] instanceof Date:', date instanceof Date);

    // 날짜 객체 유효성 검사
    if (!date || !(date instanceof Date) || isNaN(date.getTime())) {
        console.error('[formatDate] Invalid date object:', date);
        return '';  // 빈 문자열 반환
    }

    const year = date.getFullYear();
    const month = date.getMonth() + 1;
    const day = date.getDate();

    console.log('[formatDate] year:', year, 'month:', month, 'day:', day);

    const monthStr = String(month).padStart(2, '0');
    const dayStr = String(day).padStart(2, '0');

    console.log('[formatDate] monthStr:', monthStr, 'dayStr:', dayStr);

    const formatted = year + '-' + monthStr + '-' + dayStr;

    console.log('[formatDate] 최종 결과:', formatted);
    return formatted;
}
</script>
