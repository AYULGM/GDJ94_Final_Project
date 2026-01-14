package com.health.app.approval;

import lombok.Data;

@Data
public class HandoverUserDTO {
    private Long userId;
    private String name;
    private String roleCode;
    private String departmentCode;
}
