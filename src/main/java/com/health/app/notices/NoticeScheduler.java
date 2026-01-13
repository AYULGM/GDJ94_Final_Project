package com.health.app.notices;

import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class NoticeScheduler {

    private final NoticeService noticeService;

    // 시스템 사용자(예: 1번 관리자)로 update_user 기록
    private static final Long SYSTEM_USER_ID = 1L;

    // 매 10분마다 실행 (원하면 cron 변경)
    @Scheduled(cron = "0 */10 * * * *")
    public void closeExpired() {
        noticeService.closeExpiredNotices(SYSTEM_USER_ID);
    }
}
