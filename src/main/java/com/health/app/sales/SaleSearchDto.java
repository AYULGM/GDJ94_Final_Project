package com.health.app.sales;

import lombok.Data;

import java.time.LocalDate;

/**
 * 매출 검색 조건 DTO
 */
@Data
public class SaleSearchDto {

    private Long branchId;           // 지점 ID
    private String statusCode;       // 매출 상태 (COMPLETED, CANCELLED)
    private String categoryCode;     // 매출 카테고리
    private LocalDate startDate;     // 검색 시작일
    private LocalDate endDate;       // 검색 종료일
    private String keyword;          // 검색 키워드 (매출 번호, 메모)
    private Boolean settlementFlag;  // 정산 여부 (true: 정산됨, false: 미정산)

    // 페이징 관련
    private Integer page;            // 현재 페이지
    private Integer pageSize;        // 페이지당 개수
    private Integer offset;          // OFFSET
}
