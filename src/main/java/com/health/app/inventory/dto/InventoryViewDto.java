package com.health.app.inventory.dto;

import lombok.Data;

@Data
public class InventoryViewDto {

    private Long inventoryId;

    private Long branchId;
    private String branchName;

    private Long productId;
    private String productName;

    private Long quantity;

    private Long thresholdValue;   // 화면용 기준 수량
    private Integer lowStock;      // 1=부족, 0=정상
}
