package com.health.app.approval;

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
    @ResponseBody
    public ApprovalDraftDTO saveDraftForm(@AuthenticationPrincipal LoginUser loginUser,
                                          @ModelAttribute ApprovalDraftDTO dto) {
        return approvalService.saveDraft(loginUser.getUserId(), dto);
    }

}
