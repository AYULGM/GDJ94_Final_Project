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
    private Boolean settlementFlag;   // 정산 대상 여부 (지출 등록 시 설정)
    private Boolean settled;          // 실제 정산 완료 여부 (매핑 테이블 기준)

    // 생성/수정 정보
    private Long createUser;
    private String createUserName;
    private LocalDateTime createDate;
    private Long updateUser;
    private String updateUserName;
    private LocalDateTime updateDate;
}
