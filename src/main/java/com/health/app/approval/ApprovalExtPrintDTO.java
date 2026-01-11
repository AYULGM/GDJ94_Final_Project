package com.health.app.approval;

import java.time.LocalDate;
import lombok.Getter;
import lombok.Setter;
@Getter @Setter
public class ApprovalExtPrintDTO extends ApprovalPrintDTO {

    private LocalDate extDt1;
    private LocalDate extDt2;

    // 추가
    private LocalDate extDt3;
    private LocalDate extDt4;

    private Long extNo1;
    private Long extNo2;
    private Long extNo3;

    private String extTxt1;
    private String extTxt2;
    private String extTxt3;
    private String extTxt4;
    private String extTxt6;

    private String extCode1;

    private String writtenDateStr;
    private Long drafterSignatureFileId;

    private String employeeName;
    private String departmentName;
    private String positionName;
}

