package com.health.app.sales.dto;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 매출 기본 DTO
 */
@Data
@Builder
public class SaleDto {

    private Long saleId;
    private String saleNo;
    private Long branchId;
    private LocalDateTime soldAt;
    private String statusCode;
    private String categoryCode;
    private BigDecimal totalAmount;
    private String memo;

    private Long createUser;
    private LocalDateTime createDate;
    private Long updateUser;
    private LocalDateTime updateDate;
    private Boolean useYn;
}
