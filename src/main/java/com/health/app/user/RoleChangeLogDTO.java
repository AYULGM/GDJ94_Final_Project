package com.health.app.user;

import lombok.Data;

@Data
public class RoleChangeLogDTO {
    private String beforeRoleCode;
    private String afterRoleCode;
    private String reason;
    private String createDate;
}


