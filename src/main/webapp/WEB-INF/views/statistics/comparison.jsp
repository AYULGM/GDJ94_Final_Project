<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>

<jsp:include page="../includes/admin_header.jsp" />

<!-- 권한 정보를 JavaScript에서 사용하기 위한 숨김 필드 -->
<sec:authorize access="isAuthenticated()">
    <sec:authentication property="principal" var="loginUser"/>
    <input type="hidden" id="userRoleCode" value="${loginUser.roleCode}"/>
    <input type="hidden" id="userBranchId" value="${loginUser.branchId}"/>
    <input type="hidden" id="isAdminOrHigher" value="${loginUser.adminOrHigher}"/>
    <input type="hidden" id="isCaptain" value="${loginUser.captain}"/>
</sec:authorize>

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
                                    <th class="text-end">추정 손익 (세후)</th>
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

// 권한 정보 (hidden input에서 읽어옴)
const userPermissions = {
    roleCode: document.getElementById('userRoleCode')?.value || '',
    branchId: document.getElementById('userBranchId')?.value || '0',
    isAdminOrHigher: document.getElementById('isAdminOrHigher')?.value === 'true',
    isCaptain: document.getElementById('isCaptain')?.value === 'true'
};

// 페이지 로드 시 초기화
document.addEventListener('DOMContentLoaded', function() {
    // 기본 날짜 설정 (최근 6개월)
    const today = new Date();
    const sixMonthsAgo = new Date(today.getFullYear(), today.getMonth() - 6, 1);
    document.getElementById('startDate').value = formatDate(sixMonthsAgo);
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
    const select = document.getElementById('branchId');

    // 캡틴인 경우: 본인 지점만 선택 가능하도록 처리
    if (userPermissions.isCaptain && userPermissions.branchId && userPermissions.branchId !== '0') {
        try {
            const response = await fetch('/sales/api/options/branches');
            const branches = await response.json();

            // 전체 옵션 제거
            select.innerHTML = '';

            // 본인 지점만 추가
            const myBranch = branches.find(b => b && b.id && b.id.toString() === userPermissions.branchId);
            if (myBranch) {
                const option = document.createElement('option');
                option.value = myBranch.id;
                option.textContent = myBranch.name || '미지정';
                option.selected = true;
                select.appendChild(option);
            }

            // 선택 비활성화 (readonly 효과)
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
            height: 400,
            stacked: false
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
            categories: [],
            labels: {
                rotate: -45,
                rotateAlways: true,
                style: {
                    fontSize: '11px'
                }
            }
        },
        yaxis: {
            labels: {
                formatter: function(val) {
                    // 음수도 통화 형식으로 표시
                    return formatCurrency(val);
                }
            }
        },
        tooltip: {
            y: {
                formatter: function(val, { seriesIndex }) {
                    // 지출(seriesIndex=1)은 절대값으로 표시
                    if (seriesIndex === 1) {
                        return formatCurrency(Math.abs(val));
                    }
                    return formatCurrency(val);
                }
            }
        },
        legend: {
            position: 'top'
        }
    };

    comparisonChart = new ApexCharts(document.querySelector("#comparisonChart"), options);
    comparisonChart.render();
}

// 차트 업데이트
function updateChart(data) {
    // 기간 + 지점명을 조합하여 카테고리 생성
    const categories = data.map(item => {
        const period = item.periodLabel || item.period;
        const branch = item.branchName || '전체';
        return period + ' (' + branch + ')';
    });

    const salesValues = data.map(item => item.salesAmount || 0);
    // 지출은 음수로 변환하여 아래쪽으로 표시
    const expenseValues = data.map(item => -(item.expenseAmount || 0));
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

    // 테이블 바디 (각 행도 법인세 반영)
    tbody.innerHTML = data.map(item => {
        // 각 행별 세후 순이익 계산
        const grossProfit = (item.salesAmount || 0) - (item.expenseAmount || 0);
        const tax = calculateCorporateTax(grossProfit);
        const netProfit = grossProfit - tax;
        const profitRate = item.salesAmount > 0 ? ((netProfit / item.salesAmount) * 100) : 0;

        const profitClass = netProfit >= 0 ? 'text-success' : 'text-danger';
        const profitStatus = netProfit >= 0 ? 'PROFIT' : 'LOSS';

        return '<tr>' +
                '<td>' + (item.periodLabel || item.period) + '</td>' +
                '<td>' + (item.branchName || '전체') + '</td>' +
                '<td class="text-end">' + formatNumber(item.salesCount || 0) + '</td>' +
                '<td class="text-end">' + formatCurrency(item.salesAmount || 0) + '</td>' +
                '<td class="text-end">' + formatNumber(item.expenseCount || 0) + '</td>' +
                '<td class="text-end">' + formatCurrency(item.expenseAmount || 0) + '</td>' +
                '<td class="text-end ' + profitClass + '">' + formatCurrency(netProfit) + '</td>' +
                '<td class="text-end ' + profitClass + '">' + profitRate.toFixed(1) + '%</td>' +
                '<td>' +
                    '<span class="badge ' + getProfitBadgeClass(profitStatus) + '">' +
                        getProfitStatusName(profitStatus) +
                    '</span>' +
                '</td>' +
            '</tr>';
    }).join('');

    // 합계 행 (법인세 반영)
    const totalSales = data.reduce((sum, item) => sum + (item.salesAmount || 0), 0);
    const totalExpenses = data.reduce((sum, item) => sum + (item.expenseAmount || 0), 0);
    const grossProfit = totalSales - totalExpenses;  // 세전 순이익
    const corporateTax = calculateCorporateTax(grossProfit);  // 법인세
    const totalProfit = grossProfit - corporateTax;  // 세후 순이익 (추정)
    const totalRate = totalSales > 0 ? ((totalProfit / totalSales) * 100) : 0;
    const totalSalesCount = data.reduce((sum, item) => sum + (item.salesCount || 0), 0);
    const totalExpenseCount = data.reduce((sum, item) => sum + (item.expenseCount || 0), 0);

    const profitClass = totalProfit >= 0 ? 'text-success' : 'text-danger';

    document.getElementById('tableFoot').innerHTML =
        '<tr class="table-active fw-bold">' +
            '<td colspan="2">합계</td>' +
            '<td class="text-end">' + formatNumber(totalSalesCount) + '</td>' +
            '<td class="text-end">' + formatCurrency(totalSales) + '</td>' +
            '<td class="text-end">' + formatNumber(totalExpenseCount) + '</td>' +
            '<td class="text-end">' + formatCurrency(totalExpenses) + '</td>' +
            '<td class="text-end ' + profitClass + '">' + formatCurrency(totalProfit) + '</td>' +
            '<td class="text-end ' + profitClass + '">' + totalRate.toFixed(1) + '%</td>' +
            '<td>-</td>' +
        '</tr>';
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
</script>
