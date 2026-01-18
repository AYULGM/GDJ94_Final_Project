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

    // NOTE
    // - 구매요청서(PR)는 "지점 -> 본사" 요청 문서
    // - 최종 승인 완료 후에는, 요청 지점(request_branch_id)의 재고가 증가해야 함

    @Transactional(readOnly = true)
    public List<InboundOptionDto> getProductOptions() {
        return inboundRequestMapper.selectProductOptions();
    }

    @Transactional
    public Long createInboundRequestAndDraft(Long loginUserId, Long requestBranchId, InboundRequestFormDto form) {

        validateForm(form, requestBranchId);

        InboundRequestHeaderDto header = new InboundRequestHeaderDto();
        header.setInboundRequestNo("IR-" + System.currentTimeMillis());
        header.setRequestBranchId(requestBranchId);
        header.setVendorName(form.getVendorName());
        header.setStatusCode("IR_REQ");
        header.setRequestedBy(loginUserId);
        header.setTitle(form.getTitle());
        header.setMemo(form.getMemo());
        header.setCreateUser(loginUserId);
        header.setUpdateUser(loginUserId);
        header.setUseYn(1);

        inboundRequestMapper.insertInboundHeader(header);
        Long inboundRequestId = header.getInboundRequestId();

        for (InboundRequestItemDto item : form.getItems()) {
            item.setInboundRequestId(inboundRequestId);
            item.setCreateUser(loginUserId);
            item.setUpdateUser(loginUserId);
            item.setUseYn(1);
            inboundRequestMapper.insertInboundDetail(item);
        }

        ApprovalDraftDTO draft = new ApprovalDraftDTO();
        draft.setTypeCode("AT005");
        draft.setFormCode("AT005");
        draft.setTitle(safe(form.getTitle()));
        draft.setBody(buildBody(form));
        draft.setExtTxt1(safe(form.getVendorName()));
        draft.setExtTxt6(form.buildItemsJsonLikeText());

        ApprovalDraftDTO saved = approvalService.saveDraft(loginUserId, draft);

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

    @Transactional
    public void applyApprovedInboundToInventory(Long inboundRequestId, Long approvedBy) {

        InboundRequestDetailDto header = inboundRequestMapper.selectInboundHeader(inboundRequestId);
        if (header == null) {
            throw new IllegalArgumentException("입고요청서가 존재하지 않습니다. inboundRequestId=" + inboundRequestId);
        }

        if (header.getRequestBranchId() == null || header.getRequestBranchId() <= 0) {
            throw new IllegalStateException("요청 지점(request_branch_id)이 비어있습니다. DB 컬럼/저장 로직을 확인하세요.");
        }

        if ("IR_DONE".equals(header.getStatusCode())) {
            throw new IllegalStateException("이미 처리 완료된 구매요청서입니다.");
        }

        // 승인 훅 미연결 대비: IR_REQ면 승인 처리 먼저(테스트/운영 겸용)
        if ("IR_REQ".equals(header.getStatusCode())) {
            inboundRequestMapper.updateStatusApproved(inboundRequestId, approvedBy);
            header = inboundRequestMapper.selectInboundHeader(inboundRequestId);
        }

        if (!"IR_APPROVED".equals(header.getStatusCode())) {
            throw new IllegalStateException("승인 완료(IR_APPROVED) 상태에서만 재고 반영이 가능합니다. 현재 상태=" + header.getStatusCode());
        }

        List<InboundRequestItemDto> items = inboundRequestMapper.selectInboundItems(inboundRequestId);
        if (items == null || items.isEmpty()) {
            throw new IllegalStateException("입고요청 품목이 없습니다.");
        }

        Long targetBranchId = header.getRequestBranchId();

        for (InboundRequestItemDto it : items) {
            inboundRequestMapper.upsertInventoryIncrease(targetBranchId, it.getProductId(), it.getQuantity(), approvedBy);

            inboundRequestMapper.insertInventoryHistoryIn(
                    targetBranchId,
                    it.getProductId(),
                    it.getQuantity(),
                    "INBOUND_APPROVED",
                    approvedBy,
                    "INBOUND_REQUEST",
                    inboundRequestId
            );
        }

        inboundRequestMapper.updateStatusDone(inboundRequestId, approvedBy);
    }

    private void validateForm(InboundRequestFormDto form, Long requestBranchId) {
        if (form == null) throw new IllegalArgumentException("요청 데이터가 없습니다.");
        if (requestBranchId == null || requestBranchId <= 0) {
            throw new IllegalArgumentException("요청 지점 정보가 없습니다. 로그인 유저의 branch_id를 확인하세요.");
        }
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
