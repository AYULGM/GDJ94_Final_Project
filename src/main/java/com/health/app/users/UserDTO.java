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
    private String departmentName; // 권한을 한글로도 표현하기 위해 추가 ( common_code 조인)
    private String email;
    private String phone;

    private Long createUser;

    private String statusCode;
    private String roleCode;
    private String roleName; // 권한을 한글로도 표현하기 위해 추가함 ( common_code 조인)
    private String lockStatusCode;
    private Integer failCount;
    private Boolean useYn;
}
