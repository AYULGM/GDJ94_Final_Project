package com.health.app.approval;

import lombok.Data;

@Data
public class ApprovalProductDTO {
	private Long productId;
    private String productName;
    private String productDesc;
    private Long price;
    private Long stockQty;
}
