package com.health.app.statistics.dto;

import lombok.Data;

import java.math.BigDecimal;

/**
 * 손익 비교 통계 결과 DTO
 */
@Data
public class ProfitComparisonDto {

    // 기준 정보
    private Long branchId;
    private String branchName;
    private String period;           // 기간 (YYYY-MM)
    private String periodLabel;      // 기간 라벨 (2024년 1월)

    // 매출 정보
    private BigDecimal salesAmount;  // 총 매출 금액
    private Long salesCount;         // 매출 건수

    // 지출 정보
    private BigDecimal expenseAmount; // 총 지출 금액
    private Long expenseCount;        // 지출 건수

    // 손익 정보
    private BigDecimal profitAmount;  // 손익 금액 (매출 - 지출)
    private String profitStatus;      // 손익 상태 (PROFIT:흑자, LOSS:적자, BREAK_EVEN:손익분기)
    private Double profitRate;        // 수익률 (%)
}
