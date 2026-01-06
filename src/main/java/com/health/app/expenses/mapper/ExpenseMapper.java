package com.health.app.expenses.mapper;

import com.health.app.expenses.dto.ExpenseDetailDto;
import com.health.app.expenses.dto.ExpenseDto;
import com.health.app.expenses.dto.ExpenseSearchDto;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 지출 관리 Mapper 인터페이스
 */
@Mapper
public interface ExpenseMapper {

    /**
     * 지출 목록 조회 (검색 조건 포함)
     */
    List<ExpenseDetailDto> selectExpenseList(ExpenseSearchDto searchDto);

    /**
     * 지출 목록 총 개수
     */
    int selectExpenseCount(ExpenseSearchDto searchDto);

    /**
     * 지출 상세 조회
     */
    ExpenseDetailDto selectExpenseDetail(@Param("expenseId") Long expenseId);

    /**
     * 지출 등록
     */
    int insertExpense(ExpenseDto expenseDto);

    /**
     * 지출 수정
     */
    int updateExpense(ExpenseDto expenseDto);

    /**
     * 지출 삭제 (논리 삭제)
     */
    int deleteExpense(@Param("expenseId") Long expenseId, @Param("updateUser") Long updateUser);

    /**
     * 지점 옵션 조회 (드롭다운용)
     */
    List<com.health.app.inventory.OptionDto> selectBranchOptions();
}
