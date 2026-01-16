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
        // 페이지 타이틀(헤더/브레드크럼)
        model.addAttribute("pageTitle", "감사 로그");

        // 드롭다운 옵션
        model.addAttribute("branches", inventoryService.getBranchOptions());
        model.addAttribute("products", inventoryService.getProductOptions(branchId));

        List<AuditLogDto> logs = inventoryService.getAuditLogs(from, to, actionType, branchId, productId, keyword);

        model.addAttribute("logs", logs);

        // 검색값 유지
        model.addAttribute("from", from);
        model.addAttribute("to", to);
        model.addAttribute("actionType", actionType);
        model.addAttribute("branchId", branchId);
        model.addAttribute("productId", productId);
        model.addAttribute("keyword", keyword);

        return "audit/list";
    }
}
