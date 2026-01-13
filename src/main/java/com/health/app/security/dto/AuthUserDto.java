package com.health.app.security.dto;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
public class AuthUserDto {

    private Long userId;
    private String loginId;
    private String password;

    private String name;

    private String roleCode;        // RL00x
    private String statusCode;      // US00x
    private String lockStatusCode;  // AL001/AL002
    private Integer failCount;
    private LocalDateTime lockUntil;

    private Boolean useYn;

    private Long branchId;          // 소속 지점 ID (캡틴 권한 처리용)
}
