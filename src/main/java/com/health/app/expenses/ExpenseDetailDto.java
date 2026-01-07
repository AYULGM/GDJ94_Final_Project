package com.health.app.expenses;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 지출 상세 조회용 DTO (JOIN 결과)
 */
@Data
public class ExpenseDetailDto {

    // 지출 기본 정보
    private Long expenseId;
    private Long branchId;
    private String branchName;
    private LocalDateTime expenseAt;
    private String categoryCode;
    private BigDecimal amount;
    private String description;
    private String memo;
    private Long handledBy;
    private String handledByName;
    private Boolean settlementFlag;

    // 생성/수정 정보
    private Long createUser;
    private String createUserName;
    private LocalDateTime createDate;
    private Long updateUser;
    private String updateUserName;
    private LocalDateTime updateDate;
}
