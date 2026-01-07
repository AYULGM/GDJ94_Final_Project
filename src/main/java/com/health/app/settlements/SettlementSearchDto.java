package com.health.app.settlements;

import lombok.Data;

import java.time.LocalDate;

/**
 * 정산 검색 조건 DTO
 */
@Data
public class SettlementSearchDto {

    private Long branchId;           // 지점 ID
    private String statusCode;       // 정산 상태 (PENDING, CONFIRMED, CANCELLED)
    private LocalDate startDate;     // 검색 시작일 (fromDate 기준)
    private LocalDate endDate;       // 검색 종료일 (toDate 기준)
    private String keyword;          // 검색 키워드 (정산 번호)

    // 페이징 관련
    private Integer page;            // 현재 페이지
    private Integer pageSize;        // 페이지당 개수
    private Integer offset;          // OFFSET
}
