package com.health.app.user;

import lombok.Data;

@Data
public class UserBranchLogDTO {
    private String historyType;   // UPDATE / BRANCH / ROLE
    private String changeField;
    private String beforeValue;
    private String afterValue;
    private String reason;
    private String createUserName;
    private String createDate;
}

