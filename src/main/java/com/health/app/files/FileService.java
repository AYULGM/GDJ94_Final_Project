package com.health.app.files;

import com.health.app.attachments.Attachment;
import com.health.app.attachments.AttachmentRepository;
import com.health.app.attachments.AttachmentLink; // AttachmentLink 임포트
import com.health.app.attachments.AttachmentLinkRepository; // AttachmentLinkRepository 임포트
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import jakarta.transaction.Transactional; // 트랜잭션 추가
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.io.IOException;
import java.net.MalformedURLException;
import java.time.LocalDateTime;
import java.util.UUID;

@Service
public class FileService {

    private final Path fileStorageLocation;
    private final AttachmentRepository attachmentRepository;
    private final AttachmentLinkRepository attachmentLinkRepository; // AttachmentLinkRepository 주입

    @Autowired
    public FileService(AttachmentRepository attachmentRepository, 
                       AttachmentLinkRepository attachmentLinkRepository, // AttachmentLinkRepository 주입
                       @Value("${app.upload.base}") String uploadBaseDir) {
        this.attachmentRepository = attachmentRepository;
        this.attachmentLinkRepository = attachmentLinkRepository; // AttachmentLinkRepository 초기화
        this.fileStorageLocation = Paths.get(uploadBaseDir).toAbsolutePath().normalize();
        
        try {
            Files.createDirectories(this.fileStorageLocation);
        } catch (IOException e) {
            throw new RuntimeException("파일 업로드 디렉토리를 생성할 수 없습니다: " + this.fileStorageLocation, e);
        }
    }

    // 파일 저장
    @Transactional // 트랜잭션 처리
    public Long storeFile(MultipartFile file) {
        String originalFileName = org.springframework.util.StringUtils.cleanPath(file.getOriginalFilename());
        if (originalFileName.contains("..")) {
            throw new RuntimeException("파일명에 부적절한 경로 시퀀스가 포함되어 있습니다. " + originalFileName);
        }

        try {
            String fileExtension = "";
            int dotIndex = originalFileName.lastIndexOf('.');
            if (dotIndex > 0 && dotIndex < originalFileName.length() - 1) {
                fileExtension = originalFileName.substring(dotIndex);
            }
            String storageKey = UUID.randomUUID().toString() + fileExtension;
            Path targetLocation = this.fileStorageLocation.resolve(storageKey);
            
            Files.copy(file.getInputStream(), targetLocation, StandardCopyOption.REPLACE_EXISTING);
            
            Attachment attachment = new Attachment();
            attachment.setStorageProvider("LOCAL");
            attachment.setStorageKey(storageKey);
            attachment.setOriginalName(originalFileName);
            attachment.setContentType(file.getContentType());
            attachment.setFileSize(file.getSize());
            attachment.setCreateUser(1L); // TODO: 실제 로그인 사용자 ID로 변경
            attachment.setCreateDate(LocalDateTime.now());
            attachment.setUseYn(true);

            Attachment savedAttachment = attachmentRepository.save(attachment);
            return savedAttachment.getFileId();

        } catch (IOException e) {
            throw new RuntimeException("파일 " + originalFileName + "을(를) 저장할 수 없습니다. 다시 시도해 주세요!", e);
        }
    }

    // 파일 로드 (다운로드 등을 위해)
    public Resource loadFileAsResource(Long fileId) {
        try {
            Attachment attachment = attachmentRepository.findById(fileId)
                    .orElseThrow(() -> new RuntimeException("파일을 찾을 수 없습니다 (ID: " + fileId + ")"));
            
            Path filePath = this.fileStorageLocation.resolve(attachment.getStorageKey()).normalize();
            Resource resource = new UrlResource(filePath.toUri());
            if (resource.exists() && attachment.getUseYn()) { // useYn이 true인 경우에만 로드
                return resource;
            } else {
                throw new RuntimeException("파일을 찾을 수 없습니다 " + attachment.getStorageKey() + " 또는 비활성화된 파일입니다.");
            }
        } catch (MalformedURLException e) {
            throw new RuntimeException("파일을 찾을 수 없습니다 (Malformed URL)", e);
        }
    }
    
    // 파일 정보 조회
    public Attachment getAttachment(Long fileId) {
        return attachmentRepository.findById(fileId)
                .orElseThrow(() -> new RuntimeException("첨부파일 정보를 찾을 수 없습니다 (ID: " + fileId + ")"));
    }

    /**
     * 첨부파일을 다른 엔티티(게시물 등)와 연결합니다.
     * @param fileId 연결할 첨부파일의 ID
     * @param entityType 연결될 엔티티의 타입 (예: "NOTICE", "APPROVAL", "PRODUCT")
     * @param entityId 연결될 엔티티의 ID
     * @param linkRole 파일의 역할 (예: "MAIN_IMAGE", "ATTACHMENT", "THUMBNAIL")
     * @param createUser 연결을 생성하는 사용자 ID
     * @return 생성된 AttachmentLink 엔티티의 ID
     */
    @Transactional
    public Long linkFileToEntity(Long fileId, String entityType, Long entityId, String linkRole, Long createUser) {
        AttachmentLink attachmentLink = new AttachmentLink();
        attachmentLink.setFileId(fileId);
        attachmentLink.setEntityType(entityType);
        attachmentLink.setEntityId(entityId);
        attachmentLink.setLinkRole(linkRole);
        attachmentLink.setCreateUser(createUser);
        // createDate, useYn, sortOrder는 @PrePersist에서 설정되거나 기본값 가짐

        AttachmentLink savedLink = attachmentLinkRepository.save(attachmentLink);
        return savedLink.getLinkId();
    }

    /**
     * 첨부파일을 논리적으로 삭제 처리합니다. (useYn = false)
     * @param fileId 삭제할 첨부파일의 ID
     * @param updateUser 업데이트하는 사용자 ID
     */
    @Transactional
    public void deleteAttachment(Long fileId, Long updateUser) {
        Attachment attachment = attachmentRepository.findById(fileId)
                .orElseThrow(() -> new RuntimeException("삭제할 첨부파일을 찾을 수 없습니다 (ID: " + fileId + ")"));
        
        attachment.setUseYn(false);
        attachment.setUpdateUser(updateUser); // TODO: 실제 로그인 사용자 ID로 변경
        attachment.setUpdateDate(LocalDateTime.now());
        attachmentRepository.save(attachment); // 변경사항 저장
    }
}
