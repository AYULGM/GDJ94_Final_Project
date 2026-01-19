<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>

<jsp:include page="../includes/admin_header.jsp" />

<!-- 로그인 사용자 정보 -->
<sec:authorize access="isAuthenticated()">
    <sec:authentication property="principal" var="loginUser"/>
    <input type="hidden" id="userBranchId" value="${loginUser.branchId}"/>
</sec:authorize>


<div class="app-content">
    <div class="container-fluid">

        <div class="row">
            <div class="col-md-8 offset-md-2">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">매출 정보</h3>
                    </div>

                    <form id="saleForm">
                        <div class="card-body">
                            <input type="hidden" id="saleId" name="saleId" value="${param.saleId}">

                            <div class="row mb-3">
                                <div class="col-md-6">
                                    <label for="saleNo" class="form-label">매출번호</label>
                                    <input type="text" class="form-control" id="saleNo" name="saleNo" placeholder="자동 생성">
                                </div>
                                <div class="col-md-6">
                                    <label for="branchId" class="form-label">지점 <span class="text-danger">*</span></label>
                                    <select class="form-select" id="branchId" name="branchId" required>
                                        <option value="">선택하세요</option>
                                    </select>
                                </div>
                            </div>

                            <div class="row mb-3">
                                <div class="col-md-6">
                                    <label for="soldAt" class="form-label">판매일시 <span class="text-danger">*</span></label>
                                    <input type="datetime-local" class="form-control" id="soldAt" name="soldAt" required>
                                </div>
                                <div class="col-md-6">
                                    <label for="categoryCode" class="form-label">카테고리 <span class="text-danger">*</span></label>
                                    <select class="form-select" id="categoryCode" name="categoryCode" required>
                                        <option value="">선택하세요</option>
                                        <option value="MEMBERSHIP">회원권</option>
                                        <option value="PT">PT</option>
                                        <option value="GOODS">용품</option>
                                        <option value="ETC">기타</option>
                                    </select>
                                </div>
                            </div>

                            <div class="row mb-3">
                                <div class="col-md-6">
                                    <label for="totalAmount" class="form-label">금액 (원) <span class="text-danger">*</span></label>
                                    <input type="number" class="form-control" id="totalAmount" name="totalAmount" required min="0">
                                </div>
                                <div class="col-md-6">
                                    <label for="statusCode" class="form-label">상태 <span class="text-danger">*</span></label>
                                    <select class="form-select" id="statusCode" name="statusCode" required>
                                        <option value="PENDING">대기</option>
                                        <option value="CONFIRMED">확정</option>
                                        <option value="CANCELLED">취소</option>
                                    </select>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label for="memo" class="form-label">메모</label>
                                <textarea class="form-control" id="memo" name="memo" rows="3"></textarea>
                            </div>
                        </div>

                        <div class="card-footer">
                            <div class="d-flex justify-content-between">
                                <a href="<c:url value='/sales'/>" class="btn btn-secondary">
                                    <i class="bi bi-arrow-left"></i> 목록
                                </a>
                                <div>
                                    <c:if test="${not empty param.saleId}">
                                        <button type="button" class="btn btn-danger" onclick="deleteSale()">
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
const saleId = document.getElementById('saleId').value;
const isEditMode = saleId && saleId !== 'null' && saleId !== '';

// 페이지 로드
document.addEventListener('DOMContentLoaded', function() {
    // 제목 설정
    if (isEditMode) {
        document.getElementById('pageTitle').textContent = '매출 수정';
        document.getElementById('breadcrumbTitle').textContent = '매출 수정';
    }

    // 지점 목록 로드
    loadBranchOptions();

    // 수정 모드면 데이터 로드
    if (isEditMode) {
        loadSaleData();
    } else {
        // 등록 모드면 현재 시각 설정
        setCurrentDateTime();
    }

    // 폼 제출 이벤트
    document.getElementById('saleForm').addEventListener('submit', handleSubmit);
});

// 지점 옵션 로드 (등록 모드: 본인 지점 자동 선택)
async function loadBranchOptions() {
    try {
        const response = await fetch('/sales/api/options/branches');
        const branches = await response.json();

        const select = document.getElementById('branchId');
        const userBranchId = document.getElementById('userBranchId')?.value || '0';

        branches.filter(branch => branch != null && branch.id != null).forEach(branch => {
            const option = document.createElement('option');
            option.value = branch.id;
            option.textContent = branch.name || '미지정';
            select.appendChild(option);
        });

        // 등록 모드이고 본인 지점이 있으면 자동 선택
        if (!isEditMode && userBranchId && userBranchId !== '0') {
            select.value = userBranchId;
        }
    } catch (error) {
        console.error('지점 목록 로드 실패:', error);
    }
}

// 매출 데이터 로드 (수정 모드)
async function loadSaleData() {
    try {
        const response = await fetch(`/sales/api/${saleId}`);
        const sale = await response.json();

        // 폼에 데이터 채우기
        document.getElementById('saleNo').value = sale.saleNo || '';
        document.getElementById('branchId').value = sale.branchId;
        document.getElementById('soldAt').value = formatDateTimeLocal(sale.soldAt);
        document.getElementById('categoryCode').value = sale.categoryCode;
        document.getElementById('totalAmount').value = sale.totalAmount;
        document.getElementById('statusCode').value = sale.statusCode;
        document.getElementById('memo').value = sale.memo || '';
    } catch (error) {
        console.error('데이터 로드 실패:', error);
        alert('매출 정보를 불러오는데 실패했습니다.');
        window.location.href = '/sales';
    }
}

// 현재 시각 설정
function setCurrentDateTime() {
    const now = new Date();
    document.getElementById('soldAt').value = formatDateTimeLocal(now);
}

// 폼 제출
async function handleSubmit(e) {
    e.preventDefault();

    const formData = {
        saleId: saleId || null,
        saleNo: document.getElementById('saleNo').value || null,
        branchId: parseInt(document.getElementById('branchId').value),
        soldAt: document.getElementById('soldAt').value,
        categoryCode: document.getElementById('categoryCode').value,
        totalAmount: parseFloat(document.getElementById('totalAmount').value),
        statusCode: document.getElementById('statusCode').value,
        memo: document.getElementById('memo').value || null
    };

    try {
        const url = isEditMode ? `/sales/api/${saleId}` : '/sales/api';
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
            window.location.href = '/sales';
        } else {
            throw new Error('저장 실패');
        }
    } catch (error) {
        console.error('저장 실패:', error);
        alert('매출 정보 저장에 실패했습니다.');
    }
}

// 삭제
async function deleteSale() {
    if (!confirm('정말 삭제하시겠습니까?')) {
        return;
    }

    try {
        const response = await fetch(`/sales/api/${saleId}`, {
            method: 'DELETE'
        });

        if (response.ok) {
            const result = await response.json();
            alert(result.message);
            window.location.href = '/sales';
        } else {
            throw new Error('삭제 실패');
        }
    } catch (error) {
        console.error('삭제 실패:', error);
        alert('매출 삭제에 실패했습니다.');
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
