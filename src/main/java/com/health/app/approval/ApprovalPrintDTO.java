package com.health.app.approval;

import java.time.LocalDateTime;
import java.util.List;
import lombok.Getter;
import lombok.Setter;

@Getter @Setter
public class ApprovalPrintDTO {

    /* 문서 헤더 */
    private Long docId;
    private Long docVerId;
    private String docNo;
    private String typeCode;     // AT009 등
    private String formCode;     // DFxxx
    private String statusCode;

    /* 기안 정보 */
    private Long drafterUserId;
    private String drafterName;
    private String drafterDeptName;   // 있으면
    private String drafterPosition;   // 있으면
    private String drafterBranchName; // 지점명
    private LocalDateTime draftDate;  // 기안일(또는 create_date)
    private LocalDateTime submitDate; // 상신일(있으면)

    /* 결재선(결재/합의/참조 등) */
    private List<ApprovalPrintLineDTO> lines;

    /* 보고서(양식) 데이터: 폼별 DTO를 통째로 넣음 */
    private Object form; // 예: VacationFormDTO
}
