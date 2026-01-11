package com.health.app.approval;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.health.app.expenses.ExpenseDto;
import com.health.app.expenses.ExpenseMapper;
import com.health.app.inbound.InboundRequestService;
import com.health.app.inventory.InventoryDetailDto;
import com.health.app.inventory.InventoryMapper;
import com.health.app.purchase.PurchaseRequestDto;
import com.health.app.purchase.PurchaseService;
import com.health.app.sales.SaleDto;
import com.health.app.sales.SaleMapper;
import com.health.app.sales.SaleStatus;
import com.health.app.settlements.SettlementDto;
import com.health.app.settlements.SettlementMapper;
import com.health.app.settlements.SettlementStatus;

import lombok.Data;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
@Transactional
public class ApprovalApplyService {

    private final ApprovalMapper approvalMapper;

    private final ExpenseMapper expenseMapper;
    private final SettlementMapper settlementMapper;
    private final SaleMapper saleMapper;
    private final InventoryMapper inventoryMapper;

    private final ObjectMapper objectMapper;
    private final PurchaseService purchaseService;
    private final InboundRequestService inboundRequestService;
    /**
     * 결재문서(상신 시점 또는 최종승인 시점 등)에 맞춰
     * 실제 업무 테이블로 반영.
     *
     * 현재 구현: AT001~AT004 DTO 변환 방식 반영.
     */
    public void applyApprovedDoc(Long docVerId, Long actorUserId) {

        ApprovalDraftDTO draft = approvalMapper.selectDraftByDocVerId(docVerId);
        if (draft == null) {
            throw new IllegalStateException("draft not found: " + docVerId);
        }

        switch (draft.getTypeCode()) {

        case "AT001" -> applyExpense(draft, actorUserId);
        case "AT002" -> applySettlement(draft, actorUserId);
        case "AT003" -> applySales(draft, actorUserId);
        case "AT004" -> applyInventoryAdjust(draft, actorUserId);

        case "AT005" -> applyPurchaseRequest(draft, actorUserId);
        case "AT006" -> applyInboundRequest(draft, actorUserId);

        default -> {
            throw new UnsupportedOperationException(
                "Unsupported typeCode: " + draft.getTypeCode()
            );
        }
    }

    }

    /* =========================================================
     * AT001 지출 (expenses)
     * - form: extNo1(branchId), extNo2(total), extTxt3(reason), extTxt6(items json)
     * - mapper: ExpenseMapper.insertExpense(ExpenseDto)
     * ========================================================= */
    private void applyExpense(ApprovalDraftDTO draft, Long actorUserId) {

        Long branchId = draft.getExtNo1();
        if (branchId == null || branchId <= 0) {
            throw new IllegalArgumentException("AT001: branchId(extNo1)가 없습니다.");
        }

        // extTxt6: [{item, amount, date, memo}, ...]
        List<ExpenseLine> lines = readJsonList(draft.getExtTxt6(), new TypeReference<List<ExpenseLine>>() {});
        if (lines == null || lines.isEmpty()) {
            // 총액만 있고 라인이 없을 수도 있으니 정책적으로 허용/차단 결정
            throw new IllegalArgumentException("AT001: 지출 내역(extTxt6)이 비어 있습니다.");
        }

        // 대표일자: 첫 라인의 date 우선, 없으면 now
        LocalDateTime expenseAt = (lines.get(0).getDate() != null)
                ? lines.get(0).getDate().atStartOfDay()
                : LocalDateTime.now();

        BigDecimal amount = toBigDecimalOrNull(draft.getExtNo2());
        if (amount == null) {
            // 총액(extNo2)이 없으면 라인 합계로 계산
            amount = sumExpenseAmount(lines);
        }

        // category_code는 프로젝트에서 FK 여부가 불명확하므로,
        // 우선 "ETC"로 고정(필요 시 실제 코드셋에 맞게 매핑 함수 수정)
        String categoryCode = "ETC";

        ExpenseDto dto = ExpenseDto.builder()
                .branchId(branchId)
                .expenseAt(expenseAt)
                .categoryCode(categoryCode)
                .amount(amount)
                .description(draft.getExtTxt3()) // 사유
                .memo(draft.getBody())           // 기안 내용
                .settlementFlag(true)            // ExpenseService 기본값과 동일 정책
                .createUser(actorUserId)
                .useYn(true)
                .build();

        expenseMapper.insertExpense(dto);
    }

    private BigDecimal sumExpenseAmount(List<ExpenseLine> lines) {
        BigDecimal sum = BigDecimal.ZERO;
        for (ExpenseLine l : lines) {
            if (l != null && l.getAmount() != null) {
                sum = sum.add(l.getAmount());
            }
        }
        return sum;
    }

    /* =========================================================
     * AT002 정산 (settlement)
     * - form: extDt1~2(period), extNo1~3(amounts), extTxt2(memo)
     * - mapper: SettlementMapper.insertSettlement(SettlementDto)
     * ========================================================= */
    private void applySettlement(ApprovalDraftDTO draft, Long actorUserId) {

        LocalDate from = draft.getExtDt1();
        LocalDate to = draft.getExtDt2();
        if (from == null || to == null) {
            throw new IllegalArgumentException("AT002: 기간(extDt1/extDt2)이 없습니다.");
        }

        BigDecimal sales = toBigDecimalOrZero(draft.getExtNo1());
        BigDecimal expense = toBigDecimalOrZero(draft.getExtNo2());
        BigDecimal profit = toBigDecimalOrZero(draft.getExtNo3());

        SettlementDto dto = SettlementDto.builder()
                .settlementNo(generateSettlementNo())
                .branchId(draft.getBranchId())
                .fromDate(from)                 // ✅ DTO 필드명에 맞춤
                .toDate(to)                     // ✅ DTO 필드명에 맞춤
                .salesAmount(sales)
                .expenseAmount(expense)
                .profitAmount(profit)
                .statusCode(SettlementStatus.PENDING.name())
                .createUser(actorUserId)
                .useYn(true)
                .build();

        settlementMapper.insertSettlement(dto);
    }


    /* =========================================================
     * AT003 매출 (sales)
     * - form: extNo1(branchId), extTxt2(memo), extTxt6(lines json)
     * - mapper: SaleMapper.insertSale(SaleDto)
     *
     * 주의: 폼은 여러 라인(카테고리/금액/일자) 구조인데,
     * sales 테이블은 보통 1건 1카테고리로 설계되어 있으므로
     * 라인별로 sales row를 "여러 건 insert" 처리.
     * ========================================================= */
    private void applySales(ApprovalDraftDTO draft, Long actorUserId) {

        Long branchId = draft.getExtNo1();
        if (branchId == null || branchId <= 0) {
            throw new IllegalArgumentException("AT003: branchId(extNo1)가 없습니다.");
        }

        List<SalesLine> lines = readJsonList(draft.getExtTxt6(), new TypeReference<List<SalesLine>>() {});
        if (lines == null || lines.isEmpty()) {
            throw new IllegalArgumentException("AT003: 매출 내역(extTxt6)이 비어 있습니다.");
        }

        for (SalesLine line : lines) {
            if (line == null) continue;

            if (line.getAmount() == null) continue;
            if (line.getType() == null || line.getType().isBlank()) continue;

            LocalDateTime soldAt = (line.getDate() != null)
                    ? line.getDate().atStartOfDay()
                    : LocalDateTime.now();

            SaleDto dto = SaleDto.builder()
                    .saleNo(generateSaleNo())
                    .branchId(branchId)
                    .soldAt(soldAt)
                    .statusCode(SaleStatus.COMPLETED.name())
                    .categoryCode(line.getType()) // MEMBERSHIP/PT/PRODUCT/ETC
                    .totalAmount(line.getAmount())
                    .memo(mergeMemo(draft.getExtTxt2(), line.getMemo()))
                    .createUser(actorUserId)
                    .useYn(true)
                    .build();

            saleMapper.insertSale(dto);
        }
    }

    /* =========================================================
     * AT004 재고 조정 (inventory)
     * - form: extNo1(branchId), extCode2(reason), extTxt6(lines json with signedQty)
     * - mapper: InventoryMapper.selectInventoryDetail(...)
     *           InventoryMapper.updateInventoryQuantity(...)
     *           InventoryMapper.insertInventoryHistory(...)
     *
     * moveTypeCode는 InventoryServiceImpl 기준(IN/OUT)로 기록
     * ========================================================= */
    private void applyInventoryAdjust(ApprovalDraftDTO draft, Long actorUserId) {

        Long branchId = draft.getExtNo1();
        if (branchId == null || branchId <= 0) {
            throw new IllegalArgumentException("AT004: branchId(extNo1)가 없습니다.");
        }

        String reason = (draft.getExtCode2() != null && !draft.getExtCode2().isBlank())
                ? draft.getExtCode2()
                : "APPROVAL_ADJUST";

        List<InventoryAdjustLine> lines =
                readJsonList(draft.getExtTxt6(), new TypeReference<List<InventoryAdjustLine>>() {});

        if (lines == null || lines.isEmpty()) {
            throw new IllegalArgumentException("AT004: 조정 내역(extTxt6)이 비어 있습니다.");
        }

        for (InventoryAdjustLine line : lines) {
            if (line == null) continue;

            Long productId = line.getProductId();
            if (productId == null || productId <= 0) continue;

            Long signedQty = line.getSignedQty(); // 증가:+, 감소:-
            if (signedQty == null || signedQty == 0) continue;

            long absQty = Math.abs(signedQty);

            InventoryDetailDto current = inventoryMapper.selectInventoryDetail(branchId, productId);
            if (current == null) {
                throw new IllegalArgumentException("AT004: 재고 데이터가 없습니다. branchId=" + branchId + ", productId=" + productId);
            }

            long beforeQty = (current.getQuantity() == null) ? 0L : current.getQuantity();
            long afterQty;

            String moveTypeCode;
            if (signedQty > 0) {
                moveTypeCode = "IN";
                afterQty = beforeQty + absQty;
            } else {
                moveTypeCode = "OUT";
                afterQty = beforeQty - absQty;
                if (afterQty < 0) {
                    throw new IllegalArgumentException("AT004: 출고 수량이 현재 수량을 초과할 수 없습니다. productId=" + productId);
                }
            }

            // 1) 재고 수량 업데이트
            inventoryMapper.updateInventoryQuantity(
                    branchId,
                    productId,
                    afterQty,
                    null,           // lowStockThreshold (InventoryServiceImpl과 동일하게 null 허용)
                    actorUserId
            );

            // 2) 이력 적재
            inventoryMapper.insertInventoryHistory(
                    branchId,
                    productId,
                    moveTypeCode,
                    absQty,
                    reason,
                    "INVENTORY_ADJUST",
                    null,
                    actorUserId
            );
        }
    }

    /* =========================
     * JSON helper
     * ========================= */
    private <T> List<T> readJsonList(String json, TypeReference<List<T>> typeRef) {
        if (json == null || json.isBlank()) return null;
        try {
            return objectMapper.readValue(json, typeRef);
        } catch (Exception e) {
            throw new IllegalStateException("JSON 파싱 실패: " + e.getMessage(), e);
        }
    }

    /* =========================
     * converters
     * ========================= */
    private BigDecimal toBigDecimalOrZero(Long n) {
        if (n == null) return BigDecimal.ZERO;
        return BigDecimal.valueOf(n);
    }

    private BigDecimal toBigDecimalOrNull(Long n) {
        if (n == null) return null;
        return BigDecimal.valueOf(n);
    }

    private String mergeMemo(String a, String b) {
        if ((a == null || a.isBlank()) && (b == null || b.isBlank())) return null;
        if (a == null || a.isBlank()) return b;
        if (b == null || b.isBlank()) return a;
        return a + " / " + b;
    }

    /* =========================
     * numbers
     * ========================= */
    private String generateExpenseNo() {
        String date = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        String rnd = String.format("%06d", (int) (Math.random() * 1_000_000));
        return "EXP-" + date + "-" + rnd;
    }

    private String generateSettlementNo() {
        String date = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        String rnd = String.format("%06d", (int) (Math.random() * 1_000_000));
        return "STL-" + date + "-" + rnd;
    }

    private String generateSaleNo() {
        String date = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        String rnd = String.format("%06d", (int) (Math.random() * 1_000_000));
        return "SALE-" + date + "-" + rnd;
    }

    /* =========================
     * JSON line DTOs (폼 구조 그대로)
     * ========================= */

    // AT001 extTxt6
    @Data
    public static class ExpenseLine {
        private String item;
        private BigDecimal amount;
        private LocalDate date;
        private String memo;
    }

    // AT003 extTxt6
    @Data
    public static class SalesLine {
        private String type;          // MEMBERSHIP / PT / PRODUCT / ETC
        private BigDecimal amount;
        private LocalDate date;
        private String memo;
    }

    // AT004 extTxt6
    @Data
    public static class InventoryAdjustLine {
        private Long branchId;
        private Long productId;
        private String productName;
        private String adjustType;    // INCREASE / DECREASE
        private Long adjustQty;       // 절대값
        private Long signedQty;       // 증가:+, 감소:-
        private String operator;
        private String remark;
        private Long price;
    }
    private void applyPurchaseRequest(ApprovalDraftDTO draft, Long actorUserId) {

        Long branchId = draft.getExtNo1();
        if (branchId == null || branchId <= 0) {
            throw new IllegalArgumentException("AT005: branchId(extNo1)가 없습니다.");
        }

        // extTxt6: 구매 항목 JSON
        List<PurchaseItemLine> lines =
                readJsonList(draft.getExtTxt6(), new TypeReference<List<PurchaseItemLine>>() {});

        if (lines == null || lines.isEmpty()) {
            throw new IllegalArgumentException("AT005: 구매 항목(extTxt6)이 비어 있습니다.");
        }

        PurchaseRequestDto req = new PurchaseRequestDto();
        req.setBranchId(branchId);
        req.setStatusCode("REQUESTED");
        req.setRequestedBy(actorUserId);
        req.setMemo(draft.getBody());

        for (PurchaseItemLine line : lines) {
            if (line == null) continue;
            if (line.getProductId() == null || line.getQuantity() == null) continue;

            PurchaseRequestDto.PurchaseItemDto item =
                    new PurchaseRequestDto.PurchaseItemDto();

            item.setProductId(line.getProductId());
            item.setQuantity(line.getQuantity());
            item.setUnitPrice(line.getUnitPrice());

            req.getItems().add(item);
        }

        if (req.getItems().isEmpty()) {
            throw new IllegalArgumentException("AT005: 유효한 구매 항목이 없습니다.");
        }

        // ✅ ZIP 기준 실제 서비스 메서드
        purchaseService.createPurchaseRequest(req);
    }



    /* =========================
     * AT006 발주/입고
     * ZIP 기준: InboundRequestService 위임
     * ========================= */
    private void applyInboundRequest(ApprovalDraftDTO draft, Long actorUserId) {

        inboundRequestService.createFromApproval(
                draft.getDocVerId(),
                actorUserId
        );
    }
}
