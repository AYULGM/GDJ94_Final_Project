package com.health.app.purchase;

import lombok.Data;

@Data
public class PurchaseDetailItemDto {
    private Long purchaseItemId;
    private Long purchaseId;

    private Long productId;
    private String productName;

    private Long quantity;
    private Long unitPrice;
    private Long amount;
}
