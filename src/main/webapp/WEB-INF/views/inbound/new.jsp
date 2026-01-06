<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../includes/admin_header.jsp" />

<div class="container-fluid py-3">

    <div class="d-flex justify-content-between align-items-center mb-3">
        <h3 class="mb-0">구매요청서(PR) - 입고요청 등록</h3>
        <a class="btn btn-outline-secondary" href="<c:url value='/inbound'/>">목록</a>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-danger">${error}</div>
    </c:if>
    <c:if test="${not empty message}">
        <div class="alert alert-success">${message}</div>
    </c:if>

    <form method="post" action="<c:url value='/inbound'/>" id="inboundForm">

        <div class="card mb-3">
            <div class="card-header">기본 정보</div>
            <div class="card-body">

                <div class="row g-2">
                    <div class="col-md-6">
                        <label class="form-label">공급처</label>
                        <input type="text" class="form-control" name="vendorName" required />
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">문서 제목</label>
                        <input type="text" class="form-control" name="title" required maxlength="200"/>
                    </div>

                    <div class="col-12 mt-2">
                        <label class="form-label">비고</label>
                        <textarea class="form-control" name="memo" rows="3"></textarea>
                    </div>
                </div>

            </div>
        </div>

        <div class="card mb-3">
            <div class="card-header d-flex justify-content-between align-items-center">
                <span>구매요청 품목(다품목)</span>
                <button type="button" class="btn btn-sm btn-outline-primary" onclick="addRow()">+ 품목 추가</button>
            </div>
            <div class="card-body">

                <table class="table table-bordered align-middle" id="itemsTable">
                    <thead>
                    <tr>
                        <th style="width: 35%;">상품</th>
                        <th style="width: 15%;">수량</th>
                        <th style="width: 15%;">단가(선택)</th>
                        <th>품목별 비고(선택)</th>
                        <th style="width: 8%;">삭제</th>
                    </tr>
                    </thead>
                    <tbody id="itemsTbody">
                    <tr>
                        <td>
                            <select class="form-select" name="items[0].productId" required>
                                <option value="">상품 선택</option>
                                <c:forEach var="p" items="${products}">
                                    <option value="${p.id}">${p.name}</option>
                                </c:forEach>
                            </select>
                        </td>
                        <td><input type="number" class="form-control" name="items[0].quantity" min="1" step="1" required/></td>
                        <td><input type="number" class="form-control" name="items[0].unitPrice" min="0" step="1"/></td>
                        <td><input type="text" class="form-control" name="items[0].lineMemo" maxlength="255"/></td>
                        <td class="text-center">
                            <button type="button" class="btn btn-sm btn-outline-danger" onclick="removeRow(this)">X</button>
                        </td>
                    </tr>
                    </tbody>
                </table>

                <div class="text-muted">
                    저장하면 <b>전자결재 임시문서</b>가 자동 생성되고, 바로 <b>결재선 지정</b> 화면으로 이동합니다.
                </div>

            </div>
        </div>

        <div class="d-flex gap-2">
            <button type="submit" class="btn btn-primary">등록 & 결재선 지정</button>
            <a class="btn btn-outline-secondary" href="<c:url value='/inbound'/>">취소</a>
        </div>

    </form>

</div>

<script>
    let rowIndex = 1;

    function addRow() {
        const tbody = document.getElementById("itemsTbody");
        const tr = document.createElement("tr");
        tr.innerHTML = `
      <td>
        <select class="form-select" name="items[${rowIndex}].productId" required>
          <option value="">상품 선택</option>
          ${buildProductOptions()}
        </select>
      </td>
      <td><input type="number" class="form-control" name="items[${rowIndex}].quantity" min="1" step="1" required/></td>
      <td><input type="number" class="form-control" name="items[${rowIndex}].unitPrice" min="0" step="1"/></td>
      <td><input type="text" class="form-control" name="items[${rowIndex}].lineMemo" maxlength="255"/></td>
      <td class="text-center">
        <button type="button" class="btn btn-sm btn-outline-danger" onclick="removeRow(this)">X</button>
      </td>
    `;
        tbody.appendChild(tr);
        rowIndex++;
    }

    function removeRow(btn) {
        const tbody = document.getElementById("itemsTbody");
        if (tbody.rows.length <= 1) {
            alert("품목은 최소 1개 필요합니다.");
            return;
        }
        btn.closest("tr").remove();
        reindexNames();
    }

    function reindexNames() {
        const tbody = document.getElementById("itemsTbody");
        const rows = tbody.querySelectorAll("tr");
        rowIndex = 0;

        rows.forEach((tr) => {
            tr.querySelectorAll("select, input").forEach((el) => {
                const name = el.getAttribute("name");
                if (!name) return;
                el.setAttribute("name", name.replace(/items\\[\\d+\\]\\./, "items[" + rowIndex + "]."));
            });
            rowIndex++;
        });
    }

    function buildProductOptions() {
        const firstSelect = document.querySelector("select[name='items[0].productId']");
        let html = "";
        for (let i = 0; i < firstSelect.options.length; i++) {
            const opt = firstSelect.options[i];
            if (!opt.value) continue;
            html += `<option value="${opt.value}">${opt.text}</option>`;
        }
        return html;
    }
</script>

<jsp:include page="../includes/admin_footer.jsp" />
