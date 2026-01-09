package com.health.app.approval;

import java.time.LocalDateTime;
import lombok.Getter;
import lombok.Setter;

@Getter @Setter
public class ApprovalPrintLineDTO {

    private Integer lineNo;          // 1,2,3...
    private String role;             // APPROVER / AGREE / REFER (프로젝트 규칙대로)
    private Long userId;

    private String userName;
    private String deptName;
    private String positionName;

    private String decisionCode;     // PENDING / APPROVED / REJECTED
    private String comment;
    private Long signatureFileId;
    private String signImagePath;    // 서명 png 경로/키
    private LocalDateTime decidedDate;
}
