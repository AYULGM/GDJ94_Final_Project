package com.health.app.settlements.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 정산 상세 조회용 DTO
 */
@Data
public class SettlementDetailDto {

    // 정산 기본 정보
    private Long settlementId;
    private String settlementNo;
    private Long branchId;
    private String branchName;
    private LocalDate fromDate;
    private LocalDate toDate;
    private BigDecimal salesAmount;
    private BigDecimal expenseAmount;
    private BigDecimal profitAmount;
    private String statusCode;
    private LocalDateTime settledAt;
    private Long settledBy;
    private String settledByName;

    // 통계 정보
    private Long salesCount;        // 매출 건수
    private Long expenseCount;      // 지출 건수

    // 생성/수정 정보
    private Long createUser;
    private String createUserName;
    private LocalDateTime createDate;
    private Long updateUser;
    private String updateUserName;
    private LocalDateTime updateDate;
}
