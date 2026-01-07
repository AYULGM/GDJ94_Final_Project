package com.health.app.expenses;

import com.health.app.expenses.ExpenseDetailDto;
import com.health.app.expenses.ExpenseDto;
import com.health.app.expenses.ExpenseSearchDto;

import java.util.List;
import java.util.Map;

/**
 * 지출 관리 Service 인터페이스
 */
public interface ExpenseService {

    /**
     * 지출 목록 조회 (페이징 포함)
     */
    Map<String, Object> getExpenseList(ExpenseSearchDto searchDto);

    /**
     * 지출 상세 조회
     */
    ExpenseDetailDto getExpenseDetail(Long expenseId);

    /**
     * 지출 등록
     */
    void createExpense(ExpenseDto expenseDto, Long currentUserId);

    /**
     * 지출 수정
     */
    void updateExpense(ExpenseDto expenseDto, Long currentUserId);

    /**
     * 지출 삭제 (논리 삭제)
     */
    void deleteExpense(Long expenseId, Long currentUserId);

    /**
     * 지점 옵션 조회
     */
    List<com.health.app.inventory.OptionDto> getBranchOptions();
}
