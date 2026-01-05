package com.health.app.common;

import com.health.app.security.model.LoginUser;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

/**
 * 모든 Controller에 공통으로 적용되는 Advice
 * JSP에서 사용할 공통 데이터를 자동으로 Model에 추가합니다.
 */
@ControllerAdvice
public class GlobalControllerAdvice {

    /**
     * 모든 View에 현재 로그인한 사용자의 ID를 자동으로 전달합니다.
     * JSP에서 ${currentUserId}로 접근 가능합니다.
     *
     * @return 현재 로그인한 사용자 ID (로그인하지 않은 경우 null)
     */
    @ModelAttribute("currentUserId")
    public Long currentUserId() {
        try {
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            if (authentication != null && authentication.isAuthenticated()
                    && !"anonymousUser".equals(authentication.getPrincipal())) {
                LoginUser loginUser = (LoginUser) authentication.getPrincipal();
                return loginUser.getUserId();
            }
        } catch (Exception e) {
            // 인증 정보를 가져올 수 없는 경우 null 반환
            return null;
        }
        return null;
    }

    /**
     * 모든 View에 현재 로그인한 사용자의 로그인 ID를 자동으로 전달합니다.
     * JSP에서 ${currentLoginId}로 접근 가능합니다.
     *
     * @return 현재 로그인한 사용자의 loginId (로그인하지 않은 경우 null)
     */
    @ModelAttribute("currentLoginId")
    public String currentLoginId() {
        try {
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            if (authentication != null && authentication.isAuthenticated()
                    && !"anonymousUser".equals(authentication.getPrincipal())) {
                LoginUser loginUser = (LoginUser) authentication.getPrincipal();
                return loginUser.getLoginId();
            }
        } catch (Exception e) {
            return null;
        }
        return null;
    }

    /**
     * 모든 View에 현재 로그인한 사용자의 이름을 자동으로 전달합니다.
     * JSP에서 ${currentUserName}로 접근 가능합니다.
     *
     * @return 현재 로그인한 사용자의 이름 (로그인하지 않은 경우 null)
     */
    @ModelAttribute("currentUserName")
    public String currentUserName() {
        try {
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            if (authentication != null && authentication.isAuthenticated()
                    && !"anonymousUser".equals(authentication.getPrincipal())) {
                LoginUser loginUser = (LoginUser) authentication.getPrincipal();
                return loginUser.getName();
            }
        } catch (Exception e) {
            return null;
        }
        return null;
    }
}
