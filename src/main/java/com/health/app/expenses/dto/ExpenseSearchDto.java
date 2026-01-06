package com.health.app.expenses.dto;

import lombok.Data;

import java.time.LocalDate;

/**
 * 지출 검색 조건 DTO
 */
@Data
public class ExpenseSearchDto {

    private Long branchId;           // 지점 ID
    private String categoryCode;     // 지출 카테고리
    private Boolean settlementFlag;  // 정산 포함 여부
    private LocalDate startDate;     // 검색 시작일
    private LocalDate endDate;       // 검색 종료일
    private String keyword;          // 검색 키워드 (설명, 메모)

    // 페이징 관련
    private Integer page;            // 현재 페이지
    private Integer pageSize;        // 페이지당 개수
    private Integer offset;          // OFFSET
}
