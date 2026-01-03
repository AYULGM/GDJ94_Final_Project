package com.health.app.approval;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ApprovalService {

    private final ApprovalMapper approvalMapper;

    @Transactional
    public ApprovalDraftDTO saveDraft(Long loginUserId, ApprovalDraftDTO dto) {

        dto.setDrafterId(loginUserId);
        dto.setCreateUser(loginUserId);
        dto.setUpdateUser(loginUserId);

        // ✅ drafter_branch_id NOT NULL 대응: userId로 branchId 조회해서 세팅
        if (dto.getBranchId() == null) {
            Long branchId = approvalMapper.selectBranchIdByUserId(loginUserId);
            if (branchId == null) {
                throw new IllegalStateException("branchId 조회 실패. userId=" + loginUserId);
            }
            dto.setBranchId(branchId);
        }

        if (dto.getDocNo() == null || dto.getDocNo().isBlank()) {
            dto.setDocNo("TMP-" + System.currentTimeMillis());
        }

        if (dto.getStatusCode() == null || dto.getStatusCode().isBlank()) {
            dto.setStatusCode("AS001");
        }

        if (dto.getVerStatusCode() == null || dto.getVerStatusCode().isBlank()) {
            dto.setVerStatusCode("AVS001");
        }
        if (dto.getVersionNo() == null) {
            dto.setVersionNo(1L);
        }

        if (dto.getTitle() == null) dto.setTitle("");
        if (dto.getBody() == null) dto.setBody("");

        approvalMapper.insertDocument(dto);
        approvalMapper.insertDocumentVersion(dto);
        approvalMapper.insertDocumentExt(dto);
        approvalMapper.updateCurrentVersion(dto);

        return dto;
    }
}
