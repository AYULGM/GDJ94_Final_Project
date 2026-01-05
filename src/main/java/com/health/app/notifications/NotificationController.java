package com.health.app.notifications;

import com.health.app.security.model.LoginUser;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 알림 관련 HTTP REST API를 제공하는 컨트롤러
 */
@RestController
@RequestMapping("/api/notifications")
public class NotificationController {

    private final NotificationService notificationService;

    @Autowired
    public NotificationController(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    /**
     * 현재 로그인한 사용자의 ID를 가져옵니다.
     * @param authentication Spring Security 인증 객체
     * @return 사용자 ID
     */
    private Long getCurrentUserId(Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new RuntimeException("인증되지 않은 사용자입니다.");
        }
        LoginUser loginUser = (LoginUser) authentication.getPrincipal();
        return loginUser.getUserId();
    }

    /**
     * 현재 로그인한 사용자의 알림 목록을 조회합니다.
     * GET /api/notifications
     *
     * @param authentication Spring Security 인증 객체
     * @return 알림 목록
     */
    @GetMapping
    public ResponseEntity<List<Notification>> getNotifications(Authentication authentication) {
        Long currentUserId = getCurrentUserId(authentication);

        List<Notification> notifications = notificationService.getNotificationsByUserId(currentUserId);
        return ResponseEntity.ok(notifications);
    }

    /**
     * 현재 로그인한 사용자의 읽지 않은 알림 개수를 조회합니다.
     * GET /api/notifications/unread-count
     *
     * @param authentication Spring Security 인증 객체
     * @return 읽지 않은 알림 개수
     */
    @GetMapping("/unread-count")
    public ResponseEntity<Map<String, Long>> getUnreadCount(Authentication authentication) {
        Long currentUserId = getCurrentUserId(authentication);

        Long count = notificationService.getUnreadCount(currentUserId);

        Map<String, Long> response = new HashMap<>();
        response.put("count", count);

        return ResponseEntity.ok(response);
    }

    /**
     * 특정 알림을 읽음 처리합니다.
     * POST /api/notifications/{notifId}/read
     *
     * @param notifId 알림 ID
     * @param authentication Spring Security 인증 객체
     * @return 성공 메시지
     */
    @PostMapping("/{notifId}/read")
    public ResponseEntity<Map<String, String>> markAsRead(@PathVariable Long notifId, Authentication authentication) {
        Long currentUserId = getCurrentUserId(authentication);

        notificationService.markAsRead(notifId, currentUserId);

        Map<String, String> response = new HashMap<>();
        response.put("message", "알림을 읽음 처리했습니다.");

        return ResponseEntity.ok(response);
    }

    /**
     * 모든 알림을 읽음 처리합니다.
     * POST /api/notifications/read-all
     *
     * @param authentication Spring Security 인증 객체
     * @return 읽음 처리된 알림 개수
     */
    @PostMapping("/read-all")
    public ResponseEntity<Map<String, Object>> markAllAsRead(Authentication authentication) {
        Long currentUserId = getCurrentUserId(authentication);

        int count = notificationService.markAllAsRead(currentUserId);

        Map<String, Object> response = new HashMap<>();
        response.put("message", "모든 알림을 읽음 처리했습니다.");
        response.put("count", count);

        return ResponseEntity.ok(response);
    }
}
