package com.health.app.approval;

import java.time.LocalDateTime;
import java.util.List;
import lombok.Getter;
import lombok.Setter;

@Getter @Setter
public class ApprovalPrintDTO {

    private Long docId;
    private Long docVerId;
    private String docNo;
    private String typeCode;
    private String formCode;
    private String statusCode;

    private Long drafterUserId;
    private String drafterName;
    private String drafterDeptName;
    private String drafterPosition;
    private String drafterBranchName;
    private LocalDateTime draftDate;
    private LocalDateTime submitDate;

    private List<ApprovalPrintLineDTO> lines;

    private Object form;
}
