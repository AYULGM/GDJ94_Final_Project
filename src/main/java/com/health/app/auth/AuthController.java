package com.health.app.auth;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequiredArgsConstructor
@RequestMapping("/auth")
public class AuthController {

    private final AuthMapper authMapper;

    @GetMapping("/login")
    public String loginPage() {
        return "auth/login";
    }

    @PostMapping("/login")
    public String login(LoginRequest req,
                        HttpSession session,
                        Model model) {

        UserLoginView user = authMapper.selectLoginUser(req.getLoginId());

        if (user == null || !req.getPassword().equals(user.getPassword())) {
            model.addAttribute("error", "아이디 또는 비밀번호가 올바르지 않습니다.");
            return "auth/login";
        }

        SessionUser sessionUser = new SessionUser(
            user.getUserId(),
            user.getLoginId(),
            user.getName()
        );

        // ✔ 로그인 사용자 객체
        session.setAttribute("LOGIN_USER", sessionUser);

        // ✔ 사용자 PK (Long)
        session.setAttribute("userId", user.getUserId());

        return "redirect:/approval/list";
    }

}
