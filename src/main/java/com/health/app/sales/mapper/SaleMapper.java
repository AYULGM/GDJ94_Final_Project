package com.health.app.sales.mapper;

import com.health.app.sales.dto.SaleDetailDto;
import com.health.app.sales.dto.SaleDto;
import com.health.app.sales.dto.SaleSearchDto;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 매출 관리 Mapper 인터페이스
 */
@Mapper
public interface SaleMapper {

    /**
     * 매출 목록 조회 (검색 조건 포함)
     */
    List<SaleDetailDto> selectSaleList(SaleSearchDto searchDto);

    /**
     * 매출 목록 총 개수
     */
    int selectSaleCount(SaleSearchDto searchDto);

    /**
     * 매출 상세 조회
     */
    SaleDetailDto selectSaleDetail(@Param("saleId") Long saleId);

    /**
     * 매출 등록
     */
    int insertSale(SaleDto saleDto);

    /**
     * 매출 수정
     */
    int updateSale(SaleDto saleDto);

    /**
     * 매출 삭제 (논리 삭제)
     */
    int deleteSale(@Param("saleId") Long saleId, @Param("updateUser") Long updateUser);

    /**
     * 지점 옵션 조회 (드롭다운용)
     */
    List<com.health.app.inventory.OptionDto> selectBranchOptions();
}
