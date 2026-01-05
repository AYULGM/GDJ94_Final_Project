package com.health.app.approval;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

import org.springframework.format.annotation.DateTimeFormat;

@Getter
@Setter
public class ApprovalDraftDTO {

    // ====== documents ======
    private Long docId;                 // PK (insert 후 채워짐)
    private String docNo; 
    private String typeCode;
    private String formCode;
    private String statusCode;          // DRAFT 등
    private Long drafterId;
    private Long branchId;
    private Long currentDocVerId;       // update로 세팅
    private Long createUser;
    private Long updateUser;

    // ====== versions ======
    private Long docVerId;              // PK (insert 후 채워짐)
    private Long versionNo;             // 1
    private String verStatusCode;       // DRAFT
    private String title;
    private String body;

    // ====== ext (컬럼별 개별 저장) ======
    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
    private LocalDate extDt1;

    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
    private LocalDate extDt2;

    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
    private LocalDate extDt3;

    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
    private LocalDate extDt4;

    private Long extNo1;
    private Long extNo2;
    private Long extNo3;
    private Long extNo4;

    private String extTxt1;
    private String extTxt2;
    private String extTxt3;
    private String extTxt4;
    private String extTxt5;
    private String extTxt6;

    private String extCode1;
    private String extCode2;
    private String extCode3;
    private String extCode4;
}
