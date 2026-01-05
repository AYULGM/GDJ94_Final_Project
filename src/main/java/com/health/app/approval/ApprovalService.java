package com.health.app.approval;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ApprovalService {

    private final ApprovalMapper approvalMapper;

    // =========================
    // Draft 저장
    // =========================
    @Transactional
    public ApprovalDraftDTO saveDraft(Long loginUserId, ApprovalDraftDTO dto) {

        dto.setDrafterId(loginUserId);
        dto.setCreateUser(loginUserId);
        dto.setUpdateUser(loginUserId);

        // ✅ drafter_branch_id NOT NULL 대응
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

    // =========================
    // 결재선 저장 (Controller가 호출하는 메서드)
    // =========================
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

            // 서버 강제 세팅
            line.setDocVerId(docVerId);

            // seq 자동 부여
            if (line.getSeq() == null) {
                line.setSeq(seqAuto++);
            } else {
                seqAuto = Math.max(seqAuto, line.getSeq() + 1);
            }

            // 상태 기본값
            if (line.getLineStatusCode() == null || line.getLineStatusCode().isBlank()) {
                line.setLineStatusCode("ALS001");
            }

            line.setCreateUser(loginUserId);
            line.setUpdateUser(loginUserId);

            approvalMapper.insertLine(line);
        }
    }

    // =========================
    // 결재선 조회 (Controller linesForm이 호출)
    // =========================
    @Transactional(readOnly = true)
    public List<ApprovalLineDTO> getLines(Long docVerId) {
        if (docVerId == null) {
            throw new IllegalArgumentException("docVerId is required");
        }
        return approvalMapper.selectLinesByDocVerId(docVerId);
    }

    // =========================
    // 결재자 트리 조회 (Controller approvers/tree가 호출)
    // =========================
    @Transactional(readOnly = true)
    public Map<String, Object> getApproverTree() {

        // Mapper에 아래 3개 메서드가 추가되어 있어야 함
        // - selectHeadOfficeApprovers()
        // - selectBranchApprovers()
        // - selectBranches()
        List<Map<String, Object>> hqUsers = approvalMapper.selectHeadOfficeApprovers();
        List<Map<String, Object>> brUsers = approvalMapper.selectBranchApprovers();
        List<Map<String, Object>> brList  = approvalMapper.selectBranches();

        // 1) 본사: deptCode별 그룹핑
        Map<String, List<Map<String, Object>>> headOfficeByDept = new LinkedHashMap<>();
        for (Map<String, Object> u : hqUsers) {
            String deptCode = String.valueOf(u.get("deptCode"));
            headOfficeByDept.computeIfAbsent(deptCode, k -> new ArrayList<>()).add(u);
        }

        // 2) 지점명 매핑
        Map<Long, String> branchNameMap = new HashMap<>();
        for (Map<String, Object> b : brList) {
            Long branchId = ((Number) b.get("branchId")).longValue();
            branchNameMap.put(branchId, String.valueOf(b.get("branchName")));
        }

        // 3) 지점: branchId별 {branchName, users}
        Map<String, Object> branches = new LinkedHashMap<>();
        for (Map<String, Object> u : brUsers) {

            Long branchId = ((Number) u.get("branchId")).longValue();
            String key = String.valueOf(branchId);

            @SuppressWarnings("unchecked")
            Map<String, Object> node = (Map<String, Object>) branches.get(key);
            if (node == null) {
                node = new LinkedHashMap<>();
                node.put("branchName", branchNameMap.getOrDefault(branchId, "지점 " + branchId));
                node.put("users", new ArrayList<Map<String, Object>>());
                branches.put(key, node);
            }

            @SuppressWarnings("unchecked")
            List<Map<String, Object>> users = (List<Map<String, Object>>) node.get("users");
            users.add(u);
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("headOfficeByDept", headOfficeByDept);
        result.put("branches", branches);
        return result;
    }
    
 // =========================
 // 결재 요청(SUBMIT)
 // =========================
 @Transactional
 public void submit(Long loginUserId, Long docVerId) {

     if (docVerId == null) {
         throw new IllegalArgumentException("docVerId is required");
     }

     // 1) 기안자 권한 체크
     Long drafterId = approvalMapper.selectDrafterIdByDocVerId(docVerId);
     if (drafterId == null) {
         throw new IllegalStateException("문서를 찾을 수 없습니다. docVerId=" + docVerId);
     }
     if (!drafterId.equals(loginUserId)) {
         throw new IllegalStateException("기안자만 결재 요청할 수 있습니다.");
     }

     // 2) 결재선 존재 체크
     int lineCount = approvalMapper.countLinesByDocVerId(docVerId);
     if (lineCount <= 0) {
         throw new IllegalStateException("결재선이 없습니다. 결재선을 먼저 설정하세요.");
     }

     // (선택) 이미 결재중/완료 등 재제출 방지
     String docStatus = approvalMapper.selectDocStatusByDocVerId(docVerId);
     if (docStatus == null) {
         throw new IllegalStateException("문서 상태 조회 실패. docVerId=" + docVerId);
     }
     if (!"AS001".equals(docStatus)) {
         throw new IllegalStateException("임시저장 문서만 결재 요청할 수 있습니다. 현재상태=" + docStatus);
     }

     // 3) 문서/버전 상태를 결재중으로 변경
     approvalMapper.updateDocumentStatusByDocVerId(docVerId, "AS002", loginUserId);
     approvalMapper.updateVersionStatusByDocVerId(docVerId, "AVS002", loginUserId);

     // 4) 결재선 상태 초기화: 전원 WAIT -> 첫 결재자 PENDING
     approvalMapper.updateAllLinesStatusByDocVerId(docVerId, "ALS001", loginUserId);
     approvalMapper.updateFirstLineToPending(docVerId, "ALS002", loginUserId);
 }

}
