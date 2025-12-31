package com.health.app.inventory;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class InventoryServiceImpl implements InventoryService {

    private final InventoryMapper inventoryMapper;

    @Override
    public List<OptionDto> getBranchOptions() {
        return inventoryMapper.selectBranchOptions();
    }

    @Override
    public List<InventoryViewDto> getInventoryList(Long branchId, String keyword, Boolean onlyLowStock) {
        return inventoryMapper.selectInventoryList(branchId, keyword, onlyLowStock);
    }

    @Override
    public InventoryDetailDto getInventoryDetail(Long branchId, Long productId) {
        return inventoryMapper.selectInventoryDetail(branchId, productId);
    }

    @Override
    public List<InventoryHistoryViewDto> getInventoryHistory(Long branchId, Long productId) {
        return inventoryMapper.selectInventoryHistory(branchId, productId);
    }

    /**
     * 재고 조정 (IN/OUT/ADJUST)
     * - IN: 현재 + 수량
     * - OUT: 현재 - 수량 (음수 불가)
     * - ADJUST: 입력 수량으로 절대값 세팅
     */
    @Override
    public void adjustInventory(Long branchId, Long productId, String moveTypeCode, Long quantity, String reason, Long userId) {

        if (branchId == null || branchId <= 0) throw new IllegalArgumentException("branchId가 올바르지 않습니다.");
        if (productId == null || productId <= 0) throw new IllegalArgumentException("productId가 올바르지 않습니다.");

        if (quantity == null || quantity <= 0) {
            throw new IllegalArgumentException("수량은 1 이상이어야 합니다.");
        }
        if (moveTypeCode == null || moveTypeCode.isBlank()) {
            throw new IllegalArgumentException("유형(moveTypeCode)은 필수입니다.");
        }
        if (reason == null || reason.isBlank()) {
            throw new IllegalArgumentException("사유(reason)는 필수입니다.");
        }
        if (userId == null) {
            // 로그인 연동 전 임시 처리 (원하면 Controller에서 1L 넣어도 됨)
            userId = 1L;
        }

        InventoryDetailDto current = inventoryMapper.selectInventoryDetail(branchId, productId);
        if (current == null) {
            throw new IllegalArgumentException("재고 데이터가 존재하지 않습니다. (branchId/productId 확인)");
        }

        long beforeQty = current.getQuantity() == null ? 0L : current.getQuantity();
        long afterQty;

        switch (moveTypeCode) {
            case "IN" -> afterQty = beforeQty + quantity;
            case "OUT" -> {
                afterQty = beforeQty - quantity;
                if (afterQty < 0) {
                    throw new IllegalArgumentException("출고 수량이 현재 수량을 초과할 수 없습니다.");
                }
            }
            case "ADJUST" -> afterQty = quantity;
            default -> throw new IllegalArgumentException("유효하지 않은 유형입니다. (IN/OUT/ADJUST)");
        }

        // 1) 재고 업데이트
        inventoryMapper.updateInventoryQuantity(branchId, productId, afterQty, null, userId);

        // 2) 이력 적재
        inventoryMapper.insertInventoryHistory(
                branchId, productId, moveTypeCode, quantity, reason,
                "INVENTORY_ADJUST", null, userId
        );
    }
}
