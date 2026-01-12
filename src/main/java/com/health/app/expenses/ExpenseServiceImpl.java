package com.health.app.expenses;

import com.health.app.expenses.ExpenseDetailDto;
import com.health.app.expenses.ExpenseDto;
import com.health.app.expenses.ExpenseSearchDto;
import com.health.app.expenses.ExpenseMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 지출 관리 Service 구현체
 *
 * @CacheEvict: 지출 데이터 변경 시 통계 캐시 무효화
 * - 지출 등록/수정/삭제 시 모든 통계 캐시를 삭제하여 데이터 정합성 보장
 */
@Service
@RequiredArgsConstructor
public class ExpenseServiceImpl implements ExpenseService {

    private final ExpenseMapper expenseMapper;

    @Override
    public Map<String, Object> getExpenseList(ExpenseSearchDto searchDto) {
        // 페이징 처리
        if (searchDto.getPage() == null) {
            searchDto.setPage(1);
        }
        if (searchDto.getPageSize() == null) {
            searchDto.setPageSize(10);
        }
        searchDto.setOffset((searchDto.getPage() - 1) * searchDto.getPageSize());

        // 목록 조회
        List<ExpenseDetailDto> list = expenseMapper.selectExpenseList(searchDto);
        int totalCount = expenseMapper.selectExpenseCount(searchDto);

        Map<String, Object> result = new HashMap<>();
        result.put("list", list);
        result.put("totalCount", totalCount);
        result.put("currentPage", searchDto.getPage());
        result.put("pageSize", searchDto.getPageSize());
        result.put("totalPages", (int) Math.ceil((double) totalCount / searchDto.getPageSize()));

        return result;
    }

    @Override
    public ExpenseDetailDto getExpenseDetail(Long expenseId) {
        return expenseMapper.selectExpenseDetail(expenseId);
    }

    @Override
    @Transactional
    @CacheEvict(value = "statistics", allEntries = true)
    public void createExpense(ExpenseDto expenseDto, Long currentUserId) {
        expenseDto.setCreateUser(currentUserId);

        // settlement_flag 기본값 설정
        if (expenseDto.getSettlementFlag() == null) {
            expenseDto.setSettlementFlag(true);
        }

        expenseMapper.insertExpense(expenseDto);
    }

    @Override
    @Transactional
    @CacheEvict(value = "statistics", allEntries = true)
    public void updateExpense(ExpenseDto expenseDto, Long currentUserId) {
        expenseDto.setUpdateUser(currentUserId);
        expenseMapper.updateExpense(expenseDto);
    }

    @Override
    @Transactional
    @CacheEvict(value = "statistics", allEntries = true)
    public void deleteExpense(Long expenseId, Long currentUserId) {
        expenseMapper.deleteExpense(expenseId, currentUserId);
    }

    @Override
    @org.springframework.cache.annotation.Cacheable(value = "options", key = "'branches'")
    public List<com.health.app.inventory.OptionDto> getBranchOptions() {
        return expenseMapper.selectBranchOptions();
    }
}
