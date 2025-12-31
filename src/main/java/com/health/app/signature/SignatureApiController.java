package com.health.app.signature;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("/approval/signature/api")
public class SignatureApiController {

    private final SignatureService signatureService;
    private final HttpSession session;

    // 1) 목록
    @GetMapping("/list")
    public List<SignatureDTO> list() {
        Long userId = getLoginUserId();
        return signatureService.list(userId);
    }

    // 2) 저장
    @PostMapping("/save")
    public Map<String, Object> save(@RequestBody SignatureDTO req) throws Exception {
        Long userId = getLoginUserId();
        Long actorId = userId;

        Long signatureId = signatureService.save(userId, actorId, req.getSignBase64());
        return Map.of("signatureId", signatureId);
    }

    // 3) 삭제(soft delete)
    @DeleteMapping("/{signatureId}")
    public void delete(@PathVariable Long signatureId) {
        Long userId = getLoginUserId();
        Long actorId = userId;
        signatureService.softDelete(userId, signatureId, actorId);
    }

    // 4) 대표 변경
    @PostMapping("/primary")
    public void setPrimary(@RequestBody Map<String, Object> body) {
        Long userId = getLoginUserId();
        Long actorId = userId;

        Long signatureId = ((Number) body.get("signatureId")).longValue();
        signatureService.changePrimary(userId, signatureId, actorId);
    }

    private Long getLoginUserId() {
        Object v = session.getAttribute("userId");
        if (v == null) {
            throw new IllegalStateException("로그인이 필요합니다. (session.userId 없음)");
        }
        if (v instanceof Long) return (Long) v;
        if (v instanceof Integer) return ((Integer) v).longValue();
        if (v instanceof String) return Long.parseLong((String) v);
        throw new IllegalStateException("세션 userId 타입이 올바르지 않습니다: " + v.getClass());
    }
}
