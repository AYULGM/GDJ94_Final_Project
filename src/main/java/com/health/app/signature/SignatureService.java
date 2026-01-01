package com.health.app.signature;

import com.health.app.attachments.Attachment;
import com.health.app.attachments.AttachmentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class SignatureService {

    private final SignatureMapper signatureMapper;
    private final AttachmentRepository attachmentRepository;

    @Value("${app.upload.base:uploads}")
    private String uploadBaseDir;

    /** 목록: 카드 렌더링용으로 imageUrl까지 세팅 */
    public List<SignatureDTO> list(Long userId) {
        List<SignatureDTO> list = signatureMapper.selectListByUserId(userId);
        for (SignatureDTO dto : list) {
            if (dto.getFileId() != null) {
                String previewUrl = "/files/preview/" + dto.getFileId();
                try {
                    Attachment att = attachmentRepository.findById(dto.getFileId()).orElse(null);
                    if (att != null) {
                        Path base = Paths.get(uploadBaseDir).toAbsolutePath().normalize();
                        Path altBase = Paths.get("uploads").toAbsolutePath().normalize();

                        Path[] candidates = new Path[] {
                            base.resolve(att.getStorageKey()).normalize(),
                            base.resolve(Paths.get(att.getStorageKey()).getFileName()).normalize(),
                            altBase.resolve(att.getStorageKey()).normalize(),
                            altBase.resolve(Paths.get(att.getStorageKey()).getFileName()).normalize(),
                            altBase.resolve("signatures").resolve(Paths.get(att.getStorageKey()).getFileName()).normalize()
                        };

                        for (Path p : candidates) {
                            if (Files.exists(p)) {
                                byte[] bytes = Files.readAllBytes(p);
                                String ct = att.getContentType() == null || att.getContentType().isBlank() ? "image/png" : att.getContentType();
                                String b64 = Base64.getEncoder().encodeToString(bytes);
                                dto.setImageUrl("data:" + ct + ";base64," + b64);
                                break;
                            }
                        }
                        if (dto.getImageUrl() == null) dto.setImageUrl(previewUrl);
                        continue;
                    }
                } catch (Exception ignored) {
                }

                dto.setImageUrl(previewUrl);
            }
        }
        return list;
    }

    /**
     * 저장 흐름(서명 base64 -> 파일 저장 -> attachments insert -> user_signatures insert)
     * - 첫 저장인 경우 대표(is_primary=true) 자동 지정
     */
    @Transactional(rollbackFor = Exception.class)
    public Long save(Long userId, Long actorId, String signBase64) throws Exception {
        if (signBase64 == null || signBase64.isBlank()) {
            throw new IllegalArgumentException("signBase64 is empty");
        }

        byte[] pngBytes = decodeDataUrl(signBase64);
        Long fileId = storeSignatureAsAttachment(actorId, pngBytes);

        boolean makePrimary = signatureMapper.countPrimary(userId) == 0;

        SignatureDTO us = new SignatureDTO();
        us.setUserId(userId);
        us.setFileId(fileId);
        us.setCreateUser(actorId);
        us.setIsPrimary(makePrimary);

        signatureMapper.insertUserSignature(us);
        return us.getSignatureId();
    }

    /** 삭제: use_yn=false (소프트 삭제) */
    @Transactional(rollbackFor = Exception.class)
    public void softDelete(Long userId, Long signatureId, Long actorId) {
        signatureMapper.softDeleteSignature(userId, signatureId, actorId);
    }

    /** 대표 변경: 유저당 대표 1개 */
    @Transactional(rollbackFor = Exception.class)
    public void changePrimary(Long userId, Long signatureId, Long actorId) {
        signatureMapper.clearPrimary(userId, actorId);
        signatureMapper.setPrimary(userId, signatureId, actorId);
    }

    // -----------------------------
    // private helpers
    // -----------------------------

    private byte[] decodeDataUrl(String dataUrl) {
        String base64 = dataUrl;
        int commaIdx = dataUrl.indexOf(',');
        if (commaIdx >= 0) {
            base64 = dataUrl.substring(commaIdx + 1);
        }
        return Base64.getDecoder().decode(base64);
    }

    /**
     * uploads/signatures 하위에 파일 저장 후 attachments에 메타데이터를 남기고 fileId를 반환.
     * - FileService와 동일하게 storageKey는 '파일명'만 저장합니다(전체 경로 X).
     */
    private Long storeSignatureAsAttachment(Long actorId, byte[] pngBytes) throws Exception {
        Path baseDir = Paths.get(uploadBaseDir).toAbsolutePath().normalize();
        Files.createDirectories(baseDir);

        String storageKey = UUID.randomUUID().toString() + ".png";
        Path target = baseDir.resolve(storageKey);
        Files.write(target, pngBytes);

        Attachment attachment = new Attachment();
        attachment.setStorageProvider("LOCAL");
        // FileService expects storageKey to be the filename only
        attachment.setStorageKey(storageKey);
        attachment.setOriginalName("signature.png");
        attachment.setContentType("image/png");
        attachment.setFileSize((long) pngBytes.length);
        attachment.setCreateUser(actorId);
        attachment.setCreateDate(LocalDateTime.now());
        attachment.setUseYn(true);

        Attachment saved = attachmentRepository.save(attachment);
        return saved.getFileId();
    }
}
