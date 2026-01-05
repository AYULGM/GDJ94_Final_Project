package com.health.app.inventory;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface InventoryMapper {

    // 1) 목록
    List<InventoryViewDto> selectInventoryList(
            @Param("branchId") Long branchId,
            @Param("keyword") String keyword,
            @Param("onlyLowStock") Boolean onlyLowStock
    );

    // 2) 지점 옵션
    List<OptionDto> selectBranchOptions();

    // 3) 상품 옵션(선택)
    List<OptionDto> selectProductOptions(@Param("branchId") Long branchId);

    // 4) 상세
    InventoryDetailDto selectInventoryDetail(
            @Param("branchId") Long branchId,
            @Param("productId") Long productId
    );

    // 5) 이력
    List<InventoryHistoryViewDto> selectInventoryHistory(
            @Param("branchId") Long branchId,
            @Param("productId") Long productId
    );

    // 6) 수량 업데이트
    int updateInventoryQuantity(
            @Param("branchId") Long branchId,
            @Param("productId") Long productId,
            @Param("quantity") Long quantity,
            @Param("lowStockThreshold") Long lowStockThreshold,
            @Param("updateUser") Long updateUser
    );

    // 7) 이력 insert
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
}
