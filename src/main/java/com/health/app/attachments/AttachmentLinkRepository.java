package com.health.app.attachments;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AttachmentLinkRepository extends JpaRepository<AttachmentLink, Long> {

    /**
     * 특정 엔티티에 연결된 모든 첨부파일 링크를 논리적으로 삭제합니다.
     * @param entityType 엔티티 타입 (e.g., "CALENDAR_EVENT")
     * @param entityId 엔티티 ID
     */
    @Modifying
    @Query("UPDATE AttachmentLink al SET al.useYn = false, al.updateDate = NOW() WHERE al.entityType = :entityType AND al.entityId = :entityId")
    void logicalDeleteByEntityTypeAndEntityId(@Param("entityType") String entityType, @Param("entityId") Long entityId);

    /**
     * 특정 엔티티에 연결된 모든 첨부파일을 조회합니다.
     * @param entityType 엔티티 타입 (e.g., "CALENDAR_EVENT")
     * @param entityId 엔티티 ID
     * @return 첨부파일 목록
     */
    @Query("SELECT a FROM Attachment a JOIN AttachmentLink al ON a.fileId = al.fileId WHERE al.entityType = :entityType AND al.entityId = :entityId AND al.useYn = true AND a.useYn = true ORDER BY al.sortOrder")
    List<Attachment> findAttachmentsByEntityTypeAndEntityId(@Param("entityType") String entityType, @Param("entityId") Long entityId);
}
