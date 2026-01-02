package com.health.app.users;

import com.health.app.users.dto.UserDTO;
import com.health.app.users.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;
    private final PasswordEncoder passwordEncoder;

    /**
     * 사용자 목록
     * GET /users
     */
    @GetMapping
    public String userList(Model model) {
        model.addAttribute("pageTitle", "사용자 관리");
        return "users/list";
    }

    /**
     * 회원가입 화면
     * GET /users/join
     */
    @GetMapping("/join")
    public String join() {
        return "users/join";
    }

    /**
     * 회원가입 처리
     * POST /users/joinProc
     */
    @PostMapping("/joinProc")
    public String joinProc(UserDTO userDTO) {

        // 1️⃣ 비밀번호 암호화
        userDTO.setPassword(
            passwordEncoder.encode(userDTO.getPassword())
        );

        // 2️⃣ 기본 코드값 세팅 (매우 중요)
        userDTO.setStatusCode("US001");     // 정상
        userDTO.setRoleCode("RL004");       // 일반 사용자
        userDTO.setLockStatusCode("AL001"); // 잠금 아님
        userDTO.setFailCount(0);
        userDTO.setUseYn(true);
        
        // 🔥 핵심: 공통 컬럼 세팅
        // 실무에서도 “SYSTEM = 0” 또는 “ADMIN = 1”로 많이 씀
        userDTO.setCreateUser(0L); // 0 = SYSTEM
        
        userService.join(userDTO);

        // 3️⃣ 가입 후 로그인 페이지로
        return "redirect:/login";
    }
}
