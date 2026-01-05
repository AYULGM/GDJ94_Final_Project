package com.health.app.notifications;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Notification 엔티티에 대한 JPA Repository
 */
@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long> {

    /**
     * 특정 사용자의 알림 목록을 최신순으로 조회합니다.
     * @param userId 사용자 ID
     * @return 알림 목록
     */
    @Query("SELECT DISTINCT n FROM Notification n " +
           "JOIN FETCH n.recipients r " +
           "WHERE r.recipientUserId = :userId AND r.useYn = true AND n.useYn = true " +
           "ORDER BY n.createDate DESC")
    List<Notification> findByRecipientUserId(@Param("userId") Long userId);

    /**
     * 특정 사용자의 읽지 않은 알림 개수를 조회합니다.
     * @param userId 사용자 ID
     * @return 읽지 않은 알림 개수
     */
    @Query("SELECT COUNT(DISTINCT n) FROM Notification n " +
           "JOIN n.recipients r " +
           "WHERE r.recipientUserId = :userId AND r.readYn = false AND r.useYn = true AND n.useYn = true")
    Long countUnreadByUserId(@Param("userId") Long userId);
}
