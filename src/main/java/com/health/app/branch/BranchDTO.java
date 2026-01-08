package com.health.app.branch;

import java.time.LocalDateTime;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class BranchDTO {

    private Long branchId;
    private String branchName;
    private String postNo;
    private String baseAddress;
    private String detailAddress;
    private String managerName;
    private String managerPhone;
    private String operatingHours;
    private String statusCode;
    private String statusName; // BS001 - OPEN 처럼 한글표시를 위해.
    
    private Long createUser;
    private LocalDateTime createDate;
    
    private Long updateUser;
}
