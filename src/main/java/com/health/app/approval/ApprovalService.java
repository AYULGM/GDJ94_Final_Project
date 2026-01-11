package com.health.app.approval;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.health.app.schedules.CalendarEventDto;
import com.health.app.schedules.CalendarEventMapper;
import com.health.app.schedules.ScheduleStatus;
import com.health.app.schedules.ScheduleType;
import com.health.app.signature.SignatureDTO;
import com.health.app.signature.SignatureMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ApprovalService {

    private final ApprovalMapper approvalMapper;
    private final ApprovalProductMapper approvalProductMapper;
    private final SignatureMapper signatureMapper;
    private final CalendarEventMapper calendarEventMapper;
    private final ApprovalApplyService approvalApplyService;
    // 내가 기안한 문서 목록
    @Transactional(readOnly = true)
    public List<ApprovalMyDocRowDTO> getMyDocs(Long drafterId) {
        return approvalMapper.selectMyDocs(drafterId);
    }

    // 상세 페이지 데이터
    @Transactional(readOnly = true)
    public ApprovalDetailPageDTO getDetailPage(Long userId, Long docVerId) {

        ApprovalDocDetailDTO doc = approvalMapper.selectDocDetail(docVerId);
        List<ApprovalLineViewDTO> lines = approvalMapper.selectLinesForDetail(docVerId);

        ApprovalDetailPageDTO page = new ApprovalDetailPageDTO();
        page.setDoc(doc);
        page.setLines(lines);

        boolean isDrafter = doc != null && doc.getDrafterUserId() != null && doc.getDrafterUserId().equals(userId);
        boolean canRecall = approvalMapper.canRecallDoc(docVerId, userId) > 0;

        boolean canEdit = false;
        if (isDrafter && doc != null) {
            String st = doc.getDocStatusCode();
            canEdit = "AS001".equals(st) || "AS004".equals(st) || "AS005".equals(st);
        }

        page.setCanRecall(canRecall);
        page.setCanEdit(canEdit);

        return page;
    }

    // 수정용 초안 조회
    @Transactional(readOnly = true)
    public ApprovalDraftDTO getDraftForEdit(Long docVerId, Long userId) {

        ApprovalDraftDTO draft = approvalMapper.selectDraftByDocVerId(docVerId);
        if (draft == null) throw new IllegalArgumentException("존재하지 않는 문서입니다.");

        if (!userId.equals(draft.getDrafterId())) {
            throw new SecurityException("수정 권한이 없습니다.");
        }

        String st = draft.getStatusCode();
        if (!("AS001".equals(st) || "AS004".equals(st) || "AS005".equals(st))) {
            throw new IllegalStateException("현재 상태에서는 수정할 수 없습니다.");
        }

        return draft;
    }

    // 받은 결재함
    @Transactional(readOnly = true)
    public List<ApprovalInboxRowDTO> getMyInbox(Long approverId) {
        return approvalMapper.selectMyInbox(approverId);
    }

    // 임시저장(신규)
    @Transactional
    public ApprovalDraftDTO saveDraft(Long loginUserId, ApprovalDraftDTO dto) {

        dto.setDrafterId(loginUserId);
        dto.setCreateUser(loginUserId);
        dto.setUpdateUser(loginUserId);

        if (dto.getBranchId() == null) {
            Long branchId = approvalMapper.selectBranchIdByUserId(loginUserId);
            if (branchId == null) throw new IllegalStateException("branchId 조회 실패");
            dto.setBranchId(branchId);
        }

        if (dto.getDocNo() == null || dto.getDocNo().isBlank()) {
            dto.setDocNo("TMP-" + System.currentTimeMillis());
        }

        dto.setStatusCode("AS001");
        dto.setVerStatusCode("AVS001");
        if (dto.getVersionNo() == null) dto.setVersionNo(1L);

        dto.setTitle(Optional.ofNullable(dto.getTitle()).orElse(""));
        dto.setBody(Optional.ofNullable(dto.getBody()).orElse(""));

        approvalMapper.insertDocument(dto);
        approvalMapper.insertDocumentVersion(dto);
        approvalMapper.insertDocumentExt(dto);
        approvalMapper.updateCurrentVersion(dto);

        return dto;
    }

    // 임시저장(수정)
    @Transactional
    public void updateDraft(Long loginUserId, ApprovalDraftDTO dto) {

        if (dto.getDocVerId() == null) throw new IllegalArgumentException("docVerId is required");

        ApprovalDraftDTO current = getDraftForEdit(dto.getDocVerId(), loginUserId);

        dto.setTypeCode(current.getTypeCode());
        dto.setFormCode(current.getFormCode());
        dto.setDrafterId(current.getDrafterId());

        dto.setStatusCode("AS001");
        dto.setVerStatusCode("AVS001");
        dto.setUpdateUser(loginUserId);

        dto.setTitle(Optional.ofNullable(dto.getTitle()).orElse(""));
        dto.setBody(Optional.ofNullable(dto.getBody()).orElse(""));

        approvalMapper.updateDocumentVersionByDocVerId(dto);

        if (approvalMapper.updateDocumentExtByDocVerId(dto) == 0) {
            approvalMapper.insertDocumentExt(dto);
        }
    }

    // 결재선 저장
    @Transactional
    public void saveLines(Long loginUserId, Long docVerId, List<ApprovalLineDTO> lines) {

        if (docVerId == null) throw new IllegalArgumentException("docVerId is required");

        approvalMapper.deleteLinesByDocVerId(docVerId);

        int seq = 1;
        for (ApprovalLineDTO line : lines) {
            line.setDocVerId(docVerId);
            line.setSeq(seq++);
            line.setLineStatusCode("ALS001");
            line.setCreateUser(loginUserId);
            line.setUpdateUser(loginUserId);
            approvalMapper.insertLine(line);
        }
    }

    // 결재선 조회
    @Transactional(readOnly = true)
    public List<ApprovalLineDTO> getLines(Long docVerId) {
        if (docVerId == null) throw new IllegalArgumentException("docVerId is required");
        return approvalMapper.selectLinesByDocVerId(docVerId);
    }

    // 결재자 트리
    @Transactional(readOnly = true)
    public Map<String, Object> getApproverTree() {

        List<Map<String, Object>> hqUsers = approvalMapper.selectHeadOfficeApprovers();
        List<Map<String, Object>> brUsers = approvalMapper.selectBranchApprovers();
        List<Map<String, Object>> brList  = approvalMapper.selectBranches();

        Map<String, List<Map<String, Object>>> headOfficeByDept = new LinkedHashMap<>();
        for (Map<String, Object> u : hqUsers) {
            String deptCode = String.valueOf(u.get("deptCode"));
            headOfficeByDept.computeIfAbsent(deptCode, k -> new ArrayList<>()).add(u);
        }

        Map<Long, String> branchNameMap = new HashMap<>();
        for (Map<String, Object> b : brList) {
            branchNameMap.put(((Number) b.get("branchId")).longValue(), String.valueOf(b.get("branchName")));
        }

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

    // 지점 목록
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getBranches() {
        return approvalMapper.selectBranches();
    }

    // 지점별 상품 조회
    @Transactional(readOnly = true)
    public List<ApprovalProductDTO> getProductsByBranch(Long branchId) {
        return approvalProductMapper.selectProductsByBranch(branchId);
    }

    // 결재 요청(최초 상신)
    @Transactional
    public void submit(Long loginUserId, Long docVerId) {

        if (docVerId == null) throw new IllegalArgumentException("docVerId is required");

        Long drafterId = approvalMapper.selectDrafterIdByDocVerId(docVerId);
        if (drafterId == null) throw new IllegalStateException("문서를 찾을 수 없습니다.");
        if (!loginUserId.equals(drafterId)) throw new IllegalStateException("기안자만 상신할 수 있습니다.");

        int lineCount = approvalMapper.countLinesByDocVerId(docVerId);
        if (lineCount <= 0) throw new IllegalStateException("결재선이 없습니다. 결재선을 먼저 설정하세요.");

        String docStatus = approvalMapper.selectDocStatusByDocVerId(docVerId);
        if (!"AS001".equals(docStatus)) throw new IllegalStateException("임시저장 문서만 결재 요청할 수 있습니다.");

        approvalMapper.updateDocumentStatusByDocVerId(docVerId, "AS002", loginUserId);
        approvalMapper.updateVersionStatusByDocVerId(docVerId, "AVS002", loginUserId);
        approvalMapper.updateAllLinesStatusByDocVerId(docVerId, "ALS001", loginUserId);
        approvalMapper.updateFirstLineToPending(docVerId, "ALS002", loginUserId);

        // 🔴 🔴 🔴 이게 빠져 있었음
        String typeCode = approvalMapper.selectTypeCodeByDocVerId(docVerId);
        if (!"AT009".equals(typeCode)) {
            approvalApplyService.applyApprovedDoc(docVerId, loginUserId);
        }

    }


    // 재상신(임시/반려/회수만 가능)
    @Transactional
    public void resubmit(Long loginUserId, Long docVerId) {

        ApprovalDraftDTO draft = approvalMapper.selectDraftByDocVerId(docVerId);
        if (draft == null) throw new IllegalArgumentException("존재하지 않는 문서입니다.");
        if (!loginUserId.equals(draft.getDrafterId())) throw new SecurityException("기안자만 재상신할 수 있습니다.");

        String st = draft.getStatusCode();
        if (!("AS001".equals(st) || "AS004".equals(st) || "AS005".equals(st))) {
            throw new IllegalStateException("현재 상태에서는 재상신할 수 없습니다.");
        }

        int lineCount = approvalMapper.countLinesByDocVerId(docVerId);
        if (lineCount <= 0) throw new IllegalStateException("결재선이 없습니다. 결재선을 먼저 설정하세요.");

        approvalMapper.updateDocumentStatusByDocVerId(docVerId, "AS002", loginUserId);
        approvalMapper.updateVersionStatusByDocVerId(docVerId, "AVS002", loginUserId);
        approvalMapper.updateAllLinesStatusByDocVerId(docVerId, "ALS001", loginUserId);
        approvalMapper.updateFirstLineToPending(docVerId, "ALS002", loginUserId);
    }

    // 상신 회수
    @Transactional
    public void recall(Long loginUserId, Long docVerId) {

        int can = approvalMapper.canRecallDoc(docVerId, loginUserId);
        if (can <= 0) throw new IllegalStateException("상신 취소가 불가능한 상태입니다.");

        approvalMapper.updateDocumentStatusByDocVerId(docVerId, "AS005", loginUserId);
        approvalMapper.updateVersionStatusByDocVerId(docVerId, "AVS001", loginUserId);
        approvalMapper.updateAllLinesStatusByDocVerId(docVerId, "ALS001", loginUserId);
    }

    // 출력 데이터
    @Transactional(readOnly = true)
    public ApprovalPrintDTO getPrintData(Long docVerId) {

        VacationPrintDTO doc = approvalMapper.selectVacationPrint(docVerId);
        if (doc == null) throw new IllegalStateException("문서를 찾을 수 없습니다.");

        doc.setLines(approvalMapper.selectPrintLines(docVerId));
        return doc;
    }

    // 결재 처리(승인/반려)
    @Transactional
    public void handleDecision(Long docVerId, Long userId, String action, String comment) {

        Long signatureFileId = null;
        SignatureDTO sign = signatureMapper.selectPrimaryByUserId(userId);
        if (sign != null) signatureFileId = sign.getFileId();

        if ("APPROVE".equals(action)) {

            int updated = approvalMapper.approveMyTurn(docVerId, userId, comment, signatureFileId);
            if (updated == 0) throw new IllegalStateException("결재 차례가 아니거나 이미 처리된 문서입니다.");

            approvalMapper.activateNextApprover(docVerId);

            int waiting = approvalMapper.existsWaitingLine(docVerId);
            if (waiting > 0) {
                approvalMapper.updateDocStatusByDocVerId(docVerId, "AS002");
            } else {
                approvalMapper.updateDocStatusByDocVerId(docVerId, "AS003");
                approvalMapper.updateVersionStatusByDocVerId(docVerId, "AVS003", userId);
                createLeaveCalendarEvent(docVerId, userId);
            }

        } else if ("REJECT".equals(action)) {

            int updated = approvalMapper.rejectMyTurn(docVerId, userId, comment, signatureFileId);
            if (updated == 0) throw new IllegalStateException("결재 차례가 아니거나 이미 처리된 문서입니다.");

            approvalMapper.updateDocStatusByDocVerId(docVerId, "AS004");

        } else {
            throw new IllegalArgumentException("지원하지 않는 action 입니다: " + action);
        }
    }

    // 최종 승인 시 휴가 일정 생성
    private void createLeaveCalendarEvent(Long docVerId, Long actorUserId) {

        VacationPrintDTO doc = approvalMapper.selectVacationPrint(docVerId);
        if (doc == null) throw new IllegalStateException("휴가 문서를 찾을 수 없습니다.");

        Long ownerUserId = doc.getDrafterUserId();
        if (ownerUserId == null) throw new IllegalStateException("기안자 정보가 없습니다.");

        Map<String, Object> org = approvalMapper.selectUserOrg(ownerUserId);
        String departmentCode = org == null ? null : (String) org.get("departmentCode");

        Long branchId = null;
        if (org != null && org.get("branchId") != null) {
            branchId = ((Number) org.get("branchId")).longValue();
        }

        LocalDate startDate = doc.getLeaveStartDate();
        LocalDate endDate = doc.getLeaveEndDate();

        LocalDateTime startAt = startDate.atStartOfDay();
        LocalDateTime endAt = endDate.atTime(23, 59, 59);

        CalendarEventDto event = CalendarEventDto.builder()
                .scope(ScheduleType.PERSONAL)
                .title(buildLeaveTitle(doc))
                .description(buildLeaveDescription(doc, docVerId))
                .startAt(startAt)
                .endAt(endAt)
                .statusCode(ScheduleStatus.SCHEDULED)
                .allDay(true)
                .repeating(false)
                .repeatInfo(null)
                .departmentCode(departmentCode)
                .ownerUserId(ownerUserId)
                .branchId(branchId)
                .createUser(actorUserId)
                .useYn(true)
                .build();

        calendarEventMapper.insertCalendarEvent(event);
    }

    // 휴가 제목 생성
    private String buildLeaveTitle(VacationPrintDTO doc) {
        String t = doc.getLeaveType();
        return (t == null || t.isBlank()) ? "휴가" : "휴가(" + t + ")";
    }

    // 휴가 설명 생성
    private String buildLeaveDescription(VacationPrintDTO doc, Long docVerId) {

        String reason = doc.getLeaveReason() == null ? "" : doc.getLeaveReason();
        String handover = doc.getHandoverNote() == null ? "" : doc.getHandoverNote();

        StringBuilder sb = new StringBuilder();
        if (!reason.isBlank()) sb.append("사유: ").append(reason);
        if (!handover.isBlank()) {
            if (sb.length() > 0) sb.append("\n");
            sb.append("인수인계: ").append(handover);
        }
        if (sb.length() > 0) sb.append("\n");
        sb.append("(docVerId=").append(docVerId).append(")");

        return sb.toString();
    }
}
