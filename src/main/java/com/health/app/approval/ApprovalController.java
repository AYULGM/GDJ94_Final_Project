package com.health.app.approval;

import java.util.ArrayList;
import java.util.List;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import com.health.app.security.model.LoginUser;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/approval/*")
@RequiredArgsConstructor
public class ApprovalController {

    private final ApprovalService approvalService;

    @GetMapping("list")
    public void approvalList() { }

    @GetMapping("form")
    public void approvalForm() { }

    @GetMapping("signature")
    public void approvalSignature() { }

    @GetMapping("print")
    public void approvalPrint() { }

    @PostMapping("saveDraftForm")
    public String saveDraftForm(@AuthenticationPrincipal LoginUser loginUser,
                                @ModelAttribute ApprovalDraftDTO dto) {

        ApprovalDraftDTO saved = approvalService.saveDraft(loginUser.getUserId(), dto);

        // 저장된 docVerId로 결재선 화면 이동
        return "redirect:/approval/line?docVerId=" + saved.getDocVerId();
    }

    
    @GetMapping("line")
    public String linePage(@RequestParam Long docVerId, org.springframework.ui.Model model) {
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
}
