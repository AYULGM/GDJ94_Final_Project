package com.health.app.notices;

import com.health.app.branch.BranchDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
@RequiredArgsConstructor
public class NoticeService {

    private final NoticeMapper noticeMapper;

    // 사용자 목록
    public List<NoticeDTO> list(Long branchId) {
        return noticeMapper.selectList(branchId);
    }

    // 상세 조회(조회수 증가)
    @Transactional
    public NoticeDTO view(Long noticeId) {
        noticeMapper.incrementViewCount(noticeId);
        return noticeMapper.selectOne(noticeId);
    }

    // 공지 등록
    @Transactional
    public Long create(NoticeDTO dto, Long actorUserId, String reason) {
        validateTargets(dto);

        if (dto.getIsPinned() == null) dto.setIsPinned(false);
        if (dto.getStatus() == null) dto.setStatus("NS001");

        dto.setUpdateUser(actorUserId);
        noticeMapper.insertNotice(dto);

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
    public void update(NoticeDTO dto, Long actorUserId, String reason) {
        validateTargets(dto);

        if (dto.getIsPinned() == null) dto.setIsPinned(false);
        if (dto.getStatus() == null) dto.setStatus("NS001");

        NoticeDTO before = noticeMapper.selectOne(dto.getNoticeId());

        dto.setUpdateUser(actorUserId);
        noticeMapper.updateNotice(dto);

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

        NoticeHistoryDTO h = new NoticeHistoryDTO();
        h.setNoticeId(noticeId);
        h.setChangeType("DELETE");
        h.setBeforeValue(null);
        h.setAfterValue("use_yn=0");
        h.setReason((reason == null || reason.isBlank()) ? "DELETE" : reason);
        h.setCreateUser(actorUserId);
        noticeMapper.insertHistory(h);
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
        return noticeMapper.selectAdminList();
    }

    public NoticeDTO getForEdit(Long noticeId) {
        NoticeDTO n = noticeMapper.selectOne(noticeId);
        if (n == null) return null;

        if ("TT002".equals(n.getTargetType())) {
            n.setBranchIds(noticeMapper.selectTargetBranchIds(noticeId));
        }

        DateTimeFormatter f = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
        if (n.getPublishStartDate() != null) n.setPublishStartInput(n.getPublishStartDate().format(f));
        if (n.getPublishEndDate() != null) n.setPublishEndInput(n.getPublishEndDate().format(f));

        // ===== 추가: date/time 분리 값 세팅 =====
        DateTimeFormatter df = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        DateTimeFormatter tf = DateTimeFormatter.ofPattern("HH:mm");

        if (n.getPublishStartDate() != null) {
            n.setPublishStartDateOnly(n.getPublishStartDate().format(df));
            n.setPublishStartTimeOnly(n.getPublishStartDate().format(tf));
        }
        if (n.getPublishEndDate() != null) {
            n.setPublishEndDateOnly(n.getPublishEndDate().format(df));
            n.setPublishEndTimeOnly(n.getPublishEndDate().format(tf));
        }

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
}
