package com.health.app.settlements;

import com.health.app.notifications.NotificationService;
import com.health.app.notifications.NotificationType;
import com.health.app.settlements.SettlementActionType;
import com.health.app.settlements.SettlementStatus;
import com.health.app.settlements.*;
import com.health.app.settlements.SettlementMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 정산 Service 구현체
 *
 * @CacheEvict: 정산 데이터 변경 시 통계 및 정산 캐시 무효화
 * - 정산 생성/확정/취소 시 통계 캐시를 삭제하여 데이터 정합성 보장
 */
@Service
@RequiredArgsConstructor
public class SettlementServiceImpl implements SettlementService {

    private final SettlementMapper settlementMapper;
    private final NotificationService notificationService;

    @Override
    public Map<String, Object> getSettlementList(SettlementSearchDto searchDto) {
        // 페이징 처리
        if (searchDto.getPage() == null) {
            searchDto.setPage(1);
        }
        if (searchDto.getPageSize() == null) {
            searchDto.setPageSize(10);
        }
        searchDto.setOffset((searchDto.getPage() - 1) * searchDto.getPageSize());

        // 목록 조회
        List<SettlementDetailDto> list = settlementMapper.selectSettlementList(searchDto);
        int totalCount = settlementMapper.selectSettlementCount(searchDto);

        Map<String, Object> result = new HashMap<>();
        result.put("list", list);
        result.put("totalCount", totalCount);
        result.put("currentPage", searchDto.getPage());
        result.put("pageSize", searchDto.getPageSize());
        result.put("totalPages", (int) Math.ceil((double) totalCount / searchDto.getPageSize()));

        return result;
    }

    @Override
    public SettlementDetailDto getSettlementDetail(Long settlementId) {
        return settlementMapper.selectSettlementDetail(settlementId);
    }

    @Override
    @Transactional
    @CacheEvict(value = {"statistics", "settlements"}, allEntries = true)
    public Long createSettlement(CreateSettlementRequestDto requestDto, Long currentUserId) {
        // 1. 기간별 매출/지출 집계
        BigDecimal salesAmount = settlementMapper.selectSalesTotalAmount(
                requestDto.getBranchId(),
                requestDto.getFromDate(),
                requestDto.getToDate()
        );

        BigDecimal expenseAmount = settlementMapper.selectExpensesTotalAmount(
                requestDto.getBranchId(),
                requestDto.getFromDate(),
                requestDto.getToDate()
        );

        // 2. 손익 계산
        BigDecimal profitAmount = salesAmount.subtract(expenseAmount);

        // 3. 정산 번호 생성
        String settlementNo = generateSettlementNo(requestDto);

        // 4. 정산 등록 (바로 확정 상태로 생성)
        SettlementDto settlementDto = SettlementDto.builder()
                .settlementNo(settlementNo)
                .branchId(requestDto.getBranchId())
                .fromDate(requestDto.getFromDate())
                .toDate(requestDto.getToDate())
                .salesAmount(salesAmount)
                .expenseAmount(expenseAmount)
                .profitAmount(profitAmount)
                .statusCode(SettlementStatus.CONFIRMED.name())
                .settledAt(LocalDateTime.now())
                .settledBy(currentUserId)
                .createUser(currentUserId)
                .build();

        settlementMapper.insertSettlement(settlementDto);
        Long settlementId = settlementDto.getSettlementId();

        // 5. 정산-매출/지출 매핑 등록
        settlementMapper.insertSettlementSaleMaps(
                settlementId,
                requestDto.getBranchId(),
                requestDto.getFromDate(),
                requestDto.getToDate(),
                currentUserId
        );

        settlementMapper.insertSettlementExpenseMaps(
                settlementId,
                requestDto.getBranchId(),
                requestDto.getFromDate(),
                requestDto.getToDate(),
                currentUserId
        );

        // 6. 정산 이력 로그 등록 (바로 확정)
        saveSettlementHistory(
                settlementId,
                SettlementActionType.CONFIRM.name(),
                null,
                SettlementStatus.CONFIRMED.name(),
                "정산 확정",
                currentUserId
        );

        return settlementId;
    }

    @Override
    @Transactional
    @CacheEvict(value = {"statistics", "settlements"}, allEntries = true)
    public Long createSelectedSettlement(SelectedSettlementRequestDto requestDto, Long currentUserId) {
        // 선택된 항목이 없으면 예외
        if ((requestDto.getSaleIds() == null || requestDto.getSaleIds().isEmpty()) &&
            (requestDto.getExpenseIds() == null || requestDto.getExpenseIds().isEmpty())) {
            throw new IllegalArgumentException("정산할 항목을 선택해주세요.");
        }

        // 1. 선택된 매출/지출의 지점별 그룹화 조회
        List<Map<String, Object>> salesByBranch = new java.util.ArrayList<>();
        List<Map<String, Object>> expensesByBranch = new java.util.ArrayList<>();

        if (requestDto.getSaleIds() != null && !requestDto.getSaleIds().isEmpty()) {
            salesByBranch = settlementMapper.selectSelectedSalesGroupByBranch(requestDto.getSaleIds());
        }

        if (requestDto.getExpenseIds() != null && !requestDto.getExpenseIds().isEmpty()) {
            expensesByBranch = settlementMapper.selectSelectedExpensesGroupByBranch(requestDto.getExpenseIds());
        }

        // 2. 모든 지점 ID 수집 (중복 제거)
        java.util.Set<Long> allBranchIds = new java.util.HashSet<>();
        for (Map<String, Object> sales : salesByBranch) {
            Object branchIdObj = sales.get("branchId");
            if (branchIdObj != null) {
                allBranchIds.add(((Number) branchIdObj).longValue());
            }
        }
        for (Map<String, Object> expense : expensesByBranch) {
            Object branchIdObj = expense.get("branchId");
            if (branchIdObj != null) {
                allBranchIds.add(((Number) branchIdObj).longValue());
            }
        }

        if (allBranchIds.isEmpty()) {
            throw new IllegalArgumentException("선택된 항목의 지점 정보를 확인할 수 없습니다.");
        }

        // 3. 지점별로 개별 정산 생성
        Long firstSettlementId = null;
        for (Long branchId : allBranchIds) {
            // 해당 지점의 매출/지출 합계 계산
            BigDecimal salesAmount = BigDecimal.ZERO;
            BigDecimal expenseAmount = BigDecimal.ZERO;

            if (requestDto.getSaleIds() != null && !requestDto.getSaleIds().isEmpty()) {
                salesAmount = settlementMapper.selectSelectedSalesTotalAmountByBranch(requestDto.getSaleIds(), branchId);
                if (salesAmount == null) salesAmount = BigDecimal.ZERO;
            }

            if (requestDto.getExpenseIds() != null && !requestDto.getExpenseIds().isEmpty()) {
                expenseAmount = settlementMapper.selectSelectedExpensesTotalAmountByBranch(requestDto.getExpenseIds(), branchId);
                if (expenseAmount == null) expenseAmount = BigDecimal.ZERO;
            }

            // 해당 지점에 매출/지출이 없으면 스킵
            if (salesAmount.compareTo(BigDecimal.ZERO) == 0 && expenseAmount.compareTo(BigDecimal.ZERO) == 0) {
                continue;
            }

            // 손익 계산
            BigDecimal profitAmount = salesAmount.subtract(expenseAmount);

            // 정산 번호 생성
            String settlementNo = generateSelectedSettlementNo();

            // 정산 등록 (바로 확정 상태로 생성)
            SettlementDto settlementDto = SettlementDto.builder()
                    .settlementNo(settlementNo)
                    .branchId(branchId)
                    .fromDate(requestDto.getFromDate())
                    .toDate(requestDto.getToDate())
                    .salesAmount(salesAmount)
                    .expenseAmount(expenseAmount)
                    .profitAmount(profitAmount)
                    .statusCode(SettlementStatus.CONFIRMED.name())
                    .settledAt(LocalDateTime.now())
                    .settledBy(currentUserId)
                    .createUser(currentUserId)
                    .build();

            settlementMapper.insertSettlement(settlementDto);
            Long settlementId = settlementDto.getSettlementId();

            if (firstSettlementId == null) {
                firstSettlementId = settlementId;
            }

            // 정산-매출/지출 매핑 등록 (해당 지점의 항목만)
            if (requestDto.getSaleIds() != null && !requestDto.getSaleIds().isEmpty()) {
                settlementMapper.insertSelectedSettlementSaleMapsByBranch(
                        settlementId,
                        requestDto.getSaleIds(),
                        branchId,
                        currentUserId
                );
            }

            if (requestDto.getExpenseIds() != null && !requestDto.getExpenseIds().isEmpty()) {
                settlementMapper.insertSelectedSettlementExpenseMapsByBranch(
                        settlementId,
                        requestDto.getExpenseIds(),
                        branchId,
                        currentUserId
                );
            }

            // 정산 이력 로그 등록 (바로 확정)
            saveSettlementHistory(
                    settlementId,
                    SettlementActionType.CONFIRM.name(),
                    null,
                    SettlementStatus.CONFIRMED.name(),
                    "선택 정산 확정",
                    currentUserId
            );
        }

        return firstSettlementId;
    }

    /**
     * 선택 정산 번호 생성 (SEL-YYYYMMDD-XXXXXX)
     */
    private String generateSelectedSettlementNo() {
        String dateStr = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        String randomNum = String.format("%06d", (int) (Math.random() * 1000000));
        return "SEL-" + dateStr + "-" + randomNum;
    }

    @Override
    @Transactional
    @CacheEvict(value = {"statistics", "settlements"}, allEntries = true)
    public void confirmSettlement(Long settlementId, String reason, Long currentUserId) {
        // 1. 기존 정산 정보 조회
        SettlementDetailDto settlement = settlementMapper.selectSettlementDetail(settlementId);
        if (settlement == null) {
            throw new IllegalArgumentException("정산 정보를 찾을 수 없습니다.");
        }

        if (!SettlementStatus.PENDING.name().equals(settlement.getStatusCode())) {
            throw new IllegalStateException("대기 상태의 정산만 확정할 수 있습니다.");
        }

        // 2. 정산 상태 업데이트
        SettlementDto updateDto = SettlementDto.builder()
                .settlementId(settlementId)
                .statusCode(SettlementStatus.CONFIRMED.name())
                .settledAt(LocalDateTime.now())
                .settledBy(currentUserId)
                .updateUser(currentUserId)
                .build();

        settlementMapper.updateSettlement(updateDto);

        // 3. 정산 이력 로그 등록
        saveSettlementHistory(
                settlementId,
                SettlementActionType.CONFIRM.name(),
                SettlementStatus.PENDING.name(),
                SettlementStatus.CONFIRMED.name(),
                reason != null ? reason : "정산 확정",
                currentUserId
        );

        // 4. 알림 전송
        String periodText = String.format("%s ~ %s",
                settlement.getFromDate(),
                settlement.getToDate());

        String notificationMessage = String.format(
                "%s 정산이 확정되었습니다. (매출: %s원, 지출: %s원, 손익: %s원)",
                periodText,
                settlement.getSalesAmount(),
                settlement.getExpenseAmount(),
                settlement.getProfitAmount()
        );

        // TODO: 지점장 ID를 조회하여 알림 전송
        // 현재는 생성자에게만 알림
        notificationService.send(
                NotificationType.SETTLEMENT_CONFIRMED,
                "정산 확정 알림",
                notificationMessage,
                "SETTLEMENT",
                settlementId,
                List.of(settlement.getCreateUser()),
                currentUserId
        );
    }

    @Override
    @Transactional
    @CacheEvict(value = {"statistics", "settlements"}, allEntries = true)
    public void cancelSettlement(Long settlementId, String reason, Long currentUserId) {
        // 1. 기존 정산 정보 조회
        SettlementDetailDto settlement = settlementMapper.selectSettlementDetail(settlementId);
        if (settlement == null) {
            throw new IllegalArgumentException("정산 정보를 찾을 수 없습니다.");
        }

        if (SettlementStatus.CANCELLED.name().equals(settlement.getStatusCode())) {
            throw new IllegalStateException("이미 취소된 정산입니다.");
        }

        String beforeStatus = settlement.getStatusCode();

        // 2. 정산 상태 업데이트
        SettlementDto updateDto = SettlementDto.builder()
                .settlementId(settlementId)
                .statusCode(SettlementStatus.CANCELLED.name())
                .updateUser(currentUserId)
                .build();

        settlementMapper.updateSettlement(updateDto);

        // 2-1. 매출/지출 매핑 해제 (미정산 상태로 복원)
        settlementMapper.releaseSettlementSaleMaps(settlementId, currentUserId);
        settlementMapper.releaseSettlementExpenseMaps(settlementId, currentUserId);

        // 3. 정산 이력 로그 등록
        saveSettlementHistory(
                settlementId,
                SettlementActionType.CANCEL.name(),
                beforeStatus,
                SettlementStatus.CANCELLED.name(),
                reason != null ? reason : "정산 취소",
                currentUserId
        );

        // 4. 알림 전송 (정산 반려 타입 사용)
        String periodText = String.format("%s ~ %s",
                settlement.getFromDate(),
                settlement.getToDate());

        notificationService.send(
                NotificationType.SETTLEMENT_REJECTED,
                "정산 취소 알림",
                String.format("%s 정산이 취소되었습니다. 사유: %s", periodText, reason != null ? reason : "없음"),
                "SETTLEMENT",
                settlementId,
                List.of(settlement.getCreateUser()),
                currentUserId
        );
    }

    @Override
    @Transactional
    @CacheEvict(value = {"statistics", "settlements"}, allEntries = true)
    public void deleteSettlement(Long settlementId, Long currentUserId) {
        settlementMapper.deleteSettlement(settlementId, currentUserId);
    }

    @Override
    public List<SettlementHistoryDto> getSettlementHistories(Long settlementId) {
        return settlementMapper.selectSettlementHistories(settlementId);
    }

    /**
     * 정산 번호 생성 (STL-YYYYMM-XXXXXX)
     */
    private String generateSettlementNo(CreateSettlementRequestDto requestDto) {
        String yearMonth = requestDto.getFromDate().format(DateTimeFormatter.ofPattern("yyyyMM"));
        String randomNum = String.format("%06d", (int) (Math.random() * 1000000));
        return "STL-" + yearMonth + "-" + randomNum;
    }

    /**
     * 정산 이력 로그 저장
     */
    private void saveSettlementHistory(Long settlementId, String actionType,
                                       String beforeStatus, String afterStatus,
                                       String reason, Long actorUserId) {
        SettlementHistoryDto historyDto = SettlementHistoryDto.builder()
                .settlementId(settlementId)
                .actionType(actionType)
                .beforeStatus(beforeStatus)
                .afterStatus(afterStatus)
                .reason(reason)
                .actorUserId(actorUserId)
                .actedAt(LocalDateTime.now())
                .createUser(actorUserId)
                .build();

        settlementMapper.insertSettlementHistory(historyDto);
    }
}
