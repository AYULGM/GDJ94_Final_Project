package com.health.app.branch;

import java.util.List;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.health.app.security.model.LoginUser;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/branch")
@RequiredArgsConstructor
public class BranchController {

    private final BranchService branchService;

    @GetMapping("/list")
    public String branchList(Model model) {

        List<BranchDTO> list = branchService.getBranchList();
        model.addAttribute("branchList", list);
        model.addAttribute("pageTitle", "지점 관리");
        return "branch/list";
    }
    
    @GetMapping("/detail")
    public String branchDetail(@RequestParam Long branchId, Model model) {
        BranchDTO branch = branchService.getBranchDetail(branchId);
        model.addAttribute("branch", branch);
        return "branch/detail"; // /WEB-INF/views/branch/detail.jsp
    }
    
    @GetMapping("/register")
    public String branchRegisterForm() {
        return "branch/register";
    }

    @PostMapping("/register")
    public String registerBranch(BranchDTO branchDTO,
                                 @AuthenticationPrincipal LoginUser loginUser) {

        Long loginUserId = loginUser.getUserId(); // 🔥 여기서 바로 꺼냄

        branchService.registerBranch(branchDTO, loginUserId);

        return "redirect:/branch/list";
    }
    
    // 수정 화면
    @GetMapping("/update")
    public String updateForm(@RequestParam Long branchId, Model model) {
        model.addAttribute("branch", branchService.getBranchDetail(branchId));
        return "branch/update";
    }

    // 수정 처리
    @PostMapping("/update")
    public String update(
            BranchDTO dto,
            @AuthenticationPrincipal LoginUser loginUser
    ) {
        branchService.updateBranch(dto, loginUser.getUserId());
        return "redirect:/branch/detail?branchId=" + dto.getBranchId();
    }
    
    // 지점상태변경
    @PostMapping("/status")
    public String changeStatus(
            Long branchId,
            String statusCode,
            String reason,
            @AuthenticationPrincipal LoginUser loginUser
    ) {
        branchService.changeStatus(
            branchId,
            statusCode,
            reason,
            loginUser.getUserId()
        );
        return "redirect:/branch/detail?branchId=" + branchId;
    }

}
