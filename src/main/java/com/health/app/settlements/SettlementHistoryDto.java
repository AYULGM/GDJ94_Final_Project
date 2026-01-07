package com.health.app.settlements;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 정산 이력 로그 DTO
 */
@Data
@Builder
public class SettlementHistoryDto {

    private Long logId;
    private Long settlementId;
    private String actionType;       // CREATE, CONFIRM, CANCEL, UPDATE
    private String beforeStatus;
    private String afterStatus;
    private String reason;
    private Long actorUserId;
    private String actorUserName;
    private LocalDateTime actedAt;

    private Long createUser;
    private LocalDateTime createDate;
}
