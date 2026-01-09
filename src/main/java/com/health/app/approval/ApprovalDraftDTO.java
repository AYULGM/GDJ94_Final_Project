package com.health.app.approval;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

import org.springframework.format.annotation.DateTimeFormat;

@Getter
@Setter
public class ApprovalDraftDTO {
	 // ====== 화면용(DB 컬럼 아님) ======
    private String mode;   // "new" / "edit"
    private String tempYn; // "Y" / "N"

    // ====== documents ======
    private Long docId;                
    private String docNo; 
    private String typeCode;
    private String formCode;
    private String statusCode;          
    private Long drafterId;
    private Long branchId;
    private Long currentDocVerId;      
    private Long createUser;
    private Long updateUser;

    // ====== versions ======
    private Long docVerId;             
    private Long versionNo;            
    private String verStatusCode;       
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
