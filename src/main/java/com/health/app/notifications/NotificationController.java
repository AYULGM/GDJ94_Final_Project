package com.health.app.notifications;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
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
     * 현재 로그인한 사용자의 알림 목록을 조회합니다.
     * GET /api/notifications
     *
     * @return 알림 목록
     */
    @GetMapping
    public ResponseEntity<List<Notification>> getNotifications() {
        // TODO: 실제 로그인 사용자 ID를 가져와야 함 (현재는 임시로 1L)
        Long currentUserId = 1L;

        List<Notification> notifications = notificationService.getNotificationsByUserId(currentUserId);
        return ResponseEntity.ok(notifications);
    }

    /**
     * 현재 로그인한 사용자의 읽지 않은 알림 개수를 조회합니다.
     * GET /api/notifications/unread-count
     *
     * @return 읽지 않은 알림 개수
     */
    @GetMapping("/unread-count")
    public ResponseEntity<Map<String, Long>> getUnreadCount() {
        // TODO: 실제 로그인 사용자 ID를 가져와야 함 (현재는 임시로 1L)
        Long currentUserId = 1L;

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
     * @return 성공 메시지
     */
    @PostMapping("/{notifId}/read")
    public ResponseEntity<Map<String, String>> markAsRead(@PathVariable Long notifId) {
        // TODO: 실제 로그인 사용자 ID를 가져와야 함 (현재는 임시로 1L)
        Long currentUserId = 1L;

        notificationService.markAsRead(notifId, currentUserId);

        Map<String, String> response = new HashMap<>();
        response.put("message", "알림을 읽음 처리했습니다.");

        return ResponseEntity.ok(response);
    }

    /**
     * 모든 알림을 읽음 처리합니다.
     * POST /api/notifications/read-all
     *
     * @return 읽음 처리된 알림 개수
     */
    @PostMapping("/read-all")
    public ResponseEntity<Map<String, Object>> markAllAsRead() {
        // TODO: 실제 로그인 사용자 ID를 가져와야 함 (현재는 임시로 1L)
        Long currentUserId = 1L;

        int count = notificationService.markAllAsRead(currentUserId);

        Map<String, Object> response = new HashMap<>();
        response.put("message", "모든 알림을 읽음 처리했습니다.");
        response.put("count", count);

        return ResponseEntity.ok(response);
    }
}
