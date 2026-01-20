package com.health.app.purchase;

import com.health.app.security.model.LoginUser;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/purchase")
@RequiredArgsConstructor
public class PurchaseController {

    private final PurchaseService purchaseService;

    @GetMapping("/new")
    @PreAuthorize("hasAnyRole('GRANDMASTER','MASTER','ADMIN','CAPTAIN','CREW')")
    public String newPurchaseForm() {
        return "redirect:/approval/form?entry=buy&typeCode=AT006";
    }

    @GetMapping("/request/new")
    @PreAuthorize("hasAnyRole('GRANDMASTER','MASTER','ADMIN')")
    public String newPurchaseRequestForm() {
        return "redirect:/approval/form?entry=buy&typeCode=AT005";
    }

    /**
     *  구매/발주 통합 목록
     * - 지점(CAPTAIN/CREW)은 '자기 지점만' 서버단에서 강제 필터
     */
    @GetMapping("/orders")
    @PreAuthorize("hasAnyRole('GRANDMASTER','MASTER','ADMIN','CAPTAIN','CREW')")
    public String orders(@RequestParam(required = false) Long branchId,
                         @RequestParam(required = false) String statusCode,
                         @RequestParam(required = false) String keyword,
                         @RequestParam(required = false, defaultValue = "ALL") String docType,
                         @AuthenticationPrincipal LoginUser loginUser,
                         Model model) {

        if (loginUser != null && (loginUser.isCaptain() || loginUser.isCrew())) {
            branchId = loginUser.getBranchId(); //  강제
        }

        List<PurchaseOptionDto> branches = purchaseService.getBranchOptions();
        if (loginUser != null && (loginUser.isCaptain() || loginUser.isCrew()) && branchId != null) {
            Long myBranchId = branchId;
            branches = branches.stream()
                    .filter(b -> b != null && b.getId() != null && b.getId().equals(myBranchId))
                    .collect(Collectors.toList());
        }

        model.addAttribute("branches", branches);
        model.addAttribute("list", purchaseService.getPurchaseList(branchId, statusCode, keyword, docType));

        model.addAttribute("branchId", branchId);
        model.addAttribute("statusCode", statusCode);
        model.addAttribute("keyword", keyword);
        model.addAttribute("docType", docType);

        model.addAttribute("pageTitle", "구매/발주 목록");
        return "purchase/list";
    }

    /**
     *  발주 상세 (뷰 전용)
     * - /purchase/12 로 들어올 때 여기서 받아줘야 No static resource가 사라짐
     * - 지점(CAPTAIN/CREW)은 자기 지점 문서만 접근 가능
     */
    @GetMapping("/{purchaseId}")
    @PreAuthorize("hasAnyRole('GRANDMASTER','MASTER','ADMIN','CAPTAIN','CREW')")
    public String detail(@PathVariable Long purchaseId,
                         @AuthenticationPrincipal LoginUser loginUser,
                         Model model) {

        PurchaseDetailDto detail = purchaseService.getPurchaseDetail(purchaseId);
        if (detail == null) {
            model.addAttribute("error", "발주 정보를 찾을 수 없습니다.");
            model.addAttribute("detail", null);
            return "purchase/detail";
        }

        //  지점 계정 접근 제한(서버 강제)
        if (loginUser != null && (loginUser.isCaptain() || loginUser.isCrew())) {
            Long myBranchId = loginUser.getBranchId();
            if (myBranchId != null && detail.getBranchId() != null && !myBranchId.equals(detail.getBranchId())) {
                model.addAttribute("error", "해당 문서를 열람할 권한이 없습니다.");
                model.addAttribute("detail", null);
                return "purchase/detail";
            }
        }

        model.addAttribute("detail", detail);
        return "purchase/detail";
    }

    /** /purchase 루트는 통합 목록으로 */
    @GetMapping
    @PreAuthorize("hasAnyRole('GRANDMASTER','MASTER','ADMIN','CAPTAIN','CREW')")
    public String root() {
        return "redirect:/purchase/orders";
    }
}
