package com.health.app.security.handler;

import com.health.app.security.dto.LoginHistoryDto;
import com.health.app.security.mapper.AuthUserMapper;
import com.health.app.security.model.LoginUser;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;

@Component
@RequiredArgsConstructor
public class CustomAuthenticationSuccessHandler implements AuthenticationSuccessHandler {

    private final AuthUserMapper authUserMapper;

    @Override
    public void onAuthenticationSuccess(
            HttpServletRequest request,
            HttpServletResponse response,
            Authentication authentication
    ) throws IOException, ServletException {

        LoginUser user = (LoginUser) authentication.getPrincipal();

        // 1) 실패횟수 초기화 / 잠금 해제
        authUserMapper.resetFailCount(user.getUserId());

        // 2) 로그인 성공 이력
        LoginHistoryDto history = new LoginHistoryDto();
        history.setUserId(user.getUserId());
        history.setLoginIdInput(user.getLoginId());
        history.setSuccessYn(true);
        history.setFailReason(null);
        authUserMapper.insertLoginHistory(history);

        // 3) 이동
        response.sendRedirect(request.getContextPath() + "/");
    }
}
