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
                        <p>추정 순이익 (세후)</p>
                        <small class="text-white-50" style="font-size: 0.75rem;">
                            법인세: <span id="corporateTax">-</span>
                        </small>
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
                        <h3 id="profitRate" class="text-white">-</h3>
                        <p class="text-white">수익률</p>
                    </div>
                    <div class="small-box-footer link-light link-underline-opacity-0 link-underline-opacity-50-hover">
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

<!-- v1.2 - 전월 대비 증감률 기능 추가 -->
<script>
// 전역 변수
let trendChart, profitChart, branchChart;

// 페이지 로드 시 초기화
document.addEventListener('DOMContentLoaded', function() {
    // 기본 날짜 설정 (최근 6개월)
    const today = new Date();
    const sixMonthsAgo = new Date(today.getFullYear(), today.getMonth() - 6, 1);
    const startDateInput = document.getElementById('startDate');
    const endDateInput = document.getElementById('endDate');

    startDateInput.value = formatDate(sixMonthsAgo);
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

// 대시보드 데이터 로드
async function loadDashboardData() {
    const branchId = document.getElementById('branchId').value || '0';
    let startDate = document.getElementById('startDate').value;
    let endDate = document.getElementById('endDate').value;

    // ✅ 날짜가 비어있으면 기본값으로 재설정 (DOM 업데이트 미완료 대비)
    if (!startDate || !endDate) {
        console.warn('[loadDashboardData] 날짜가 비어있어 기본값 사용');
        const today = new Date();
        const sixMonthsAgo = new Date(today.getFullYear(), today.getMonth() - 6, 1);
        startDate = formatDate(sixMonthsAgo);
        endDate = formatDate(today);

        // input 필드에도 다시 설정
        document.getElementById('startDate').value = startDate;
        document.getElementById('endDate').value = endDate;
    }

    console.log('[loadDashboardData] 조회 조건:', { startDate, endDate, branchId });

    // 전월 기간 계산 (증감률 비교용)
    const currentStart = new Date(startDate);
    const prevMonthEnd = new Date(currentStart.getFullYear(), currentStart.getMonth(), 0); // 전월 마지막날
    const prevMonthStart = new Date(prevMonthEnd.getFullYear(), prevMonthEnd.getMonth(), 1); // 전월 첫날
    const prevStartDate = formatDate(prevMonthStart);
    const prevEndDate = formatDate(prevMonthEnd);

    console.log('[loadDashboardData] 전월 기간:', { prevStartDate, prevEndDate });

    try {
        // 병렬로 데이터 로드 (현재 월 + 전월 데이터)
        const [salesByPeriod, expensesByPeriod, salesByBranch, expensesByBranch, comparison,
               prevSalesByPeriod, prevExpensesByPeriod] = await Promise.all([
            // 현재 월 데이터
            fetch('/statistics/api/sales/by-period?startDate=' + startDate + '&endDate=' + endDate + '&branchId=' + branchId + '&groupBy=monthly').then(r => r.json()),
            fetch('/statistics/api/expenses/by-period?startDate=' + startDate + '&endDate=' + endDate + '&branchId=' + branchId + '&groupBy=monthly').then(r => r.json()),
            fetch('/statistics/api/sales/by-branch?startDate=' + startDate + '&endDate=' + endDate).then(r => r.json()),
            fetch('/statistics/api/expenses/by-branch?startDate=' + startDate + '&endDate=' + endDate).then(r => r.json()),
            fetch('/statistics/api/comparison?startDate=' + startDate + '&endDate=' + endDate + '&branchId=' + branchId + '&groupBy=monthly').then(r => r.json()),
            // 전월 데이터 (증감률 계산용)
            fetch('/statistics/api/sales/by-period?startDate=' + prevStartDate + '&endDate=' + prevEndDate + '&branchId=' + branchId + '&groupBy=monthly').then(r => r.json()),
            fetch('/statistics/api/expenses/by-period?startDate=' + prevStartDate + '&endDate=' + prevEndDate + '&branchId=' + branchId + '&groupBy=monthly').then(r => r.json())
        ]);

        // 요약 카드 업데이트 (전월 데이터 포함)
        updateSummaryCards(salesByPeriod, expensesByPeriod, prevSalesByPeriod, prevExpensesByPeriod);

        // 차트 업데이트
        updateTrendChart(salesByPeriod, expensesByPeriod);
        updateProfitChart(comparison);
        updateBranchChart(salesByBranch, expensesByBranch);

    } catch (error) {
        console.error('데이터 로드 실패:', error);
        alert('데이터를 불러오는데 실패했습니다.');
    }
}

// 요약 카드 업데이트
function updateSummaryCards(salesData, expensesData, prevSalesData, prevExpensesData) {
    // 현재 월 집계
    const totalSales = salesData.reduce((sum, item) => sum + (item.totalAmount || 0), 0);
    const totalExpenses = expensesData.reduce((sum, item) => sum + (item.totalAmount || 0), 0);
    const grossProfit = totalSales - totalExpenses;  // 세전 순이익

    // 법인세 자동 계산 (누진세율)
    const corporateTax = calculateCorporateTax(grossProfit);
    const netProfit = grossProfit - corporateTax;  // 세후 순이익 (추정)
    const profitRate = totalSales > 0 ? ((netProfit / totalSales) * 100) : 0;

    // 전월 집계 (데이터 없을 경우 빈 배열로 처리)
    const prevTotalSales = (prevSalesData || []).reduce((sum, item) => sum + (item.totalAmount || 0), 0);
    const prevTotalExpenses = (prevExpensesData || []).reduce((sum, item) => sum + (item.totalAmount || 0), 0);
    const prevGrossProfit = prevTotalSales - prevTotalExpenses;  // 전월 세전 순이익
    const prevCorporateTax = calculateCorporateTax(prevGrossProfit);
    const prevNetProfit = prevGrossProfit - prevCorporateTax;  // 전월 세후 순이익
    const prevProfitRate = prevTotalSales > 0 ? ((prevNetProfit / prevTotalSales) * 100) : 0;

    // 증감률 계산
    const salesGrowth = calculateGrowthRate(totalSales, prevTotalSales);
    const expensesGrowth = calculateGrowthRate(totalExpenses, prevTotalExpenses);
    const profitGrowth = calculateGrowthRate(netProfit, prevNetProfit);
    const rateChange = profitRate - prevProfitRate;

    // 요약 카드 업데이트
    document.getElementById('totalSales').textContent = formatCurrency(totalSales);
    document.getElementById('totalExpenses').textContent = formatCurrency(totalExpenses);
    document.getElementById('netProfit').textContent = formatCurrency(netProfit);
    document.getElementById('corporateTax').textContent = formatCurrency(corporateTax);  // 법인세액 표시
    document.getElementById('profitRate').textContent = profitRate.toFixed(1) + '%';

    // 증감률 표시
    document.getElementById('salesGrowth').innerHTML = formatGrowthRate(salesGrowth, '매출');
    document.getElementById('expensesGrowth').innerHTML = formatGrowthRate(expensesGrowth, '지출', true);
    document.getElementById('profitGrowth').innerHTML = formatGrowthRate(profitGrowth, '순이익');
    document.getElementById('rateChange').innerHTML = formatRateChange(rateChange);
}

/**
 * 법인세 자동 계산 (누진세율)
 *
 * 세율 구조:
 * - 2억 이하: 9%
 * - 2억 초과: 2억까지는 9%, 초과분은 19%
 *
 * @param {number} profit - 세전 순이익
 * @returns {number} - 법인세액
 */
function calculateCorporateTax(profit) {
    if (profit <= 0) return 0;  // 이익이 0 이하면 세금 없음

    const threshold = 200000000;  // 2억원
    const lowRate = 0.09;         // 9% (2억 이하)
    const highRate = 0.19;        // 19% (2억 초과분)

    if (profit <= threshold) {
        // 2억 이하: 전체에 9% 적용
        return profit * lowRate;
    } else {
        // 2억 초과: 2억까지는 9%, 초과분은 19%
        const lowTax = threshold * lowRate;          // 2억 × 9% = 1,800만원
        const highTax = (profit - threshold) * highRate;  // 초과분 × 19%
        return lowTax + highTax;
    }
}

// 증감률 계산 함수
function calculateGrowthRate(current, previous) {
    if (previous === 0) {
        if (current === 0) return 0;
        return 100; // 전월 0원에서 현재 값이 있으면 100% 증가로 표시
    }
    return ((current - previous) / previous) * 100;
}

// 증감률 포맷팅 함수
function formatGrowthRate(rate, label, isExpense = false) {
    if (rate === 0) {
        return '전월 대비 <span class="text-white-50">0%</span>';
    }

    const icon = rate > 0 ? '↑' : '↓';
    const absRate = Math.abs(rate).toFixed(1);

    return '전월 대비 <span class="text-white">' + icon + ' ' + absRate + '%</span>';
}

// 수익률 변화 포맷팅 함수
function formatRateChange(change) {
    if (change === 0) {
        return '전월 대비 <span class="text-white-50">0%p</span>';
    }

    const icon = change > 0 ? '↑' : '↓';
    const absChange = Math.abs(change).toFixed(1);

    return '전월 대비 <span class="text-white">' + icon + ' ' + absChange + '%p</span>';
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
function updateBranchChart(salesData, expensesData) {
    // 매출 데이터를 기준으로 지점명 추출 (매출이 있는 지점만 표시)
    const branchNames = salesData.map(item => item.branchName);
    const salesValues = salesData.map(item => item.totalAmount || 0);

    // 매출 지점 순서에 맞춰 지출 데이터 매칭
    const expensesValues = salesData.map(salesItem => {
        const expenseItem = expensesData.find(e => e.branchId === salesItem.branchId);
        return expenseItem ? (expenseItem.totalAmount || 0) : 0;
    });

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
