package com.health.app.inbound;

import com.health.app.security.model.LoginUser;
import lombok.RequiredArgsConstructor;
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

    @GetMapping("/new")
    public String newForm(Model model) {
        model.addAttribute("products", inboundRequestService.getProductOptions());
        model.addAttribute("form", new InboundRequestFormDto());
        model.addAttribute("pageTitle", "재고 현황");
        return "inbound/new";
    }

    @PostMapping
    public String create(@AuthenticationPrincipal LoginUser loginUser,
                         @ModelAttribute InboundRequestFormDto form,
                         RedirectAttributes ra) {

        Long userId = (loginUser != null ? loginUser.getUserId() : 1L);
        Long requestBranchId = (loginUser != null ? loginUser.getBranchId() : 1L);

        try {
            Long docVerId = inboundRequestService.createInboundRequestAndDraft(userId, requestBranchId, form);

            ra.addFlashAttribute("message", "구매요청서가 등록되었습니다. 결재선을 지정해주세요.");
            return "redirect:/approval/line?docVerId=" + docVerId;

        } catch (Exception e) {
            ra.addFlashAttribute("error", e.getMessage());
            return "redirect:/inbound/new";
        }
    }

    @GetMapping
    public String list(@RequestParam(required = false) String statusCode,
                       Model model) {

        List<InboundRequestListDto> list = inboundRequestService.getInboundRequestList(statusCode);
        model.addAttribute("list", list);
        model.addAttribute("statusCode", statusCode);
        model.addAttribute("pageTitle", "재고 현황");
        return "inbound/list";
    }

    @GetMapping("/detail")
    public String detail(@RequestParam Long inboundRequestId, Model model) {
        InboundRequestDetailDto header = inboundRequestService.getInboundRequestDetail(inboundRequestId);
        List<InboundRequestItemDto> items = inboundRequestService.getInboundRequestItems(inboundRequestId);
        model.addAttribute("pageTitle", "재고 현황");
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
