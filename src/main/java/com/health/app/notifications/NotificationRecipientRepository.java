package com.health.app.notifications;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * NotificationRecipient 엔티티에 대한 JPA Repository
 */
@Repository
public interface NotificationRecipientRepository extends JpaRepository<NotificationRecipient, Long> {

    /**
     * 특정 알림의 특정 수신자 레코드를 조회합니다.
     * @param notifId 알림 ID
     * @param userId 사용자 ID
     * @return NotificationRecipient
     */
    @Query("SELECT nr FROM NotificationRecipient nr " +
           "WHERE nr.notification.notifId = :notifId AND nr.recipientUserId = :userId AND nr.useYn = true")
    Optional<NotificationRecipient> findByNotificationIdAndUserId(@Param("notifId") Long notifId,
                                                                    @Param("userId") Long userId);

    /**
     * 특정 사용자의 모든 알림 수신자 레코드를 조회합니다.
     * @param userId 사용자 ID
     * @return NotificationRecipient 목록
     */
    List<NotificationRecipient> findByRecipientUserIdAndUseYnTrue(Long userId);

    /**
     * 특정 사용자의 모든 읽지 않은 알림을 읽음 처리합니다.
     * @param userId 사용자 ID
     * @param readAt 읽은 시간
     * @return 업데이트된 행 수
     */
    @Modifying
    @Query("UPDATE NotificationRecipient nr " +
           "SET nr.readYn = true, nr.readAt = :readAt, nr.updateDate = :readAt, nr.updateUser = :userId " +
           "WHERE nr.recipientUserId = :userId AND nr.readYn = false AND nr.useYn = true")
    int markAllAsReadByUserId(@Param("userId") Long userId, @Param("readAt") LocalDateTime readAt);
}
