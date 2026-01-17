package com.health.app.statistics;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 정산 대상 지출 조회 DTO
 */
@Data
public class UnsettledExpenseDto {

    private Long expenseId;
    private Long branchId;
    private String branchName;
    private LocalDateTime expenseAt;
    private String categoryCode;
    private BigDecimal amount;
    private String description;
    private Boolean settlementFlag;  // 정산 대상 여부
    private Boolean settled;         // 정산 여부 (true: 정산완료, false: 미정산)
    private Long settlementId;       // 정산 ID (정산된 경우)
}
