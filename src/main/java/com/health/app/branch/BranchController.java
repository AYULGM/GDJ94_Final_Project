package com.health.app.branch;

import java.util.List;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

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

        return "branch/list";
    }
    
    @GetMapping("/detail")
    public String branchDetail(@RequestParam Long branchId, Model model) {
        BranchDTO branch = branchService.getBranchDetail(branchId);
        model.addAttribute("branch", branch);
        return "branch/detail"; // /WEB-INF/views/branch/detail.jsp
    }
}
