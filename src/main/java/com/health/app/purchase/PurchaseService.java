package com.health.app.purchase;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class PurchaseService {

    private final PurchaseMapper purchaseMapper;

    public List<PurchaseOptionDto> getBranchOptions() {
        return purchaseMapper.selectBranchOptions();
    }

    public List<PurchaseOptionDto> getProductOptions() {
        return purchaseMapper.selectProductOptions();
    }

    public Long createPurchase(PurchaseRequestDto dto, Long userId) {
        if (dto == null) throw new IllegalArgumentException("요청 데이터가 비어있습니다.");
        if (dto.getBranchId() == null || dto.getBranchId() <= 0) throw new IllegalArgumentException("지점을 선택하세요.");
        if (dto.getItems() == null || dto.getItems().isEmpty()) throw new IllegalArgumentException("발주 품목이 없습니다.");
        if (userId == null) userId = 1L;

        // 품목 검증
        for (PurchaseRequestDto.PurchaseItemDto item : dto.getItems()) {
            if (item.getProductId() == null || item.getProductId() <= 0) {
                throw new IllegalArgumentException("상품 선택이 올바르지 않습니다.");
            }
            if (item.getQuantity() == null || item.getQuantity() <= 0) {
                throw new IllegalArgumentException("수량은 1 이상이어야 합니다.");
            }
            if (item.getUnitPrice() == null || item.getUnitPrice() < 0) {
                throw new IllegalArgumentException("단가는 0 이상이어야 합니다.");
            }
        }

        // purchase_no 생성(요구정의서에 명확 규칙 없어서 충돌 없는 형태로)
        String purchaseNo = "PO-" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmssSSS"));

        dto.setPurchaseNo(purchaseNo);
        dto.setStatusCode("REQUESTED");
        dto.setRequestedBy(userId);

        // 1) 헤더 저장 (useGeneratedKeys로 purchaseId 세팅)
        purchaseMapper.insertPurchaseHeader(dto);

        Long purchaseId = dto.getPurchaseId();
        if (purchaseId == null || purchaseId <= 0) {
            throw new IllegalArgumentException("발주 헤더 저장 실패(purchaseId 생성 실패)");
        }

        // 2) 상세 저장
        for (PurchaseRequestDto.PurchaseItemDto item : dto.getItems()) {
            purchaseMapper.insertPurchaseDetail(purchaseId, item, userId);
        }

        return purchaseId;
    }

    @Transactional(readOnly = true)
    public List<PurchaseListDto> getPurchaseList(Long branchId, String statusCode, String keyword) {
        return purchaseMapper.selectPurchaseList(branchId, statusCode, keyword);
    }

    @Transactional(readOnly = true)
    public PurchaseDetailDto getPurchaseDetail(Long purchaseId) {
        PurchaseDetailDto header = purchaseMapper.selectPurchaseHeader(purchaseId);
        if (header == null) return null;
        header.setItems(purchaseMapper.selectPurchaseItems(purchaseId));
        return header;
    }

    public void approvePurchase(Long purchaseId, Long userId) {
        if (purchaseId == null || purchaseId <= 0) throw new IllegalArgumentException("purchaseId가 올바르지 않습니다.");
        if (userId == null) userId = 1L;

        PurchaseDetailDto current = getPurchaseDetail(purchaseId);
        if (current == null) throw new IllegalArgumentException("발주 정보를 찾을 수 없습니다.");

        if (!"REQUESTED".equals(current.getStatusCode())) {
            throw new IllegalArgumentException("요청 상태(REQUESTED)인 발주만 승인할 수 있습니다.");
        }

        // 1) 발주 상태 승인 처리
        int updated = purchaseMapper.approvePurchase(purchaseId, userId);
        if (updated != 1) throw new IllegalArgumentException("발주 승인 처리 실패");

        // 2) 재고 반영 (입고)
        // - inventory 있으면 quantity += 발주수량
        // - 없으면 신규 insert
        // - inventory_history 기록(선택이지만 요구정의서 '이력 저장' 흐름에 맞춰 넣음)
        for (PurchaseDetailItemDto item : current.getItems()) {
            Long branchId = current.getBranchId();
            Long productId = item.getProductId();
            Long qty = item.getQuantity();

            // upsert
            int exists = purchaseMapper.countInventory(branchId, productId);
            if (exists > 0) {
                purchaseMapper.increaseInventory(branchId, productId, qty, userId);
            } else {
                purchaseMapper.insertInventory(branchId, productId, qty, userId);
            }

            purchaseMapper.insertInventoryHistory(branchId, productId, "IN", qty,
                    "발주 승인 입고", "PURCHASE", purchaseId, userId);
        }
    }

    public void rejectPurchase(Long purchaseId, String rejectReason, Long userId) {
        if (purchaseId == null || purchaseId <= 0) throw new IllegalArgumentException("purchaseId가 올바르지 않습니다.");
        if (rejectReason == null || rejectReason.isBlank()) throw new IllegalArgumentException("반려 사유는 필수입니다.");
        if (userId == null) userId = 1L;

        PurchaseDetailDto current = getPurchaseDetail(purchaseId);
        if (current == null) throw new IllegalArgumentException("발주 정보를 찾을 수 없습니다.");

        if (!"REQUESTED".equals(current.getStatusCode())) {
            throw new IllegalArgumentException("요청 상태(REQUESTED)인 발주만 반려할 수 있습니다.");
        }

        int updated = purchaseMapper.rejectPurchase(purchaseId, rejectReason, userId);
        if (updated != 1) throw new IllegalArgumentException("발주 반려 처리 실패");
    }
}
