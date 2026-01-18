package com.health.app.inbound;

import java.util.List;

/**
 * 입고요청 Service (정석 구조: interface + impl)
 */
public interface InboundRequestService {

    /** 상품 옵션(셀렉트) */
    List<InboundOptionDto> getProductOptions();

    /**
     * 입고요청서 저장 + 전자결재(임시저장) 초안 생성
     * @return docVerId
     */
    Long createInboundRequestAndDraft(Long loginUserId, Long requestBranchId, InboundRequestFormDto form);

    /** ✅ 기존 호출 호환용(본사 전체 조회 기본) */
    List<InboundRequestListDto> getInboundRequestList(String statusCode);

    /** ✅ 지점 필터용(지점사용자는 자기 지점만 조회) */
    List<InboundRequestListDto> getInboundRequestList(String statusCode, Long requestBranchId);

    InboundRequestDetailDto getInboundRequestDetail(Long inboundRequestId);

    List<InboundRequestItemDto> getInboundRequestItems(Long inboundRequestId);

    /** 승인완료(IR_APPROVED) 문서를 처리완료로 변경하면서 재고 반영 + 이력 기록 */
    void applyApprovedInboundToInventory(Long inboundRequestId, Long approvedBy);
}
