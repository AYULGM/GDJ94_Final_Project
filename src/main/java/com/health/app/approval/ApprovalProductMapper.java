package com.health.app.approval;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface ApprovalProductMapper {

    // 지점 선택 후 상품 목록
    List<ApprovalProductDTO> selectProductsByBranch(
            @Param("branchId") Long branchId
    );

    // AT005(구매요청서): product 테이블 전체(사용중) 상품
    List<ApprovalProductDTO> selectAllActiveProducts();

    // AT006(발주서): inventory 에 등록된 "내 지점" 상품만
    List<ApprovalProductDTO> selectInventoryProductsByBranch(@Param("branchId") Long branchId);
}
