package com.health.app.inventory;

import java.util.List;

public interface InventoryService {

        List<OptionDto> getBranchOptions();

        List<OptionDto> getProductOptions(Long branchId);

        List<InventoryViewDto> getInventoryList(Long branchId, String keyword, Boolean onlyLowStock, Integer page, Integer size);

        long getInventoryListCount(Long branchId, String keyword, Boolean onlyLowStock);

        InventoryDetailDto getInventoryDetail(Long branchId, Long productId);

        List<InventoryHistoryViewDto> getInventoryHistory(Long branchId, Long productId);

        void adjustInventory(Long branchId, Long productId, String moveTypeCode, Long quantity, String reason, Long userId);

        void updateLowStockThreshold(Long branchId, Long productId, Long lowStockThreshold, Long userId);

        List<AuditLogDto> getAuditLogs(String from, String to, String actionType, Long branchId, Long productId, String keyword);
}
