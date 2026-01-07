package com.health.app.purchase;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Data
public class PurchaseDetailDto {

    private Long purchaseId;
    private String purchaseNo;

    private Long branchId;
    private String branchName;

    private String statusCode;

    private LocalDateTime requestedAt;
    private Long requestedBy;

    private LocalDateTime approvedAt;
    private Long approvedBy;

    private LocalDateTime rejectedAt;
    private Long rejectedBy;

    private String rejectReason;
    private String memo;

    private List<PurchaseDetailItemDto> items = new ArrayList<>();
}
