package com.health.app.inventory;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface InventoryMapper {

    // =========================
    // 1) 재고 목록 (페이징)
    // =========================
    List<InventoryViewDto> selectInventoryList(
            @Param("branchId") Long branchId,
            @Param("keyword") String keyword,
            @Param("onlyLowStock") Boolean onlyLowStock,
            @Param("offset") Integer offset,
            @Param("pageSize") Integer pageSize
    );

    // 페이징용 COUNT
    long selectInventoryListCount(
            @Param("branchId") Long branchId,
            @Param("keyword") String keyword,
            @Param("onlyLowStock") Boolean onlyLowStock
    );

    // =========================
    // 2) 지점/상품 옵션
    // =========================
    List<OptionDto> selectBranchOptions();

    List<OptionDto> selectProductOptions(@Param("branchId") Long branchId);

    // =========================
    // 3) 재고 상세 / 이력
    // =========================
    InventoryDetailDto selectInventoryDetail(
            @Param("branchId") Long branchId,
            @Param("productId") Long productId
    );

    List<InventoryHistoryViewDto> selectInventoryHistory(
            @Param("branchId") Long branchId,
            @Param("productId") Long productId
    );

    // =========================
    // 4) 재고 업데이트(수량/기준수량)
    // =========================
    int updateInventoryQuantity(
            @Param("branchId") Long branchId,
            @Param("productId") Long productId,
            @Param("quantity") Long quantity,
            @Param("lowStockThreshold") Long lowStockThreshold,
            @Param("updateUser") Long updateUser
    );

    int updateLowStockThreshold(
            @Param("branchId") Long branchId,
            @Param("productId") Long productId,
            @Param("lowStockThreshold") Long lowStockThreshold,
            @Param("updateUser") Long updateUser
    );

    // =========================
    // 5) 재고 이력 INSERT
    // =========================
    int insertInventoryHistory(
            @Param("branchId") Long branchId,
            @Param("productId") Long productId,
            @Param("moveTypeCode") String moveTypeCode,
            @Param("quantity") Long quantity,
            @Param("reason") String reason,
            @Param("refType") String refType,
            @Param("refId") Long refId,
            @Param("createUser") Long createUser
    );

    // =========================
    // 6) 감사로그
    // =========================
    Long selectInventoryId(
            @Param("branchId") Long branchId,
            @Param("productId") Long productId
    );

    int insertAuditLog(
            @Param("actorUserId") Long actorUserId,
            @Param("actionType") String actionType,
            @Param("targetType") String targetType,
            @Param("targetId") Long targetId,
            @Param("beforeValue") String beforeValue,
            @Param("afterValue") String afterValue,
            @Param("reason") String reason,
            @Param("createUser") Long createUser
    );

    List<AuditLogDto> selectAuditLogs(
            @Param("from") String from,
            @Param("to") String to,
            @Param("actionType") String actionType,
            @Param("branchId") Long branchId,
            @Param("productId") Long productId,
            @Param("keyword") String keyword
    );
}
