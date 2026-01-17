package com.health.app.statistics;

import com.health.app.statistics.*;
import com.health.app.statistics.StatisticsMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

/**
 * 통계 Service 구현체
 *
 * @Cacheable 적용으로 통계 조회 성능 개선:
 * - 동일한 검색 조건의 반복 조회 시 DB 쿼리 생략
 * - 캐시 TTL: 5분 (CacheConfig 참조)
 */
@Service
@RequiredArgsConstructor
public class StatisticsServiceImpl implements StatisticsService {

    private final StatisticsMapper statisticsMapper;

    @Override
    @Cacheable(value = "statistics",
               key = "'salesByBranch:' + #searchDto.startDate + ':' + #searchDto.endDate + ':' + (#searchDto.branchId != null ? #searchDto.branchId : 'all')")
    public List<SalesStatisticsDto> getSalesByBranch(StatisticsSearchDto searchDto) {
        validateSearchDto(searchDto);
        return statisticsMapper.selectSalesByBranch(searchDto);
    }

    @Override
    @Cacheable(value = "statistics",
               key = "'salesByCategory:' + #searchDto.startDate + ':' + #searchDto.endDate + ':' + (#searchDto.branchId != null ? #searchDto.branchId : 'all')")
    public List<SalesStatisticsDto> getSalesByCategory(StatisticsSearchDto searchDto) {
        validateSearchDto(searchDto);
        return statisticsMapper.selectSalesByCategory(searchDto);
    }

    @Override
    @Cacheable(value = "statistics",
               key = "'salesByPeriod:' + #searchDto.startDate + ':' + #searchDto.endDate + ':' + (#searchDto.branchId != null ? #searchDto.branchId : 'all') + ':' + (#searchDto.groupBy != null ? #searchDto.groupBy : 'monthly')")
    public List<SalesStatisticsDto> getSalesByPeriod(StatisticsSearchDto searchDto) {
        validateSearchDto(searchDto);
        // groupBy 기본값 설정
        if (searchDto.getGroupBy() == null || searchDto.getGroupBy().isEmpty()) {
            searchDto.setGroupBy("monthly");
        }
        return statisticsMapper.selectSalesByPeriod(searchDto);
    }

    @Override
    @Cacheable(value = "statistics",
               key = "'expensesByBranch:' + #searchDto.startDate + ':' + #searchDto.endDate + ':' + (#searchDto.branchId != null ? #searchDto.branchId : 'all')")
    public List<ExpenseStatisticsDto> getExpensesByBranch(StatisticsSearchDto searchDto) {
        validateSearchDto(searchDto);
        return statisticsMapper.selectExpensesByBranch(searchDto);
    }

    @Override
    @Cacheable(value = "statistics",
               key = "'expensesByCategory:' + #searchDto.startDate + ':' + #searchDto.endDate + ':' + (#searchDto.branchId != null ? #searchDto.branchId : 'all')")
    public List<ExpenseStatisticsDto> getExpensesByCategory(StatisticsSearchDto searchDto) {
        validateSearchDto(searchDto);
        return statisticsMapper.selectExpensesByCategory(searchDto);
    }

    @Override
    @Cacheable(value = "statistics",
               key = "'expensesByPeriod:' + #searchDto.startDate + ':' + #searchDto.endDate + ':' + (#searchDto.branchId != null ? #searchDto.branchId : 'all') + ':' + (#searchDto.groupBy != null ? #searchDto.groupBy : 'monthly')")
    public List<ExpenseStatisticsDto> getExpensesByPeriod(StatisticsSearchDto searchDto) {
        validateSearchDto(searchDto);
        // groupBy 기본값 설정
        if (searchDto.getGroupBy() == null || searchDto.getGroupBy().isEmpty()) {
            searchDto.setGroupBy("monthly");
        }
        return statisticsMapper.selectExpensesByPeriod(searchDto);
    }

    @Override
    @Cacheable(value = "statistics",
               key = "'unsettledSales:' + #searchDto.startDate + ':' + #searchDto.endDate + ':' + (#searchDto.branchId != null ? #searchDto.branchId : 'all')")
    public List<UnsettledSaleDto> getUnsettledSales(StatisticsSearchDto searchDto) {
        validateSearchDto(searchDto);
        return statisticsMapper.selectUnsettledSales(searchDto);
    }

    @Override
    @Cacheable(value = "statistics",
               key = "'unsettledExpenses:' + #searchDto.startDate + ':' + #searchDto.endDate + ':' + (#searchDto.branchId != null ? #searchDto.branchId : 'all')")
    public List<UnsettledExpenseDto> getUnsettledExpenses(StatisticsSearchDto searchDto) {
        validateSearchDto(searchDto);
        return statisticsMapper.selectUnsettledExpenses(searchDto);
    }

    @Override
    @Cacheable(value = "statistics",
               key = "'profitComparison:' + #searchDto.startDate + ':' + #searchDto.endDate + ':' + (#searchDto.branchId != null ? #searchDto.branchId : 'all') + ':' + (#searchDto.groupBy != null ? #searchDto.groupBy : 'monthly')")
    public List<ProfitComparisonDto> getProfitComparison(StatisticsSearchDto searchDto) {
        validateSearchDto(searchDto);
        // groupBy 기본값 설정
        if (searchDto.getGroupBy() == null || searchDto.getGroupBy().isEmpty()) {
            searchDto.setGroupBy("monthly");
        }
        return statisticsMapper.selectProfitComparison(searchDto);
    }

    /**
     * 검색 조건 유효성 검사 및 기본값 설정
     */
    private void validateSearchDto(StatisticsSearchDto searchDto) {
        // 날짜가 없으면 이번 달 기본값 설정
        if (searchDto.getStartDate() == null) {
            LocalDate today = LocalDate.now();
            searchDto.setStartDate(today.withDayOfMonth(1)); // 이번 달 1일
        }
        if (searchDto.getEndDate() == null) {
            searchDto.setEndDate(LocalDate.now()); // 오늘
        }

        // 시작일이 종료일보다 이후인 경우 스왑
        if (searchDto.getStartDate().isAfter(searchDto.getEndDate())) {
            LocalDate temp = searchDto.getStartDate();
            searchDto.setStartDate(searchDto.getEndDate());
            searchDto.setEndDate(temp);
        }
    }
}
