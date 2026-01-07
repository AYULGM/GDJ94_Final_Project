package com.health.app.inbound;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
public class InboundRequestListDto {
    private Long inboundRequestId;
    private String inboundRequestNo;
    private String vendorName;
    private String statusCode;
    private LocalDateTime requestedAt;
    private Long requestedBy;
    private String title;
    private Long approvalDocVerId;
}
