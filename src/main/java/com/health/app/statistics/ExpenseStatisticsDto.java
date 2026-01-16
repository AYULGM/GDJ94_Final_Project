package com.health.app.statistics;

import lombok.Data;

import java.math.BigDecimal;

/**
 * 지출 통계 결과 DTO
 */
@Data
public class ExpenseStatisticsDto {

    // 지점별 통계
    private Long branchId;
    private String branchName;

    // 항목별 통계
    private String categoryCode;
    private String categoryName;

    // 기간별 통계
    private String period;           // 기간 (YYYY-MM, YYYY-Q1, YYYY)
    private String periodLabel;      // 기간 라벨 (2024년 1월, 2024년 1분기)

    // 통계 데이터
    private BigDecimal totalAmount;  // 총 지출 금액
    private Long expenseCount;       // 지출 건수
    private BigDecimal avgAmount;    // 평균 지출 금액

    // 비중 데이터
    private Double percentage;       // 지출 비중 (%)
}
