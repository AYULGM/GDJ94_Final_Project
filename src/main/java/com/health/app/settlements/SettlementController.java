package com.health.app.settlements;

import com.health.app.settlements.*;
import com.health.app.settlements.SettlementService;
import com.health.app.security.model.LoginUser;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 정산 Controller
 */
@Controller
@RequestMapping("/settlements")
@RequiredArgsConstructor
public class SettlementController {

    private final SettlementService settlementService;

    /**
     * 정산 목록 페이지
     */
    @GetMapping
    public String settlementListPage(Model model) {
        model.addAttribute("pageTitle", "정산 내역");
        return "settlements/list";
    }

    /**
     * 정산 상세 페이지
     */
    @GetMapping("/{settlementId}")
    public String settlementDetailPage(@PathVariable Long settlementId, Model model) {
        model.addAttribute("pageTitle", "정산 상세");
        model.addAttribute("settlementId", settlementId);
        return "settlements/detail";
    }

    /**
     * 정산 확정 페이지 (정산 대상 조회 및 정산 생성)
     */
    @GetMapping("/confirm")
    public String settlementConfirmListPage(Model model) {
        model.addAttribute("pageTitle", "정산 확정");
        return "settlements/confirm";
    }

    /**
     * 정산 이력 로그 페이지
     */
    @GetMapping("/history")
    public String settlementHistoryPage(Model model) {
        model.addAttribute("pageTitle", "정산 처리 이력");
        return "settlements/history";
    }

    /**
     * 정산 목록 조회 API
     */
    @GetMapping("/api/list")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getSettlementList(SettlementSearchDto searchDto) {
        Map<String, Object> result = settlementService.getSettlementList(searchDto);
        return ResponseEntity.ok(result);
    }

    /**
     * 정산 상세 조회 API
     */
    @GetMapping("/api/{settlementId}")
    @ResponseBody
    public ResponseEntity<SettlementDetailDto> getSettlementDetail(@PathVariable Long settlementId) {
        SettlementDetailDto settlement = settlementService.getSettlementDetail(settlementId);
        return ResponseEntity.ok(settlement);
    }

    /**
     * 정산 생성 API (전체 기간)
     */
    @PostMapping("/api")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> createSettlement(
            @RequestBody CreateSettlementRequestDto requestDto,
            Authentication authentication) {
        Long currentUserId = getCurrentUserId(authentication);
        Long settlementId = settlementService.createSettlement(requestDto, currentUserId);

        Map<String, Object> response = Map.of(
                "success", true,
                "message", "정산이 생성되었습니다.",
                "settlementId", settlementId
        );
        return ResponseEntity.ok(response);
    }

    /**
     * 선택 정산 생성 API (선택된 항목만)
     */
    @PostMapping("/api/selected")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> createSelectedSettlement(
            @RequestBody SelectedSettlementRequestDto requestDto,
            Authentication authentication) {
        Long currentUserId = getCurrentUserId(authentication);
        Long settlementId = settlementService.createSelectedSettlement(requestDto, currentUserId);

        Map<String, Object> response = Map.of(
                "success", true,
                "message", "정산이 생성되었습니다.",
                "settlementId", settlementId
        );
        return ResponseEntity.ok(response);
    }

    /**
     * 정산 확정 API
     */
    @PutMapping("/api/{settlementId}/confirm")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> confirmSettlement(
            @PathVariable Long settlementId,
            @RequestBody(required = false) Map<String, String> body,
            Authentication authentication) {
        Long currentUserId = getCurrentUserId(authentication);
        String reason = body != null ? body.get("reason") : null;

        settlementService.confirmSettlement(settlementId, reason, currentUserId);

        Map<String, Object> response = Map.of(
                "success", true,
                "message", "정산이 확정되었습니다."
        );
        return ResponseEntity.ok(response);
    }

    /**
     * 정산 취소 API
     */
    @PutMapping("/api/{settlementId}/cancel")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> cancelSettlement(
            @PathVariable Long settlementId,
            @RequestBody(required = false) Map<String, String> body,
            Authentication authentication) {
        Long currentUserId = getCurrentUserId(authentication);
        String reason = body != null ? body.get("reason") : null;

        settlementService.cancelSettlement(settlementId, reason, currentUserId);

        Map<String, Object> response = Map.of(
                "success", true,
                "message", "정산이 취소되었습니다."
        );
        return ResponseEntity.ok(response);
    }

    /**
     * 정산 삭제 API
     */
    @DeleteMapping("/api/{settlementId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deleteSettlement(
            @PathVariable Long settlementId,
            Authentication authentication) {
        Long currentUserId = getCurrentUserId(authentication);
        settlementService.deleteSettlement(settlementId, currentUserId);

        Map<String, Object> response = Map.of(
                "success", true,
                "message", "정산이 삭제되었습니다."
        );
        return ResponseEntity.ok(response);
    }

    /**
     * 정산 이력 조회 API
     */
    @GetMapping("/api/{settlementId}/histories")
    @ResponseBody
    public ResponseEntity<List<SettlementHistoryDto>> getSettlementHistories(@PathVariable Long settlementId) {
        List<SettlementHistoryDto> histories = settlementService.getSettlementHistories(settlementId);
        return ResponseEntity.ok(histories);
    }

    /**
     * 현재 사용자 ID 조회 (인증 없을 경우 기본값 1L 반환)
     */
    private Long getCurrentUserId(Authentication authentication) {
        if (authentication != null && authentication.getPrincipal() instanceof LoginUser) {
            LoginUser loginUser = (LoginUser) authentication.getPrincipal();
            return loginUser.getUserId();
        }
        return 1L; // 기본 사용자 ID (개발용)
    }
}
