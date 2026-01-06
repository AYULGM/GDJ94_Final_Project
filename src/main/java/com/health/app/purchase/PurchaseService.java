//package com.health.app.purchase;
//
//import jakarta.transaction.Transactional;
//import lombok.RequiredArgsConstructor;
//import org.springframework.stereotype.Service;
//
//@Service
//@RequiredArgsConstructor
//@Transactional
//public class PurchaseService {
//
//    private final PurchaseMapper purchaseMapper;
//
//    public void createPurchase(PurchaseRequestDto dto) {
//
//        // 1. 헤더 저장
//        purchaseMapper.insertPurchaseHeader(dto);
//
//        Long purchaseId = dto.getPurchaseId(); // useGeneratedKeys
//
//        // 2. 상세 저장
//        for (PurchaseRequestDto.PurchaseItemDto item : dto.getItems()) {
//            purchaseMapper.insertPurchaseDetail(purchaseId, item);
//        }
//    }
//}
