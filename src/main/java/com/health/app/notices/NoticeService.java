package com.health.app.notices;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.health.app.branch.BranchDTO;

import java.util.List;

@Service
@RequiredArgsConstructor
public class NoticeService {

    private final NoticeMapper noticeMapper;

    public List<NoticeDTO> list(Long branchId) {
        return noticeMapper.selectList(branchId);
    }

    @Transactional
    public NoticeDTO view(Long noticeId) {
        noticeMapper.incrementViewCount(noticeId);
        return noticeMapper.selectOne(noticeId);
    }

    @Transactional
    public Long create(NoticeDTO dto, Long actorUserId, String reason) {
        validateTargets(dto);

        if (dto.getIsPinned() == null) dto.setIsPinned(false);
        if (dto.getStatus() == null) dto.setStatus("NS001"); // 게시


        // DB감사 컬럼 정책: notices는 create_user 없음, update_user만 채움
        dto.setUpdateUser(actorUserId);

        noticeMapper.insertNotice(dto);

        // targets 저장(지점 대상)
        saveTargets(dto, actorUserId);

        // history 저장 (create_user NOT NULL, reason NOT NULL)
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

    @Transactional
    public void update(NoticeDTO dto, Long actorUserId, String reason) {
        validateTargets(dto);

        NoticeDTO before = noticeMapper.selectOne(dto.getNoticeId());

        dto.setUpdateUser(actorUserId);
        noticeMapper.updateNotice(dto);

        // 기존 targets는 논리삭제(use_yn=0) + update_user 필요
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

    private void saveTargets(NoticeDTO dto, Long actorUserId) {
        if ("TT002".equals(dto.getTargetType()) && dto.getBranchIds() != null) {
            for (Long b : dto.getBranchIds()) {
                noticeMapper.insertTarget(dto.getNoticeId(), b, actorUserId);
            }
        }
    }

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
    

	public List<BranchDTO> getTargetBranches(Long noticeId) {
	    return noticeMapper.selectTargetBranches(noticeId);
	}
}
