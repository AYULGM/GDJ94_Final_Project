package com.health.app.signature;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import com.health.app.security.model.LoginUser;

import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("/approval/signature/api")
public class SignatureApiController {

    private final SignatureService signatureService;

    // 1) 목록
    @GetMapping("/list")
    public List<SignatureDTO> list(@AuthenticationPrincipal LoginUser loginUser) {
        Long userId = requireUserId(loginUser);
        return signatureService.list(userId);
    }

    // 2) 저장
    @PostMapping("/save")
    public Map<String, Object> save(@AuthenticationPrincipal LoginUser loginUser,
                                    @RequestBody SignatureDTO req) throws Exception {
        Long userId = requireUserId(loginUser);
        Long actorId = userId;

        Long signatureId = signatureService.save(userId, actorId, req.getSignBase64());
        return Map.of("signatureId", signatureId);
    }

    // 3) 삭제(soft delete)
    @DeleteMapping("/{signatureId}")
    public void delete(@AuthenticationPrincipal LoginUser loginUser,
                       @PathVariable Long signatureId) {
        Long userId = requireUserId(loginUser);
        Long actorId = userId;

        signatureService.softDelete(userId, signatureId, actorId);
    }

    // 4) 대표 변경
    @PostMapping("/primary")
    public void setPrimary(@AuthenticationPrincipal LoginUser loginUser,
                           @RequestBody Map<String, Object> body) {
        Long userId = requireUserId(loginUser);
        Long actorId = userId;

        Object raw = body.get("signatureId");
        if (!(raw instanceof Number)) {
            throw new IllegalArgumentException("signatureId는 숫자여야 합니다.");
        }
        Long signatureId = ((Number) raw).longValue();

        signatureService.changePrimary(userId, signatureId, actorId);
    }

    private Long requireUserId(LoginUser loginUser) {
        if (loginUser == null) {
            throw new IllegalStateException("로그인이 필요합니다. (principal 없음)");
        }
        Long userId = loginUser.getUserId();
        if (userId == null) {
            throw new IllegalStateException("로그인 사용자 정보에 userId가 없습니다.");
        }
        return userId;
    }
}
