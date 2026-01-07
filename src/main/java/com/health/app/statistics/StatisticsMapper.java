package com.health.app.statistics;

import com.health.app.statistics.*;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 통계 Mapper 인터페이스
 */
@Mapper
public interface StatisticsMapper {

    // ===== 매출 통계 =====

    /**
     * ST-001: 지점별 매출 통계
     */
    List<SalesStatisticsDto> selectSalesByBranch(StatisticsSearchDto searchDto);

    /**
     * ST-002: 항목별 매출 통계
     */
    List<SalesStatisticsDto> selectSalesByCategory(StatisticsSearchDto searchDto);

    /**
     * ST-003: 기간별 매출 통계
     */
    List<SalesStatisticsDto> selectSalesByPeriod(StatisticsSearchDto searchDto);

    // ===== 지출 통계 =====

    /**
     * ST-004: 지점별 지출 통계
     */
    List<ExpenseStatisticsDto> selectExpensesByBranch(StatisticsSearchDto searchDto);

    /**
     * ST-005: 항목별 지출 통계
     */
    List<ExpenseStatisticsDto> selectExpensesByCategory(StatisticsSearchDto searchDto);

    /**
     * ST-006: 기간별 지출 통계
     */
    List<ExpenseStatisticsDto> selectExpensesByPeriod(StatisticsSearchDto searchDto);

    // ===== 비교 분석 =====

    /**
     * ST-007: 정산 대상 매출 조회
     */
    List<UnsettledSaleDto> selectUnsettledSales(StatisticsSearchDto searchDto);

    /**
     * ST-008: 매출 대비 지출 비교 (손익 분석)
     */
    List<ProfitComparisonDto> selectProfitComparison(StatisticsSearchDto searchDto);
}
