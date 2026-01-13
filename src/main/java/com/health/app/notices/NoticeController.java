package com.health.app.notices;

import com.health.app.security.model.LoginUser;
import com.health.app.branch.BranchMapper;
import com.health.app.commoncode.CommonCodeMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.stream.Collectors;

@Controller
@RequiredArgsConstructor
@RequestMapping("/notices")
public class NoticeController {

    private final NoticeService noticeService;
    private final BranchMapper branchMapper;
    private final CommonCodeMapper commonCodeMapper;

    // 관리자 여부 판단
    private boolean isAdmin(LoginUser user) {
        if (user == null) return false;
        String role = user.getRoleCode();
        return "RL001".equals(role) || "RL002".equals(role);
    }

    // 공통코드 Map 주입
    private void putCodeMaps(Model model) {
        model.addAttribute("noticeTypeMap",
                commonCodeMapper.selectByGroup("NOTICE_TYPE")
                        .stream().collect(Collectors.toMap(c -> c.getCode(), c -> c.getCodeDesc())));
        model.addAttribute("targetTypeMap",
                commonCodeMapper.selectByGroup("NOTICE_TARGET_TYPE")
                        .stream().collect(Collectors.toMap(c -> c.getCode(), c -> c.getCodeDesc())));
        model.addAttribute("statusMap",
                commonCodeMapper.selectByGroup("NOTICE_STATUS")
                        .stream().collect(Collectors.toMap(c -> c.getCode(), c -> c.getCodeDesc())));
        model.addAttribute("categoryMap",
                commonCodeMapper.selectByGroup("NOTICE_CATEGORY")
                        .stream().collect(Collectors.toMap(c -> c.getCode(), c -> c.getCodeDesc())));
    }

    // 폼에 필요한 리스트 주입
    private void putFormLists(Model model) {
        model.addAttribute("noticeTypes", commonCodeMapper.selectByGroup("NOTICE_TYPE"));
        model.addAttribute("targetTypes", commonCodeMapper.selectByGroup("NOTICE_TARGET_TYPE"));
        model.addAttribute("statusCodes", commonCodeMapper.selectByGroup("NOTICE_STATUS"));
        model.addAttribute("categories", commonCodeMapper.selectByGroup("NOTICE_CATEGORY"));
        model.addAttribute("branches", branchMapper.selectBranchList());
    }

    // 사용자 목록
    @GetMapping
    public String list(@RequestParam(required = false) Long branchId,
                       @AuthenticationPrincipal LoginUser user,
                       Model model) {
        model.addAttribute("list", noticeService.list(branchId));
        model.addAttribute("branchId", branchId);
        model.addAttribute("isAdmin", isAdmin(user));
        model.addAttribute("pageTitle", "공지사항");
        putCodeMaps(model);
        return "notices/list";
    }

    // 관리자 목록
    @GetMapping("/admin")
    public String adminList(@AuthenticationPrincipal LoginUser user, Model model) {
        if (!isAdmin(user)) return "redirect:/notices";
        model.addAttribute("list", noticeService.adminList());
        model.addAttribute("isAdmin", true);
        model.addAttribute("pageTitle", "공지사항");
        putCodeMaps(model);
        return "notices/admin_list";
    }

    // 상세
    @GetMapping("/{noticeId}")
    public String view(@PathVariable Long noticeId,
                       @AuthenticationPrincipal LoginUser user,
                       Model model) {
        NoticeDTO notice = noticeService.view(noticeId);
        model.addAttribute("notice", notice);
        model.addAttribute("isAdmin", isAdmin(user));
        model.addAttribute("pageTitle", "공지사항");
        putCodeMaps(model);
        if (notice != null && "TT002".equals(notice.getTargetType())) {
            model.addAttribute("targets", noticeService.getTargetBranches(noticeId));
        }
        return "notices/view";
    }

    // 등록 화면
    @GetMapping("/new")
    public String form(@AuthenticationPrincipal LoginUser user, Model model) {
        if (!isAdmin(user)) return "redirect:/notices";
        model.addAttribute("notice", new NoticeDTO());
        model.addAttribute("isAdmin", true);
        model.addAttribute("pageTitle", "공지사항");
        putFormLists(model);
        return "notices/form";
    }

    // 등록 저장
    @PostMapping
    public String create(NoticeDTO dto,
                         @RequestParam(required = false) String reason,
                         @AuthenticationPrincipal LoginUser user, Model model) {
        if (!isAdmin(user)) return "redirect:/notices";
        Long actorUserId = user.getUserId();
        dto.setWriterId(actorUserId);
        noticeService.create(dto, actorUserId, reason);
        model.addAttribute("pageTitle", "공지사항");
        return "redirect:/notices/admin";
    }

    // 수정 화면
    @GetMapping("/{noticeId}/edit")
    public String edit(@PathVariable Long noticeId,
                       @AuthenticationPrincipal LoginUser user,
                       Model model) {
        if (!isAdmin(user)) return "redirect:/notices";
        model.addAttribute("notice", noticeService.getForEdit(noticeId));
        model.addAttribute("isAdmin", true);
        model.addAttribute("pageTitle", "공지사항");
        putFormLists(model);
        return "notices/form";
    }

    // 수정 저장
    @PostMapping("/{noticeId}/edit")
    public String update(@PathVariable Long noticeId,
                         NoticeDTO dto,
                         @RequestParam(required = false) String reason,
                         @AuthenticationPrincipal LoginUser user, Model model) {
        if (!isAdmin(user)) return "redirect:/notices";
        dto.setNoticeId(noticeId);
        Long actorUserId = user.getUserId();
        noticeService.update(dto, actorUserId, reason);
        model.addAttribute("pageTitle", "공지사항");
        return "redirect:/notices/admin";
    }

    // 삭제
    @PostMapping("/{noticeId}/delete")
    public String delete(@PathVariable Long noticeId,
                         @RequestParam(required = false) String reason,
                         @AuthenticationPrincipal LoginUser user) {
        if (!isAdmin(user)) return "redirect:/notices";
        Long actorUserId = user.getUserId();
        noticeService.delete(noticeId, actorUserId, reason);
        return "redirect:/notices/admin";
    }

    // 사용자 공개 목록
    @GetMapping("/public")
    public String publicList(@RequestParam(required = false) Long branchId,
                             @AuthenticationPrincipal LoginUser user,
                             Model model) {
        model.addAttribute("list", noticeService.list(branchId));
        model.addAttribute("branchId", branchId);
        model.addAttribute("isAdmin", isAdmin(user));
        putCodeMaps(model);
        return "notices/list";
    }
}
