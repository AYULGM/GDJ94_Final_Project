package com.health.app.notifications;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

import java.time.LocalDateTime;

/**
 * notification_recipients 테이블에 매핑되는 엔티티
 * 알림 수신자 및 읽음 상태 정보를 저장
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "notification_recipients")
public class NotificationRecipient {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "notif_recipient_id")
    private Long notifRecipientId;

    // 연관 관계: 알림
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "notif_id", nullable = false)
    @JsonBackReference // JSON 직렬화 시 순환 참조 방지 (이 필드는 직렬화하지 않음)
    private Notification notification;

    @Column(name = "recipient_user_id", nullable = false)
    private Long recipientUserId; // 수신자 사용자 ID

    @Column(name = "read_yn", nullable = false)
    private Boolean readYn; // 읽음 여부

    @Column(name = "read_at")
    private LocalDateTime readAt; // 읽은 시간

    // 공통 필드
    @Column(name = "create_user", nullable = false)
    private Long createUser;

    @Column(name = "create_date", nullable = false)
    private LocalDateTime createDate;

    @Column(name = "update_user")
    private Long updateUser;

    @Column(name = "update_date")
    private LocalDateTime updateDate;

    @Column(name = "use_yn", nullable = false)
    private Boolean useYn;

    @PrePersist
    protected void onCreate() {
        this.createDate = LocalDateTime.now();
        if (this.readYn == null) {
            this.readYn = false;
        }
        if (this.useYn == null) {
            this.useYn = true;
        }
    }

    @PreUpdate
    protected void onUpdate() {
        this.updateDate = LocalDateTime.now();
    }

    /**
     * 알림을 읽음 처리합니다.
     */
    public void markAsRead(Long userId) {
        this.readYn = true;
        this.readAt = LocalDateTime.now();
        this.updateUser = userId;
    }
}
