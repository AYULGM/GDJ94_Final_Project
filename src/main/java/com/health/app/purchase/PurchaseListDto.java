package com.health.app.purchase;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class PurchaseListDto {
    private Long purchaseId;
    private String purchaseNo;

    private Long branchId;
    private String branchName;

    private String statusCode;
    private LocalDateTime requestedAt;

    private String memo;

    private Long totalQuantity;
    private Long totalAmount;
}
