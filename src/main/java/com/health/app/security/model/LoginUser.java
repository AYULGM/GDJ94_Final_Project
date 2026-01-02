package com.health.app.security.model;

import lombok.Getter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;

@Getter
public class LoginUser implements UserDetails {

    private final Long userId;
    private final String loginId;
    private final String password;

    private final String name;
    private final String roleCode;       // RL001~ 이런 값
    private final String statusCode;     // US001~ 등
    private final String lockStatusCode; // AL001/AL002
    private final Integer failCount;
    private final LocalDateTime lockUntil;
    private final Boolean useYn;

    public LoginUser(
            Long userId,
            String loginId,
            String password,
            String name,
            String roleCode,
            String statusCode,
            String lockStatusCode,
            Integer failCount,
            LocalDateTime lockUntil,
            Boolean useYn
    ) {
        this.userId = userId;
        this.loginId = loginId;
        this.password = password;
        this.name = name;
        this.roleCode = roleCode;
        this.statusCode = statusCode;
        this.lockStatusCode = lockStatusCode;
        this.failCount = failCount;
        this.lockUntil = lockUntil;
        this.useYn = useYn;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        // 공통코드 RL00x -> 스프링 시큐리티 ROLE_ 로 매핑
        String role = mapRoleCodeToRoleName(roleCode);
        return List.of(new SimpleGrantedAuthority(role));
    }

    private String mapRoleCodeToRoleName(String roleCode) {
        if (roleCode == null) return "ROLE_USER";
        if (roleCode.startsWith("ROLE_")) return roleCode;

        return switch (roleCode) {
            case "RL001" -> "ROLE_MASTER";
            case "RL002" -> "ROLE_ADMIN";
            case "RL003" -> "ROLE_MANAGER";
            case "RL004" -> "ROLE_USER";
            case "RL005" -> "ROLE_GUEST";
            default -> "ROLE_USER";
        };
    }

    @Override
    public String getUsername() {
        return loginId;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        // 실제 “잠금” 판단은 UserDetailsService에서 LockedException으로 처리하는게 더 명확함
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        // use_yn이 false면 비활성
        return Boolean.TRUE.equals(useYn);
    }
}
