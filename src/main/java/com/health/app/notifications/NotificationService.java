package com.health.app.notifications;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 알림 비즈니스 로직을 처리하는 서비스
 * CODING_PLAN.md의 NotificationService.send() 제공
 */
@Service
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final NotificationRecipientRepository recipientRepository;
    private final NotificationWebSocketHandler webSocketHandler;

    @Autowired
    public NotificationService(NotificationRepository notificationRepository,
                                NotificationRecipientRepository recipientRepository,
                                NotificationWebSocketHandler webSocketHandler) {
        this.notificationRepository = notificationRepository;
        this.recipientRepository = recipientRepository;
        this.webSocketHandler = webSocketHandler;
    }

    /**
     * 알림을 생성하고 수신자들에게 전송합니다.
     * 다른 팀원들이 호출하는 공용 메서드 (CODING_PLAN.md 명세)
     *
     * @param type 알림 타입
     * @param title 알림 제목
     * @param message 알림 메시지
     * @param refType 참조 엔티티 타입 (CALENDAR_EVENT, NOTICE 등)
     * @param refId 참조 엔티티 ID
     * @param recipientUserIds 수신자 사용자 ID 목록
     * @param createUser 알림 생성자
     * @return 생성된 알림
     */
    @Transactional
    public Notification send(NotificationType type,
                             String title,
                             String message,
                             String refType,
                             Long refId,
                             List<Long> recipientUserIds,
                             Long createUser) {

        // 1. 알림 본문 생성
        Notification notification = Notification.builder()
                .notifType(type)
                .title(title)
                .message(message)
                .refType(refType)
                .refId(refId)
                .createUser(createUser)
                .useYn(true)
                .build();

        // 2. 수신자 추가
        for (Long recipientUserId : recipientUserIds) {
            NotificationRecipient recipient = NotificationRecipient.builder()
                    .recipientUserId(recipientUserId)
                    .readYn(false)
                    .createUser(createUser)
                    .useYn(true)
                    .build();

            notification.addRecipient(recipient);
        }

        // 3. 저장
        Notification savedNotification = notificationRepository.save(notification);

        // 4. WebSocket을 통해 실시간으로 푸시
        webSocketHandler.pushNotification(recipientUserIds, savedNotification);

        return savedNotification;
    }

    /**
     * 특정 사용자의 알림 목록을 조회합니다.
     * @param userId 사용자 ID
     * @return 알림 목록 (최신순)
     */
    public List<Notification> getNotificationsByUserId(Long userId) {
        return notificationRepository.findByRecipientUserId(userId);
    }

    /**
     * 특정 사용자의 읽지 않은 알림 개수를 조회합니다.
     * @param userId 사용자 ID
     * @return 읽지 않은 알림 개수
     */
    public Long getUnreadCount(Long userId) {
        return notificationRepository.countUnreadByUserId(userId);
    }

    /**
     * 특정 알림을 읽음 처리합니다.
     * @param notifId 알림 ID
     * @param userId 사용자 ID
     */
    @Transactional
    public void markAsRead(Long notifId, Long userId) {
        NotificationRecipient recipient = recipientRepository
                .findByNotificationIdAndUserId(notifId, userId)
                .orElseThrow(() -> new RuntimeException("알림을 찾을 수 없습니다."));

        recipient.markAsRead(userId);
        recipientRepository.save(recipient);
    }

    /**
     * 특정 사용자의 모든 알림을 읽음 처리합니다.
     * @param userId 사용자 ID
     * @return 읽음 처리된 알림 개수
     */
    @Transactional
    public int markAllAsRead(Long userId) {
        return recipientRepository.markAllAsReadByUserId(userId, LocalDateTime.now());
    }
}
