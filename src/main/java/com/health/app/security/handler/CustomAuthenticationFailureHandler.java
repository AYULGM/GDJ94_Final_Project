package com.health.app.security.handler;

import com.health.app.security.dto.AuthUserDto;
import com.health.app.security.dto.LoginHistoryDto;
import com.health.app.security.mapper.AuthUserMapper;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.*;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.web.authentication.AuthenticationFailureHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;

@Component
@RequiredArgsConstructor
public class CustomAuthenticationFailureHandler implements AuthenticationFailureHandler {

    private final AuthUserMapper authUserMapper;

    // 정책(요구사항에 맞게 변경 가능)
    private static final int MAX_FAIL_COUNT = 5;
    private static final int LOCK_MINUTES = 10;

    @Override
    public void onAuthenticationFailure(
            HttpServletRequest request,
            HttpServletResponse response,
            AuthenticationException exception
    ) throws IOException, ServletException {

        String loginId = request.getParameter("loginId");

        String failReason = classifyReason(exception);

        // 사용자 조회(비번 틀린 경우 fail_count 올리기 위해)
        AuthUserDto user = null;
        if (loginId != null && !loginId.isBlank()) {
            user = authUserMapper.findByLoginId(loginId);
        }

        // 1) user 존재하면 fail_count 증가 + 잠금처리
        if (user != null && user.getUserId() != null) {
            authUserMapper.increaseFailCount(user.getUserId());

            // 최신 fail_count 다시 계산(간단히 현재값+1로 봄)
            int newFailCount = (user.getFailCount() == null ? 0 : user.getFailCount()) + 1;

            // 임계치 도달하면 잠금
            if (newFailCount >= MAX_FAIL_COUNT) {
                LocalDateTime lockUntil = LocalDateTime.now().plusMinutes(LOCK_MINUTES);
                authUserMapper.lockUser(user.getUserId(), lockUntil);
                failReason = "LOCKED_UNTIL:" + lockUntil;
            }
        }

        // 2) 로그인 이력 기록
        LoginHistoryDto history = new LoginHistoryDto();
        history.setUserId(user == null ? null : user.getUserId());
        history.setLoginIdInput(loginId);
        history.setSuccessYn(false);
        history.setFailReason(failReason);
        authUserMapper.insertLoginHistory(history);

        // 3) 화면으로 에러 전달
        // 한글/특수문자 깨짐 방지
        String encoded = URLEncoder.encode(failReason, StandardCharsets.UTF_8);

        response.sendRedirect(request.getContextPath() + "/login?error=true&reason=" + encoded);
    }

    private String classifyReason(AuthenticationException e) {

        if (e instanceof UsernameNotFoundException) return "존재하지 않는 사용자";
        if (e instanceof BadCredentialsException) return "아이디 또는 비밀번호가 틀림";
        if (e instanceof LockedException) return e.getMessage();     // "USER_LOCKED_UNTIL:..."
        if (e instanceof DisabledException) return e.getMessage();   // "USER_DISABLED" 등
        if (e instanceof AccountExpiredException) return "계정 만료";
        if (e instanceof CredentialsExpiredException) return "비밀번호 만료";

        return "AUTH_FAILED";
    }
}
