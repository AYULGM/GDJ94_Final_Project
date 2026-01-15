package com.health.app.user;

import java.util.List;

import org.springframework.dao.DuplicateKeyException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.health.app.security.model.LoginUser;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/userManagement")
@RequiredArgsConstructor
public class UserAdminController {

    private final UserAdminService userAdminService;

 // 사용자 관리 목록
    @GetMapping("/list")
    public String userList(
            @AuthenticationPrincipal LoginUser loginUser,
            Model model
    ) {

        String roleCode = loginUser.getRoleCode();
        Long branchId = loginUser.getBranchId();

        List<UserAdminDTO> users;

        // ADMIN → 본인 지점만
        if ("RL003".equals(roleCode)) {  
            users = userAdminService.getUserAdminListByBranch(branchId);
        }
        // MASTER, GRANDMASTER → 전체
        else {
            users = userAdminService.getUserAdminList();
        }

        model.addAttribute("users", users);
        model.addAttribute("pageTitle", "사용자 관리");

        return "userManagement/list";
    }


    
 // 사용자 상세화면 (이력 데이터 조회 추가)
    @GetMapping("/detail")
    public String detail(Long userId, @AuthenticationPrincipal LoginUser loginUser, Model model) {

        try {
            UserAdminDTO user =
                userAdminService.getUserAdminDetail(userId, loginUser);

            model.addAttribute("user", user);
            model.addAttribute("pageTitle", "사용자 상세 · 변경 이력");

            model.addAttribute("historyList",
                    userAdminService.getUserAllHistory(userId));

            return "userManagement/detail";

        } catch (Exception e) {

            // 잘못된 접근 (없는 ID, 탈퇴 회원)
            return "redirect:/userManagement/list";
        }
    }



    // 사용자 등록
    @GetMapping("/add")
    public String addForm(HttpSession session, Model model) {
    	model.addAttribute("pageTitle", "사용자 등록");
    	
        return "userManagement/add";
    }
    
 // 사용자 등록
    @PostMapping("/add")
    public String addUser(UserAdminDTO dto,
                          RedirectAttributes ra) {

        Authentication auth =
            SecurityContextHolder.getContext().getAuthentication();

        LoginUser loginUser =
            (LoginUser) auth.getPrincipal();

        dto.setCreateUser(loginUser.getUserId());

        try {
            userAdminService.addUser(dto);
            return "redirect:/userManagement/list";

        } catch (DuplicateKeyException e) {

            // 🔥 DB UNIQUE 중복 처리
            ra.addFlashAttribute("error", "이미 사용중인 아이디입니다.");
            return "redirect:/userManagement/add";

        } catch (IllegalStateException e) {

            // 서비스단에서 던진 예외 처리
            ra.addFlashAttribute("error", e.getMessage());
            return "redirect:/userManagement/add";
        }
    }

    
    // 사용자 수정
    @GetMapping("/edit")
    public String editForm(
            Long userId,
            @AuthenticationPrincipal LoginUser loginUser,
            Model model) {

        try {
            UserAdminDTO user =
                userAdminService.getUserAdminDetail(userId, loginUser);

            model.addAttribute("user", user);
            model.addAttribute("pageTitle", "사용자 수정");

            return "userManagement/edit";

        } catch (Exception e) {
            return "redirect:/userManagement/list";
        }
    }

    
    @PostMapping("/edit")
    public String editUser(UserAdminDTO dto, @RequestParam String reason) {

        Authentication auth =
            SecurityContextHolder.getContext().getAuthentication();

        LoginUser loginUser =
            (LoginUser) auth.getPrincipal();

        dto.setUpdateUser(loginUser.getUserId());

        userAdminService.updateUser(dto, reason);

        return "redirect:/userManagement/detail?userId=" + dto.getUserId();
    }

    // 상태 변경 처리
    @PostMapping("/status")
    public String changeStatus(Long userId, String statusCode) {

        Authentication auth =
            SecurityContextHolder.getContext().getAuthentication();

        LoginUser loginUser =
            (LoginUser) auth.getPrincipal();

        userAdminService.changeUserStatus(
            userId,
            statusCode,
            loginUser.getUserId()
        );

        return "redirect:/userManagement/detail?userId=" + userId;
    }

    // 비밀번호 초기화 요청 처리
    @PostMapping("/reset-password")
    public String resetPassword(Long userId) {

        Authentication auth =
            SecurityContextHolder.getContext().getAuthentication();

        LoginUser loginUser =
            (LoginUser) auth.getPrincipal();

        userAdminService.resetPassword(userId, loginUser.getUserId());

        return "redirect:/userManagement/detail?userId=" + userId;
    }

    // 회원탈퇴기능( use_yn = 0)
    @PostMapping("/withdraw")
    public String withdrawUser(Long userId,
                               String reason,
                               @AuthenticationPrincipal LoginUser loginUser) {

        userAdminService.withdrawUser(
            userId,
            loginUser.getUserId(),
            reason
        );

        return "redirect:/userManagement/detail?userId=" + userId;
    }

}
