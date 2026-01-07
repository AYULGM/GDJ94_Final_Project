package com.health.app.users;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UserDTO {

    private Long userId;
    private String loginId;
    private String password;
    private String name;
    private String postNo;
    private String baseAddress;
    private String detailAddress;
    private Long branchId;
    
    private String departmentCode;
    private String email;
    private String phone;

    private Long createUser;

    private String statusCode;
    private String roleCode;
    private String lockStatusCode;
    private Integer failCount;
    private Boolean useYn;
}
