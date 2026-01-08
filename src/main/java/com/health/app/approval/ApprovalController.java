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



    // ✅ form은 한 군데만 유지 (branches 세팅 포함)
    @GetMapping("form")
    public String approvalForm(Model model) {
        model.addAttribute("branches", approvalService.getBranches());
        model.addAttribute("products", java.util.Collections.emptyList()); // 초기 비움
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
                                @ModelAttribute ApprovalDraftDTO dto) {

        ApprovalDraftDTO saved = approvalService.saveDraft(loginUser.getUserId(), dto);
        return "redirect:/approval/line?docVerId=" + saved.getDocVerId();
    }

    @PostMapping("submit")
    public String submit(@AuthenticationPrincipal LoginUser loginUser,
                         @RequestParam Long docVerId) {
        approvalService.submit(loginUser.getUserId(), docVerId);
        return "redirect:/approval/list";
    }

    /* =========================
     * Lines
     * ========================= */

    @GetMapping("line")
    public String linePage(@RequestParam Long docVerId, Model model) {
        model.addAttribute("docVerId", docVerId);
        return "approval/line";
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
