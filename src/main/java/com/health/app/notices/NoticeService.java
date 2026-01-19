package com.health.app.notices;

import com.health.app.attachments.Attachment;
import com.health.app.attachments.AttachmentLinkRepository;
import com.health.app.branch.BranchDTO;
import com.health.app.files.FileService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
@RequiredArgsConstructor
public class NoticeService {

    private final NoticeMapper noticeMapper;
    private final FileService fileService;
    private final AttachmentLinkRepository attachmentLinkRepository;

    private static final DateTimeFormatter DF = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    private static final DateTimeFormatter TF = DateTimeFormatter.ofPattern("HH:mm");
    private static final DateTimeFormatter DT_LOCAL = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm"); // datetime-local 용

    // 사용자 목록
    public List<NoticeDTO> list(Long branchId) {
        List<NoticeDTO> list = noticeMapper.selectList(branchId);
        if (list != null) {
            for (NoticeDTO n : list) {
                decorateForDisplay(n);
            }
        }
        return list;
    }

    // 상세 조회(조회수 증가)
    @Transactional
    public NoticeDTO view(Long noticeId) {
        noticeMapper.incrementViewCount(noticeId);
        NoticeDTO n = noticeMapper.selectOne(noticeId);
        decorateForDisplay(n);
        return n;
    }

    // 공지 등록
    @Transactional
    public Long create(NoticeDTO dto, java.util.List<MultipartFile> files, Long actorUserId, String reason) {
        validateTargets(dto);

        if (dto.getIsPinned() == null) dto.setIsPinned(false);
        if (dto.getStatus() == null) dto.setStatus("NS001");

        dto.setUpdateUser(actorUserId);
        noticeMapper.insertNotice(dto);

        // 첨부파일 저장/연결 (attachments + attachment_links)
        storeAndLinkAttachments(dto.getNoticeId(), files, actorUserId);

        saveTargets(dto, actorUserId);

        NoticeHistoryDTO h = new NoticeHistoryDTO();
        h.setNoticeId(dto.getNoticeId());
        h.setChangeType("CREATE");
        h.setBeforeValue(null);
        h.setAfterValue("title=" + dto.getTitle());
        h.setReason((reason == null || reason.isBlank()) ? "CREATE" : reason);
        h.setCreateUser(actorUserId);
        noticeMapper.insertHistory(h);

        return dto.getNoticeId();
    }

    // 공지 수정
    @Transactional
    public void update(NoticeDTO dto, java.util.List<MultipartFile> files, Long actorUserId, String reason) {
        validateTargets(dto);

        if (dto.getIsPinned() == null) dto.setIsPinned(false);
        if (dto.getStatus() == null) dto.setStatus("NS001");

        NoticeDTO before = noticeMapper.selectOne(dto.getNoticeId());

        dto.setUpdateUser(actorUserId);
        noticeMapper.updateNotice(dto);

        // 신규 첨부파일만 추가(기존 첨부는 유지)
        storeAndLinkAttachments(dto.getNoticeId(), files, actorUserId);

        noticeMapper.deleteTargets(dto.getNoticeId(), actorUserId);
        saveTargets(dto, actorUserId);

        NoticeHistoryDTO h = new NoticeHistoryDTO();
        h.setNoticeId(dto.getNoticeId());
        h.setChangeType("UPDATE");
        h.setBeforeValue("title=" + (before != null ? before.getTitle() : ""));
        h.setAfterValue("title=" + dto.getTitle());
        h.setReason((reason == null || reason.isBlank()) ? "UPDATE" : reason);
        h.setCreateUser(actorUserId);
        noticeMapper.insertHistory(h);
    }

    // 공지 삭제(soft delete)
    @Transactional
    public void delete(Long noticeId, Long actorUserId, String reason) {
        noticeMapper.softDelete(noticeId, actorUserId);

        // 첨부 링크도 논리 삭제
        attachmentLinkRepository.logicalDeleteByEntityTypeAndEntityId("NOTICE", noticeId);

        NoticeHistoryDTO h = new NoticeHistoryDTO();
        h.setNoticeId(noticeId);
        h.setChangeType("DELETE");
        h.setBeforeValue(null);
        h.setAfterValue("use_yn=0");
        h.setReason((reason == null || reason.isBlank()) ? "DELETE" : reason);
        h.setCreateUser(actorUserId);
        noticeMapper.insertHistory(h);
    }

    /**
     * 공지사항에 연결된 첨부파일 목록 조회
     */
    public java.util.List<Attachment> getAttachments(Long noticeId) {
        return attachmentLinkRepository.findAttachmentsByEntityTypeAndEntityId("NOTICE", noticeId);
    }

    private void storeAndLinkAttachments(Long noticeId, java.util.List<MultipartFile> files, Long actorUserId) {
        if (files == null || files.isEmpty()) return;
        long sort = 0L;
        for (MultipartFile f : files) {
            if (f == null || f.isEmpty()) continue;
            Long fileId = fileService.storeFile(f, actorUserId);
            // role은 범용적으로 "ATTACHMENT" 사용
            fileService.linkFileToEntity(fileId, "NOTICE", noticeId, "ATTACHMENT", actorUserId);
            sort++;
        }
    }

    // 대상 지점 저장
    private void saveTargets(NoticeDTO dto, Long actorUserId) {
        if ("TT002".equals(dto.getTargetType()) && dto.getBranchIds() != null) {
            for (Long b : dto.getBranchIds()) {
                noticeMapper.insertTarget(dto.getNoticeId(), b, actorUserId);
            }
        }
    }

    // 대상 유효성 검사
    private void validateTargets(NoticeDTO dto) {
        if (dto.getTargetType() == null) {
            throw new IllegalArgumentException("targetType은 필수입니다.");
        }
        if ("TT001".equals(dto.getTargetType())) {
            return;
        }
        if ("TT002".equals(dto.getTargetType())) {
            if (dto.getBranchIds() == null || dto.getBranchIds().isEmpty()) {
                throw new IllegalArgumentException("지점 대상 공지는 branchIds가 필요합니다.");
            }
            return;
        }
        throw new IllegalArgumentException("알 수 없는 targetType: " + dto.getTargetType());
    }

    // 관리자 목록
    public List<NoticeDTO> adminList() {
        List<NoticeDTO> list = noticeMapper.selectAdminList();
        if (list != null) {
            for (NoticeDTO n : list) {
                decorateForDisplay(n);
            }
        }
        return list;
    }

    public NoticeDTO getForEdit(Long noticeId) {
        NoticeDTO n = noticeMapper.selectOne(noticeId);
        if (n == null) return null;

        if ("TT002".equals(n.getTargetType())) {
            n.setBranchIds(noticeMapper.selectTargetBranchIds(noticeId));
        }

        // 입력 폼(datetime-local)용: T 포함이 정상
        if (n.getPublishStartDate() != null) n.setPublishStartInput(n.getPublishStartDate().format(DT_LOCAL));
        if (n.getPublishEndDate() != null) n.setPublishEndInput(n.getPublishEndDate().format(DT_LOCAL));

        // 표시용(목록/상세에서 T 제거)
        decorateForDisplay(n);

        return n;
    }

    // 만료 공지 종료
    @Transactional
    public int closeExpiredNotices(Long systemUserId) {
        return noticeMapper.closeExpiredNotices(systemUserId);
    }

    // 상세에서 대상 지점 표시용
    public List<BranchDTO> getTargetBranches(Long noticeId) {
        return noticeMapper.selectTargetBranches(noticeId);
    }

    // ===== 추가: 화면 표시용 date/time 분리 세팅 =====
    private void decorateForDisplay(NoticeDTO n) {
        if (n == null) return;

        if (n.getPublishStartDate() != null) {
            n.setPublishStartDateOnly(n.getPublishStartDate().format(DF));
            n.setPublishStartTimeOnly(n.getPublishStartDate().format(TF));
        } else {
            n.setPublishStartDateOnly(null);
            n.setPublishStartTimeOnly(null);
        }

        if (n.getPublishEndDate() != null) {
            n.setPublishEndDateOnly(n.getPublishEndDate().format(DF));
            n.setPublishEndTimeOnly(n.getPublishEndDate().format(TF));
        } else {
            n.setPublishEndDateOnly(null);
            n.setPublishEndTimeOnly(null);
        }
    }
    public List<NoticeDTO> listPaged(Long branchId, int limit, int offset) {
        return noticeMapper.selectListPaged(branchId, limit, offset);
    }

    public long countForUserList(Long branchId) {
        return noticeMapper.countUserList(branchId);
    }

    public List<NoticeDTO> adminListPaged(Long branchId, String status, String targetType, int limit, int offset) {
        return noticeMapper.selectAdminListPaged(branchId, status, targetType, limit, offset);
    }

    public long adminCount(Long branchId, String status, String targetType) {
        return noticeMapper.countAdminList(branchId, status, targetType);
    }

}
