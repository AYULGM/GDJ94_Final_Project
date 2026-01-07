package com.health.app.inbound;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface InboundRequestMapper {

    // 옵션
    List<InboundOptionDto> selectProductOptions();

    // insert
    void insertInboundHeader(InboundRequestHeaderDto header);
    void insertInboundDetail(InboundRequestItemDto item);

    // 결재 링크 업데이트
    void updateApprovalLink(@Param("inboundRequestId") Long inboundRequestId,
                            @Param("approvalDocId") Long approvalDocId,
                            @Param("approvalDocVerId") Long approvalDocVerId,
                            @Param("refType") String refType,
                            @Param("refId") Long refId,
                            @Param("userId") Long userId);

    // 조회
    List<InboundRequestListDto> selectInboundList(@Param("statusCode") String statusCode);
    InboundRequestDetailDto selectInboundHeader(@Param("inboundRequestId") Long inboundRequestId);
    List<InboundRequestItemDto> selectInboundItems(@Param("inboundRequestId") Long inboundRequestId);

    // 승인완료 → 재고 반영
    void upsertInventoryIncrease(@Param("branchId") Long branchId,
                                 @Param("productId") Long productId,
                                 @Param("qty") Long qty,
                                 @Param("userId") Long userId);

    void insertInventoryHistoryIn(@Param("branchId") Long branchId,
                                  @Param("productId") Long productId,
                                  @Param("qty") Long qty,
                                  @Param("reason") String reason,
                                  @Param("userId") Long userId,
                                  @Param("refType") String refType,
                                  @Param("refId") Long refId);

    void updateStatusApproved(@Param("inboundRequestId") Long inboundRequestId,
                              @Param("userId") Long userId);
}
