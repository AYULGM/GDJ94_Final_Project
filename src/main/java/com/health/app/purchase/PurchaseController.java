package com.health.app.purchase;

import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
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

    /** 발주 요청 화면 (본사만) */
    @GetMapping("/new")
    @PreAuthorize("hasAnyRole('GRANDMASTER','MASTER','ADMIN')")
    public String newPurchaseForm(Model model) {
        List<PurchaseOptionDto> branches = purchaseService.getBranchOptions();
        List<PurchaseOptionDto> products = purchaseService.getProductOptions();

        model.addAttribute("branches", branches);
        model.addAttribute("products", products);
        model.addAttribute("pageTitle", "발주서 작성");

        return "purchase/new";
    }

    /** 발주 요청 등록 (본사만) */
    @PostMapping
    @PreAuthorize("hasAnyRole('GRANDMASTER','MASTER','ADMIN')")
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

    /**
     * ✅ 발주서(PO) 목록
     * - 본사 + 지점 공통 조회
     * - 기존 에러 원인: /purchase/{purchaseId} 가 orders 문자열을 잡아먹음
     *   => /purchase/orders 고정 경로로 분리 + 상세는 숫자만(\d+) 매칭
     */
    @GetMapping("/orders")
    @PreAuthorize("hasAnyRole('GRANDMASTER','MASTER','ADMIN','CAPTAIN','CREW')")
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

    /** /purchase 루트 진입 시 목록으로 정리 (본사/지점 공통) */
    @GetMapping
    @PreAuthorize("hasAnyRole('GRANDMASTER','MASTER','ADMIN','CAPTAIN','CREW')")
    public String purchaseRootRedirect() {
        return "redirect:/purchase/orders";
    }

    /** 발주 상세 (본사/지점 공통) - 숫자만 매칭 */
    @GetMapping("/{purchaseId:\\d+}")
    @PreAuthorize("hasAnyRole('GRANDMASTER','MASTER','ADMIN','CAPTAIN','CREW')")
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

    /** 발주 승인(=결재 완료만) (본사만) */
    @PostMapping("/{purchaseId:\\d+}/approve")
    @PreAuthorize("hasAnyRole('GRANDMASTER','MASTER','ADMIN')")
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

    /** 입고 처리(=재고 반영) (본사만) */
    @PostMapping("/{purchaseId:\\d+}/fulfill")
    @PreAuthorize("hasAnyRole('GRANDMASTER','MASTER','ADMIN')")
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

    /** 발주 반려 (본사만) */
    @PostMapping("/{purchaseId:\\d+}/reject")
    @PreAuthorize("hasAnyRole('GRANDMASTER','MASTER','ADMIN')")
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
