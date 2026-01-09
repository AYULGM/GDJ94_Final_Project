package com.health.app.approval;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.health.app.approval.ApprovalProductDTO;
import com.health.app.security.model.LoginUser;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/approval")
@RequiredArgsConstructor
public class ApprovalController {

    private final ApprovalService approvalService;

    /* =========================
     * 페이지 라우팅
     * ========================= */

    @GetMapping("list")
    public String approvalList(@AuthenticationPrincipal LoginUser loginUser, Model model) {
        Long userId = loginUser.getUserId();
        model.addAttribute("list", approvalService.getMyDocs(userId));
        return "approval/list";
    }

    @GetMapping("detail")
    public String approvalDetail(@AuthenticationPrincipal LoginUser loginUser,
                                 @RequestParam("docVerId") Long docVerId,
                                 Model model) {

        Long userId = loginUser.getUserId();
        ApprovalDetailPageDTO page = approvalService.getDetailPage(userId, docVerId);

        model.addAttribute("page", page);
        model.addAttribute("docVerId", docVerId); // iframe용
        return "approval/detail";
    }



    @GetMapping("form")
    public String approvalForm(@AuthenticationPrincipal LoginUser loginUser,
                               @RequestParam(required = false) Long docVerId,
                               Model model) {

        model.addAttribute("branches", approvalService.getBranches());

        if (docVerId != null) {
            // ===== 수정 모드 =====
            ApprovalDraftDTO draft =
                    approvalService.getDraftForEdit(docVerId, loginUser.getUserId());

            model.addAttribute("draft", draft);
            model.addAttribute("mode", "edit");

            // 수정 시 기존 선택값에 맞는 상품 목록 로딩
            if (draft.getBranchId() != null) {
                model.addAttribute("products",
                        approvalService.getProductsByBranch(draft.getBranchId()));
            } else {
                model.addAttribute("products", java.util.Collections.emptyList());
            }

        } else {
            // ===== 신규 작성 =====
            model.addAttribute("mode", "new");
            model.addAttribute("products", java.util.Collections.emptyList());
        }

        return "approval/form";
    }


    @GetMapping("signature")
    public String approvalSignature() {
        return "approval/signature";
    }

    @GetMapping("print")
    public String approvalPrint() {
        return "approval/print";
    }

    /* =========================
     * Inbox
     * ========================= */

    @GetMapping("inbox")
    public String inbox(@AuthenticationPrincipal LoginUser loginUser, Model model) {
        Long userId = loginUser.getUserId();
        model.addAttribute("list", approvalService.getMyInbox(userId));
        return "approval/inbox";
    }

    /* =========================
     * Draft / Submit
     * ========================= */

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


    /* =========================
     * Lines
     * ========================= */

    @GetMapping("line")
    public String linePage(@RequestParam Long docVerId, Model model) {
        model.addAttribute("docVerId", docVerId);
        return "approval/line";
    }
    @PostMapping("recall")
    public String recall(@AuthenticationPrincipal LoginUser loginUser,
                         @RequestParam Long docVerId,
                         RedirectAttributes ra) {

        Long userId = loginUser.getUserId();

        try {
            approvalService.recall(userId, docVerId);
            ra.addFlashAttribute("msg", "상신이 취소(회수)되었습니다.");
        } catch (Exception e) {
            ra.addFlashAttribute("msg", e.getMessage());
        }

        return "redirect:/approval/detail?docVerId=" + docVerId;
    }
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
        return "redirect:/approval/detail?docVerId=" + docVerId;
    }
    @PostMapping("submit")
    public String submit(@AuthenticationPrincipal LoginUser loginUser,
                         @RequestParam Long docVerId,
                         RedirectAttributes ra) {
        try {
            approvalService.resubmit(loginUser.getUserId(), docVerId); // ✅ 여기만 변경
            ra.addFlashAttribute("msg", "결재 요청되었습니다.");
            return "redirect:/approval/detail?docVerId=" + docVerId;
        } catch (Exception e) {
            ra.addFlashAttribute("msg", e.getMessage());
            return "redirect:/approval/line?docVerId=" + docVerId;
        }
    }


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

    @GetMapping("linesForm")
    @ResponseBody
    public List<ApprovalLineDTO> linesForm(@RequestParam Long docVerId) {
        return approvalService.getLines(docVerId);
    }

    @GetMapping("approvers/tree")
    @ResponseBody
    public Map<String, Object> approverTree() {
        return approvalService.getApproverTree();
    }

    /* =========================
     * ✅ Approval 전용 상품 조회 API
     * - 프론트에서 branchId 선택 시 호출해서 products 채우는 용도
     * ========================= */

    @GetMapping("products")
    @ResponseBody
    public List<ApprovalProductDTO> products(@RequestParam(required = false) Long branchId) {
        return approvalService.getProductsByBranch(branchId);
    }
    @GetMapping("view")
    public String view(@RequestParam Long docVerId, Model model) {

        ApprovalPrintDTO doc = approvalService.getPrintData(docVerId);
        model.addAttribute("doc", doc);

        // _print_base.jspf가 요구하는 값 (안 넣으면 fieldsJspf null include 터질 수 있음)
        model.addAttribute("bgImageUrl", "/approval/formPng/leave.png");
        model.addAttribute("fieldsJspf", "/WEB-INF/views/approval/print/_fields_vacation.jspf");

        return "approval/print/vacation_print";
    }
    @GetMapping("handle")
    public String handle(@RequestParam Long docVerId, Model model) {

        ApprovalPrintDTO doc = approvalService.getPrintData(docVerId);
        model.addAttribute("doc", doc);

        // 결재처리 화면 JSP
        return "approval/handle";
    }

    @PostMapping("handle")
    public String handle(@AuthenticationPrincipal LoginUser loginUser,
                         @RequestParam Long docVerId,
                         @RequestParam String action,
                         @RequestParam(required = false) String comment,
                         RedirectAttributes ra) {

        Long userId = loginUser.getUserId();

        try {
            approvalService.handleDecision(docVerId, userId, action, comment);
            ra.addFlashAttribute("msg", "처리가 완료되었습니다.");
        } catch (Exception e) {
            ra.addFlashAttribute("msg", e.getMessage());
        }

        return "redirect:/approval/inbox";
    }

    
    
    
}
