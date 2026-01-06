package com.health.app.sales.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 매출 상세 조회용 DTO (JOIN 결과)
 */
@Data
public class SaleDetailDto {

    // 매출 기본 정보
    private Long saleId;
    private String saleNo;
    private Long branchId;
    private String branchName;
    private LocalDateTime soldAt;
    private String statusCode;
    private String categoryCode;
    private BigDecimal totalAmount;
    private String memo;

    // 생성/수정 정보
    private Long createUser;
    private String createUserName;
    private LocalDateTime createDate;
    private Long updateUser;
    private String updateUserName;
    private LocalDateTime updateDate;
}
