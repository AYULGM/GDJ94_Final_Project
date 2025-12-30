package com.health.app.inventory;

import com.health.app.inventory.dto.InventoryDetailDto;
import com.health.app.inventory.dto.InventoryHistoryViewDto;
import com.health.app.inventory.dto.InventoryViewDto;
import com.health.app.inventory.dto.OptionDto;
import com.health.app.inventory.service.InventoryService;
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
            // TODO: 로그인 사용자 ID 연동 시 교체
            Long userId = 1L;
            inventoryService.adjustInventory(branchId, productId, moveTypeCode, quantity, reason, userId);
        } catch (IllegalArgumentException ex) {
            redirectAttributes.addFlashAttribute("error", ex.getMessage());
        }

        return "redirect:/inventory/detail?branchId=" + branchId + "&productId=" + productId;
    }
}
