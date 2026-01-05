package com.health.app.notifications;

/**
 * 알림 타입 Enum
 * CODING_PLAN.md NT-001 요구사항 기반
 */
public enum NotificationType {
    // 일정 관련
    EVENT_CREATED("일정 등록"),
    EVENT_UPDATED("일정 수정"),
    EVENT_CANCELLED("일정 취소"),
    EVENT_REMINDER("일정 알림"),

    // 공지사항 관련
    NOTICE_CREATED("공지사항 등록"),
    NOTICE_UPDATED("공지사항 수정"),

    // 정산 관련
    SETTLEMENT_CONFIRMED("정산 확정"),
    SETTLEMENT_REJECTED("정산 반려"),

    // 파일 관련
    FILE_UPLOADED("파일 첨부 완료"),

    // 기타
    SYSTEM("시스템 알림");

    private final String displayName;

    NotificationType(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }
}
