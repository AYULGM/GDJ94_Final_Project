package com.health.app.inventory;

import lombok.Data;

@Data
public class InventoryDetailDto {

    private Long branchId;
    private String branchName;

    private Long productId;
    private String productName;

    private Long quantity;

    private Long lowStockThreshold; // inventory.low_stock_threshold
    private Long reorderPoint;       // product.reorder_point

    private Long standardQuantity;   // 화면용 기준 수량 (계산 결과)

    private Integer lowStock;        // 1=부족, 0=정상
}
