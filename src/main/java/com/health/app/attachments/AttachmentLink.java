package com.health.app.attachments;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "attachment_links")
public class AttachmentLink {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "link_id")
    private Long linkId;

    @Column(name = "file_id", nullable = false)
    private Long fileId;

    @Column(name = "entity_type", nullable = false)
    private String entityType; // 공지사항(notice), 전자결재(approval), 상품(product) 등

    @Column(name = "entity_id", nullable = false)
    private Long entityId; // 연결된 엔티티(게시물, 상품 등)의 ID

    @Column(name = "link_role", nullable = false)
    private String linkRole; // 예를 들어 'main_image', 'attachment', 'thumbnail' 등

    @Column(name = "sort_order", nullable = false)
    private Long sortOrder; // 정렬 순서

    @Column(name = "create_user", nullable = false)
    private Long createUser;

    @Column(name = "create_date", nullable = false)
    private LocalDateTime createDate;

    @Column(name = "update_user")
    private Long updateUser;

    @Column(name = "update_date")
    private LocalDateTime updateDate;

    @Column(name = "use_yn", nullable = false)
    private Boolean useYn; // 사용 여부 (논리 삭제)

    @PrePersist
    protected void onCreate() {
        this.createDate = LocalDateTime.now();
        this.useYn = true;
        this.sortOrder = (this.sortOrder == null) ? 0L : this.sortOrder; // 기본값 설정
        // create_user는 로그인 정보를 통해 설정
    }

    @PreUpdate
    protected void onUpdate() {
        this.updateDate = LocalDateTime.now();
        // update_user는 로그인 정보를 통해 설정
    }
}
