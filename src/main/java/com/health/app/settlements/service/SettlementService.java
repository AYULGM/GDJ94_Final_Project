package com.health.app.settlements.service;

import com.health.app.settlements.dto.*;

import java.util.List;
import java.util.Map;

/**
 * 정산 Service 인터페이스
 */
public interface SettlementService {

    /**
     * 정산 목록 조회 (페이징 포함)
     */
    Map<String, Object> getSettlementList(SettlementSearchDto searchDto);

    /**
     * 정산 상세 조회
     */
    SettlementDetailDto getSettlementDetail(Long settlementId);

    /**
     * 정산 생성 (기간별 자동 집계)
     */
    Long createSettlement(CreateSettlementRequestDto requestDto, Long currentUserId);

    /**
     * 정산 확정
     */
    void confirmSettlement(Long settlementId, String reason, Long currentUserId);

    /**
     * 정산 취소
     */
    void cancelSettlement(Long settlementId, String reason, Long currentUserId);

    /**
     * 정산 삭제 (논리 삭제)
     */
    void deleteSettlement(Long settlementId, Long currentUserId);

    /**
     * 정산 이력 조회
     */
    List<SettlementHistoryDto> getSettlementHistories(Long settlementId);
}
