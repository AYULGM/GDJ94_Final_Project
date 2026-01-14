package com.health.app.approval;

import lombok.Data;

@Data
public class HandoverCandidateDTO {
    private Long userId;
    private String name;
    private String roleCode;
    private Long branchId;
}
