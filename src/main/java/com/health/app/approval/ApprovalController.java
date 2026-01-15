package com.health.app.approval;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.health.app.security.model.LoginUser;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/approval")
@RequiredArgsConstructor
public class ApprovalController {

    private final ApprovalService approvalService;

    // 목록
    @GetMapping("list")
    public String approvalList(@AuthenticationPrincipal LoginUser loginUser, Model model) {
        model.addAttribute("list", approvalService.getMyDocs(loginUser.getUserId()));
        model.addAttribute("pageTitle", "전자결재");
        return "approval/list";
    }

    // 상세
    @GetMapping("detail")
    public String approvalDetail(@AuthenticationPrincipal LoginUser loginUser,
                                 @RequestParam("docVerId") Long docVerId,
                                 Model model) {
        ApprovalDetailPageDTO page = approvalService.getDetailPage(loginUser.getUserId(), docVerId);
        model.addAttribute("page", page);
        model.addAttribute("docVerId", docVerId);
        model.addAttribute("pageTitle", "전자결재");
        return "approval/detail";
    }

 // 작성/수정 폼
    @GetMapping("form")
    public String approvalForm(@AuthenticationPrincipal LoginUser loginUser,
                               @RequestParam(required = false) Long docVerId,
                               Model model) {

        model.addAttribute("branches", approvalService.getBranches());
        if (docVerId != null) {
            ApprovalDraftDTO draft = approvalService.getDraftForEdit(docVerId, loginUser.getUserId());
            model.addAttribute("draft", draft);
            model.addAttribute("mode", "edit");
            model.addAttribute("pageTitle", "전자수정");
            model.addAttribute("products",
                    draft.getBranchId() != null
                            ? approvalService.getProductsByBranch(draft.getBranchId())
                            : java.util.Collections.emptyList());
        } else {
            model.addAttribute("mode", "new");
            model.addAttribute("products", approvalService.getProductsByBranch(null)); // draft 사용 금지
            model.addAttribute("pageTitle", "전자작성");

        }
        model.addAttribute("handoverCandidates", approvalService.getHandoverCandidates(loginUser.getUserId()));
        return "approval/form";
    }


    // 서명 페이지
    @GetMapping("signature")
    public String approvalSignature(Model model) {
    	model.addAttribute("pageTitle", "서명창");
        return "approval/signature";
    }

    // 출력 페이지(일반)
    @GetMapping("print")
    public String approvalPrint() {
        return "approval/print";
    }

    // 결재함(Inbox)
    @GetMapping("inbox")
    public String inbox(@AuthenticationPrincipal LoginUser loginUser, Model model) {
        model.addAttribute("list", approvalService.getMyInbox(loginUser.getUserId()));
    	model.addAttribute("pageTitle", "결재함");
        return "approval/inbox";
    }

    // 임시저장/수정 저장
    @PostMapping("saveDraftForm")
    public String saveDraftForm(@AuthenticationPrincipal LoginUser loginUser,
                                @ModelAttribute ApprovalDraftDTO dto,
                                RedirectAttributes ra) {

        Long userId = loginUser.getUserId();

        if ("edit".equals(dto.getMode()) && dto.getDocVerId() != null) {
            approvalService.updateDraft(userId, dto);
            ra.addFlashAttribute("msg", "문서가 수정되었습니다.");
            return "redirect:/approval/detail?docVerId=" + dto.getDocVerId();
        }

        ApprovalDraftDTO saved = approvalService.saveDraft(userId, dto);
        ra.addFlashAttribute("msg", "문서가 저장되었습니다.");
        return "redirect:/approval/line?docVerId=" + saved.getDocVerId();
    }

    // 결재선 페이지
    @GetMapping("line")
    public String linePage(@RequestParam Long docVerId, Model model) {
        model.addAttribute("docVerId", docVerId);
    	model.addAttribute("pageTitle", "결재라인");
        return "approval/line";
    }

    // 상신 회수
    @PostMapping("recall")
    public String recall(@AuthenticationPrincipal LoginUser loginUser,
                         @RequestParam Long docVerId,
                         RedirectAttributes ra) {

        try {
            approvalService.recall(loginUser.getUserId(), docVerId);
            ra.addFlashAttribute("msg", "상신이 취소(회수)되었습니다.");
        } catch (Exception e) {
            ra.addFlashAttribute("msg", e.getMessage());
        }

        return  "redirect:/approval/detail?docVerId=" + docVerId;

    }

    // 재상신
    @PostMapping("resubmit")
    public String resubmit(@AuthenticationPrincipal LoginUser loginUser,
                           @RequestParam Long docVerId,
                           RedirectAttributes ra) {

        try {
            approvalService.resubmit(loginUser.getUserId(), docVerId);
            ra.addFlashAttribute("msg", "재상신되었습니다.");
        } catch (Exception e) {
            ra.addFlashAttribute("msg", e.getMessage());
        }

        return  "redirect:/approval/detail?docVerId=" + docVerId;

    }

    // 결재 요청(최초 상신)
    @PostMapping("submit")
    public String submit(@AuthenticationPrincipal LoginUser loginUser,
                         @RequestParam Long docVerId,
                         RedirectAttributes ra) {

        Long userId = loginUser.getUserId();

        // 1) 먼저 typeCode 확보 (상신 전이므로 getDraftForEdit이 안전)
        String typeCode = approvalService
                .getDraftForEdit(docVerId, userId)
                .getTypeCode();

        try {
            // 2) 상신 처리
            approvalService.submit(userId, docVerId);
            ra.addFlashAttribute("msg", "결재 요청되었습니다.");

            // 3) AT009만 detail
            if ("AT009".equals(typeCode)) {
                return "redirect:/approval/detail?docVerId=" + docVerId;
            }
            return "redirect:/approval/list";

        } catch (Exception e) {
            ra.addFlashAttribute("msg", e.getMessage());
            return "redirect:/approval/list";
        }
    }


    // 결재선 저장(AJAX)
    @PostMapping("saveLinesForm")
    @ResponseBody
    public String saveLinesForm(@AuthenticationPrincipal LoginUser loginUser,
                                @RequestParam Long docVerId,
                                @RequestParam(name = "approverIds") List<Long> approverIds,
                                @RequestParam(name = "lineRoleCodes") List<String> lineRoleCodes) {

        if (approverIds == null || lineRoleCodes == null || approverIds.size() != lineRoleCodes.size()) {
            throw new IllegalArgumentException("approverIds/lineRoleCodes 파라미터가 없거나 길이가 다릅니다.");
        }

        List<ApprovalLineDTO> lines = new ArrayList<>();
        for (int i = 0; i < approverIds.size(); i++) {
            ApprovalLineDTO line = new ApprovalLineDTO();
            line.setDocVerId(docVerId);
            line.setSeq(i + 1);
            line.setApproverId(approverIds.get(i));
            line.setLineRoleCode(lineRoleCodes.get(i));
            lines.add(line);
        }

        approvalService.saveLines(loginUser.getUserId(), docVerId, lines);
        return "OK";
    }

    // 결재선 조회(AJAX)
    @GetMapping("linesForm")
    @ResponseBody
    public List<ApprovalLineDTO> linesForm(@RequestParam Long docVerId) {
        return approvalService.getLines(docVerId);
    }

    // 결재자 트리 조회(AJAX)
    @GetMapping("approvers/tree")
    @ResponseBody
    public Map<String, Object> approverTree() {
        return approvalService.getApproverTree();
    }

    // 지점별 상품 조회(AJAX)
    @GetMapping("products")
    @ResponseBody
    public List<ApprovalProductDTO> products(@RequestParam(required = false) Long branchId) {
        return approvalService.getProductsByBranch(branchId);
    }

    // 출력 뷰(휴가 양식)
    @GetMapping("view")
    public String view(@RequestParam Long docVerId, Model model) {
        model.addAttribute("doc", approvalService.getPrintData(docVerId));
        model.addAttribute("bgImageUrl", "/approval/formPng/leave.png");
        model.addAttribute("docVerId", docVerId);
        model.addAttribute("fieldsJspf", "/WEB-INF/views/approval/print/_fields_vacation.jspf");
        return "approval/print/vacation_print";
    }

    // 결재 처리 화면(GET)
    @GetMapping("handle")
    public String handle(@RequestParam Long docVerId, Model model) {
        model.addAttribute("doc", approvalService.getPrintData(docVerId));
        return "approval/handle";
    }

    // 결재 처리 실행(POST)
    @PostMapping("handle")
    public String handle(@AuthenticationPrincipal LoginUser loginUser,
                         @RequestParam Long docVerId,
                         @RequestParam String action,
                         @RequestParam(required = false) String comment,
                         RedirectAttributes ra) {

        try {
            approvalService.handleDecision(docVerId, loginUser.getUserId(), action, comment);
            ra.addFlashAttribute("msg", "처리가 완료되었습니다.");
        } catch (Exception e) {
            ra.addFlashAttribute("msg", e.getMessage());
        }

        return "redirect:/approval/inbox";
    }
}
