package com.health.app.approval;

import java.time.LocalDate;
import lombok.Getter;
import lombok.Setter;

@Getter @Setter
public class VacationPrintDTO extends ApprovalPrintDTO {

    // JSP가 기대하는 인적사항
    private String employeeName;
    private String departmentName;
    private String positionName;

    private String mainDuty;

    // 휴가 종류/사유
    private String leaveType;       // ANNUAL / SICK / OFFICIAL / ETC
    private String leaveTypeEtc;    // 기타 텍스트
    private String leaveReason;

    private Long leaveDays;

    // 인수인계
    private String handoverNote;

    private String joinDateStr;
    private String leaveStartDateStr;
    private String leaveEndDateStr;
    private String writtenDateStr;
    private Long drafterSignatureFileId;


}
