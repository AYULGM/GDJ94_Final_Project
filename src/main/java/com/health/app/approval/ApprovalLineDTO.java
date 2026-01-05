package com.health.app.approval;

import java.time.LocalDateTime;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ApprovalLineDTO {

    // ===== PK =====
    private Long lineId;

    // ===== FK (너 ERD 기준: approval_lines.doc_ver_id) =====
    private Long docVerId;

    // ===== 결재선 정보 =====
    private Integer seq;            // 결재 순서 (1,2,3...)
    private String lineRoleCode;    // 결재 역할(기안/검토/결재 등) - 공통코드
    private Long approverId;        // 결재자 user_id
    private String lineStatusCode;  // 상태코드(대기/승인/반려 등)
    private String approverName;

    
    // ===== 처리 정보 =====
    private LocalDateTime actedAt;
    private String comment;
    private Long signatureFileId;

    // ===== 공통 =====
    private Long createUser;
    private LocalDateTime createDate;
    private Long updateUser;
    private LocalDateTime updateDate;
    private Boolean useYn;
}
