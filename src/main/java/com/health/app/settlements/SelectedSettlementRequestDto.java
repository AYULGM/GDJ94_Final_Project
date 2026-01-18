package com.health.app.settlements;

import lombok.Data;

import java.time.LocalDate;
import java.util.List;

/**
 * 선택 정산 생성 요청 DTO
 */
@Data
public class SelectedSettlementRequestDto {

    private List<Long> saleIds;       // 선택된 매출 ID 목록
    private List<Long> expenseIds;    // 선택된 지출 ID 목록
    private Long branchId;            // 지점 ID (null이면 전체)
    private LocalDate fromDate;       // 정산 시작일
    private LocalDate toDate;         // 정산 종료일
}
