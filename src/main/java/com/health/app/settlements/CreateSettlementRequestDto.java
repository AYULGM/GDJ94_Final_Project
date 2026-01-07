package com.health.app.settlements;

import lombok.Data;

import java.time.LocalDate;

/**
 * 정산 생성 요청 DTO
 */
@Data
public class CreateSettlementRequestDto {

    private Long branchId;           // 지점 ID (null이면 전체)
    private LocalDate fromDate;      // 정산 시작일 (필수)
    private LocalDate toDate;        // 정산 종료일 (필수)
}
