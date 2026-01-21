package com.health.app.inventory;

import lombok.Data;

@Data
public class AuditLogDto {
    private Long auditId;
    private Long actorUserId;

    // DB 컬럼명: action_type, target_type, target_id
    private String actionType;
    private String targetType;
    private Long targetId;

    private String beforeValue;
    private String afterValue;
    private String reason;
    private String createdAt;

    // 조회 편의를 위한 조인 컬럼 (target_id = inventory_id 기준)
    private Long branchId;
    private String branchName;
    private Long productId;
    private String productName;

    // =========================
    // 화면 표시용(서비스단에서 세팅)
    // =========================
    private String actionTypeName;   // 상태(한글)
    private String reasonDisplay;    // 사유(한글/자연어)
}
