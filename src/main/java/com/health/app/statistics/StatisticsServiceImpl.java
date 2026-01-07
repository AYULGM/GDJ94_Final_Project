package com.health.app.statistics;

import com.health.app.statistics.*;
import com.health.app.statistics.StatisticsMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 통계 Service 구현체
 */
@Service
@RequiredArgsConstructor
public class StatisticsServiceImpl implements StatisticsService {

    private final StatisticsMapper statisticsMapper;

    @Override
    public List<SalesStatisticsDto> getSalesByBranch(StatisticsSearchDto searchDto) {
        validateSearchDto(searchDto);
        return statisticsMapper.selectSalesByBranch(searchDto);
    }

    @Override
    public List<SalesStatisticsDto> getSalesByCategory(StatisticsSearchDto searchDto) {
        validateSearchDto(searchDto);
        return statisticsMapper.selectSalesByCategory(searchDto);
    }

    @Override
    public List<SalesStatisticsDto> getSalesByPeriod(StatisticsSearchDto searchDto) {
        validateSearchDto(searchDto);
        // groupBy 기본값 설정
        if (searchDto.getGroupBy() == null || searchDto.getGroupBy().isEmpty()) {
            searchDto.setGroupBy("monthly");
        }
        return statisticsMapper.selectSalesByPeriod(searchDto);
    }

    @Override
    public List<ExpenseStatisticsDto> getExpensesByBranch(StatisticsSearchDto searchDto) {
        validateSearchDto(searchDto);
        return statisticsMapper.selectExpensesByBranch(searchDto);
    }

    @Override
    public List<ExpenseStatisticsDto> getExpensesByCategory(StatisticsSearchDto searchDto) {
        validateSearchDto(searchDto);
        return statisticsMapper.selectExpensesByCategory(searchDto);
    }

    @Override
    public List<ExpenseStatisticsDto> getExpensesByPeriod(StatisticsSearchDto searchDto) {
        validateSearchDto(searchDto);
        // groupBy 기본값 설정
        if (searchDto.getGroupBy() == null || searchDto.getGroupBy().isEmpty()) {
            searchDto.setGroupBy("monthly");
        }
        return statisticsMapper.selectExpensesByPeriod(searchDto);
    }

    @Override
    public List<UnsettledSaleDto> getUnsettledSales(StatisticsSearchDto searchDto) {
        validateSearchDto(searchDto);
        return statisticsMapper.selectUnsettledSales(searchDto);
    }

    @Override
    public List<ProfitComparisonDto> getProfitComparison(StatisticsSearchDto searchDto) {
        validateSearchDto(searchDto);
        // groupBy 기본값 설정
        if (searchDto.getGroupBy() == null || searchDto.getGroupBy().isEmpty()) {
            searchDto.setGroupBy("monthly");
        }
        return statisticsMapper.selectProfitComparison(searchDto);
    }

    /**
     * 검색 조건 유효성 검사
     */
    private void validateSearchDto(StatisticsSearchDto searchDto) {
        if (searchDto.getStartDate() == null || searchDto.getEndDate() == null) {
            throw new IllegalArgumentException("조회 기간은 필수입니다.");
        }
        if (searchDto.getStartDate().isAfter(searchDto.getEndDate())) {
            throw new IllegalArgumentException("시작일은 종료일보다 이전이어야 합니다.");
        }
    }
}
