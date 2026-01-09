package com.health.app.approval;

import java.util.List;
import lombok.Data;

@Data
public class ApprovalDetailPageDTO {
    private ApprovalDocDetailDTO doc;
    private List<ApprovalLineViewDTO> lines;

    private boolean canRecall; // 기안자 + 결재중 + 1차 대기
    private boolean canEdit;   // 기안자 + 임시/회수 상태(또는 정책에 맞게)
}
