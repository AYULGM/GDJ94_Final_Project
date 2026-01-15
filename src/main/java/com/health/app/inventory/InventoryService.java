package com.health.app.inventory;

import java.util.List;

public interface InventoryService {

        // 조회
        List<OptionDto> getBranchOptions();

        /**
         * 상품 옵션
         * - branchId가 있으면 해당 지점(inventory)에 존재하는 상품만
         * - 없으면 전체 상품
         */
        List<OptionDto> getProductOptions(Long branchId);

        List<InventoryViewDto> getInventoryList(Long branchId, String keyword, Boolean onlyLowStock);
        InventoryDetailDto getInventoryDetail(Long branchId, Long productId);
        List<InventoryHistoryViewDto> getInventoryHistory(Long branchId, Long productId);

        // 변경(재고 조정)
        void adjustInventory(Long branchId, Long productId, String moveTypeCode, Long quantity, String reason, Long userId);

        // 기준수량(지점별) 변경
        void updateLowStockThreshold(Long branchId, Long productId, Long lowStockThreshold, Long userId);

        //  감사로그 조회
        List<AuditLogDto> getAuditLogs(String from, String to, String actionType, Long branchId, Long productId, String keyword);
}
