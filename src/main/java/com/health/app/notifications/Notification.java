package com.health.app.notifications;

import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * notifications 테이블에 매핑되는 엔티티
 * 알림 본문 정보를 저장
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "notifications")
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "notif_id")
    private Long notifId;

    @Enumerated(EnumType.STRING)
    @Column(name = "notif_type", nullable = false, columnDefinition = "LONGTEXT")
    private NotificationType notifType;

    @Column(name = "title", nullable = false, columnDefinition = "LONGTEXT")
    private String title;

    @Column(name = "message", nullable = false, columnDefinition = "LONGTEXT")
    private String message;

    @Column(name = "ref_type", nullable = false, columnDefinition = "LONGTEXT")
    private String refType; // 참조 엔티티 타입 (CALENDAR_EVENT, NOTICE 등)

    @Column(name = "ref_id")
    private Long refId; // 참조 엔티티 ID

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

    // 연관 관계: 하나의 알림은 여러 수신자를 가질 수 있음
    @OneToMany(mappedBy = "notification", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonManagedReference // JSON 직렬화 시 순환 참조 방지
    @Builder.Default
    private List<NotificationRecipient> recipients = new ArrayList<>();

    // 프론트엔드용 필드 (DB에 저장되지 않음)
    @Transient
    private Boolean isRead; // 현재 사용자가 읽었는지 여부

    @Transient
    private String relatedUrl; // 관련 페이지 URL

    @PrePersist
    protected void onCreate() {
        this.createDate = LocalDateTime.now();
        if (this.useYn == null) {
            this.useYn = true;
        }
    }

    @PreUpdate
    protected void onUpdate() {
        this.updateDate = LocalDateTime.now();
    }

    /**
     * 수신자 추가 헬퍼 메서드
     */
    public void addRecipient(NotificationRecipient recipient) {
        recipients.add(recipient);
        recipient.setNotification(this);
    }
}
