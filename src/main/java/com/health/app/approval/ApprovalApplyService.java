package com.health.app.approval;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

import com.health.app.purchase.PurchaseService;
import org.jsoup.Jsoup;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.health.app.expenses.ExpenseDto;
import com.health.app.expenses.ExpenseMapper;
import com.health.app.inbound.InboundRequestHeaderDto;
import com.health.app.inbound.InboundRequestItemDto;
import com.health.app.inbound.InboundRequestMapper;
import com.health.app.inventory.InventoryDetailDto;
import com.health.app.inventory.InventoryMapper;
import com.health.app.purchase.PurchaseRequestDto;
import com.health.app.sales.SaleDto;
import com.health.app.sales.SaleMapper;
import com.health.app.sales.SaleStatus;
import com.health.app.settlements.SettlementDto;
import com.health.app.settlements.SettlementHistoryDto;
import com.health.app.settlements.SettlementMapper;
import com.health.app.settlements.SettlementStatus;
import com.health.app.purchase.PurchaseMapper;

import lombok.Data;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
@Transactional
public class ApprovalApplyService {

    // ✅ 본사 branchId (지점 테이블 기준 확정)
    private static final Long HQ_BRANCH_ID = 1L;

    private final ApprovalMapper approvalMapper;

    private final ExpenseMapper expenseMapper;
    private final SettlementMapper settlementMapper;
    private final SaleMapper saleMapper;
    private final InventoryMapper inventoryMapper;
    private final PurchaseMapper purchaseMapper;

    // AT005
    private final PurchaseService purchaseService;

    // AT006
    private final InboundRequestMapper inboundRequestMapper;

    private final ObjectMapper objectMapper;

    /* =========================================================
     * Entry
     * ========================================================= */
    public void applyApprovedDoc(Long docVerId, Long actorUserId) {

        ApprovalDraftDTO draft = approvalMapper.selectDraftByDocVerId(docVerId);
        if (draft == null) {
            throw new IllegalStateException("draft not found: " + docVerId);
        }
//        System.out.println("### APPLY START type=" + draft.getTypeCode());
//        System.out.println("### extTxt6=" + draft.getExtTxt6());

        switch (draft.getTypeCode()) {
            case "AT001" -> applyExpense(draft, actorUserId);
            case "AT002" -> applySettlement(draft, actorUserId);
            case "AT003" -> applySales(draft, actorUserId);
            case "AT004" -> applyInventoryAdjust(draft, actorUserId);
            case "AT005" -> applyPurchaseRequest(draft, actorUserId);
            case "AT006" -> applyInboundRequest(draft, actorUserId);
            default -> {
                // throw new UnsupportedOperationException("Unsupported typeCode: " + draft.getTypeCode());
            }
        }
    }

    /* =========================================================
     * AT001 지출 (expenses)
     * ========================================================= */
    private void applyExpense(ApprovalDraftDTO draft, Long actorUserId) {

        Long branchId = draft.getExtNo1();
        if (branchId == null || branchId <= 0) {
            throw new IllegalArgumentException("AT001: branchId(extNo1)가 없습니다.");
        }

        List<ExpenseLine> lines = readJsonList(draft.getExtTxt6(), new TypeReference<List<ExpenseLine>>() {});
        if (lines == null || lines.isEmpty()) {
            throw new IllegalArgumentException("AT001: 지출 내역(extTxt6)이 비어 있습니다.");
        }

        LocalDateTime expenseAt = (lines.get(0).getDate() != null)
                ? lines.get(0).getDate().atStartOfDay()
                : LocalDateTime.now();

        BigDecimal amount = toBigDecimalOrNull(draft.getExtNo2());
        if (amount == null) {
            amount = sumExpenseAmount(lines);
        }

        String bodyHtml = draft.getBody();
        String plain = Jsoup.parse(bodyHtml == null ? "" : bodyHtml).text();

        ExpenseDto dto = ExpenseDto.builder()
                .branchId(branchId)
                .expenseAt(expenseAt)
                .categoryCode("ETC")
                .amount(amount)
                .description(plain)
                .memo(plain)
                .settlementFlag(true)
                .createUser(actorUserId)
                .useYn(true)
                .build();

        expenseMapper.insertExpense(dto);
    }

    private BigDecimal sumExpenseAmount(List<ExpenseLine> lines) {
        BigDecimal sum = BigDecimal.ZERO;
        for (ExpenseLine l : lines) {
            if (l != null && l.getAmount() != null) sum = sum.add(l.getAmount());
        }
        return sum;
    }

    /* =========================================================
     * AT002 정산 (settlement)
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
                .fromDate(from)
                .toDate(to)
                .salesAmount(sales)
                .expenseAmount(expense)
                .profitAmount(profit)
                .statusCode(SettlementStatus.PENDING.name())
                .createUser(actorUserId)
                .useYn(true)
                .build();

        settlementMapper.insertSettlement(dto);

        // 정산 이력 로그 등록 (생성 - 대기)
        SettlementHistoryDto historyDto = SettlementHistoryDto.builder()
                .settlementId(dto.getSettlementId())
                .actionType("CREATE")
                .beforeStatus(null)
                .afterStatus(SettlementStatus.PENDING.name())
                .reason("전자결재 승인으로 정산 생성")
                .actorUserId(actorUserId)
                .actedAt(LocalDateTime.now())
                .createUser(actorUserId)
                .build();

        settlementMapper.insertSettlementHistory(historyDto);
    }

    /* =========================================================
     * AT003 매출 (sales)
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
                    .categoryCode(line.getType())
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

            Long signedQty = line.getSignedQty();
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

            inventoryMapper.updateInventoryQuantity(
                    branchId, productId, afterQty, null, actorUserId
            );

            inventoryMapper.insertInventoryHistory(
                    branchId, productId, moveTypeCode, absQty,
                    reason, "INVENTORY_ADJUST", null, actorUserId
            );
        }
    }

    /* =========================================================
     * ✅ 공통: 재고 IN 반영 (재고 row 없으면 예외)
     * - InventoryMapper에 insert/upsert가 없어서, AT004처럼 "없으면 예외" 정책으로 통일
     * ========================================================= */
    private void applyStockInOrThrow(
            Long branchId,
            Long productId,
            Long qty,
            String reason,
            String refType,
            Long refId,
            Long actorUserId
    ) {
        if (branchId == null || branchId <= 0) {
            throw new IllegalArgumentException("재고반영: branchId가 올바르지 않습니다.");
        }
        if (productId == null || productId <= 0) {
            throw new IllegalArgumentException("재고반영: productId가 올바르지 않습니다.");
        }
        if (qty == null || qty <= 0) return;

        InventoryDetailDto current = inventoryMapper.selectInventoryDetail(branchId, productId);
        if (current == null) {
            throw new IllegalArgumentException(
                    "재고반영: inventory row가 없습니다. (지점/상품 재고를 먼저 생성해야 합니다) branchId="
                            + branchId + ", productId=" + productId
            );
        }

        long beforeQty = (current.getQuantity() == null) ? 0L : current.getQuantity();
        long afterQty = beforeQty + qty;

        inventoryMapper.updateInventoryQuantity(branchId, productId, afterQty, null, actorUserId);

        inventoryMapper.insertInventoryHistory(
                branchId, productId, "IN", qty,
                reason, refType, refId, actorUserId
        );
    }
    
    /* =========================================================
     * ✅ 공통: 재고 OUT 반영 (재고 row 없으면 예외, 수량 부족 시 예외)
     * ========================================================= */
    private void applyStockOutOrThrow(
            Long branchId,
            Long productId,
            Long qty,
            String reason,
            String refType,
            Long refId,
            Long actorUserId
    ) {
        if (branchId == null || branchId <= 0) {
            throw new IllegalArgumentException("재고반영: branchId가 올바르지 않습니다.");
        }
        if (productId == null || productId <= 0) {
            throw new IllegalArgumentException("재고반영: productId가 올바르지 않습니다.");
        }
        if (qty == null || qty <= 0) return;

        InventoryDetailDto current = inventoryMapper.selectInventoryDetail(branchId, productId);
        if (current == null) {
            throw new IllegalArgumentException(
                    "재고반영: inventory row가 없습니다. (지점/상품 재고를 먼저 생성해야 합니다) branchId="
                            + branchId + ", productId=" + productId
            );
        }

        long beforeQty = (current.getQuantity() == null) ? 0L : current.getQuantity();
        long afterQty = beforeQty - qty;

        if (afterQty < 0) {
            throw new IllegalArgumentException(
                    "재고부족: 출고 수량이 현재 수량을 초과할 수 없습니다. branchId="
                            + branchId + ", productId=" + productId
                            + ", current=" + beforeQty + ", request=" + qty
            );
        }

        inventoryMapper.updateInventoryQuantity(branchId, productId, afterQty, null, actorUserId);

        inventoryMapper.insertInventoryHistory(
                branchId, productId, "OUT", qty,
                reason, refType, refId, actorUserId
        );
    }


    /* =========================================================
     * AT005 구매요청(PR)
     * - ✅ 최종 승인 시: 본사(HQ_BRANCH_ID=1) 재고 IN
     * ========================================================= */
    private void applyPurchaseRequest(ApprovalDraftDTO draft, Long actorUserId) {

        Long branchId = draft.getBranchId();
        if (branchId == null || branchId <= 0) {
            throw new IllegalArgumentException("AT005: branchId가 없습니다.");
        }

        List<PrPoLine> lines =
                readJsonList(draft.getExtTxt6(), new TypeReference<List<PrPoLine>>() {});
        if (lines == null || lines.isEmpty()) {
            throw new IllegalArgumentException("AT005: 구매 품목이 없습니다.");
        }

        PurchaseRequestDto req = new PurchaseRequestDto();
        req.setPurchaseNo(generatePurchaseNo());
        req.setBranchId(branchId);
        req.setStatusCode("REQUESTED");
        req.setRequestedBy(actorUserId);
        req.setMemo(buildPrMemo(draft));
        req.setItems(new java.util.ArrayList<>());

        for (PrPoLine l : lines) {
            if (l == null) continue;

            Long productId = l.getProductId();
            Long qty = l.getQty();

            if (productId == null || productId <= 0) {
                throw new IllegalArgumentException("AT005: productId 누락");
            }
            if (qty == null || qty <= 0) continue;

            PurchaseRequestDto.PurchaseItemDto item = new PurchaseRequestDto.PurchaseItemDto();
            item.setProductId(productId);
            item.setQuantity(qty);
            item.setUnitPrice(l.getUnitPrice() == null ? 0L : l.getUnitPrice());

            req.getItems().add(item);
        }

        if (req.getItems().isEmpty()) {
            throw new IllegalArgumentException("AT005: 유효한 품목 없음");
        }

        purchaseMapper.insertPurchaseHeader(req);

        Long purchaseId = req.getPurchaseId();
        if (purchaseId == null || purchaseId <= 0) {
            throw new IllegalStateException("AT005: purchaseId 생성 실패");
        }

        for (PurchaseRequestDto.PurchaseItemDto item : req.getItems()) {
            purchaseMapper.insertPurchaseDetail(purchaseId, item, actorUserId);
        }

        // ✅ (추가) 본사 재고 IN 반영
        for (PurchaseRequestDto.PurchaseItemDto item : req.getItems()) {
            applyStockInOrThrow(
                    HQ_BRANCH_ID,
                    item.getProductId(),
                    item.getQuantity(),
                    "AT005_FINAL_APPROVED",
                    "PURCHASE_REQUEST",
                    purchaseId,
                    actorUserId
            );
        }
    }

    /* =========================================================
     * AT006 발주서(입고요청)
     * - ✅ 최종 승인 시: 자기 지점(requestBranchId = draft.branchId) 재고 IN
     * ========================================================= */
    private void applyInboundRequest(ApprovalDraftDTO draft, Long actorUserId) {

        if (draft.getExtDt1() == null) { // 납기일(필수)
            throw new IllegalArgumentException("AT006: 납기일(extDt1)이 없습니다.");
        }

        List<PrPoLine> lines =
                readJsonList(draft.getExtTxt6(), new TypeReference<List<PrPoLine>>() {});
        if (lines == null || lines.isEmpty()) {
            throw new IllegalArgumentException("AT006: 발주 품목(extTxt6)이 비어 있습니다.");
        }

        Long requestBranchId = draft.getBranchId();
        if (requestBranchId == null || requestBranchId <= 0) {
            throw new IllegalArgumentException("AT006: requestBranchId(branchId)가 없습니다.");
        }

        // 1) Header 저장
        InboundRequestHeaderDto header = new InboundRequestHeaderDto();
        header.setRequestBranchId(requestBranchId);
        header.setInboundRequestNo(generateInboundRequestNo());
        header.setStatusCode("IR_REQ");
        header.setRequestedAt(LocalDateTime.now());
        header.setRequestedBy(actorUserId);
        header.setTitle(safeTrim(draft.getTitle()));
        header.setMemo(buildPoMemoZipSafe(draft));
        header.setCreateUser(actorUserId);
        header.setUpdateUser(actorUserId);
        header.setUseYn(1);

        inboundRequestMapper.insertInboundHeader(header);

        Long inboundRequestId = header.getInboundRequestId();
        if (inboundRequestId == null || inboundRequestId <= 0) {
            throw new IllegalStateException("AT006: inbound_request_header 저장 실패(inboundRequestId 생성 실패)");
        }

        // 2) Detail 저장
        for (PrPoLine l : lines) {
            if (l == null) continue;

            Long productId = l.getProductId();
            if (productId == null || productId <= 0) {
                throw new IllegalArgumentException("AT006: productId가 없습니다. productName=" + safeTrim(l.getProductName()));
            }

            Long qty = l.getQty();
            if (qty == null || qty <= 0) continue;

            InboundRequestItemDto item = new InboundRequestItemDto();
            item.setInboundRequestId(inboundRequestId);
            item.setProductId(productId);
            item.setQuantity(qty);

            item.setCreateUser(actorUserId);
            item.setUpdateUser(actorUserId);
            item.setUseYn(1);

            inboundRequestMapper.insertInboundDetail(item);
        }

        // 3) 결재 링크 저장
        inboundRequestMapper.updateApprovalLink(
                inboundRequestId,
                draft.getDocId(),
                draft.getDocVerId(),
                "INBOUND_REQUEST",
                inboundRequestId,
                actorUserId
        );

     // ✅ (수정) 본사 재고 OUT + 자기 지점 재고 IN 반영
        for (PrPoLine l : lines) {
            if (l == null) continue;

            Long productId = l.getProductId();
            Long qty = l.getQty();
            if (productId == null || productId <= 0) continue;
            if (qty == null || qty <= 0) continue;

            // 1) 본사 재고 감소(OUT)
            applyStockOutOrThrow(
                    HQ_BRANCH_ID,
                    productId,
                    qty,
                    "AT006_FINAL_APPROVED",
                    "INBOUND_REQUEST",
                    inboundRequestId,
                    actorUserId
            );

            // 2) 요청 지점 재고 증가(IN) - 없으면 자동 생성
            applyStockInOrCreate(
            	    requestBranchId,
            	    productId,
            	    qty,
            	    "AT006_FINAL_APPROVED",
            	    "INBOUND_REQUEST",
            	    inboundRequestId,
            	    actorUserId
            	);

        }

    }

    /* =========================================================
     * JSON helper
     * ========================================================= */
    private <T> List<T> readJsonList(String json, TypeReference<List<T>> typeRef) {
        if (json == null || json.isBlank()) return null;
        try {
            return objectMapper.readValue(json, typeRef);
        } catch (Exception e) {
            throw new IllegalStateException("JSON 파싱 실패: " + e.getMessage(), e);
        }
    }

    /* =========================================================
     * converters / helpers
     * ========================================================= */
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

    private String safeTrim(String s) {
        return s == null ? "" : s.trim();
    }

    private String normalizeKey(String s) {
        return safeTrim(s).toLowerCase().replaceAll("\\s+", " ");
    }

    /* =========================================================
     * JSON line DTOs
     * ========================================================= */

    @Data
    public static class ExpenseLine {
        private String item;
        private BigDecimal amount;
        private LocalDate date;
        private String memo;
    }

    @Data
    public static class SalesLine {
        private String type;
        private BigDecimal amount;
        private LocalDate date;
        private String memo;
    }

    @Data
    public static class InventoryAdjustLine {
        private Long branchId;
        private Long productId;
        private String productName;
        private String adjustType;
        private Long adjustQty;
        private Long signedQty;
        private String operator;
        private String remark;
        private Long price;
    }

    @Data
    public static class PrPoLine {
        private Long productId;
        private String productName;
        private Long qty;
        private Long unitPrice;
        private Long amount;
    }

    private String buildPrMemo(ApprovalDraftDTO draft) {
        StringBuilder sb = new StringBuilder();
        if (draft.getExtDt1() != null) sb.append("희망납기일: ").append(draft.getExtDt1()).append("\n");
        if (!safeTrim(draft.getExtTxt1()).isEmpty()) sb.append("거래처: ").append(safeTrim(draft.getExtTxt1())).append("\n");
        if (!safeTrim(draft.getExtTxt2()).isEmpty()) sb.append("요청사유: ").append(safeTrim(draft.getExtTxt2())).append("\n");
        if (!safeTrim(draft.getExtTxt3()).isEmpty()) sb.append("비고: ").append(safeTrim(draft.getExtTxt3())).append("\n");
        if (!safeTrim(draft.getBody()).isEmpty()) sb.append("본문: ").append(safeTrim(draft.getBody()));
        return sb.toString().trim();
    }

    private String generatePurchaseNo() {
        String date = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        String rnd = String.format("%06d", (int) (Math.random() * 1_000_000));
        return "PR-" + date + "-" + rnd;
    }

    private String generateInboundRequestNo() {
        String date = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        String rnd = String.format("%06d", (int) (Math.random() * 1_000_000));
        return "IR-" + date + "-" + rnd;
    }

    private String buildPoMemoZipSafe(ApprovalDraftDTO draft) {
        StringBuilder sb = new StringBuilder();

        if (draft.getExtDt1() != null) sb.append("납기일: ").append(draft.getExtDt1()).append("\n");
        if (!safeTrim(draft.getExtTxt2()).isEmpty()) sb.append("담당/연락처: ").append(safeTrim(draft.getExtTxt2())).append("\n");
        if (!safeTrim(draft.getExtTxt3()).isEmpty()) sb.append("결제조건: ").append(safeTrim(draft.getExtTxt3())).append("\n");
        if (draft.getExtNo1() != null) sb.append("총액: ").append(draft.getExtNo1()).append("\n");
        if (!safeTrim(draft.getExtTxt4()).isEmpty()) sb.append("비고: ").append(safeTrim(draft.getExtTxt4())).append("\n");

        if (!safeTrim(draft.getBody()).isEmpty()) sb.append("본문: ").append(safeTrim(draft.getBody()));

        return sb.toString().trim();
    }
    /**
     * ✅ 재고 IN 반영 (없으면 inventory row 자동 생성)
     * - AT006 전용 정책
     */
    private void applyStockInOrCreate(
            Long branchId,
            Long productId,
            Long qty,
            String reason,
            String refType,
            Long refId,
            Long actorUserId
    ) {
        if (branchId == null || branchId <= 0) {
            throw new IllegalArgumentException("재고반영: branchId가 올바르지 않습니다.");
        }
        if (productId == null || productId <= 0) {
            throw new IllegalArgumentException("재고반영: productId가 올바르지 않습니다.");
        }
        if (qty == null || qty <= 0) return;

        InventoryDetailDto current = inventoryMapper.selectInventoryDetail(branchId, productId);

        // ✅ 없으면 inventory row 생성
        if (current == null) {
            inventoryMapper.insertInventory(
                    branchId,
                    productId,
                    0L,
                    actorUserId
            );
            current = inventoryMapper.selectInventoryDetail(branchId, productId);
            if (current == null) {
                throw new IllegalStateException(
                        "재고반영: inventory row 생성 실패 branchId="
                                + branchId + ", productId=" + productId
                );
            }
        }

        long beforeQty = current.getQuantity() == null ? 0L : current.getQuantity();
        long afterQty = beforeQty + qty;

        inventoryMapper.updateInventoryQuantity(
                branchId,
                productId,
                afterQty,
                null,
                actorUserId
        );

        inventoryMapper.insertInventoryHistory(
                branchId,
                productId,
                "IN",
                qty,
                reason,
                refType,
                refId,
                actorUserId
        );
    }

}
