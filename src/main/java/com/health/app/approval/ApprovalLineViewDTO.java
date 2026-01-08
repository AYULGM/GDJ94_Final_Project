package com.health.app.approval;

import java.time.LocalDateTime;
import lombok.Data;

@Data
public class ApprovalLineViewDTO {
    private Integer seq;
    private Long userId;
    private String approverName;

    private String lineStatusCode;
    private String lineStatusName;

    private LocalDateTime actionDate;
    private String comment;
}
