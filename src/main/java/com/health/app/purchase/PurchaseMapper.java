package com.health.app.purchase;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface PurchaseMapper {

    // 옵션
    List<PurchaseOptionDto> selectBranchOptions();

    List<PurchaseOptionDto> selectProductOptions();

    // 발주 생성
    int insertPurchaseHeader(PurchaseRequestDto dto);

    int insertPurchaseDetail(@Param("purchaseId") Long purchaseId,
                             @Param("item") PurchaseRequestDto.PurchaseItemDto item,
                             @Param("userId") Long userId);

    // 조회
    List<PurchaseListDto> selectPurchaseList(@Param("branchId") Long branchId,
                                             @Param("statusCode") String statusCode,
                                             @Param("keyword") String keyword);

    PurchaseDetailDto selectPurchaseHeader(@Param("purchaseId") Long purchaseId);

    List<PurchaseDetailItemDto> selectPurchaseItems(@Param("purchaseId") Long purchaseId);

    // 상태 변경
    int approvePurchase(@Param("purchaseId") Long purchaseId,
                        @Param("userId") Long userId);

    int fulfillPurchase(@Param("purchaseId") Long purchaseId,
                        @Param("userId") Long userId);

    int rejectPurchase(@Param("purchaseId") Long purchaseId,
                       @Param("rejectReason") String rejectReason,
                       @Param("userId") Long userId);

    // 재고 처리
    int countInventory(@Param("branchId") Long branchId,
                       @Param("productId") Long productId);

    int increaseInventory(@Param("branchId") Long branchId,
                          @Param("productId") Long productId,
                          @Param("qty") Long qty,
                          @Param("userId") Long userId);

    int insertInventory(@Param("branchId") Long branchId,
                        @Param("productId") Long productId,
                        @Param("qty") Long qty,
                        @Param("userId") Long userId);

    int insertInventoryHistory(@Param("branchId") Long branchId,
                               @Param("productId") Long productId,
                               @Param("moveTypeCode") String moveTypeCode,
                               @Param("quantity") Long quantity,
                               @Param("reason") String reason,
                               @Param("refType") String refType,
                               @Param("refId") Long refId,
                               @Param("userId") Long userId);
}
