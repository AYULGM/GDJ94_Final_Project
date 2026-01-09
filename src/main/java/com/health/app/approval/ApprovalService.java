package com.health.app.approval;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

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
    private final SignatureMapper signatureMapper; // ✅ 추가 (대표 서명 조회용)
    private final CalendarEventMapper calendarEventMapper; // ✅ 추가
    public List<ApprovalMyDocRowDTO> getMyDocs(Long drafterId) {
        return approvalMapper.selectMyDocs(drafterId);
    }
    public ApprovalDraftDTO getDraftForEdit(Long docVerId, Long userId) {

        ApprovalDraftDTO draft = approvalMapper.selectDraftByDocVerId(docVerId);

        if (draft == null) {
            throw new IllegalArgumentException("존재하지 않는 문서입니다.");
        }

        // 기안자만 수정 가능
        if (draft.getDrafterId() == null || !draft.getDrafterId().equals(userId)) {
            throw new SecurityException("수정 권한이 없습니다.");
        }

        // 수정 가능 상태
        String st = draft.getStatusCode();
        if (!("AS001".equals(st) || "AS004".equals(st) || "AS005".equals(st))) {
            throw new IllegalStateException("현재 상태에서는 수정할 수 없습니다.");
        }

        return draft;
    }


    /* ==================================================
     * 받은 결재함
     * ================================================== */
    @Transactional(readOnly = true)
    public List<ApprovalInboxRowDTO> getMyInbox(Long approverId) {
        return approvalMapper.selectMyInbox(approverId);
    }

    /* ==================================================
     * 임시저장
     * ================================================== */
    @Transactional
    public ApprovalDraftDTO saveDraft(Long loginUserId, ApprovalDraftDTO dto) {

        dto.setDrafterId(loginUserId);
        dto.setCreateUser(loginUserId);
        dto.setUpdateUser(loginUserId);

        // 지점 자동 세팅
        if (dto.getBranchId() == null) {
            Long branchId = approvalMapper.selectBranchIdByUserId(loginUserId);
            if (branchId == null) {
                throw new IllegalStateException("branchId 조회 실패. userId=" + loginUserId);
            }
            dto.setBranchId(branchId);
        }

        // 문서 번호
        if (dto.getDocNo() == null || dto.getDocNo().isBlank()) {
            dto.setDocNo("TMP-" + System.currentTimeMillis());
        }

        // 상태 기본값
        if (dto.getStatusCode() == null || dto.getStatusCode().isBlank()) {
            dto.setStatusCode("AS001"); // 임시저장
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
    public void updateDraft(Long loginUserId, ApprovalDraftDTO dto) {

        if (dto.getDocVerId() == null) {
            throw new IllegalArgumentException("docVerId is required");
        }

        ApprovalDraftDTO current = getDraftForEdit(dto.getDocVerId(), loginUserId);

        // 수정 정책: 문서유형/양식 변경 불가
        dto.setTypeCode(current.getTypeCode());
        dto.setFormCode(current.getFormCode());

        // 작성자 고정
        dto.setDrafterId(current.getDrafterId());

        // 상태 정책(원하면 유지로 변경 가능)
        dto.setStatusCode("AS001");
        dto.setVerStatusCode("AVS001");

        dto.setUpdateUser(loginUserId);

        if (dto.getTitle() == null) dto.setTitle("");
        if (dto.getBody() == null) dto.setBody("");

        approvalMapper.updateDocumentVersionByDocVerId(dto);

        int extUpdated = approvalMapper.updateDocumentExtByDocVerId(dto);
        if (extUpdated == 0) {
            approvalMapper.insertDocumentExt(dto);
        }
    }
    
    @Transactional
    public void resubmit(Long loginUserId, Long docVerId) {

        ApprovalDraftDTO draft = approvalMapper.selectDraftByDocVerId(docVerId);
        if (draft == null) throw new IllegalArgumentException("존재하지 않는 문서입니다.");

        if (draft.getDrafterId() == null || !draft.getDrafterId().equals(loginUserId)) {
            throw new SecurityException("기안자만 재상신할 수 있습니다.");
        }

        String st = draft.getStatusCode();
        if (!("AS001".equals(st) || "AS004".equals(st) || "AS005".equals(st))) {
            throw new IllegalStateException("현재 상태에서는 재상신할 수 없습니다.");
        }

        // 결재선 존재 체크
        int lineCount = approvalMapper.countLinesByDocVerId(docVerId);
        if (lineCount <= 0) throw new IllegalStateException("결재선이 없습니다. 결재선을 먼저 설정하세요.");

        // 문서/버전 상태 결재중
        approvalMapper.updateDocumentStatusByDocVerId(docVerId, "AS002", loginUserId);
        approvalMapper.updateVersionStatusByDocVerId(docVerId, "AVS002", loginUserId);

        // 라인 초기화 후 1번만 pending
        approvalMapper.updateAllLinesStatusByDocVerId(docVerId, "ALS001", loginUserId);
        approvalMapper.updateFirstLineToPending(docVerId, "ALS002", loginUserId);
    }

    
    @Transactional
    public void recall(Long loginUserId, Long docVerId) {

        if (docVerId == null) throw new IllegalArgumentException("docVerId is required");

        int can = approvalMapper.canRecallDoc(docVerId, loginUserId);
        if (can <= 0) {
            throw new IllegalStateException("상신 취소가 불가능한 상태입니다.");
        }

        // ✅ 문서 상태를 회수(AS005)로 변경
        approvalMapper.updateDocumentStatusByDocVerId(docVerId, "AS005", loginUserId);
        approvalMapper.updateVersionStatusByDocVerId(docVerId, "AVS001", loginUserId);

        // ✅ 결재선은 다시 '대기전(ALS001)'로 되돌림 + 첫 라인 pending 해제
        // (원하면 전체 초기화 없이 1번 라인만 ALS001로 바꿔도 됨)
        approvalMapper.updateAllLinesStatusByDocVerId(docVerId, "ALS001", loginUserId);
    }


    /* ==================================================
     * 결재선 저장
     * ================================================== */
    @Transactional
    public void saveLines(Long loginUserId, Long docVerId, List<ApprovalLineDTO> lines) {

        if (docVerId == null) {
            throw new IllegalArgumentException("docVerId is required");
        }

        approvalMapper.deleteLinesByDocVerId(docVerId);

        int seqAuto = 1;
        for (ApprovalLineDTO line : lines) {

            line.setDocVerId(docVerId);

            if (line.getSeq() == null) {
                line.setSeq(seqAuto++);
            } else {
                seqAuto = Math.max(seqAuto, line.getSeq() + 1);
            }

            if (line.getLineStatusCode() == null || line.getLineStatusCode().isBlank()) {
                line.setLineStatusCode("ALS001");
            }

            line.setCreateUser(loginUserId);
            line.setUpdateUser(loginUserId);

            approvalMapper.insertLine(line);
        }
    }

    /* ==================================================
     * 결재선 조회
     * ================================================== */
    @Transactional(readOnly = true)
    public List<ApprovalLineDTO> getLines(Long docVerId) {
        if (docVerId == null) {
            throw new IllegalArgumentException("docVerId is required");
        }
        return approvalMapper.selectLinesByDocVerId(docVerId);
    }

    /* ==================================================
     * 결재자 트리
     * ================================================== */
    @Transactional(readOnly = true)
    public Map<String, Object> getApproverTree() {

        List<Map<String, Object>> hqUsers = approvalMapper.selectHeadOfficeApprovers();
        List<Map<String, Object>> brUsers = approvalMapper.selectBranchApprovers();
        List<Map<String, Object>> brList  = approvalMapper.selectBranches();

        // 본사 → 부서
        Map<String, List<Map<String, Object>>> headOfficeByDept = new LinkedHashMap<>();
        for (Map<String, Object> u : hqUsers) {
            String deptCode = String.valueOf(u.get("deptCode"));
            headOfficeByDept.computeIfAbsent(deptCode, k -> new ArrayList<>()).add(u);
        }

        // 지점명 맵
        Map<Long, String> branchNameMap = new HashMap<>();
        for (Map<String, Object> b : brList) {
            Long branchId = ((Number) b.get("branchId")).longValue();
            branchNameMap.put(branchId, String.valueOf(b.get("branchName")));
        }

        // 지점 → 사용자
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

    /* ==================================================
     * 결재 요청
     * ================================================== */
    @Transactional
    public void submit(Long loginUserId, Long docVerId) {

        if (docVerId == null) {
            throw new IllegalArgumentException("docVerId is required");
        }

        Long drafterId = approvalMapper.selectDrafterIdByDocVerId(docVerId);
        if (drafterId == null) {
            throw new IllegalStateException("문서를 찾을 수 없습니다. docVerId=" + docVerId);
        }
        if (!drafterId.equals(loginUserId)) {
            throw new IllegalStateException("기안자만 결재 요청할 수 있습니다.");
        }

        int lineCount = approvalMapper.countLinesByDocVerId(docVerId);
        if (lineCount <= 0) {
            throw new IllegalStateException("결재선이 없습니다. 결재선을 먼저 설정하세요.");
        }

        String docStatus = approvalMapper.selectDocStatusByDocVerId(docVerId);
        if (!"AS001".equals(docStatus)) {
            throw new IllegalStateException("임시저장 문서만 결재 요청할 수 있습니다.");
        }

        approvalMapper.updateDocumentStatusByDocVerId(docVerId, "AS002", loginUserId);
        approvalMapper.updateVersionStatusByDocVerId(docVerId, "AVS002", loginUserId);
        approvalMapper.updateAllLinesStatusByDocVerId(docVerId, "ALS001", loginUserId);
        approvalMapper.updateFirstLineToPending(docVerId, "ALS002", loginUserId);
    }

    /* ==================================================
     * approval 전용 상품 조회
     * ================================================== */
    @Transactional(readOnly = true)
    public List<ApprovalProductDTO> getProductsByBranch(Long branchId) {
        return approvalProductMapper.selectProductsByBranch(branchId);
    }

    /* ==================================================
     * 지점 목록
     * ================================================== */
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getBranches() {
        return approvalMapper.selectBranches();
    }

    /* ==================================================
     * 출력 데이터
     * ================================================== */
    @Transactional(readOnly = true)
    public ApprovalPrintDTO getPrintData(Long docVerId) {

        if (docVerId == null) {
            throw new IllegalArgumentException("docVerId is required");
        }

        VacationPrintDTO doc = approvalMapper.selectVacationPrint(docVerId);
        if (doc == null) {
            throw new IllegalStateException("문서를 찾을 수 없습니다. docVerId=" + docVerId);
        }

        doc.setLines(approvalMapper.selectPrintLines(docVerId));

        return doc;
    }

    /* ==================================================
     * 결재 처리 (승인/반려)  ✅ 서명 저장 포함
     * ================================================== */
    @Transactional
    public void processDecision(Long loginUserId, Long docVerId, String action, String comment) {

        if (loginUserId == null) throw new IllegalArgumentException("loginUserId is required");
        if (docVerId == null) throw new IllegalArgumentException("docVerId is required");
        if (action == null || action.isBlank()) throw new IllegalArgumentException("action is required");

        Long lineId = approvalMapper.selectCurrentPendingLineId(docVerId);
        if (lineId == null) {
            throw new IllegalStateException("처리할 결재 라인이 없습니다. docVerId=" + docVerId);
        }

        // ✅ 현재 결재자 대표서명(file_id) 조회 → approval_lines.signature_file_id로 저장
        Long signatureFileId = null;
        SignatureDTO sign = signatureMapper.selectPrimaryByUserId(loginUserId);
        if (sign != null) signatureFileId = sign.getFileId();

        if ("APPROVE".equalsIgnoreCase(action)) {

            approvalMapper.updateLineStatusByLineId(
                lineId,
                "ALS003",
                comment,
                signatureFileId,
                loginUserId
            );

            int moved = approvalMapper.updateNextLineToPending(docVerId, "ALS002", loginUserId);

            if (moved == 0) {
                approvalMapper.updateDocumentStatusByDocVerId(docVerId, "AS003", loginUserId);
                approvalMapper.updateVersionStatusByDocVerId(docVerId, "AVS003", loginUserId);
            }

        } else if ("REJECT".equalsIgnoreCase(action)) {

            approvalMapper.updateLineStatusByLineId(
                lineId,
                "ALS004",
                comment,
                signatureFileId,
                loginUserId
            );

            approvalMapper.updateDocumentStatusByDocVerId(docVerId, "AS004", loginUserId);
            approvalMapper.updateVersionStatusByDocVerId(docVerId, "AVS004", loginUserId);

        } else {
            throw new IllegalArgumentException("invalid action: " + action);
        }
    }
    
    public ApprovalDetailPageDTO getDetailPage(Long userId, Long docVerId) {

        ApprovalDocDetailDTO doc = approvalMapper.selectDocDetail(docVerId);
        List<ApprovalLineViewDTO> lines = approvalMapper.selectLinesForDetail(docVerId);

        ApprovalDetailPageDTO page = new ApprovalDetailPageDTO();
        page.setDoc(doc);
        page.setLines(lines);

        boolean isDrafter = (doc != null && doc.getDrafterUserId() != null && doc.getDrafterUserId().equals(userId));
        boolean canRecall = approvalMapper.canRecallDoc(docVerId, userId) > 0;

        // 수정 가능 정책(예시): 기안자 + 임시저장(AS001) 또는 회수(AS005)일 때
        boolean canEdit = false;
        if (doc != null && isDrafter) {
            String st = doc.getDocStatusCode();
            canEdit = "AS001".equals(st) || "AS004".equals(st) || "AS005".equals(st);
        }

        page.setCanRecall(canRecall);
        page.setCanEdit(canEdit);

        return page;
    }

    
    @Transactional
    public void handleDecision(Long docVerId, Long userId, String action, String comment) {

        // ✅ 대표서명(file_id) 조회
        Long signatureFileId = null;
        SignatureDTO sign = signatureMapper.selectPrimaryByUserId(userId);
        if (sign != null) signatureFileId = sign.getFileId();

        int updated = 0;

        if ("APPROVE".equals(action)) {
            // ✅ 4파라미터 호출로 변경
            updated = approvalMapper.approveMyTurn(docVerId, userId, comment, signatureFileId);

            if (updated == 0) throw new IllegalStateException("결재 차례가 아니거나 이미 처리된 문서입니다.");

            approvalMapper.activateNextApprover(docVerId);

            int waiting = approvalMapper.existsWaitingLine(docVerId);
            if (waiting > 0) {
                approvalMapper.updateDocStatusByDocVerId(docVerId, "AS002");
            } else {
                approvalMapper.updateDocStatusByDocVerId(docVerId, "AS003");

                // ✅ 버전 상태도 완료로 맞추는 게 정합성 좋음
                approvalMapper.updateVersionStatusByDocVerId(docVerId, "AVS003", userId);

                // ✅ 최종 승인 시에만 휴가 일정 생성
                createLeaveCalendarEvent(docVerId, userId);
            }


        } else if ("REJECT".equals(action)) {
            // ✅ 4파라미터 호출로 변경
            updated = approvalMapper.rejectMyTurn(docVerId, userId, comment, signatureFileId);

            if (updated == 0) throw new IllegalStateException("결재 차례가 아니거나 이미 처리된 문서입니다.");

            approvalMapper.updateDocStatusByDocVerId(docVerId, "AS004");

        } else {
            throw new IllegalArgumentException("지원하지 않는 action 입니다: " + action);
        }
    }
    private void createLeaveCalendarEvent(Long docVerId, Long actorUserId) {

        VacationPrintDTO doc = approvalMapper.selectVacationPrint(docVerId);
        if (doc == null) throw new IllegalStateException("휴가 문서를 찾을 수 없습니다. docVerId=" + docVerId);

        // ✅ owner는 기안자
        Long ownerUserId = doc.getDrafterUserId();
        if (ownerUserId == null) throw new IllegalStateException("기안자 정보가 없습니다. docVerId=" + docVerId);

        // ✅ 조직정보 보강 (department_code, branch_id)
        Map<String, Object> org = approvalMapper.selectUserOrg(ownerUserId);
        String departmentCode = org == null ? null : (String) org.get("departmentCode");
        Long branchId = null;
        if (org != null && org.get("branchId") != null) {
            branchId = ((Number) org.get("branchId")).longValue();
        }

        // ✅ 휴가 시작/종료: (날짜형이면) 종일 일정으로 00:00~23:59:59
        // selectVacationPrint에서 ext_dt1/ext_dt2를 그대로 들고 있다고 가정
        LocalDate startDate = doc.getLeaveStartDate();
        LocalDate endDate   = doc.getLeaveEndDate();


        LocalDateTime startAt = startDate.atStartOfDay();
        LocalDateTime endAt   = endDate.atTime(23, 59, 59);

        String title = buildLeaveTitle(doc); // 아래 헬퍼 참고
        String description = buildLeaveDescription(doc, docVerId);

        CalendarEventDto event = CalendarEventDto.builder()
        	.scope(ScheduleType.PERSONAL)
            .title(title)
            .description(description)
            .startAt(startAt)
            .endAt(endAt)
            .location(null)
            .statusCode(ScheduleStatus.SCHEDULED)   // ✅ 너희 배치(updatePastEventsToCompleted)가 SCHEDULED 기준이라 이게 가장 자연스러움
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
    private String buildLeaveTitle(VacationPrintDTO doc) {
        String t = doc.getLeaveType();
        if (t == null || t.isBlank()) return "휴가";
        return "휴가(" + t + ")";
    }

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
