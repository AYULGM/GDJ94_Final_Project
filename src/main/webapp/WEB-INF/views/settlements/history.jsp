<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<jsp:include page="../includes/admin_header.jsp" />



<div class="app-content">
    <div class="container-fluid">

        <!-- 검색 필터 -->
        <div class="row mb-3">
            <div class="col-12">
                <div class="card">
                    <div class="card-body">
                        <form id="searchForm" class="row g-3">
                            <div class="col-md-2">
                                <label class="form-label">정산 번호</label>
                                <input type="number" class="form-control" id="settlementId" name="settlementId" placeholder="전체">
                            </div>
                            <div class="col-md-2">
                                <label class="form-label">작업내용</label>
                                <select class="form-select" id="actionType" name="actionType">
                                    <option value="">전체</option>
                                    <option value="CREATE">생성</option>
                                    <option value="CONFIRM">확정</option>
                                    <option value="CANCEL">취소</option>
                                    <option value="UPDATE">수정</option>
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
                        <h3 class="card-title">정산 처리 이력</h3>
                    </div>

                    <div class="card-body p-0">
                        <table class="table table-striped table-sm">
                            <thead>
                                <tr>
                                    <th>정산번호</th>
                                    <th>정산코드</th>
                                    <th>작업내용</th>
                                    <th>변경전</th>
                                    <th>변경후</th>
                                    <th>처리자</th>
                                    <th>처리일시</th>
                                    <th>비고</th>
                                </tr>
                            </thead>
                            <tbody id="historyTableBody">
                                <tr>
                                    <td colspan="8" class="text-center">
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
const pageSize = 20;

// 페이지 로드
document.addEventListener('DOMContentLoaded', function() {
    // 검색 폼 이벤트
    document.getElementById('searchForm').addEventListener('submit', function(e) {
        e.preventDefault();
        currentPage = 1;
        loadHistoryList();
    });

    // 초기 데이터 로드
    loadHistoryList();
});

// 정산 이력 목록 로드
async function loadHistoryList() {
    try {
        const tbody = document.getElementById('historyTableBody');
        tbody.innerHTML = '<tr><td colspan="8" class="text-center"><div class="spinner-border spinner-border-sm"></div></td></tr>';

        // 정산 목록 조회
        const settlementsResponse = await fetch('/settlements/api/list?page=1&pageSize=100');
        if (!settlementsResponse.ok) {
            throw new Error('정산 목록 조회 실패: ' + settlementsResponse.status);
        }
        const settlementsData = await settlementsResponse.json();

        if (!settlementsData.list || settlementsData.list.length === 0) {
            tbody.innerHTML = '<tr><td colspan="8" class="text-center">정산 이력이 없습니다.</td></tr>';
            return;
        }

        // 각 정산의 이력 조회 (에러 처리 강화)
        const historyPromises = settlementsData.list.map(async function(settlement) {
            try {
                const response = await fetch('/settlements/api/' + settlement.settlementId + '/histories');
                if (!response.ok) {
                    console.warn('이력 조회 실패: settlementId=' + settlement.settlementId);
                    return [];
                }
                const histories = await response.json();
                // 배열인지 확인
                if (!Array.isArray(histories)) {
                    console.warn('이력이 배열이 아님: settlementId=' + settlement.settlementId);
                    return [];
                }
                return histories.map(function(h) {
                    return Object.assign({}, h, { settlementNo: settlement.settlementNo });
                });
            } catch (e) {
                console.warn('이력 조회 에러: settlementId=' + settlement.settlementId, e);
                return [];
            }
        });

        const allHistoriesArrays = await Promise.all(historyPromises);
        const allHistories = allHistoriesArrays.flat();

        // 날짜순 정렬 (최신순)
        allHistories.sort(function(a, b) {
            return new Date(b.actedAt) - new Date(a.actedAt);
        });

        renderHistoryTable(allHistories);

    } catch (error) {
        console.error('목록 로드 실패:', error);
        document.getElementById('historyTableBody').innerHTML =
            '<tr><td colspan="8" class="text-center text-danger">데이터를 불러오는데 실패했습니다.</td></tr>';
    }
}

// 테이블 렌더링
function renderHistoryTable(histories) {
    const tbody = document.getElementById('historyTableBody');

    if (!histories || histories.length === 0) {
        tbody.innerHTML = '<tr><td colspan="8" class="text-center">정산 이력이 없습니다.</td></tr>';
        return;
    }

    // 검색 필터 적용
    const searchForm = new FormData(document.getElementById('searchForm'));
    const settlementIdFilter = searchForm.get('settlementId');
    const actionTypeFilter = searchForm.get('actionType');
    const startDateFilter = searchForm.get('startDate');
    const endDateFilter = searchForm.get('endDate');

    let filtered = histories;

    if (settlementIdFilter) {
        filtered = filtered.filter(h => h.settlementId == settlementIdFilter);
    }
    if (actionTypeFilter) {
        filtered = filtered.filter(h => h.actionType === actionTypeFilter);
    }
    if (startDateFilter) {
        const startDate = new Date(startDateFilter);
        filtered = filtered.filter(h => new Date(h.actedAt) >= startDate);
    }
    if (endDateFilter) {
        const endDate = new Date(endDateFilter);
        endDate.setHours(23, 59, 59);
        filtered = filtered.filter(h => new Date(h.actedAt) <= endDate);
    }

    // 페이징 처리
    const start = (currentPage - 1) * pageSize;
    const end = start + pageSize;
    const paged = filtered.slice(start, end);

    tbody.innerHTML = paged.map(history =>
        '<tr>' +
            '<td>' +
                '<a href="/settlements/' + history.settlementId + '?readonly=true">' +
                    history.settlementId +
                '</a>' +
            '</td>' +
            '<td>' + (history.settlementNo || '-') + '</td>' +
            '<td>' +
                '<span class="badge ' + getActionBadgeClass(history.actionType) + '">' +
                    getActionName(history.actionType) +
                '</span>' +
            '</td>' +
            '<td>' +
                '<span class="badge ' + getStatusBadgeClass(history.beforeStatus) + '">' +
                    getStatusName(history.beforeStatus) +
                '</span>' +
            '</td>' +
            '<td>' +
                '<span class="badge ' + getStatusBadgeClass(history.afterStatus) + '">' +
                    getStatusName(history.afterStatus) +
                '</span>' +
            '</td>' +
            '<td>' + (history.actorUserName || '-') + '</td>' +
            '<td>' + formatDateTime(history.actedAt) + '</td>' +
            '<td>' + (history.reason || '-') + '</td>' +
        '</tr>'
    ).join('');

    // 페이징
    const totalPages = Math.ceil(filtered.length / pageSize);
    renderPagination(currentPage, totalPages);
}

// 페이징 렌더링
function renderPagination(current, total) {
    const pagination = document.getElementById('pagination');

    if (total <= 1) {
        pagination.innerHTML = '';
        return;
    }

    let html = '';

    if (current > 1) {
        html += '<li class="page-item"><a class="page-link" href="#" onclick="goToPage(' + (current - 1) + '); return false;">«</a></li>';
    }

    const startPage = Math.max(1, current - 2);
    const endPage = Math.min(total, current + 2);

    for (let i = startPage; i <= endPage; i++) {
        html += '<li class="page-item ' + (i === current ? 'active' : '') + '">' +
            '<a class="page-link" href="#" onclick="goToPage(' + i + '); return false;">' + i + '</a>' +
        '</li>';
    }

    if (current < total) {
        html += '<li class="page-item"><a class="page-link" href="#" onclick="goToPage(' + (current + 1) + '); return false;">»</a></li>';
    }

    pagination.innerHTML = html;
}

// 페이지 이동
function goToPage(page) {
    currentPage = page;
    loadHistoryList();
}

// 액션 이름
function getActionName(action) {
    const actions = {
        'CREATE': '생성',
        'CONFIRM': '확정',
        'CANCEL': '취소',
        'UPDATE': '수정'
    };
    return actions[action] || action;
}

// 액션 뱃지 클래스
function getActionBadgeClass(action) {
    const classes = {
        'CREATE': 'bg-primary',
        'CONFIRM': 'bg-success',
        'CANCEL': 'bg-danger',
        'UPDATE': 'bg-warning'
    };
    return classes[action] || 'bg-secondary';
}

// 상태 이름
function getStatusName(status) {
    if (!status) return '-';
    const statuses = {
        'PENDING': '대기',
        'CONFIRMED': '확정',
        'CANCELLED': '취소'
    };
    return statuses[status] || status;
}

// 상태 뱃지 클래스
function getStatusBadgeClass(status) {
    if (!status) return 'bg-light text-dark';
    const classes = {
        'PENDING': 'bg-warning',
        'CONFIRMED': 'bg-success',
        'CANCELLED': 'bg-danger'
    };
    return classes[status] || 'bg-secondary';
}

// 날짜/시간 포맷
function formatDateTime(dateString) {
    if (!dateString) return '-';
    const date = new Date(dateString);
    return date.toLocaleString('ko-KR');
}
</script>
