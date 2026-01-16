<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<jsp:include page="../includes/admin_header.jsp" />



<div class="app-content">
    <div class="container-fluid">

        <div class="row">
            <div class="col-md-8 offset-md-2">
                <!-- 매출 정보 카드 -->
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">
                            <i class="bi bi-receipt"></i>
                            매출 정보
                        </h3>
                    </div>

                    <div class="card-body">
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label fw-bold">매출 번호</label>
                                <p class="form-control-plaintext" id="saleId">-</p>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">매출번호</label>
                                <p class="form-control-plaintext" id="saleNo">-</p>
                            </div>
                        </div>

                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label fw-bold">지점</label>
                                <p class="form-control-plaintext" id="branchName">-</p>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">판매일시</label>
                                <p class="form-control-plaintext" id="soldAt">-</p>
                            </div>
                        </div>

                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label fw-bold">카테고리</label>
                                <p class="form-control-plaintext" id="categoryCode">-</p>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">금액</label>
                                <p class="form-control-plaintext" id="totalAmount">-</p>
                            </div>
                        </div>

                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label fw-bold">상태</label>
                                <p class="form-control-plaintext" id="statusCode">-</p>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-bold">메모</label>
                            <p class="form-control-plaintext" id="memo">-</p>
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
                            <a href="<c:url value='/sales'/>" class="btn btn-secondary">
                                <i class="bi bi-arrow-left"></i> 목록
                            </a>
                            <div>
                                <button type="button" class="btn btn-danger" onclick="deleteSale()">
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
const saleId = '<c:out value="${saleId}"/>';

// 페이지 로드
document.addEventListener('DOMContentLoaded', function() {
    loadSaleDetail();
});

// 매출 상세 데이터 로드
async function loadSaleDetail() {
    try {
        const response = await fetch(`/sales/api/${saleId}`);

        if (!response.ok) {
            throw new Error('데이터 로드 실패');
        }

        const sale = await response.json();

        // 매출 정보
        document.getElementById('saleId').textContent = sale.saleId;
        document.getElementById('saleNo').textContent = sale.saleNo || '-';
        document.getElementById('branchName').textContent = sale.branchName || '-';
        document.getElementById('soldAt').textContent = formatDateTime(sale.soldAt);
        document.getElementById('categoryCode').textContent = getCategoryName(sale.categoryCode);
        document.getElementById('totalAmount').textContent = formatCurrency(sale.totalAmount);
        document.getElementById('memo').textContent = sale.memo || '-';

        // 상태 뱃지
        const statusBadge = '<span class="badge ' + getStatusBadgeClass(sale.statusCode) + '">' + getStatusName(sale.statusCode) + '</span>';
        document.getElementById('statusCode').innerHTML = statusBadge;

        // 이력 정보
        document.getElementById('createUser').textContent = sale.createUserName || '-';
        document.getElementById('createDate').textContent = formatDateTime(sale.createDate);
        document.getElementById('updateUser').textContent = sale.updateUserName || '-';
        document.getElementById('updateDate').textContent = formatDateTime(sale.updateDate);

        // 수정 버튼 링크 설정
        document.getElementById('editButton').href = '/sales/form?saleId=' + sale.saleId;

    } catch (error) {
        console.error('데이터 로드 실패:', error);
        alert('매출 정보를 불러오는데 실패했습니다.');
        window.location.href = '/sales';
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

// 카테고리 이름
function getCategoryName(code) {
    const categories = {
        'MEMBERSHIP': '회원권',
        'PT': 'PT',
        'GOODS': '용품',
        'ETC': '기타'
    };
    return categories[code] || code;
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
