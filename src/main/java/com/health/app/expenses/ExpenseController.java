package com.health.app.expenses;

import com.health.app.expenses.ExpenseDetailDto;
import com.health.app.expenses.ExpenseDto;
import com.health.app.expenses.ExpenseSearchDto;
import com.health.app.expenses.ExpenseService;
import com.health.app.security.model.LoginUser;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 지출 관리 Controller
 */
@Controller
@RequestMapping("/expenses")
@RequiredArgsConstructor
public class ExpenseController {

    private final ExpenseService expenseService;

    /**
     * 지출 목록 페이지
     */
    @GetMapping
    public String expenseListPage(Model model) {
        model.addAttribute("pageTitle", "지출 관리");
        return "expenses/list";
    }

    /**
     * 지출 등록 페이지
     */
    @GetMapping("/form")
    public String expenseFormPage(@RequestParam(required = false) Long expenseId, Model model) {
        model.addAttribute("pageTitle", expenseId == null ? "지출 등록" : "지출 수정");
        if (expenseId != null) {
            model.addAttribute("expenseId", expenseId);
        }
        return "expenses/form";
    }

    /**
     * 지출 상세 페이지
     */
    @GetMapping("/{expenseId}")
    public String expenseDetailPage(@PathVariable Long expenseId, Model model) {
        model.addAttribute("pageTitle", "지출 상세");
        model.addAttribute("expenseId", expenseId);
        return "expenses/detail";
    }

    /**
     * 지출 목록 조회 API
     */
    @GetMapping("/api/list")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getExpenseList(ExpenseSearchDto searchDto) {
        Map<String, Object> result = expenseService.getExpenseList(searchDto);
        return ResponseEntity.ok(result);
    }

    /**
     * 지출 상세 조회 API
     */
    @GetMapping("/api/{expenseId}")
    @ResponseBody
    public ResponseEntity<ExpenseDetailDto> getExpenseDetail(@PathVariable Long expenseId) {
        ExpenseDetailDto expense = expenseService.getExpenseDetail(expenseId);
        return ResponseEntity.ok(expense);
    }

    /**
     * 지출 등록 API
     */
    @PostMapping("/api")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> createExpense(
            @RequestBody ExpenseDto expenseDto,
            Authentication authentication) {
        LoginUser loginUser = (LoginUser) authentication.getPrincipal();
        expenseService.createExpense(expenseDto, loginUser.getUserId());

        Map<String, Object> response = Map.of(
                "success", true,
                "message", "지출이 등록되었습니다."
        );
        return ResponseEntity.ok(response);
    }

    /**
     * 지출 수정 API
     */
    @PutMapping("/api/{expenseId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updateExpense(
            @PathVariable Long expenseId,
            @RequestBody ExpenseDto expenseDto,
            Authentication authentication) {
        LoginUser loginUser = (LoginUser) authentication.getPrincipal();
        expenseDto.setExpenseId(expenseId);
        expenseService.updateExpense(expenseDto, loginUser.getUserId());

        Map<String, Object> response = Map.of(
                "success", true,
                "message", "지출이 수정되었습니다."
        );
        return ResponseEntity.ok(response);
    }

    /**
     * 지출 삭제 API
     */
    @DeleteMapping("/api/{expenseId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deleteExpense(
            @PathVariable Long expenseId,
            Authentication authentication) {
        LoginUser loginUser = (LoginUser) authentication.getPrincipal();
        expenseService.deleteExpense(expenseId, loginUser.getUserId());

        Map<String, Object> response = Map.of(
                "success", true,
                "message", "지출이 삭제되었습니다."
        );
        return ResponseEntity.ok(response);
    }

    /**
     * 지점 옵션 조회 API
     */
    @GetMapping("/api/options/branches")
    @ResponseBody
    public ResponseEntity<?> getBranchOptions() {
        return ResponseEntity.ok(expenseService.getBranchOptions());
    }
}
