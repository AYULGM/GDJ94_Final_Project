package com.health.app.statistics;

import com.health.app.statistics.*;
import com.health.app.statistics.StatisticsService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 통계 Controller
 */
@Controller
@RequestMapping("/statistics")
@RequiredArgsConstructor
public class StatisticsController {

    private final StatisticsService statisticsService;

    /**
     * 통계 대시보드 페이지
     */
    @GetMapping
    public String statisticsViewPage(Model model) {
        model.addAttribute("pageTitle", "Dash Board");
        return "statistics/view";
    }

    /**
     * 매출 통계 페이지 - 기본 탭(지점별)으로 리다이렉트
     */
    @GetMapping("/sales")
    public String salesStatisticsPage() {
        return "redirect:/statistics/sales/by-branch";
    }

    /**
     * 지출 통계 페이지 - 기본 탭(지점별)으로 리다이렉트
     */
    @GetMapping("/expenses")
    public String expensesStatisticsPage() {
        return "redirect:/statistics/expenses/by-branch";
    }

    /**
     * 매출 통계 - 지점별
     */
    @GetMapping("/sales/by-branch")
    public String salesByBranchPage(Model model) {
        model.addAttribute("pageTitle", "매출 통계 - 지점별");
        model.addAttribute("activeTab", "branch");
        return "statistics/sales";
    }

    /**
     * 매출 통계 - 항목별
     */
    @GetMapping("/sales/by-category")
    public String salesByCategoryPage(Model model) {
        model.addAttribute("pageTitle", "매출 통계 - 항목별");
        model.addAttribute("activeTab", "category");
        return "statistics/sales";
    }

    /**
     * 매출 통계 - 기간별
     */
    @GetMapping("/sales/by-period")
    public String salesByPeriodPage(Model model) {
        model.addAttribute("pageTitle", "매출 통계 - 기간별");
        model.addAttribute("activeTab", "period");
        return "statistics/sales";
    }

    /**
     * 지출 통계 - 지점별
     */
    @GetMapping("/expenses/by-branch")
    public String expensesByBranchPage(Model model) {
        model.addAttribute("pageTitle", "지출 통계 - 지점별");
        model.addAttribute("activeTab", "branch");
        return "statistics/expenses";
    }

    /**
     * 지출 통계 - 항목별
     */
    @GetMapping("/expenses/by-category")
    public String expensesByCategoryPage(Model model) {
        model.addAttribute("pageTitle", "지출 통계 - 항목별");
        model.addAttribute("activeTab", "category");
        return "statistics/expenses";
    }

    /**
     * 지출 통계 - 기간별
     */
    @GetMapping("/expenses/by-period")
    public String expensesByPeriodPage(Model model) {
        model.addAttribute("pageTitle", "지출 통계 - 기간별");
        model.addAttribute("activeTab", "period");
        return "statistics/expenses";
    }

    /**
     * 손익 비교 페이지
     */
    @GetMapping("/comparison")
    public String comparisonStatisticsPage(Model model) {
        model.addAttribute("pageTitle", "손익 비교");
        return "statistics/comparison";
    }

    // ===== 매출 통계 API =====

    /**
     * ST-001: 지점별 매출 통계 API
     */
    @GetMapping("/api/sales/by-branch")
    @ResponseBody
    public ResponseEntity<List<SalesStatisticsDto>> getSalesByBranch(StatisticsSearchDto searchDto) {
        List<SalesStatisticsDto> result = statisticsService.getSalesByBranch(searchDto);
        return ResponseEntity.ok(result);
    }

    /**
     * ST-002: 항목별 매출 통계 API
     */
    @GetMapping("/api/sales/by-category")
    @ResponseBody
    public ResponseEntity<List<SalesStatisticsDto>> getSalesByCategory(StatisticsSearchDto searchDto) {
        List<SalesStatisticsDto> result = statisticsService.getSalesByCategory(searchDto);
        return ResponseEntity.ok(result);
    }

    /**
     * ST-003: 기간별 매출 통계 API
     */
    @GetMapping("/api/sales/by-period")
    @ResponseBody
    public ResponseEntity<List<SalesStatisticsDto>> getSalesByPeriod(StatisticsSearchDto searchDto) {
        List<SalesStatisticsDto> result = statisticsService.getSalesByPeriod(searchDto);
        return ResponseEntity.ok(result);
    }

    // ===== 지출 통계 API =====

    /**
     * ST-004: 지점별 지출 통계 API
     */
    @GetMapping("/api/expenses/by-branch")
    @ResponseBody
    public ResponseEntity<List<ExpenseStatisticsDto>> getExpensesByBranch(StatisticsSearchDto searchDto) {
        List<ExpenseStatisticsDto> result = statisticsService.getExpensesByBranch(searchDto);
        return ResponseEntity.ok(result);
    }

    /**
     * ST-005: 항목별 지출 통계 API
     */
    @GetMapping("/api/expenses/by-category")
    @ResponseBody
    public ResponseEntity<List<ExpenseStatisticsDto>> getExpensesByCategory(StatisticsSearchDto searchDto) {
        List<ExpenseStatisticsDto> result = statisticsService.getExpensesByCategory(searchDto);
        return ResponseEntity.ok(result);
    }

    /**
     * ST-006: 기간별 지출 통계 API
     */
    @GetMapping("/api/expenses/by-period")
    @ResponseBody
    public ResponseEntity<List<ExpenseStatisticsDto>> getExpensesByPeriod(StatisticsSearchDto searchDto) {
        List<ExpenseStatisticsDto> result = statisticsService.getExpensesByPeriod(searchDto);
        return ResponseEntity.ok(result);
    }

    // ===== 비교 분석 API =====

    /**
     * ST-007: 정산 대상 매출 조회 API
     */
    @GetMapping("/api/unsettled-sales")
    @ResponseBody
    public ResponseEntity<List<UnsettledSaleDto>> getUnsettledSales(StatisticsSearchDto searchDto) {
        List<UnsettledSaleDto> result = statisticsService.getUnsettledSales(searchDto);
        return ResponseEntity.ok(result);
    }

    /**
     * ST-008: 매출 대비 지출 비교 API (손익 분석)
     */
    @GetMapping("/api/comparison")
    @ResponseBody
    public ResponseEntity<List<ProfitComparisonDto>> getProfitComparison(StatisticsSearchDto searchDto) {
        List<ProfitComparisonDto> result = statisticsService.getProfitComparison(searchDto);
        return ResponseEntity.ok(result);
    }
}
