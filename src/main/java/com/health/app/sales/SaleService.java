package com.health.app.sales;

import java.util.List;
import java.util.Map;

/**
 * 매출 관리 Service 인터페이스
 */
public interface SaleService {

    /**
     * 매출 목록 조회 (페이징 포함)
     */
    Map<String, Object> getSaleList(SaleSearchDto searchDto);

    /**
     * 매출 상세 조회
     */
    SaleDetailDto getSaleDetail(Long saleId);

    /**
     * 매출 등록
     */
    void createSale(SaleDto saleDto, Long currentUserId);

    /**
     * 매출 수정
     */
    void updateSale(SaleDto saleDto, Long currentUserId);

    /**
     * 매출 삭제 (논리 삭제)
     */
    void deleteSale(Long saleId, Long currentUserId);

    /**
     * 지점 옵션 조회
     */
    List<com.health.app.inventory.OptionDto> getBranchOptions();
}
