package com.health.app.approval;

import java.time.LocalDateTime;
import lombok.Data;

@Data
public class ApprovalDocDetailDTO {
    private Long docId;
    private Long docVerId;

    private String docNo;
    private String typeCode;

    private String formCode;
    private String formName;

    private String docStatusCode;
    private String docStatusName;

    private String verStatusCode;
    private String title;

    private Long drafterUserId;
    private String drafterName;

    private String currentApproverName;

    private LocalDateTime createDate;
    private LocalDateTime updateDate;
}
