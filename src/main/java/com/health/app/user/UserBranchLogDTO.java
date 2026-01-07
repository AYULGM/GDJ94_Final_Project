package com.health.app.user;

import lombok.Data;

@Data
public class UserBranchLogDTO {
    private Long beforeBranchId;
    private Long afterBranchId;
    private String reason;
    private String createDate;
}

