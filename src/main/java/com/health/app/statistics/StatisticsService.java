package com.health.app.statistics;

import com.health.app.statistics.*;

import java.util.List;

/**
 * 통계 Service 인터페이스
 */
public interface StatisticsService {

    // ===== 매출 통계 =====

    /**
     * ST-001: 지점별 매출 통계
     */
    List<SalesStatisticsDto> getSalesByBranch(StatisticsSearchDto searchDto);

    /**
     * ST-002: 항목별 매출 통계
     */
    List<SalesStatisticsDto> getSalesByCategory(StatisticsSearchDto searchDto);

    /**
     * ST-003: 기간별 매출 통계
     */
    List<SalesStatisticsDto> getSalesByPeriod(StatisticsSearchDto searchDto);

    // ===== 지출 통계 =====

    /**
     * ST-004: 지점별 지출 통계
     */
    List<ExpenseStatisticsDto> getExpensesByBranch(StatisticsSearchDto searchDto);

    /**
     * ST-005: 항목별 지출 통계
     */
    List<ExpenseStatisticsDto> getExpensesByCategory(StatisticsSearchDto searchDto);

    /**
     * ST-006: 기간별 지출 통계
     */
    List<ExpenseStatisticsDto> getExpensesByPeriod(StatisticsSearchDto searchDto);

    // ===== 비교 분석 =====

    /**
     * ST-007: 정산 대상 매출 조회
     */
    List<UnsettledSaleDto> getUnsettledSales(StatisticsSearchDto searchDto);

    /**
     * ST-008: 매출 대비 지출 비교 (손익 분석)
     */
    List<ProfitComparisonDto> getProfitComparison(StatisticsSearchDto searchDto);
}
