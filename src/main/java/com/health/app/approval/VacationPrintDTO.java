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
    private LocalDate joinDate;     // DB에 없으면 null로 둬도 JSP는 그냥 공백 출력

    private String mainDuty;

    // 휴가 종류/사유
    private String leaveType;       // ANNUAL / SICK / OFFICIAL / ETC
    private String leaveTypeEtc;    // 기타 텍스트
    private String leaveReason;

    // 휴가 기간/일수
    private LocalDate leaveStartDate;
    private LocalDate leaveEndDate;
    private Long leaveDays;

    // 인수인계
    private String handoverNote;

    // 하단 작성일
    private LocalDate writtenDate;
}
