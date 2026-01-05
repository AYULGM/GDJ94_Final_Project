package com.health.app.approval;

import java.util.List;

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

  
    @Transactional
    public void saveLines(Long loginUserId, Long docVerId, List<ApprovalLineDTO> lines) {

        if (docVerId == null) {
            throw new IllegalArgumentException("docVerId is required");
        }

        // 1) 기존 결재선 삭제
        approvalMapper.deleteLinesByDocVerId(docVerId);

        // 2) 새 결재선 삽입
        int seqAuto = 1;
        for (ApprovalLineDTO line : lines) {

            // 서버 강제 세팅 (클라 조작 방지)
            line.setDocVerId(docVerId);

            // seq가 안 오면 서버에서 자동 부여
            if (line.getSeq() == null) {
                line.setSeq(seqAuto++);
            } else {
                seqAuto = Math.max(seqAuto, line.getSeq() + 1);
            }

            // 상태 기본값
            if (line.getLineStatusCode() == null || line.getLineStatusCode().isBlank()) {
                line.setLineStatusCode("ALS001"); // 임시 결재선 상태(너희 공통코드로 교체)
            }

            line.setCreateUser(loginUserId);
            line.setUpdateUser(loginUserId);

            approvalMapper.insertLine(line);
        }
    }

  
    @Transactional(readOnly = true)
    public List<ApprovalLineDTO> getLines(Long docVerId) {
        if (docVerId == null) {
            throw new IllegalArgumentException("docVerId is required");
        }
        return approvalMapper.selectLinesByDocVerId(docVerId);
    }
}
