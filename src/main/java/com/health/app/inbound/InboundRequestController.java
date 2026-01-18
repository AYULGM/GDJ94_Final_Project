package com.health.app.inbound;

import com.health.app.security.model.LoginUser;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
@RequiredArgsConstructor
@RequestMapping("/inbound")
public class InboundRequestController {

    private final InboundRequestService inboundRequestService;

    /** ✅ 작성 폼: 지점만 (본사 차단) */
    @GetMapping("/new")
    @PreAuthorize("hasAnyRole('CAPTAIN','CREW')") // ✅ 지점만 등록 가능(본사 차단)
    public String newForm(Model model) {
        model.addAttribute("products", inboundRequestService.getProductOptions());
        model.addAttribute("form", new InboundRequestFormDto());
        model.addAttribute("pageTitle", "입고요청서 작성");
        return "inbound/new";
    }

    /** ✅ 등록 처리: 지점만 (본사 차단) */
    @PostMapping
    @PreAuthorize("hasAnyRole('CAPTAIN','CREW')") // ✅ 지점만 등록 가능(본사 차단)
    public String create(@AuthenticationPrincipal LoginUser loginUser,
                         @ModelAttribute InboundRequestFormDto form,
                         RedirectAttributes ra) {

        Long userId = (loginUser != null ? loginUser.getUserId() : 1L);
        Long requestBranchId = (loginUser != null ? loginUser.getBranchId() : 1L);

        try {
            Long docVerId = inboundRequestService.createInboundRequestAndDraft(userId, requestBranchId, form);

            ra.addFlashAttribute("message", "입고요청서가 등록되었습니다. 결재선을 지정해주세요.");
            return "redirect:/approval/line?docVerId=" + docVerId;

        } catch (Exception e) {
            ra.addFlashAttribute("error", e.getMessage());
            return "redirect:/inbound/new";
        }
    }

    /** ✅ 목록: 지점은 자기 지점만, 본사는 전체 */
    @GetMapping
    public String list(@AuthenticationPrincipal LoginUser loginUser,
                       @RequestParam(required = false) String statusCode,
                       Model model) {

        Long requestBranchId = null;

        // 본사(ADMIN 이상)는 전체 조회, 그 외(지점)는 자기 지점만
        if (loginUser != null && !loginUser.isAdminOrHigher()) {
            requestBranchId = loginUser.getBranchId();
        }

        List<InboundRequestListDto> list = inboundRequestService.getInboundRequestList(statusCode, requestBranchId);

        model.addAttribute("list", list);
        model.addAttribute("statusCode", statusCode);
        model.addAttribute("pageTitle", "입고요청서 목록");

        return "inbound/list";
    }

    @GetMapping("/detail")
    public String detail(@RequestParam Long inboundRequestId, Model model) {
        InboundRequestDetailDto header = inboundRequestService.getInboundRequestDetail(inboundRequestId);
        List<InboundRequestItemDto> items = inboundRequestService.getInboundRequestItems(inboundRequestId);
        model.addAttribute("pageTitle", "입고요청서 상세");
        model.addAttribute("header", header);
        model.addAttribute("items", items);

        return "inbound/detail";
    }

    /**
     * (임시) 승인 완료(IR_APPROVED)된 구매요청서를 "처리완료"로 만들고,
     * 요청 지점 재고를 반영한다.
     */
    @PostMapping("/{inboundRequestId}/process")
    public String process(@PathVariable Long inboundRequestId,
                          @AuthenticationPrincipal LoginUser loginUser,
                          RedirectAttributes ra) {

        Long approvedBy = (loginUser != null ? loginUser.getUserId() : 1L);

        try {
            inboundRequestService.applyApprovedInboundToInventory(inboundRequestId, approvedBy);
            ra.addFlashAttribute("message", "재고 반영 및 처리 완료로 변경했습니다.");
        } catch (Exception e) {
            ra.addFlashAttribute("error", e.getMessage());
        }

        return "redirect:/inbound/detail?inboundRequestId=" + inboundRequestId;
    }
}
