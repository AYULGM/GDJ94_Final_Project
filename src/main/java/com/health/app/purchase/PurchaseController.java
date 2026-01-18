package com.health.app.purchase;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
@RequestMapping("/purchase")
@RequiredArgsConstructor
public class PurchaseController {

    private final PurchaseService purchaseService;

    /** 발주 요청 화면 */
    @GetMapping("/new")
    public String newPurchaseForm(Model model) {
        List<PurchaseOptionDto> branches = purchaseService.getBranchOptions();
        List<PurchaseOptionDto> products = purchaseService.getProductOptions();

        model.addAttribute("branches", branches);
        model.addAttribute("products", products);
        model.addAttribute("pageTitle", "발주서 작성");

        return "purchase/new";
    }

    /** 발주 요청 등록 */
    @PostMapping
    public String createPurchase(@ModelAttribute PurchaseRequestDto dto,
                                 RedirectAttributes redirectAttributes) {

        Long userId = 1L; // TODO 로그인 연동 시 교체

        try {
            Long purchaseId = purchaseService.createPurchase(dto, userId);
            redirectAttributes.addFlashAttribute("message", "발주 요청이 등록되었습니다. (ID=" + purchaseId + ")");
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        }

        return "redirect:/purchase/new";
    }

    /** 발주 목록 조회 */
    @GetMapping
    public String purchaseList(@RequestParam(required = false) Long branchId,
                               @RequestParam(required = false) String statusCode,
                               @RequestParam(required = false) String keyword,
                               Model model) {

        model.addAttribute("branches", purchaseService.getBranchOptions());
        model.addAttribute("list", purchaseService.getPurchaseList(branchId, statusCode, keyword));
        model.addAttribute("pageTitle", "발주서 목록");

        model.addAttribute("branchId", branchId);
        model.addAttribute("statusCode", statusCode);
        model.addAttribute("keyword", keyword);

        return "purchase/list";
    }

    /** 발주 상세 */
    @GetMapping("/{purchaseId}")
    public String purchaseDetail(@PathVariable Long purchaseId, Model model) {
        PurchaseDetailDto detail = purchaseService.getPurchaseDetail(purchaseId);
        if (detail == null) {
            model.addAttribute("error", "발주 정보를 찾을 수 없습니다.");
            return "purchase/detail";
        }
        model.addAttribute("detail", detail);
        model.addAttribute("pageTitle", "발주서 상세");
        return "purchase/detail";
    }

    /** 발주 승인(=결재 완료만) */
    @PostMapping("/{purchaseId}/approve")
    public String approve(@PathVariable Long purchaseId, RedirectAttributes redirectAttributes) {
        Long userId = 1L; // TODO 로그인 연동 시 교체
        try {
            purchaseService.approvePurchase(purchaseId, userId);
            redirectAttributes.addFlashAttribute("message", "발주 결재 승인 완료");
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/purchase/" + purchaseId;
    }

    /** 입고 처리(=재고 반영) */
    @PostMapping("/{purchaseId}/fulfill")
    public String fulfill(@PathVariable Long purchaseId, RedirectAttributes redirectAttributes) {
        Long userId = 1L; // TODO 로그인 연동 시 교체
        try {
            purchaseService.fulfillPurchase(purchaseId, userId);
            redirectAttributes.addFlashAttribute("message", "입고 처리 완료 (재고 반영)");
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/purchase/" + purchaseId;
    }

    /** 발주 반려 */
    @PostMapping("/{purchaseId}/reject")
    public String reject(@PathVariable Long purchaseId,
                         @RequestParam String rejectReason,
                         RedirectAttributes redirectAttributes) {

        Long userId = 1L; // TODO 로그인 연동 시 교체
        try {
            purchaseService.rejectPurchase(purchaseId, rejectReason, userId);
            redirectAttributes.addFlashAttribute("message", "발주 반려 처리 완료");
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/purchase/" + purchaseId;
    }
}
