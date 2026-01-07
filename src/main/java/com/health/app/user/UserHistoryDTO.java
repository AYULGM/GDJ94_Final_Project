package com.health.app.user;

import lombok.Data;

@Data
public class UserHistoryDTO {
    private String changeType;
    private String beforeValue;
    private String afterValue;
    private String reason;
    private String createDate;
}

