package com.health.app.notices;

import com.health.app.security.model.LoginUser;
import com.health.app.branch.BranchMapper;
import com.health.app.commoncode.CommonCodeMapper;
import lombok.RequiredArgsConstructor;

import java.util.stream.Collectors;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequiredArgsConstructor
@RequestMapping("/notices")
public class NoticeController {

    private final NoticeService noticeService;

    // 2단계에서 사용
    private final BranchMapper branchMapper;
    private final CommonCodeMapper commonCodeMapper;


    @GetMapping
    public String list(@RequestParam(required = false) Long branchId,
                       @AuthenticationPrincipal LoginUser loginUser,
                       Model model) {

        model.addAttribute("list", noticeService.list(branchId));
        model.addAttribute("branchId", branchId);

        // ✅ 코드 -> 한글명(Map) 내려주기
        model.addAttribute("noticeTypeMap", commonCodeMapper.selectByGroup("NOTICE_TYPE")
                .stream().collect(Collectors.toMap(c -> c.getCode(), c -> c.getCodeDesc())));

        model.addAttribute("targetTypeMap", commonCodeMapper.selectByGroup("NOTICE_TARGET_TYPE")
                .stream().collect(Collectors.toMap(c -> c.getCode(), c -> c.getCodeDesc())));

        model.addAttribute("statusMap", commonCodeMapper.selectByGroup("NOTICE_STATUS")
                .stream().collect(Collectors.toMap(c -> c.getCode(), c -> c.getCodeDesc())));

        return "notices/list";
    }

    @GetMapping("/{noticeId}")
    public String view(@PathVariable Long noticeId, Model model) {

        NoticeDTO notice = noticeService.view(noticeId);
        model.addAttribute("notice", notice);

        // 코드 -> 한글(Map)
        model.addAttribute("noticeTypeMap", commonCodeMapper.selectByGroup("NOTICE_TYPE")
                .stream().collect(Collectors.toMap(c -> c.getCode(), c -> c.getCodeDesc())));
        model.addAttribute("targetTypeMap", commonCodeMapper.selectByGroup("NOTICE_TARGET_TYPE")
                .stream().collect(Collectors.toMap(c -> c.getCode(), c -> c.getCodeDesc())));
        model.addAttribute("statusMap", commonCodeMapper.selectByGroup("NOTICE_STATUS")
                .stream().collect(Collectors.toMap(c -> c.getCode(), c -> c.getCodeDesc())));
        model.addAttribute("categoryMap", commonCodeMapper.selectByGroup("NOTICE_CATEGORY")
                .stream().collect(Collectors.toMap(c -> c.getCode(), c -> c.getCodeDesc())));

        // 지점 공지면 대상 지점 목록
        if (notice != null && "TT002".equals(notice.getTargetType())) {
            model.addAttribute("targets", noticeService.getTargetBranches(noticeId));
        }

        return "notices/view";
    }

    @GetMapping("/new")
    public String form(@AuthenticationPrincipal LoginUser loginUser, Model model) {
        model.addAttribute("notice", new NoticeDTO());

        // 2단계: 공통코드 + 지점목록 주입
        model.addAttribute("noticeTypes", commonCodeMapper.selectByGroup("NOTICE_TYPE"));
        model.addAttribute("targetTypes", commonCodeMapper.selectByGroup("NOTICE_TARGET_TYPE"));
        model.addAttribute("statusCodes", commonCodeMapper.selectByGroup("NOTICE_STATUS"));
        model.addAttribute("categories", commonCodeMapper.selectByGroup("NOTICE_CATEGORY"));

        model.addAttribute("branches", branchMapper.selectBranchList());
        return "notices/form";
    }

    @PostMapping
    public String create(NoticeDTO dto,
                         @RequestParam(required = false) String reason,
                         @AuthenticationPrincipal LoginUser loginUser) {

        Long actorUserId = loginUser.getUserId();

        // writer_id NOT NULL
        dto.setWriterId(actorUserId);

        noticeService.create(dto, actorUserId, reason);
        return "redirect:/notices";
    }

    @PostMapping("/{noticeId}")
    public String update(@PathVariable Long noticeId,
                         NoticeDTO dto,
                         @RequestParam(required = false) String reason,
                         @AuthenticationPrincipal LoginUser loginUser) {

        dto.setNoticeId(noticeId);

        Long actorUserId = loginUser.getUserId();
        noticeService.update(dto, actorUserId, reason);

        return "redirect:/notices/" + noticeId;
    }

    @PostMapping("/{noticeId}/delete")
    public String delete(@PathVariable Long noticeId,
                         @RequestParam(required = false) String reason,
                         @AuthenticationPrincipal LoginUser loginUser) {

        Long actorUserId = loginUser.getUserId();
        noticeService.delete(noticeId, actorUserId, reason);

        return "redirect:/notices";
    }
}
