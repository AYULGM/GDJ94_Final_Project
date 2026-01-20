package com.health.app.settlements;

import com.health.app.settlements.*;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

/**
 * 정산 Mapper 인터페이스
 */
@Mapper
public interface SettlementMapper {

    /**
     * 정산 목록 조회
     */
    List<SettlementDetailDto> selectSettlementList(SettlementSearchDto searchDto);

    /**
     * 정산 목록 총 개수
     */
    int selectSettlementCount(SettlementSearchDto searchDto);

    /**
     * 정산 상세 조회
     */
    SettlementDetailDto selectSettlementDetail(@Param("settlementId") Long settlementId);

    /**
     * 정산 등록
     */
    int insertSettlement(SettlementDto settlementDto);

    /**
     * 정산 수정
     */
    int updateSettlement(SettlementDto settlementDto);

    /**
     * 정산 삭제 (논리 삭제)
     */
    int deleteSettlement(@Param("settlementId") Long settlementId, @Param("updateUser") Long updateUser);

    /**
     * 기간별 매출 합계 조회
     */
    BigDecimal selectSalesTotalAmount(@Param("branchId") Long branchId,
                                      @Param("fromDate") LocalDate fromDate,
                                      @Param("toDate") LocalDate toDate);

    /**
     * 기간별 지출 합계 조회
     */
    BigDecimal selectExpensesTotalAmount(@Param("branchId") Long branchId,
                                         @Param("fromDate") LocalDate fromDate,
                                         @Param("toDate") LocalDate toDate);

    /**
     * 기간별 매출 건수 조회
     */
    Long selectSalesCount(@Param("branchId") Long branchId,
                          @Param("fromDate") LocalDate fromDate,
                          @Param("toDate") LocalDate toDate);

    /**
     * 기간별 지출 건수 조회
     */
    Long selectExpensesCount(@Param("branchId") Long branchId,
                             @Param("fromDate") LocalDate fromDate,
                             @Param("toDate") LocalDate toDate);

    /**
     * 정산-매출 매핑 등록 (일괄)
     */
    int insertSettlementSaleMaps(@Param("settlementId") Long settlementId,
                                 @Param("branchId") Long branchId,
                                 @Param("fromDate") LocalDate fromDate,
                                 @Param("toDate") LocalDate toDate,
                                 @Param("createUser") Long createUser);

    /**
     * 정산-지출 매핑 등록 (일괄)
     */
    int insertSettlementExpenseMaps(@Param("settlementId") Long settlementId,
                                    @Param("branchId") Long branchId,
                                    @Param("fromDate") LocalDate fromDate,
                                    @Param("toDate") LocalDate toDate,
                                    @Param("createUser") Long createUser);

    /**
     * 선택된 매출 합계 조회
     */
    BigDecimal selectSelectedSalesTotalAmount(@Param("saleIds") List<Long> saleIds);

    /**
     * 선택된 지출 합계 조회
     */
    BigDecimal selectSelectedExpensesTotalAmount(@Param("expenseIds") List<Long> expenseIds);

    /**
     * 선택된 매출 정산 매핑 등록
     */
    int insertSelectedSettlementSaleMaps(@Param("settlementId") Long settlementId,
                                         @Param("saleIds") List<Long> saleIds,
                                         @Param("createUser") Long createUser);

    /**
     * 선택된 지출 정산 매핑 등록
     */
    int insertSelectedSettlementExpenseMaps(@Param("settlementId") Long settlementId,
                                            @Param("expenseIds") List<Long> expenseIds,
                                            @Param("createUser") Long createUser);

    /**
     * 정산 이력 로그 등록
     */
    int insertSettlementHistory(SettlementHistoryDto historyDto);

    /**
     * 정산 이력 로그 조회
     */
    List<SettlementHistoryDto> selectSettlementHistories(@Param("settlementId") Long settlementId);

    /**
     * 정산 취소 시 매출 매핑 해제
     */
    int releaseSettlementSaleMaps(@Param("settlementId") Long settlementId,
                                   @Param("updateUser") Long updateUser);

    /**
     * 정산 취소 시 지출 매핑 해제
     */
    int releaseSettlementExpenseMaps(@Param("settlementId") Long settlementId,
                                      @Param("updateUser") Long updateUser);
     * 선택된 매출의 지점별 그룹화 조회
     */
    List<Map<String, Object>> selectSelectedSalesGroupByBranch(@Param("saleIds") List<Long> saleIds);

    /**
     * 선택된 지출의 지점별 그룹화 조회
     */
    List<Map<String, Object>> selectSelectedExpensesGroupByBranch(@Param("expenseIds") List<Long> expenseIds);

    /**
     * 특정 지점의 선택된 매출 합계 조회
     */
    BigDecimal selectSelectedSalesTotalAmountByBranch(@Param("saleIds") List<Long> saleIds, @Param("branchId") Long branchId);

    /**
     * 특정 지점의 선택된 지출 합계 조회
     */
    BigDecimal selectSelectedExpensesTotalAmountByBranch(@Param("expenseIds") List<Long> expenseIds, @Param("branchId") Long branchId);

    /**
     * 특정 지점의 선택된 매출 정산 매핑 등록
     */
    int insertSelectedSettlementSaleMapsByBranch(@Param("settlementId") Long settlementId,
                                                  @Param("saleIds") List<Long> saleIds,
                                                  @Param("branchId") Long branchId,
                                                  @Param("createUser") Long createUser);

    /**
     * 특정 지점의 선택된 지출 정산 매핑 등록
     */
    int insertSelectedSettlementExpenseMapsByBranch(@Param("settlementId") Long settlementId,
                                                     @Param("expenseIds") List<Long> expenseIds,
                                                     @Param("branchId") Long branchId,
                                                     @Param("createUser") Long createUser);
}
