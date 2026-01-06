package com.health.app.expenses.dto;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 지출 기본 DTO
 */
@Data
@Builder
public class ExpenseDto {

    private Long expenseId;
    private Long branchId;
    private LocalDateTime expenseAt;
    private String categoryCode;
    private BigDecimal amount;
    private String description;
    private String memo;
    private Long handledBy;
    private Boolean settlementFlag;

    private Long createUser;
    private LocalDateTime createDate;
    private Long updateUser;
    private LocalDateTime updateDate;
    private Boolean useYn;
}
