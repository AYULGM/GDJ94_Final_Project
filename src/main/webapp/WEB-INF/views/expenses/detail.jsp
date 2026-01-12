<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<jsp:include page="../includes/admin_header.jsp" />

<!-- Main content -->
<div class="app-content-header">
    <div class="container-fluid">
        <div class="row">
            <div class="col-sm-6">
                <h3 class="mb-0">지출 상세</h3>
            </div>
            <div class="col-sm-6">
                <ol class="breadcrumb float-sm-end">
                    <li class="breadcrumb-item"><a href="<c:url value='/'/>">Home</a></li>
                    <li class="breadcrumb-item"><a href="<c:url value='/expenses'/>">지출 관리</a></li>
                    <li class="breadcrumb-item active">지출 상세</li>
                </ol>
            </div>
        </div>
    </div>
</div>

<div class="app-content">
    <div class="container-fluid">

        <div class="row">
            <div class="col-md-8 offset-md-2">
                <!-- 지출 정보 카드 -->
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">
                            <i class="bi bi-wallet2"></i>
                            지출 정보
                        </h3>
                    </div>

                    <div class="card-body">
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label fw-bold">지출 번호</label>
                                <p class="form-control-plaintext" id="expenseId">-</p>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">정산 여부</label>
                                <p class="form-control-plaintext" id="settlementFlag">-</p>
                            </div>
                        </div>

                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label fw-bold">지점</label>
                                <p class="form-control-plaintext" id="branchName">-</p>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">지출일</label>
                                <p class="form-control-plaintext" id="expenseAt">-</p>
                            </div>
                        </div>

                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label fw-bold">카테고리</label>
                                <p class="form-control-plaintext" id="categoryCode">-</p>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">금액</label>
                                <p class="form-control-plaintext" id="amount">-</p>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-bold">내용</label>
                            <p class="form-control-plaintext" id="description">-</p>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-bold">메모</label>
                            <p class="form-control-plaintext" id="memo">-</p>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-bold">담당자</label>
                            <p class="form-control-plaintext" id="handledBy">-</p>
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

                <!-- 버튼 영역 -->
                <div class="card mt-3">
                    <div class="card-footer">
                        <div class="d-flex justify-content-between">
                            <a href="<c:url value='/expenses'/>" class="btn btn-secondary">
                                <i class="bi bi-arrow-left"></i> 목록
                            </a>
                            <div>
                                <button type="button" class="btn btn-danger" onclick="deleteExpense()">
                                    <i class="bi bi-trash"></i> 삭제
                                </button>
                                <a href="#" class="btn btn-primary" id="editButton">
                                    <i class="bi bi-pencil"></i> 수정
                                </a>
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
const expenseId = '<c:out value="${expenseId}"/>';

// 페이지 로드
document.addEventListener('DOMContentLoaded', function() {
    loadExpenseDetail();
});

// 지출 상세 데이터 로드
async function loadExpenseDetail() {
    try {
        const response = await fetch(`/expenses/api/${expenseId}`);

        if (!response.ok) {
            throw new Error('데이터 로드 실패');
        }

        const expense = await response.json();

        // 지출 정보
        document.getElementById('expenseId').textContent = expense.expenseId;
        document.getElementById('branchName').textContent = expense.branchName || '-';
        document.getElementById('expenseAt').textContent = formatDateTime(expense.expenseAt);
        document.getElementById('categoryCode').textContent = getCategoryName(expense.categoryCode);
        document.getElementById('amount').textContent = formatCurrency(expense.amount);
        document.getElementById('description').textContent = expense.description || '-';
        document.getElementById('memo').textContent = expense.memo || '-';
        document.getElementById('handledBy').textContent = expense.handledByName || '-';

        // 정산 여부 뱃지
        const settlementBadge = expense.settlementFlag
            ? '<span class="badge bg-success">정산됨</span>'
            : '<span class="badge bg-warning">미정산</span>';
        document.getElementById('settlementFlag').innerHTML = settlementBadge;

        // 이력 정보
        document.getElementById('createUser').textContent = expense.createUserName || '-';
        document.getElementById('createDate').textContent = formatDateTime(expense.createDate);
        document.getElementById('updateUser').textContent = expense.updateUserName || '-';
        document.getElementById('updateDate').textContent = formatDateTime(expense.updateDate);

        // 수정 버튼 링크 설정
        document.getElementById('editButton').href = '/expenses/form?expenseId=' + expense.expenseId;

    } catch (error) {
        console.error('데이터 로드 실패:', error);
        alert('지출 정보를 불러오는데 실패했습니다.');
        window.location.href = '/expenses';
    }
}

// 삭제
async function deleteExpense() {
    if (!confirm('정말 삭제하시겠습니까?')) {
        return;
    }

    try {
        const response = await fetch(`/expenses/api/${expenseId}`, {
            method: 'DELETE'
        });

        if (response.ok) {
            const result = await response.json();
            alert(result.message);
            window.location.href = '/expenses';
        } else {
            throw new Error('삭제 실패');
        }
    } catch (error) {
        console.error('삭제 실패:', error);
        alert('지출 삭제에 실패했습니다.');
    }
}

// 카테고리 이름
function getCategoryName(code) {
    const categories = {
        'SALARY': '급여',
        'RENT': '임대료',
        'UTILITY': '공과금',
        'SUPPLY': '비품',
        'ETC': '기타'
    };
    return categories[code] || code;
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
