package com.health.app.approval;

import lombok.Data;

@Data
public class ApprovalUserMiniDTO {
    private Long userId;
    private Long branchId;
    private String roleCode;
}
