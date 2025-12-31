package com.health.app.auth;

import lombok.Data;

@Data
public class UserLoginView {
    private Long userId;
    private String loginId;
    private String password;
    private String name;
}
