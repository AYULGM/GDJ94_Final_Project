package com.health.app.approval;

import java.time.LocalDate;
import lombok.Getter;
import lombok.Setter;

@Getter @Setter
public class ApprovalExtPrintDTO {

    private Long docId;
    private Long docVerId;
    private String docNo;
    private String typeCode;
    private String formCode;
    private String statusCode;

    private Long drafterUserId;
    private Long drafterSignatureFileId;

    private String employeeName;
    private String departmentName;
    private String positionName;

    private LocalDate extDt1;
    private LocalDate extDt2;

    private Long extNo1;
    private Long extNo2;
    private Long extNo3;

    private String extTxt1;
    private String extTxt2;
    private String extTxt3;
    private String extTxt4;
    private String extTxt6;

    private String extCode1;
}
