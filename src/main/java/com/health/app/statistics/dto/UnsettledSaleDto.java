package com.health.app.statistics.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 정산 대상 매출 조회 DTO
 */
@Data
public class UnsettledSaleDto {

    private Long saleId;
    private String saleNo;
    private Long branchId;
    private String branchName;
    private LocalDateTime soldAt;
    private String categoryCode;
    private BigDecimal totalAmount;
    private String statusCode;       // 매출 상태
    private Boolean settled;         // 정산 여부 (true: 정산완료, false: 미정산)
    private Long settlementId;       // 정산 ID (정산된 경우)
}
