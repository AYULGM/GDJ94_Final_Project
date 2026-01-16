package com.health.app.sales;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 매출 관리 Service 구현체
 *
 * @CacheEvict: 매출 데이터 변경 시 통계 캐시 무효화
 * - 매출 등록/수정/삭제 시 모든 통계 캐시를 삭제하여 데이터 정합성 보장
 */
@Service
@RequiredArgsConstructor
public class SaleServiceImpl implements SaleService {

    private final SaleMapper saleMapper;

    @Override
    public Map<String, Object> getSaleList(SaleSearchDto searchDto) {
        // 페이징 처리
        if (searchDto.getPage() == null) {
            searchDto.setPage(1);
        }
        if (searchDto.getPageSize() == null) {
            searchDto.setPageSize(10);
        }
        searchDto.setOffset((searchDto.getPage() - 1) * searchDto.getPageSize());

        // 목록 조회
        List<SaleDetailDto> list = saleMapper.selectSaleList(searchDto);
        int totalCount = saleMapper.selectSaleCount(searchDto);

        Map<String, Object> result = new HashMap<>();
        result.put("list", list);
        result.put("totalCount", totalCount);
        result.put("currentPage", searchDto.getPage());
        result.put("pageSize", searchDto.getPageSize());
        result.put("totalPages", (int) Math.ceil((double) totalCount / searchDto.getPageSize()));

        return result;
    }

    @Override
    public SaleDetailDto getSaleDetail(Long saleId) {
        return saleMapper.selectSaleDetail(saleId);
    }

    @Override
    @Transactional
    @CacheEvict(value = "statistics", allEntries = true)
    public void createSale(SaleDto saleDto, Long currentUserId) {
        // 매출 번호 생성 (SALE-YYYYMMDD-XXXXXX)
        String saleNo = generateSaleNo();
        saleDto.setSaleNo(saleNo);
        saleDto.setCreateUser(currentUserId);

        saleMapper.insertSale(saleDto);
    }

    @Override
    @Transactional
    @CacheEvict(value = "statistics", allEntries = true)
    public void updateSale(SaleDto saleDto, Long currentUserId) {
        saleDto.setUpdateUser(currentUserId);
        saleMapper.updateSale(saleDto);
    }

    @Override
    @Transactional
    @CacheEvict(value = "statistics", allEntries = true)
    public void deleteSale(Long saleId, Long currentUserId) {
        saleMapper.deleteSale(saleId, currentUserId);
    }

    @Override
    @org.springframework.cache.annotation.Cacheable(value = "options", key = "'branches'")
    public List<com.health.app.inventory.OptionDto> getBranchOptions() {
        return saleMapper.selectBranchOptions();
    }

    /**
     * 매출 번호 생성 (SALE-YYYYMMDD-XXXXXX)
     */
    private String generateSaleNo() {
        String date = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        String randomNum = String.format("%06d", (int) (Math.random() * 1000000));
        return "SALE-" + date + "-" + randomNum;
    }
}
