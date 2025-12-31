package com.health.app.auth;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class SessionUser {
    private Long userId;
    private String loginId;
    private String name;
}
