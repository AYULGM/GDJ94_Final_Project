package com.health.app.approval;

import java.time.LocalDateTime;

import lombok.Data;

@Data
public class ApprovalMyDocRowDTO {

    private Long docId;
    private Long docVerId;

    private String docNo;
    private String typeCode;
    private String formCode;

    private String docStatusCode;
    private String verStatusCode;

    private String title;

    private String currentApproverName; // 현재 결재자(대기 ALS002 중 가장 빠른 seq)

    private LocalDateTime createDate;   // 현재 버전 생성일
    private LocalDateTime updateDate;   // 문서 업데이트 일시
    private String docStatusName; // 공통코드: APPROVAL_STATUS.code_desc
    private String formName;      // 공통코드: DOCUMENT_FORM.code_desc

}
