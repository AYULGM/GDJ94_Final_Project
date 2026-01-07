package com.health.app.settlements;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 정산 기본 DTO
 */
@Data
@Builder
public class SettlementDto {

    private Long settlementId;
    private String settlementNo;
    private Long branchId;
    private LocalDate fromDate;
    private LocalDate toDate;
    private BigDecimal salesAmount;
    private BigDecimal expenseAmount;
    private BigDecimal profitAmount;
    private String statusCode;
    private LocalDateTime settledAt;
    private Long settledBy;

    private Long createUser;
    private LocalDateTime createDate;
    private Long updateUser;
    private LocalDateTime updateDate;
    private Boolean useYn;
}
