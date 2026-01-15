package com.health.app.inventory;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
@RequiredArgsConstructor
public class InventoryController {

    private final InventoryService inventoryService;

    // 목록
    @GetMapping("/inventory")
    public String inventoryList(
            @RequestParam(required = false) Long branchId,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Boolean onlyLowStock,
            Model model
    ) {
        List<OptionDto> branches = inventoryService.getBranchOptions();
        List<InventoryViewDto> list = inventoryService.getInventoryList(branchId, keyword, onlyLowStock);

        model.addAttribute("branches", branches);
        model.addAttribute("list", list);

        model.addAttribute("branchId", branchId);
        model.addAttribute("keyword", keyword);
        model.addAttribute("onlyLowStock", onlyLowStock);

        return "inventory/list";
    }

    // 상세 + 이력
    @GetMapping("/inventory/detail")
    public String inventoryDetail(
            @RequestParam Long branchId,
            @RequestParam Long productId,
            Model model
    ) {
        InventoryDetailDto detail = inventoryService.getInventoryDetail(branchId, productId);
        List<InventoryHistoryViewDto> history = inventoryService.getInventoryHistory(branchId, productId);

        model.addAttribute("detail", detail);
        model.addAttribute("history", history);

        return "inventory/detail";
    }

    // 재고 조정(입고/출고/조정)
    @PostMapping("/inventory/adjust")
    public String adjustInventory(
            @RequestParam Long branchId,
            @RequestParam Long productId,
            @RequestParam String moveTypeCode,
            @RequestParam Long quantity,
            @RequestParam String reason,
            RedirectAttributes redirectAttributes
    ) {
        try {
            Long userId = 1L; // TODO: 로그인 사용자 ID 연동 시 교체
            inventoryService.adjustInventory(branchId, productId, moveTypeCode, quantity, reason, userId);
            redirectAttributes.addFlashAttribute("adjustSuccess", "재고가 반영되었습니다.");
        } catch (IllegalArgumentException ex) {
            redirectAttributes.addFlashAttribute("adjustError", ex.getMessage());
        }

        return "redirect:/inventory/detail?branchId=" + branchId + "&productId=" + productId;
    }

    // 기준 수량 저장
    @PostMapping("/inventory/threshold")
    public String updateThreshold(
            @RequestParam Long branchId,
            @RequestParam Long productId,
            @RequestParam(required = false) Long lowStockThreshold,
            RedirectAttributes redirectAttributes
    ) {
        try {
            Long userId = 1L; // TODO 로그인 연동 시 교체
            inventoryService.updateLowStockThreshold(branchId, productId, lowStockThreshold, userId);
            redirectAttributes.addFlashAttribute("thresholdSuccess", "기준 수량이 저장되었습니다.");
        } catch (IllegalArgumentException ex) {
            redirectAttributes.addFlashAttribute("thresholdError", ex.getMessage());
        }

        return "redirect:/inventory/detail?branchId=" + branchId + "&productId=" + productId;
    }
}
