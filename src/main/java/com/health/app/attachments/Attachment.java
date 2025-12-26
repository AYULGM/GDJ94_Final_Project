package com.health.app.attachments;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "attachments")
public class Attachment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "file_id")
    private Long fileId;

    @Column(name = "storage_provider", nullable = false)
    private String storageProvider; // S3, LOCAL 등

    @Column(name = "storage_key", nullable = false)
    private String storageKey; // S3 경로 또는 로컬 파일명

    @Column(name = "original_name", nullable = false)
    private String originalName;

    @Column(name = "content_type")
    private String contentType;

    @Column(name = "file_size", nullable = false)
    private Long fileSize;

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
        // create_user는 로그인 정보를 통해 설정
    }

    @PreUpdate
    protected void onUpdate() {
        this.updateDate = LocalDateTime.now();
        // update_user는 로그인 정보를 통해 설정
    }
}
