package com.health.app.attachments;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AttachmentLinkRepository extends JpaRepository<AttachmentLink, Long> {
}
