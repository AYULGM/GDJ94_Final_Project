package com.health.app.user;

import lombok.Data;

@Data
public class UserAdminDTO {
	
	//초기비밀번호 설정해주고 나중에 비밀번호 변경 유도해야할듯
	private String password;

	private String postNo;
	private String baseAddress;
	private String detailAddress;
	
    private Long createUser;   // 등록자
    private Long updateUser;   // 수정자
	
    private Long userId;
    private String loginId;
    private String name;
    private String email;
    private String phone;

    private Long branchId;
    
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
    private String updateDate;
    
    private Boolean useYn; // 사용 여부 (1: 사용중, 0: 탈퇴)
}
