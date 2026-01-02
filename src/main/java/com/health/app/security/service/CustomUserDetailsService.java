package com.health.app.security.service;

import com.health.app.security.mapper.AuthUserMapper;
import com.health.app.security.model.LoginUser;
import com.health.app.security.dto.AuthUserDto;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.LockedException;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {

    private final AuthUserMapper authUserMapper;

    @Override
    public UserDetails loadUserByUsername(String loginId) throws UsernameNotFoundException {

        AuthUserDto u = authUserMapper.findByLoginId(loginId);
        if (u == null) {
            throw new UsernameNotFoundException("USER_NOT_FOUND");
        }

        // 1) 사용 여부(use_yn)
        if (u.getUseYn() == null || !u.getUseYn()) {
            throw new DisabledException("USER_DISABLED");
        }

        // 2) 상태 코드(예: US001=ACTIVE만 허용)
        // 너희 공통코드가 US001~US004 구조였지. 여기서 정책을 박아둠.
        if (u.getStatusCode() != null && !u.getStatusCode().equals("US001")) {
            throw new DisabledException("USER_STATUS_NOT_ACTIVE:" + u.getStatusCode());
        }

        // 3) 잠금 상태(AL002) + lock_until 미래면 로그인 거부
        if ("AL002".equals(u.getLockStatusCode())) {
            LocalDateTime until = u.getLockUntil();
            if (until != null && until.isAfter(LocalDateTime.now())) {
                throw new LockedException("USER_LOCKED_UNTIL:" + until);
            }
        }

        return new LoginUser(
                u.getUserId(),
                u.getLoginId(),
                u.getPassword(),
                u.getName(),
                u.getRoleCode(),
                u.getStatusCode(),
                u.getLockStatusCode(),
                u.getFailCount(),
                u.getLockUntil(),
                u.getUseYn()
        );
    }
}
