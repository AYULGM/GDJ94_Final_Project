package com.health.app.inventory;

import com.health.app.security.model.LoginUser;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
@RequiredArgsConstructor
public class InventoryController {

    private final InventoryService inventoryService;

    /**
     * 본사(전체조회/수정) 권한 판단
     * - 네 프로젝트에서 실제 ROLE 문자열이 다르면 여기만 바꾸면 됨
     */
    private boolean isHeadOffice(Authentication auth) {
        if (auth == null || auth.getAuthorities() == null) return false;

        for (GrantedAuthority ga : auth.getAuthorities()) {
            String role = ga.getAuthority();
            if ("ROLE_MASTER".equals(role)
                    || "ROLE_ADMIN".equals(role)
                    || "ROLE_captain".equals(role)) {
                return true;
            }
        }
        return false;
    }

    private LoginUser requireLoginUser(Authentication auth) {
        if (auth == null || auth.getPrincipal() == null) {
            throw new SecurityException("인증 정보가 없습니다.");
        }
        if (!(auth.getPrincipal() instanceof LoginUser)) {
            throw new SecurityException("Principal 타입이 LoginUser가 아닙니다.");
        }
        return (LoginUser) auth.getPrincipal();
    }

    // =========================
    // 1) 재고 목록
    // =========================
    @GetMapping("/inventory")
    public String inventoryList(
            @RequestParam(required = false) Long branchId,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Boolean onlyLowStock,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "20") Integer size,
            Authentication authentication,
            Model model
    ) {
        LoginUser loginUser = requireLoginUser(authentication);

        boolean canViewAllBranches = isHeadOffice(authentication);
        boolean canEditInventory = canViewAllBranches;

        //  branchId 최종 결정값을 별도로 둬서 "람다 final" 문제 원천 차단
        Long resolvedBranchId = branchId;

        // 지점 사용자는 본인 지점으로 강제
        if (!canViewAllBranches) {
            if (loginUser.getBranchId() == null) {
                throw new SecurityException("지점 정보(branchId)가 없는 사용자입니다.");
            }
            resolvedBranchId = loginUser.getBranchId();
        }

        final Long branchIdFinal = resolvedBranchId;

        // 지점 옵션
        List<OptionDto> branches = inventoryService.getBranchOptions();

        // 지점 사용자는 드롭다운에 본인 지점만 남김
        if (!canViewAllBranches) {
            branches.removeIf(b -> b.getId() == null || !b.getId().equals(branchIdFinal));
        }

        // 페이징 값 보정
        if (page == null || page < 1) page = 1;
        if (size == null || size < 1) size = 20;
        if (size > 200) size = 200;

        long totalCount = inventoryService.getInventoryListCount(resolvedBranchId, keyword, onlyLowStock);
        List<InventoryViewDto> list = inventoryService.getInventoryList(resolvedBranchId, keyword, onlyLowStock, page, size);

        int totalPages = (int) Math.ceil(totalCount / (double) size);

        model.addAttribute("branches", branches);
        model.addAttribute("list", list);

        model.addAttribute("branchId", resolvedBranchId);
        model.addAttribute("keyword", keyword);
        model.addAttribute("onlyLowStock", onlyLowStock);

        model.addAttribute("page", page);
        model.addAttribute("size", size);
        model.addAttribute("totalCount", totalCount);
        model.addAttribute("totalPages", totalPages);

        model.addAttribute("branchLocked", !canViewAllBranches);
        model.addAttribute("canEditInventory", canEditInventory);

        return "inventory/list";
    }

    // =========================
    // 2) 재고 상세
    // =========================
    @GetMapping("/inventory/detail")
    public String inventoryDetail(
            @RequestParam Long branchId,
            @RequestParam Long productId,
            Authentication authentication,
            Model model
    ) {
        LoginUser loginUser = requireLoginUser(authentication);

        boolean canViewAllBranches = isHeadOffice(authentication);
        boolean canEditInventory = canViewAllBranches;

        // 지점 사용자는 본인 지점만 접근
        if (!canViewAllBranches) {
            if (loginUser.getBranchId() == null) {
                throw new SecurityException("지점 정보(branchId)가 없는 사용자입니다.");
            }
            if (!loginUser.getBranchId().equals(branchId)) {
                throw new SecurityException("본인 지점이 아닌 재고에는 접근할 수 없습니다.");
            }
        }

        InventoryDetailDto detail = inventoryService.getInventoryDetail(branchId, productId);
        List<InventoryHistoryViewDto> history = inventoryService.getInventoryHistory(branchId, productId);

        model.addAttribute("detail", detail);
        model.addAttribute("history", history);
        model.addAttribute("canEditInventory", canEditInventory);

        return "inventory/detail";
    }

    // =========================
    // 3) 재고 조정 (본사만)
    // =========================
    @PostMapping("/inventory/adjust")
    public String adjustInventory(
            @RequestParam Long branchId,
            @RequestParam Long productId,
            @RequestParam String moveTypeCode,
            @RequestParam Long quantity,
            @RequestParam String reason,
            Authentication authentication,
            RedirectAttributes ra
    ) {
        LoginUser loginUser = requireLoginUser(authentication);

        if (!isHeadOffice(authentication)) {
            throw new SecurityException("지점 사용자는 재고를 조정할 수 없습니다.(READONLY)");
        }

        try {
            inventoryService.adjustInventory(branchId, productId, moveTypeCode, quantity, reason, loginUser.getUserId());
            ra.addFlashAttribute("adjustSuccess", "재고가 반영되었습니다.");
        } catch (IllegalArgumentException ex) {
            ra.addFlashAttribute("adjustError", ex.getMessage());
        }

        return "redirect:/inventory/detail?branchId=" + branchId + "&productId=" + productId;
    }

    // =========================
    // 4) 기준수량 변경 (본사만)
    // =========================
    @PostMapping("/inventory/threshold")
    public String updateThreshold(
            @RequestParam Long branchId,
            @RequestParam Long productId,
            @RequestParam(required = false) Long lowStockThreshold,
            Authentication authentication,
            RedirectAttributes ra
    ) {
        LoginUser loginUser = requireLoginUser(authentication);

        if (!isHeadOffice(authentication)) {
            throw new SecurityException("지점 사용자는 기준 수량을 수정할 수 없습니다.(READONLY)");
        }

        try {
            inventoryService.updateLowStockThreshold(branchId, productId, lowStockThreshold, loginUser.getUserId());
            ra.addFlashAttribute("thresholdSuccess", "기준 수량이 저장되었습니다.");
        } catch (IllegalArgumentException ex) {
            ra.addFlashAttribute("thresholdError", ex.getMessage());
        }

        return "redirect:/inventory/detail?branchId=" + branchId + "&productId=" + productId;
    }
}
