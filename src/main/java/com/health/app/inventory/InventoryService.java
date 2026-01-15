package com.health.app.inventory;

import java.util.List;

public interface InventoryService {

        // 조회
        List<OptionDto> getBranchOptions();
        List<InventoryViewDto> getInventoryList(Long branchId, String keyword, Boolean onlyLowStock);
        InventoryDetailDto getInventoryDetail(Long branchId, Long productId);
        List<InventoryHistoryViewDto> getInventoryHistory(Long branchId, Long productId);

        // 변경(재고 조정)
        void adjustInventory(Long branchId, Long productId, String moveTypeCode, Long quantity, String reason, Long userId);

        // 기준수량(지점별) 변경
        void updateLowStockThreshold(Long branchId, Long productId, Long lowStockThreshold, Long userId);

        // ✅ 감사로그 조회
        List<AuditLogDto> getAuditLogs(String from, String to, String actionType, Long branchId, Long productId, String keyword);
}
