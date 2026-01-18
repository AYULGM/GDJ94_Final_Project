package com.health.app.inbound;

import org.springframework.security.core.Authentication;

import java.lang.reflect.Method;

public class SecurityBranchUtil {

    private SecurityBranchUtil() {}

    /**
     * ✅ authentication.getPrincipal() 안에 들어있는 유저 객체에서 userId를 추출
     * - 프로젝트마다 principal 타입이 다르니 리플렉션으로 getUserId()/getId() 우선 시도
     */
    public static Long getMyUserId(Authentication authentication) {
        if (authentication == null || authentication.getPrincipal() == null) return null;

        Object principal = authentication.getPrincipal();

        // getUserId()
        Long v = invokeLong(principal, "getUserId");
        if (v != null) return v;

        // getId()
        v = invokeLong(principal, "getId");
        if (v != null) return v;

        // username이 숫자라면(테스트용) 변환
        try {
            return Long.parseLong(authentication.getName());
        } catch (Exception ignored) {
            return null;
        }
    }

    /**
     * ✅ principal에서 branchId 추출 (getBranchId() / getBranch_id() 등 프로젝트별 편차 대응)
     */
    public static Long getMyBranchId(Authentication authentication) {
        if (authentication == null || authentication.getPrincipal() == null) return null;

        Object principal = authentication.getPrincipal();

        Long v = invokeLong(principal, "getBranchId");
        if (v != null) return v;

        v = invokeLong(principal, "getBranch_id");
        if (v != null) return v;

        // 없으면 null (이 경우 지점필터가 동작 못하니 principal에 branchId를 넣는 게 최종 정석)
        return null;
    }

    private static Long invokeLong(Object target, String methodName) {
        try {
            Method m = target.getClass().getMethod(methodName);
            Object r = m.invoke(target);
            if (r == null) return null;
            if (r instanceof Long) return (Long) r;
            if (r instanceof Integer) return ((Integer) r).longValue();
            if (r instanceof String) return Long.parseLong((String) r);
        } catch (Exception ignored) {}
        return null;
    }
}
