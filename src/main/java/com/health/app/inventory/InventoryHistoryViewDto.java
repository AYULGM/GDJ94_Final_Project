package com.health.app.inventory;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class InventoryHistoryViewDto {

    private Long inventoryHistoryId;

    private Long branchId;
    private String branchName;

    private Long productId;
    private String productName;

    private String moveTypeCode;
    private Long quantity;
    private String reason;

    private String refType;
    private Long refId;

    private Long createUser;
    private LocalDateTime createDate;

    private Long updateUser;
    private LocalDateTime updateDate;
}
