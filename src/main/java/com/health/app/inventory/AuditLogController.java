package com.health.app.inventory;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Controller
@RequiredArgsConstructor
public class AuditLogController {

    private final InventoryService inventoryService;

    /**
     * 감사로그 조회
     * GET /audit?from=YYYY-MM-DD&to=YYYY-MM-DD&actionType=...&branchId=...&productId=...&keyword=...
     */
    @GetMapping("/audit")
    public String auditList(
            @RequestParam(required = false) String from,        // YYYY-MM-DD
            @RequestParam(required = false) String to,          // YYYY-MM-DD
            @RequestParam(required = false) String actionType,  // THRESHOLD_UPDATE / INVENTORY_ADJUST
            @RequestParam(required = false) Long branchId,
            @RequestParam(required = false) Long productId,
            @RequestParam(required = false) String keyword,
            Model model
    ) {
        // null -> 0 처리(Mapper에서 0이면 필터 제외하도록 해둔 경우 안전)
        if (branchId == null) branchId = 0L;
        if (productId == null) productId = 0L;

        List<AuditLogDto> logs = inventoryService.getAuditLogs(
                from, to, actionType, branchId, productId, keyword
        );

        model.addAttribute("logs", logs);

        // 검색값 유지
        model.addAttribute("from", from);
        model.addAttribute("to", to);
        model.addAttribute("actionType", actionType);
        model.addAttribute("branchId", branchId == 0L ? null : branchId);
        model.addAttribute("productId", productId == 0L ? null : productId);
        model.addAttribute("keyword", keyword);

        return "audit/list";
    }
}
