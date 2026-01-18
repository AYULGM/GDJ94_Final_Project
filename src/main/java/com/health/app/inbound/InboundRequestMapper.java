package com.health.app.inbound;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface InboundRequestMapper {

    List<InboundOptionDto> selectProductOptions();

    void insertInboundHeader(InboundRequestHeaderDto header);

    void insertInboundDetail(InboundRequestItemDto item);

    void updateApprovalLink(@Param("inboundRequestId") Long inboundRequestId,
                            @Param("approvalDocId") Long approvalDocId,
                            @Param("approvalDocVerId") Long approvalDocVerId,
                            @Param("refType") String refType,
                            @Param("refId") Long refId,
                            @Param("userId") Long userId);

    /** ✅ 지점필터 파라미터 추가 */
    List<InboundRequestListDto> selectInboundList(@Param("statusCode") String statusCode,
                                                  @Param("requestBranchId") Long requestBranchId);

    InboundRequestDetailDto selectInboundHeader(@Param("inboundRequestId") Long inboundRequestId);

    List<InboundRequestItemDto> selectInboundItems(@Param("inboundRequestId") Long inboundRequestId);

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

    void updateStatusDone(@Param("inboundRequestId") Long inboundRequestId,
                          @Param("userId") Long userId);
}
