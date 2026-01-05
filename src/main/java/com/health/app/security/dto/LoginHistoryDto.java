package com.health.app.security.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class LoginHistoryDto {

    private Long userId;         // 사용자 없으면 null 가능(테이블이 NOT NULL이면 바꿔야 함)
    private String loginIdInput; // 입력한 아이디
    private Boolean successYn;   // 성공 여부
    private String failReason;   // 실패 사유(성공이면 null)
}
