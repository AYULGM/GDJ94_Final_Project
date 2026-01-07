package com.health.app.user;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/userManagement")
@RequiredArgsConstructor
public class UserAdminController {

    private final UserAdminService userAdminService;

    @GetMapping("/list")
    public String userList(Model model) {

        List<UserAdminDTO> users = userAdminService.getUserAdminList();
        model.addAttribute("users", users);
        model.addAttribute("pageTitle", "사용자 관리");
        
        return "userManagement/list";
    }
}
