<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<jsp:include page="../includes/admin_header.jsp" />

<!-- Main content -->
<div class="app-content-header">
    <div class="container-fluid">
        <div class="row">
            <div class="col-sm-6">
                <h3 class="mb-0">정산 상세</h3>
            </div>
            <div class="col-sm-6">
                <ol class="breadcrumb float-sm-end">
                    <li class="breadcrumb-item"><a href="<c:url value='/'/>">Home</a></li>
                    <li class="breadcrumb-item"><a href="<c:url value='/settlements'/>">정산 내역 조회</a></li>
                    <li class="breadcrumb-item active">정산 상세</li>
                </ol>
            </div>
        </div>
    </div>
</div>

<div class="app-content">
    <div class="container-fluid">

        <div class="row">
            <div class="col-md-10 offset-md-1">
                <!-- 정산 정보 카드 -->
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">
                            <i class="bi bi-calculator"></i>
                            정산 정보
                        </h3>
                    </div>

                    <div class="card-body">
                        <div class="row mb-3">
                            <div class="col-md-4">
                                <label class="form-label fw-bold">정산 번호</label>
                                <p class="form-control-plaintext" id="settlementId">-</p>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-bold">정산번호</label>
                                <p class="form-control-plaintext" id="settlementNo">-</p>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-bold">상태</label>
                                <p class="form-control-plaintext" id="statusCode">-</p>
                            </div>
                        </div>

                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label fw-bold">지점</label>
                                <p class="form-control-plaintext" id="branchName">-</p>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">정산 기간</label>
                                <p class="form-control-plaintext" id="settlementPeriod">-</p>
                            </div>
                        </div>

                        <div class="row mb-3">
                            <div class="col-md-4">
                                <label class="form-label fw-bold">매출 건수</label>
                                <p class="form-control-plaintext" id="salesCount">-</p>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-bold">총 매출</label>
                                <p class="form-control-plaintext text-primary" id="salesAmount">-</p>
                            </div>
                        </div>

                        <div class="row mb-3">
                            <div class="col-md-4">
                                <label class="form-label fw-bold">지출 건수</label>
                                <p class="form-control-plaintext" id="expenseCount">-</p>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-bold">총 지출</label>
                                <p class="form-control-plaintext text-danger" id="expenseAmount">-</p>
                            </div>
                        </div>

                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label fw-bold">손익</label>
                                <p class="form-control-plaintext" id="profitAmount">-</p>
                            </div>
                        </div>

                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label fw-bold">정산 처리자</label>
                                <p class="form-control-plaintext" id="settledBy">-</p>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">정산 처리일</label>
                                <p class="form-control-plaintext" id="settledAt">-</p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 생성/수정 이력 카드 -->
                <div class="card mt-3">
                    <div class="card-header">
                        <h3 class="card-title">
                            <i class="bi bi-clock-history"></i>
                            이력 정보
                        </h3>
                    </div>
                    <div class="card-body">
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label fw-bold">생성자</label>
                                <p class="form-control-plaintext" id="createUser">-</p>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">생성일시</label>
                                <p class="form-control-plaintext" id="createDate">-</p>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6">
                                <label class="form-label fw-bold">수정자</label>
                                <p class="form-control-plaintext" id="updateUser">-</p>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">수정일시</label>
                                <p class="form-control-plaintext" id="updateDate">-</p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 정산 이력 카드 -->
                <div class="card mt-3">
                    <div class="card-header">
                        <h3 class="card-title">
                            <i class="bi bi-list-ul"></i>
                            정산 이력
                        </h3>
                    </div>
                    <div class="card-body p-0">
                        <table class="table table-sm">
                            <thead>
                                <tr>
                                    <th>일시</th>
                                    <th>상태</th>
                                    <th>처리자</th>
                                    <th>비고</th>
                                </tr>
                            </thead>
                            <tbody id="historyTableBody">
                                <tr>
                                    <td colspan="4" class="text-center">
                                        <div class="spinner-border spinner-border-sm" role="status">
                                            <span class="visually-hidden">Loading...</span>
                                        </div>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- 버튼 영역 -->
                <div class="card mt-3">
                    <div class="card-footer">
                        <div class="d-flex justify-content-between">
                            <a href="<c:url value='/settlements'/>" class="btn btn-secondary">
                                <i class="bi bi-arrow-left"></i> 목록
                            </a>
                            <div id="actionButtons">
                                <!-- JavaScript로 동적 생성 -->
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </div>
</div>

<jsp:include page="../includes/admin_footer.jsp" />

<script>
const settlementId = '<c:out value="${settlementId}"/>';

// 페이지 로드
document.addEventListener('DOMContentLoaded', function() {
    loadSettlementDetail();
    loadSettlementHistories();
});

// 정산 상세 데이터 로드
async function loadSettlementDetail() {
    try {
        const response = await fetch(`/settlements/api/${settlementId}`);

        if (!response.ok) {
            throw new Error('데이터 로드 실패');
        }

        const settlement = await response.json();

        // 정산 정보
        document.getElementById('settlementId').textContent = settlement.settlementId;
        document.getElementById('settlementNo').textContent = settlement.settlementNo || '-';
        document.getElementById('branchName').textContent = settlement.branchName || '-';
        document.getElementById('settlementPeriod').textContent =
            `${formatDate(settlement.fromDate)} ~ ${formatDate(settlement.toDate)}`;

        document.getElementById('salesCount').textContent = formatNumber(settlement.salesCount || 0) + ' 건';
        document.getElementById('salesAmount').textContent = formatCurrency(settlement.salesAmount || 0);

        document.getElementById('expenseCount').textContent = formatNumber(settlement.expenseCount || 0) + ' 건';
        document.getElementById('expenseAmount').textContent = formatCurrency(settlement.expenseAmount || 0);

        const profitClass = (settlement.profitAmount || 0) >= 0 ? 'text-success' : 'text-danger';
        document.getElementById('profitAmount').className = `form-control-plaintext fw-bold ${profitClass}`;
        document.getElementById('profitAmount').textContent = formatCurrency(settlement.profitAmount || 0);

        document.getElementById('settledBy').textContent = settlement.settledByName || '-';
        document.getElementById('settledAt').textContent = formatDateTime(settlement.settledAt);

        // 상태 뱃지
        const statusBadge = `<span class="badge ${getStatusBadgeClass(settlement.statusCode)}">${getStatusName(settlement.statusCode)}</span>`;
        document.getElementById('statusCode').innerHTML = statusBadge;

        // 이력 정보
        document.getElementById('createUser').textContent = settlement.createUserName || '-';
        document.getElementById('createDate').textContent = formatDateTime(settlement.createDate);
        document.getElementById('updateUser').textContent = settlement.updateUserName || '-';
        document.getElementById('updateDate').textContent = formatDateTime(settlement.updateDate);

        // 액션 버튼 렌더링
        renderActionButtons(settlement.statusCode);

    } catch (error) {
        console.error('데이터 로드 실패:', error);
        alert('정산 정보를 불러오는데 실패했습니다.');
        window.location.href = '/settlements';
    }
}

// 정산 이력 로드
async function loadSettlementHistories() {
    try {
        const response = await fetch(`/settlements/api/${settlementId}/histories`);
        const histories = await response.json();

        const tbody = document.getElementById('historyTableBody');

        if (!histories || histories.length === 0) {
            tbody.innerHTML = '<tr><td colspan="4" class="text-center">이력이 없습니다.</td></tr>';
            return;
        }

        tbody.innerHTML = histories.map(history => `
            <tr>
                <td>${formatDateTime(history.historyDate)}</td>
                <td>
                    <span class="badge ${getStatusBadgeClass(history.statusCode)}">
                        ${getStatusName(history.statusCode)}
                    </span>
                </td>
                <td>${history.handledByName || '-'}</td>
                <td>${history.reason || '-'}</td>
            </tr>
        `).join('');

    } catch (error) {
        console.error('이력 로드 실패:', error);
        document.getElementById('historyTableBody').innerHTML =
            '<tr><td colspan="4" class="text-center text-danger">이력을 불러오는데 실패했습니다.</td></tr>';
    }
}

// 액션 버튼 렌더링
function renderActionButtons(statusCode) {
    const buttonsDiv = document.getElementById('actionButtons');
    let buttons = '';

    if (statusCode === 'PENDING') {
        buttons += `
            <button type="button" class="btn btn-success" onclick="confirmSettlement()">
                <i class="bi bi-check-circle"></i> 확정
            </button>
            <button type="button" class="btn btn-warning" onclick="cancelSettlement()">
                <i class="bi bi-x-circle"></i> 취소
            </button>
        `;
    }

    buttons += `
        <button type="button" class="btn btn-danger" onclick="deleteSettlement()">
            <i class="bi bi-trash"></i> 삭제
        </button>
    `;

    buttonsDiv.innerHTML = buttons;
}

// 정산 확정
async function confirmSettlement() {
    const reason = prompt('확정 사유를 입력하세요 (선택):');
    if (reason === null) return;

    try {
        const response = await fetch(`/settlements/api/${settlementId}/confirm`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ reason: reason })
        });

        if (response.ok) {
            alert('정산이 확정되었습니다.');
            location.reload();
        } else {
            throw new Error('확정 실패');
        }
    } catch (error) {
        console.error('확정 실패:', error);
        alert('정산 확정에 실패했습니다.');
    }
}

// 정산 취소
async function cancelSettlement() {
    const reason = prompt('취소 사유를 입력하세요:');
    if (!reason) {
        alert('취소 사유를 입력해주세요.');
        return;
    }

    try {
        const response = await fetch(`/settlements/api/${settlementId}/cancel`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ reason: reason })
        });

        if (response.ok) {
            alert('정산이 취소되었습니다.');
            location.reload();
        } else {
            throw new Error('취소 실패');
        }
    } catch (error) {
        console.error('취소 실패:', error);
        alert('정산 취소에 실패했습니다.');
    }
}

// 정산 삭제
async function deleteSettlement() {
    if (!confirm('정말 삭제하시겠습니까?')) return;

    try {
        const response = await fetch(`/settlements/api/${settlementId}`, {
            method: 'DELETE'
        });

        if (response.ok) {
            alert('정산이 삭제되었습니다.');
            window.location.href = '/settlements';
        } else {
            throw new Error('삭제 실패');
        }
    } catch (error) {
        console.error('삭제 실패:', error);
        alert('정산 삭제에 실패했습니다.');
    }
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

// 날짜/시간 포맷
function formatDateTime(dateString) {
    if (!dateString) return '-';
    const date = new Date(dateString);
    return date.toLocaleString('ko-KR');
}

// 숫자 포맷
function formatNumber(value) {
    return new Intl.NumberFormat('ko-KR').format(value);
}

// 금액 포맷
function formatCurrency(value) {
    return new Intl.NumberFormat('ko-KR', {
        style: 'currency',
        currency: 'KRW'
    }).format(value);
}
</script>
