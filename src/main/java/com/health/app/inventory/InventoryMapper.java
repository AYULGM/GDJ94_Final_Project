package com.health.app.inventory;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface InventoryMapper {

    List<InventoryViewDto> selectInventoryList(
            @Param("branchId") Long branchId,
            @Param("keyword") String keyword,
            @Param("onlyLowStock") Boolean onlyLowStock
    );

    List<OptionDto> selectBranchOptions();

    List<OptionDto> selectProductOptions(@Param("branchId") Long branchId);

    InventoryDetailDto selectInventoryDetail(
            @Param("branchId") Long branchId,
            @Param("productId") Long productId
    );

    List<InventoryHistoryViewDto> selectInventoryHistory(
            @Param("branchId") Long branchId,
            @Param("productId") Long productId
    );

    int updateInventoryQuantity(
            @Param("branchId") Long branchId,
            @Param("productId") Long productId,
            @Param("quantity") Long quantity,
            @Param("lowStockThreshold") Long lowStockThreshold,
            @Param("updateUser") Long updateUser
    );

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

    int updateLowStockThreshold(
            @Param("branchId") Long branchId,
            @Param("productId") Long productId,
            @Param("lowStockThreshold") Long lowStockThreshold,
            @Param("updateUser") Long updateUser
    );

    //  inventory_id 조회
    Long selectInventoryId(@Param("branchId") Long branchId, @Param("productId") Long productId);

    //  감사로그 저장 (DB 컬럼명에 맞춤)
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

    //  감사로그 조회 (branch/product 필터 포함)
    List<AuditLogDto> selectAuditLogs(
            @Param("from") String from,
            @Param("to") String to,
            @Param("actionType") String actionType,
            @Param("branchId") Long branchId,
            @Param("productId") Long productId,
            @Param("keyword") String keyword
    );
}
