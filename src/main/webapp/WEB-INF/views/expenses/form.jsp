<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>

<jsp:include page="../includes/admin_header.jsp" />

<!-- 로그인 사용자 정보 -->
<sec:authorize access="isAuthenticated()">
    <sec:authentication property="principal" var="loginUser"/>
    <input type="hidden" id="userBranchId" value="${loginUser.branchId}"/>
    <input type="hidden" id="userId" value="${loginUser.userId}"/>
</sec:authorize>

<!-- Main content -->
<div class="app-content-header">
    <div class="container-fluid">
        <div class="row">
            <div class="col-sm-6">
                <h3 class="mb-0" id="pageTitle">지출 등록</h3>
            </div>
            <div class="col-sm-6">
                <ol class="breadcrumb float-sm-end">
                    <li class="breadcrumb-item"><a href="<c:url value='/'/>">Home</a></li>
                    <li class="breadcrumb-item"><a href="<c:url value='/expenses'/>">지출 관리</a></li>
                    <li class="breadcrumb-item active" id="breadcrumbTitle">지출 등록</li>
                </ol>
            </div>
        </div>
    </div>
</div>

<div class="app-content">
    <div class="container-fluid">

        <div class="row">
            <div class="col-md-8 offset-md-2">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">지출 정보</h3>
                    </div>

                    <form id="expenseForm">
                        <div class="card-body">
                            <input type="hidden" id="expenseId" name="expenseId" value="${param.expenseId}">

                            <div class="row mb-3">
                                <div class="col-md-6">
                                    <label for="branchId" class="form-label">지점 <span class="text-danger">*</span></label>
                                    <select class="form-select" id="branchId" name="branchId" required>
                                        <option value="">선택하세요</option>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label for="expenseAt" class="form-label">지출일 <span class="text-danger">*</span></label>
                                    <input type="datetime-local" class="form-control" id="expenseAt" name="expenseAt" required>
                                </div>
                            </div>

                            <div class="row mb-3">
                                <div class="col-md-6">
                                    <label for="categoryCode" class="form-label">카테고리 <span class="text-danger">*</span></label>
                                    <select class="form-select" id="categoryCode" name="categoryCode" required>
                                        <option value="">선택하세요</option>
                                        <option value="SALARY">급여</option>
                                        <option value="RENT">임대료</option>
                                        <option value="UTILITY">공과금</option>
                                        <option value="SUPPLY">비품</option>
                                        <option value="ETC">기타</option>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label for="amount" class="form-label">금액 (원) <span class="text-danger">*</span></label>
                                    <input type="number" class="form-control" id="amount" name="amount" required min="0">
                                </div>
                            </div>

                            <div class="mb-3">
                                <label for="description" class="form-label">내용 <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" id="description" name="description" required maxlength="200">
                            </div>

                            <div class="mb-3">
                                <label for="memo" class="form-label">메모</label>
                                <textarea class="form-control" id="memo" name="memo" rows="3"></textarea>
                            </div>

                            <!-- 담당자 (숨김 - 자동 설정) -->
                            <input type="hidden" id="handledBy" name="handledBy">

                            <div class="row mb-3">
                                <div class="col-md-6">
                                    <label for="settlementFlag" class="form-label">정산 여부</label>
                                    <select class="form-select" id="settlementFlag" name="settlementFlag">
                                        <option value="false">미정산</option>
                                        <option value="true">정산됨</option>
                                    </select>
                                </div>
                            </div>
                        </div>

                        <div class="card-footer">
                            <div class="d-flex justify-content-between">
                                <a href="<c:url value='/expenses'/>" class="btn btn-secondary">
                                    <i class="bi bi-arrow-left"></i> 목록
                                </a>
                                <div>
                                    <c:if test="${not empty param.expenseId}">
                                        <button type="button" class="btn btn-danger" onclick="deleteExpense()">
                                            <i class="bi bi-trash"></i> 삭제
                                        </button>
                                    </c:if>
                                    <button type="submit" class="btn btn-primary">
                                        <i class="bi bi-save"></i> 저장
                                    </button>
                                </div>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>

    </div>
</div>

<jsp:include page="../includes/admin_footer.jsp" />

<script>
const expenseId = document.getElementById('expenseId').value;
const isEditMode = expenseId && expenseId !== 'null' && expenseId !== '';

// 페이지 로드
document.addEventListener('DOMContentLoaded', function() {
    // 제목 설정
    if (isEditMode) {
        document.getElementById('pageTitle').textContent = '지출 수정';
        document.getElementById('breadcrumbTitle').textContent = '지출 수정';
    }

    // 지점 목록 로드
    loadBranchOptions();

    // 수정 모드면 데이터 로드
    if (isEditMode) {
        loadExpenseData();
    } else {
        // 등록 모드면 현재 시각 설정
        setCurrentDateTime();
    }

    // 폼 제출 이벤트
    document.getElementById('expenseForm').addEventListener('submit', handleSubmit);
});

// 지점 옵션 로드 (등록 모드: 본인 지점 자동 선택)
async function loadBranchOptions() {
    try {
        const response = await fetch('/expenses/api/options/branches');
        const branches = await response.json();

        const select = document.getElementById('branchId');
        const userBranchId = document.getElementById('userBranchId')?.value || '0';
        const userId = document.getElementById('userId')?.value || '';

        branches.filter(branch => branch != null && branch.id != null).forEach(branch => {
            const option = document.createElement('option');
            option.value = branch.id;
            option.textContent = branch.name || '미지정';
            select.appendChild(option);
        });

        // 등록 모드이면 본인 지점/담당자 자동 설정
        if (!isEditMode) {
            if (userBranchId && userBranchId !== '0') {
                select.value = userBranchId;
            }
            if (userId) {
                document.getElementById('handledBy').value = userId;
            }
        }
    } catch (error) {
        console.error('지점 목록 로드 실패:', error);
    }
}

// 지출 데이터 로드 (수정 모드)
async function loadExpenseData() {
    try {
        const response = await fetch(`/expenses/api/${expenseId}`);
        const expense = await response.json();

        // 폼에 데이터 채우기
        document.getElementById('branchId').value = expense.branchId;
        document.getElementById('expenseAt').value = formatDateTimeLocal(expense.expenseAt);
        document.getElementById('categoryCode').value = expense.categoryCode;
        document.getElementById('amount').value = expense.amount;
        document.getElementById('description').value = expense.description || '';
        document.getElementById('memo').value = expense.memo || '';
        document.getElementById('handledBy').value = expense.handledBy || '';
        document.getElementById('settlementFlag').value = expense.settlementFlag ? 'true' : 'false';
    } catch (error) {
        console.error('데이터 로드 실패:', error);
        alert('지출 정보를 불러오는데 실패했습니다.');
        window.location.href = '/expenses';
    }
}

// 현재 시각 설정
function setCurrentDateTime() {
    const now = new Date();
    document.getElementById('expenseAt').value = formatDateTimeLocal(now);
}

// 폼 제출
async function handleSubmit(e) {
    e.preventDefault();

    const formData = {
        expenseId: expenseId || null,
        branchId: parseInt(document.getElementById('branchId').value),
        expenseAt: document.getElementById('expenseAt').value,
        categoryCode: document.getElementById('categoryCode').value,
        amount: parseFloat(document.getElementById('amount').value),
        description: document.getElementById('description').value,
        memo: document.getElementById('memo').value || null,
        handledBy: document.getElementById('handledBy').value ? parseInt(document.getElementById('handledBy').value) : null,
        settlementFlag: document.getElementById('settlementFlag').value === 'true'
    };

    try {
        const url = isEditMode ? `/expenses/api/${expenseId}` : '/expenses/api';
        const method = isEditMode ? 'PUT' : 'POST';

        const response = await fetch(url, {
            method: method,
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(formData)
        });

        if (response.ok) {
            const result = await response.json();
            alert(result.message);
            window.location.href = '/expenses';
        } else {
            throw new Error('저장 실패');
        }
    } catch (error) {
        console.error('저장 실패:', error);
        alert('지출 정보 저장에 실패했습니다.');
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

// datetime-local 포맷
function formatDateTimeLocal(dateString) {
    const date = new Date(dateString);
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    return `${year}-${month}-${day}T${hours}:${minutes}`;
}
</script>
