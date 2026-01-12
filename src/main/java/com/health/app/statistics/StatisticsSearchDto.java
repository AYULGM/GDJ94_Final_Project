package com.health.app.statistics;

import lombok.Data;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDate;

/**
 * 통계 검색 조건 DTO
 */
@Data
public class StatisticsSearchDto {

    private Long branchId;           // 지점 ID (전체 조회 시 null)

    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)  // ISO 8601 형식 (yyyy-MM-dd) 파싱
    private LocalDate startDate;     // 시작일 (필수)

    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)  // ISO 8601 형식 (yyyy-MM-dd) 파싱
    private LocalDate endDate;       // 종료일 (필수)

    private String categoryCode;     // 카테고리 코드 (항목별 통계 시)
    private String groupBy;          // 그룹핑 기준 (daily, monthly, quarterly, yearly)
}
