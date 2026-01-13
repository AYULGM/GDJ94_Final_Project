package com.health.app.user;

import java.util.List;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

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
    public String userList(Model model) {

        List<UserAdminDTO> users = userAdminService.getUserAdminList();
        model.addAttribute("users", users);
        model.addAttribute("pageTitle", "사용자 목록");
        
        return "userManagement/list";
    }
    
    // 사용자 상세화면 (이력 데이터 조회 추가)
    @GetMapping("/detail")
    public String detail(Long userId, Model model) {

        UserAdminDTO user = userAdminService.getUserAdminDetail(userId);

        model.addAttribute("user", user);
        model.addAttribute("pageTitle", "사용자 상세 / 변경 이력");
        
        model.addAttribute("historyList",
                userAdminService.getUserAllHistory(userId));

        return "userManagement/detail";
    }


    // 사용자 등록
    @GetMapping("/add")
    public String addForm(HttpSession session, Model model) {
    	model.addAttribute("pageTitle", "사용자 등록");
    	
        return "userManagement/add";
    }
    
    // 사용자 등록
    @PostMapping("/add")
    public String addUser(UserAdminDTO dto) {

        Authentication auth =
            SecurityContextHolder.getContext().getAuthentication();

        LoginUser loginUser =
            (LoginUser) auth.getPrincipal(); // ⭐ 여기

        dto.setCreateUser(loginUser.getUserId()); // ⭐ 여기

        userAdminService.addUser(dto);
        return "redirect:/userManagement/list";
    }
    
    // 사용자 수정
    @GetMapping("/edit")
    public String editForm(Long userId, Model model) {

        UserAdminDTO user = userAdminService.getUserAdminDetail(userId);
        model.addAttribute("user", user);
        model.addAttribute("pageTitle", "사용자 수정");

        return "userManagement/edit";
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

}
