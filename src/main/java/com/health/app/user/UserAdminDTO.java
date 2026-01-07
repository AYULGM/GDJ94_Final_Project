package com.health.app.user;

import lombok.Data;

@Data
public class UserAdminDTO {

    private Long userId;
    private String loginId;
    private String name;
    private String email;
    private String phone;

    private String roleCode;
    private String roleName;

    private String departmentCode;
    private String departmentName;

    private String branchName;

    private String userStatusCode;
    private String userStatusName;

    private Integer failCount;
    private String lockStatusCode;

    private String createDate;
}
