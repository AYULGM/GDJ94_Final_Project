package com.health.app.sales;

import com.health.app.security.model.LoginUser;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 매출 관리 Controller
 */
@Controller
@RequestMapping("/sales")
@RequiredArgsConstructor
public class SaleController {

    private final SaleService saleService;

    /**
     * 매출 목록 페이지
     */
    @GetMapping
    public String saleListPage(Model model) {
        model.addAttribute("pageTitle", "매출 관리");
        return "sales/list";
    }

    /**
     * 매출 등록 페이지
     */
    @GetMapping("/form")
    public String saleFormPage(@RequestParam(required = false) Long saleId, Model model) {
        model.addAttribute("pageTitle", saleId == null ? "매출 등록" : "매출 수정");
        if (saleId != null) {
            model.addAttribute("saleId", saleId);
        }
        return "sales/form";
    }

    /**
     * 매출 상세 페이지
     */
    @GetMapping("/{saleId}")
    public String saleDetailPage(@PathVariable Long saleId, Model model) {
        model.addAttribute("pageTitle", "매출 상세");
        model.addAttribute("saleId", saleId);
        return "sales/detail";
    }

    /**
     * 매출 목록 조회 API
     */
    @GetMapping("/api/list")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getSaleList(SaleSearchDto searchDto) {
        Map<String, Object> result = saleService.getSaleList(searchDto);
        return ResponseEntity.ok(result);
    }

    /**
     * 매출 상세 조회 API
     */
    @GetMapping("/api/{saleId}")
    @ResponseBody
    public ResponseEntity<SaleDetailDto> getSaleDetail(@PathVariable Long saleId) {
        SaleDetailDto sale = saleService.getSaleDetail(saleId);
        return ResponseEntity.ok(sale);
    }

    /**
     * 매출 등록 API
     */
    @PostMapping("/api")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> createSale(
            @RequestBody SaleDto saleDto,
            Authentication authentication) {
        LoginUser loginUser = (LoginUser) authentication.getPrincipal();
        saleService.createSale(saleDto, loginUser.getUserId());

        Map<String, Object> response = Map.of(
                "success", true,
                "message", "매출이 등록되었습니다."
        );
        return ResponseEntity.ok(response);
    }

    /**
     * 매출 수정 API
     */
    @PutMapping("/api/{saleId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updateSale(
            @PathVariable Long saleId,
            @RequestBody SaleDto saleDto,
            Authentication authentication) {
        LoginUser loginUser = (LoginUser) authentication.getPrincipal();
        saleDto.setSaleId(saleId);
        saleService.updateSale(saleDto, loginUser.getUserId());

        Map<String, Object> response = Map.of(
                "success", true,
                "message", "매출이 수정되었습니다."
        );
        return ResponseEntity.ok(response);
    }

    /**
     * 매출 삭제 API
     */
    @DeleteMapping("/api/{saleId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deleteSale(
            @PathVariable Long saleId,
            Authentication authentication) {
        LoginUser loginUser = (LoginUser) authentication.getPrincipal();
        saleService.deleteSale(saleId, loginUser.getUserId());

        Map<String, Object> response = Map.of(
                "success", true,
                "message", "매출이 삭제되었습니다."
        );
        return ResponseEntity.ok(response);
    }

    /**
     * 지점 옵션 조회 API
     */
    @GetMapping("/api/options/branches")
    @ResponseBody
    public ResponseEntity<?> getBranchOptions() {
        return ResponseEntity.ok(saleService.getBranchOptions());
    }
}
