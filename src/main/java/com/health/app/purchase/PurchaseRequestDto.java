package com.health.app.purchase;

import lombok.Data;

import java.util.ArrayList;
import java.util.List;

@Data
public class PurchaseRequestDto {

    private Long purchaseId;     // useGeneratedKeys로 채워짐
    private String purchaseNo;   // 서비스에서 생성
    private Long branchId;
    private String statusCode;   // REQUESTED
    private Long requestedBy;    // userId
    private String memo;

    private List<PurchaseItemDto> items = new ArrayList<>();

    @Data
    public static class PurchaseItemDto {
        private Long productId;
        private Long quantity;
        private Long unitPrice;
    }
}
