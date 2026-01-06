package com.health.app.inbound;

import com.health.app.approval.ApprovalDraftDTO;
import com.health.app.approval.ApprovalService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class InboundRequestService {

    private final InboundRequestMapper inboundRequestMapper;
    private final ApprovalService approvalService;

    /**
     * 본사(중앙) 입고로 고정.
     * - 본사를 branch 테이블에 등록해두고 그 ID를 쓰는 게 정석
     */
    private static final Long HQ_BRANCH_ID = 1L;

    // ======================
    // 옵션
    // ======================
    @Transactional(readOnly = true)
    public List<InboundOptionDto> getProductOptions() {
        return inboundRequestMapper.selectProductOptions();
    }

    // ======================
    // 등록 + 결재 Draft 생성
    // ======================
    @Transactional
    public Long createInboundRequestAndDraft(Long loginUserId, InboundRequestFormDto form) {

        validateForm(form);

        // 1) inbound_request_header 저장
        InboundRequestHeaderDto header = new InboundRequestHeaderDto();
        header.setInboundRequestNo("IR-" + System.currentTimeMillis());
        header.setVendorName(form.getVendorName());
        header.setStatusCode("IR_REQ"); // 요청 상태(임의 코드, 프로젝트 공통코드에 맞춰 변경 가능)
        header.setRequestedBy(loginUserId);
        header.setTitle(form.getTitle());
        header.setMemo(form.getMemo());
        header.setCreateUser(loginUserId);
        header.setUpdateUser(loginUserId);
        header.setUseYn(1);

        inboundRequestMapper.insertInboundHeader(header);
        Long inboundRequestId = header.getInboundRequestId();

        // 2) inbound_request_detail 저장(다품목)
        for (InboundRequestItemDto item : form.getItems()) {
            item.setInboundRequestId(inboundRequestId);
            item.setCreateUser(loginUserId);
            item.setUpdateUser(loginUserId);
            item.setUseYn(1);
            inboundRequestMapper.insertInboundDetail(item);
        }

        // 3) 전자결재 Draft 자동 생성
        // - 전자결재 쪽에서 "구매요청서" 타입/폼 코드가 정해져 있을 거라 AT005는 필요에 맞게 바꾸면 됨.
        ApprovalDraftDTO draft = new ApprovalDraftDTO();
        draft.setTypeCode("AT005");
        draft.setFormCode("AT005"); // form_code NOT NULL 대응 (시스템에 맞게 변경)
        draft.setTitle(safe(form.getTitle()));
        draft.setBody(buildBody(form));

        // 너가 보여준 폼처럼 ext 텍스트 칸을 활용한다는 전제
        // extTxt1: 공급처
        // extTxt6: 품목 JSON(문자열)
        draft.setExtTxt1(safe(form.getVendorName()));
        draft.setExtTxt6(form.buildItemsJsonLikeText());

        ApprovalDraftDTO saved = approvalService.saveDraft(loginUserId, draft);

        // 4) inbound_request_header에 결재 문서 link 저장
        inboundRequestMapper.updateApprovalLink(
                inboundRequestId,
                saved.getDocId(),
                saved.getDocVerId(),
                "INBOUND_REQUEST",
                inboundRequestId,
                loginUserId
        );

        return saved.getDocVerId();
    }

    // ======================
    // 조회
    // ======================
    @Transactional(readOnly = true)
    public List<InboundRequestListDto> getInboundRequestList(String statusCode) {
        return inboundRequestMapper.selectInboundList(statusCode);
    }

    @Transactional(readOnly = true)
    public InboundRequestDetailDto getInboundRequestDetail(Long inboundRequestId) {
        return inboundRequestMapper.selectInboundHeader(inboundRequestId);
    }

    @Transactional(readOnly = true)
    public List<InboundRequestItemDto> getInboundRequestItems(Long inboundRequestId) {
        return inboundRequestMapper.selectInboundItems(inboundRequestId);
    }

    // ======================
    // 승인완료 → 재고 반영
    // ======================
    @Transactional
    public void applyApprovedInboundToInventory(Long inboundRequestId, Long approvedBy) {

        InboundRequestDetailDto header = inboundRequestMapper.selectInboundHeader(inboundRequestId);
        if (header == null) {
            throw new IllegalArgumentException("입고요청서가 존재하지 않습니다. inboundRequestId=" + inboundRequestId);
        }

        List<InboundRequestItemDto> items = inboundRequestMapper.selectInboundItems(inboundRequestId);
        if (items == null || items.isEmpty()) {
            throw new IllegalStateException("입고요청 품목이 없습니다.");
        }

        // 재고 반영(본사 고정)
        for (InboundRequestItemDto it : items) {
            inboundRequestMapper.upsertInventoryIncrease(HQ_BRANCH_ID, it.getProductId(), it.getQuantity(), approvedBy);

            inboundRequestMapper.insertInventoryHistoryIn(
                    HQ_BRANCH_ID,
                    it.getProductId(),
                    it.getQuantity(),
                    "INBOUND_APPROVED",
                    approvedBy,
                    "INBOUND_REQUEST",
                    inboundRequestId
            );
        }

        // inbound_request 상태 승인처리
        inboundRequestMapper.updateStatusApproved(inboundRequestId, approvedBy);
    }

    // ======================
    // 내부 유틸
    // ======================
    private void validateForm(InboundRequestFormDto form) {
        if (form == null) throw new IllegalArgumentException("요청 데이터가 없습니다.");
        if (isBlank(form.getVendorName())) throw new IllegalArgumentException("공급처(vendor_name)는 필수입니다.");
        if (isBlank(form.getTitle())) throw new IllegalArgumentException("문서 제목(title)은 필수입니다.");

        if (form.getItems() == null || form.getItems().isEmpty()) {
            throw new IllegalArgumentException("구매요청 품목이 1개 이상 필요합니다.");
        }

        for (InboundRequestItemDto it : form.getItems()) {
            if (it.getProductId() == null) throw new IllegalArgumentException("상품(product_id)은 필수입니다.");
            if (it.getQuantity() == null || it.getQuantity() <= 0) throw new IllegalArgumentException("요청 수량(quantity)은 1 이상이어야 합니다.");
            if (it.getUnitPrice() != null && it.getUnitPrice() < 0) throw new IllegalArgumentException("단가(unit_price)는 0 이상이어야 합니다.");
        }
    }

    private String buildBody(InboundRequestFormDto form) {
        StringBuilder sb = new StringBuilder();
        sb.append("공급처: ").append(safe(form.getVendorName())).append("\n\n");
        sb.append("요청 품목:\n");

        for (InboundRequestItemDto it : form.getItems()) {
            sb.append("- productId=").append(it.getProductId())
                    .append(", qty=").append(it.getQuantity());
            if (it.getUnitPrice() != null) sb.append(", unitPrice=").append(it.getUnitPrice());
            if (!isBlank(it.getLineMemo())) sb.append(", memo=").append(it.getLineMemo());
            sb.append("\n");
        }

        if (!isBlank(form.getMemo())) {
            sb.append("\n비고:\n").append(form.getMemo());
        }

        return sb.toString();
    }

    private static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private static String safe(String s) {
        return (s == null ? "" : s);
    }
}
