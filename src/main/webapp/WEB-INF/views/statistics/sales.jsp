<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<jsp:include page="../includes/admin_header.jsp" />

<!-- Main content -->
<div class="app-content-header">
    <div class="container-fluid">
        <div class="row">
            <div class="col-sm-6">
                <h3 class="mb-0">${pageTitle}</h3>
            </div>
            <div class="col-sm-6">
                <ol class="breadcrumb float-sm-end">
                    <li class="breadcrumb-item"><a href="<c:url value='/'/>">Home</a></li>
                    <li class="breadcrumb-item"><a href="<c:url value='/statistics'/>">정산·통계</a></li>
                    <li class="breadcrumb-item active">매출 통계</li>
                </ol>
            </div>
        </div>
    </div>
</div>

<div class="app-content">
    <div class="container-fluid">

        <!-- 탭 네비게이션 -->
        <div class="row mb-3">
            <div class="col-12">
                <ul class="nav nav-tabs" role="tablist">
                    <li class="nav-item">
                        <a class="nav-link ${activeTab eq 'branch' ? 'active' : ''}" href="<c:url value='/statistics/sales/by-branch'/>">
                            <i class="bi bi-building"></i> 지점별
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link ${activeTab eq 'category' ? 'active' : ''}" href="<c:url value='/statistics/sales/by-category'/>">
                            <i class="bi bi-tags"></i> 항목별
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link ${activeTab eq 'period' ? 'active' : ''}" href="<c:url value='/statistics/sales/by-period'/>">
                            <i class="bi bi-calendar-range"></i> 기간별
                        </a>
                    </li>
                </ul>
            </div>
        </div>

        <!-- 필터 영역 -->
        <div class="row mb-4">
            <div class="col-12">
                <div class="card">
                    <div class="card-body">
                        <form id="filterForm" class="row g-3">
                            <c:if test="${activeTab ne 'branch'}">
                                <div class="col-md-3">
                                    <label for="branchId" class="form-label">지점</label>
                                    <select class="form-select" id="branchId" name="branchId">
                                        <option value="0" selected>전체</option>
                                    </select>
                                </div>
                            </c:if>
                            <div class="col-md-3">
                                <label for="startDate" class="form-label">시작일</label>
                                <input type="date" class="form-control" id="startDate" name="startDate" required>
                            </div>
                            <div class="col-md-3">
                                <label for="endDate" class="form-label">종료일</label>
                                <input type="date" class="form-control" id="endDate" name="endDate" required>
                            </div>
                            <c:if test="${activeTab eq 'period'}">
                                <div class="col-md-3">
                                    <label for="groupBy" class="form-label">집계 단위</label>
                                    <select class="form-select" id="groupBy" name="groupBy">
                                        <option value="monthly">월별</option>
                                        <option value="quarterly">분기별</option>
                                        <option value="yearly">연도별</option>
                                    </select>
                                </div>
                            </c:if>
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

        <!-- 차트 영역 -->
        <div class="row mb-4">
            <div class="col-12">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">
                            <i class="bi bi-bar-chart-fill"></i>
                            매출 통계 차트
                        </h3>
                    </div>
                    <div class="card-body">
                        <div id="salesChart" style="height: 400px;"></div>
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
                            매출 통계 목록
                        </h3>
                    </div>
                    <div class="card-body p-0">
                        <table class="table table-striped">
                            <thead id="tableHead">
                                <!-- JavaScript로 동적 생성 -->
                            </thead>
                            <tbody id="tableBody">
                                <tr>
                                    <td colspan="6" class="text-center">
                                        <div class="spinner-border" role="status">
                                            <span class="visually-hidden">Loading...</span>
                                        </div>
                                    </td>
                                </tr>
                            </tbody>
                            <tfoot id="tableFoot">
                                <!-- JavaScript로 동적 생성 -->
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
const activeTab = '${activeTab}';
let salesChart;

// 페이지 로드 시 초기화
document.addEventListener('DOMContentLoaded', function() {
    // 기본 날짜 설정 (이번 달)
    const today = new Date();
    const firstDay = new Date(today.getFullYear(), today.getMonth(), 1);
    document.getElementById('startDate').value = formatDate(firstDay);
    document.getElementById('endDate').value = formatDate(today);

    // 지점 목록 로드 (지점별이 아닌 경우)
    if (activeTab !== 'branch') {
        loadBranchOptions();
    }

    // 차트 초기화
    initChart();

    // 테이블 헤더 설정
    setupTableHeader();

    // 데이터 로드
    loadStatistics();

    // 폼 제출 이벤트
    document.getElementById('filterForm').addEventListener('submit', function(e) {
        e.preventDefault();
        loadStatistics();
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

// 통계 데이터 로드
async function loadStatistics() {
    const formData = new FormData(document.getElementById('filterForm'));
    const params = new URLSearchParams(formData);

    let apiUrl;
    switch(activeTab) {
        case 'branch':
            apiUrl = '/statistics/api/sales/by-branch';
            break;
        case 'category':
            apiUrl = '/statistics/api/sales/by-category';
            break;
        case 'period':
            apiUrl = '/statistics/api/sales/by-period';
            break;
    }

    try {
        const response = await fetch(apiUrl + '?' + params.toString());
        const data = await response.json();

        updateChart(data);
        updateTable(data);
    } catch (error) {
        console.error('데이터 로드 실패:', error);
        document.getElementById('tableBody').innerHTML =
            '<tr><td colspan="6" class="text-center text-danger">데이터를 불러오는데 실패했습니다.</td></tr>';
    }
}

// 차트 초기화
function initChart() {
    const options = {
        series: [{
            name: '매출 금액',
            data: []
        }],
        chart: {
            type: 'bar',
            height: 400
        },
        colors: ['#0d6efd'],
        plotOptions: {
            bar: {
                horizontal: false,
                columnWidth: '55%',
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

    salesChart = new ApexCharts(document.querySelector("#salesChart"), options);
    salesChart.render();
}

// 차트 업데이트
function updateChart(data) {
    let categories, values;

    switch(activeTab) {
        case 'branch':
            categories = data.map(item => item.branchName || '미분류');
            break;
        case 'category':
            categories = data.map(item => item.categoryName || '미분류');
            break;
        case 'period':
            categories = data.map(item => item.periodLabel || item.period);
            break;
    }

    values = data.map(item => item.totalAmount || 0);

    salesChart.updateOptions({
        xaxis: { categories: categories },
        series: [{
            name: '매출 금액',
            data: values
        }]
    });
}

// 테이블 헤더 설정
function setupTableHeader() {
    let headerHtml = '<tr>';

    switch(activeTab) {
        case 'branch':
            headerHtml += '<th>지점명</th>';
            break;
        case 'category':
            headerHtml += '<th>항목</th>';
            break;
        case 'period':
            headerHtml += '<th>기간</th>';
            break;
    }

    headerHtml += `
        <th class="text-end">매출 건수</th>
        <th class="text-end">총 매출 금액</th>
        <th class="text-end">평균 매출 금액</th>
        <th class="text-end">평균 대비 차이</th>
        <th class="text-end">비율</th>
    </tr>`;

    document.getElementById('tableHead').innerHTML = headerHtml;
}

// 테이블 업데이트
function updateTable(data) {
    const tbody = document.getElementById('tableBody');

    if (!data || data.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" class="text-center">데이터가 없습니다.</td></tr>';
        document.getElementById('tableFoot').innerHTML = '';
        return;
    }

    // 테이블 바디
    tbody.innerHTML = data.map(item => {
        let firstColumn;
        switch(activeTab) {
            case 'branch':
                firstColumn = item.branchName || '미분류';
                break;
            case 'category':
                firstColumn = item.categoryName || '미분류';
                break;
            case 'period':
                firstColumn = item.periodLabel || item.period;
                break;
        }

        const diffClass = (item.diffPercent || 0) >= 0 ? 'text-success' : 'text-danger';

        return `
            <tr>
                <td>${firstColumn}</td>
                <td class="text-end">${formatNumber(item.saleCount || 0)}</td>
                <td class="text-end">${formatCurrency(item.totalAmount || 0)}</td>
                <td class="text-end">${formatCurrency(item.avgAmount || 0)}</td>
                <td class="text-end ${diffClass}">${formatCurrency(item.diffAmount || 0)}</td>
                <td class="text-end ${diffClass}">${(item.diffPercent || 0).toFixed(1)}%</td>
            </tr>
        `;
    }).join('');

    // 합계 행
    const totalAmount = data.reduce((sum, item) => sum + (item.totalAmount || 0), 0);
    const totalCount = data.reduce((sum, item) => sum + (item.saleCount || 0), 0);
    const avgAmount = totalCount > 0 ? totalAmount / totalCount : 0;

    document.getElementById('tableFoot').innerHTML = `
        <tr class="table-active fw-bold">
            <td>합계</td>
            <td class="text-end">${formatNumber(totalCount)}</td>
            <td class="text-end">${formatCurrency(totalAmount)}</td>
            <td class="text-end">${formatCurrency(avgAmount)}</td>
            <td class="text-end">-</td>
            <td class="text-end">-</td>
        </tr>
    `;
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
