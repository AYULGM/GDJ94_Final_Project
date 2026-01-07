package com.health.app.inbound;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
public class InboundRequestDetailDto {
    private Long inboundRequestId;
    private String inboundRequestNo;

    private String vendorName;
    private String statusCode;

    private LocalDateTime requestedAt;
    private Long requestedBy;

    private LocalDateTime approvedAt;
    private Long approvedBy;

    private LocalDateTime rejectedAt;
    private Long rejectedBy;
    private String rejectReason;

    private String title;
    private String memo;

    private Long approvalDocId;
    private Long approvalDocVerId;

    private String refType;
    private Long refId;
}
