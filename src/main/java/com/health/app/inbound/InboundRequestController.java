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

    /** 구매요청서(PR) 작성 폼 */
    @GetMapping("/new")
    public String newForm(Model model) {
        model.addAttribute("products", inboundRequestService.getProductOptions());
        model.addAttribute("form", new InboundRequestFormDto());
        return "inbound/new";
    }

    /** 구매요청서(PR) 등록 + 결재 Draft 생성 + 결재선 페이지로 이동 */
    @PostMapping
    public String create(@AuthenticationPrincipal LoginUser loginUser,
                         @ModelAttribute InboundRequestFormDto form,
                         RedirectAttributes ra) {

        Long userId = (loginUser != null ? loginUser.getUserId() : 1L); // TODO 로그인 연동되면 1L 제거

        try {
            Long docVerId = inboundRequestService.createInboundRequestAndDraft(userId, form);

            ra.addFlashAttribute("message", "구매요청서가 등록되었습니다. 결재선을 지정해주세요.");
            return "redirect:/approval/line?docVerId=" + docVerId;

        } catch (Exception e) {
            ra.addFlashAttribute("error", e.getMessage());
            return "redirect:/inbound/new";
        }
    }

    /** 목록 */
    @GetMapping
    public String list(@RequestParam(required = false) String statusCode,
                       Model model) {

        List<InboundRequestListDto> list = inboundRequestService.getInboundRequestList(statusCode);
        model.addAttribute("list", list);
        model.addAttribute("statusCode", statusCode);

        return "inbound/list";
    }

    /** 상세 */
    @GetMapping("/detail")
    public String detail(@RequestParam Long inboundRequestId, Model model) {
        InboundRequestDetailDto header = inboundRequestService.getInboundRequestDetail(inboundRequestId);
        List<InboundRequestItemDto> items = inboundRequestService.getInboundRequestItems(inboundRequestId);

        model.addAttribute("header", header);
        model.addAttribute("items", items);

        return "inbound/detail";
    }

    /**
     * 전자결재 최종 승인 완료 시점에 호출되도록 연결할 엔드포인트(임시)
     * - 전자결재 담당자가 승인완료 훅에서 호출하면, 재고 반영 + 이력 저장 + 상태 업데이트까지 처리함
     */
    @PostMapping("/apply")
    @ResponseBody
    public String applyApproved(@RequestParam Long inboundRequestId,
                                @RequestParam(required = false) Long approvedBy) {

        inboundRequestService.applyApprovedInboundToInventory(
                inboundRequestId,
                approvedBy != null ? approvedBy : 1L
        );
        return "OK";
    }
}
