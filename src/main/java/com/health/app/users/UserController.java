package com.health.app.users;

import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;
    private final PasswordEncoder passwordEncoder;
    
    
    // 회원탈퇴 기능
    @PostMapping("/withdraw")
    public String withdraw(Authentication authentication,
                           RedirectAttributes redirectAttributes) {

        String loginId = authentication.getName();

        userService.withdraw(loginId);

        // 로그아웃 후 메시지 전달
        return "redirect:/login?withdraw";
    }

    
    @GetMapping("/password")
    public String passwordForm() {
        return "users/password";
    }

    @PostMapping("/passwordProc")
    public String passwordProc(
            String currentPassword,
            String newPassword,
            String confirmPassword,
            Authentication authentication,
            RedirectAttributes redirectAttributes) {

        // 🔍 1. 인증 정보 확인
        System.out.println("auth.getName() = [" + authentication.getName() + "]");

        String loginId = authentication.getName();

        // 🔍 2. 비밀번호 변경용 조회 (password 포함)
        UserDTO user = userService.findForPasswordCheck(loginId);

        // 🔍 3. DB에서 가져온 비밀번호 해시 확인
        System.out.println("DB password hash = [" + user.getPassword() + "]");

        // 🔍 4. 입력한 현재 비밀번호 길이 (값은 출력 X)
        System.out.println("currentPassword length = "
                + (currentPassword == null ? "null" : currentPassword.length()));

        // 🔥 여기서 비교
        boolean matches = passwordEncoder.matches(
                currentPassword == null ? "" : currentPassword.trim(),
                user.getPassword()
        );

        System.out.println("passwordEncoder.matches = " + matches);

        // ---- 기존 검증 로직 ----
        if (!matches) {
            redirectAttributes.addFlashAttribute(
                    "errorMessage", "현재 비밀번호가 일치하지 않습니다."
            );
            return "redirect:/users/password";
        }

        if (!newPassword.equals(confirmPassword)) {
            redirectAttributes.addFlashAttribute(
                    "errorMessage", "새 비밀번호가 서로 일치하지 않습니다."
            );
            return "redirect:/users/password";
        }

        userService.updatePassword(
                loginId,
                passwordEncoder.encode(newPassword)
        );

        redirectAttributes.addFlashAttribute(
                "successMessage",
                "비밀번호가 변경되었습니다. 다시 로그인해주세요."
        );

        return "redirect:/login";
    }


    @GetMapping("/update")
    public String updateForm(Model model, Authentication authentication) {

        String loginId = authentication.getName();

        UserDTO userInfo = userService.findByLoginId(loginId);
        model.addAttribute("user", userInfo);

        return "users/update";
    }
    
    @PostMapping("/updateProc")
    public String updateProc(UserDTO userDTO, Authentication authentication, HttpSession session, RedirectAttributes redirectAttributes) {

        String loginId = authentication.getName();

        // 보안: 로그인한 사용자만 자기 정보 수정
        userDTO.setLoginId(loginId);

        // 부서 코드 정규화 ("" → null)
        if (userDTO.getDepartmentCode() != null &&
            userDTO.getDepartmentCode().isBlank()) {
            userDTO.setDepartmentCode(null);
        }

        userService.updateUser(userDTO);
        
        // 세션 이름 즉시 갱신 (이 줄이 핵심)
        session.setAttribute("LOGIN_USER_NAME", userDTO.getName());
        
        // ✅ 수정 완료 메시지
        redirectAttributes.addFlashAttribute(
            "successMessage",
            "정보가 성공적으로 수정되었습니다."
        );
        return "redirect:/users/mypage";
    }


    
    @GetMapping("/mypage")
    public String mypage(Model model, Authentication authentication) {

        // 🔐 로그인 안 한 경우 (익명 사용자)
        if (authentication == null || !authentication.isAuthenticated()
            || "anonymousUser".equals(authentication.getPrincipal())) {
            return "redirect:/login";
        }

        // loginId 추출
        String loginId = authentication.getName();

        UserDTO userInfo = userService.findByLoginId(loginId);
        model.addAttribute("user", userInfo);

        return "users/mypage";
    }
    
    /**
     * 사용자 목록
     * GET /users
     */
//    @GetMapping
//    public String userList(Model model) {
//        model.addAttribute("pageTitle", "사용자 관리");
//        return "users/list";
//    }

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
    	
        // 🔧 부서 코드 정규화 (회원가입 시 부서코드가 "" 라면 → null (DB에 null이 들어가도록))
        if (userDTO.getDepartmentCode() != null && userDTO.getDepartmentCode().isBlank()) 
        {
            userDTO.setDepartmentCode(null);
        }

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
