package com.health.app.notices;

import lombok.Data;

@Data
public class NoticeHistoryDTO {
    private Long noticeHistId;
    private Long noticeId;
    private String changeType;   // CREATE/UPDATE/DELETE
    private String beforeValue;
    private String afterValue;
    private String reason;
    private Long createUser;

}
