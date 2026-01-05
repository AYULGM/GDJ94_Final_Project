package com.health.app.signature;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface SignatureMapper {

    // 1) 목록
    List<SignatureDTO> selectListByUserId(@Param("userId") Long userId);

    // 2) 저장 (file_id는 attachments 저장 후 받은 값이라고 가정)
    int insertUserSignature(SignatureDTO dto);

    // 3) 삭제(soft delete)
    int softDeleteSignature(@Param("userId") Long userId,
                            @Param("signatureId") Long signatureId,
                            @Param("updateUser") Long updateUser);

    // 4) 대표 변경(2-step)
    int clearPrimary(@Param("userId") Long userId,
                     @Param("updateUser") Long updateUser);

    int setPrimary(@Param("userId") Long userId,
                   @Param("signatureId") Long signatureId,
                   @Param("updateUser") Long updateUser);

    // (선택) 대표 조회
    SignatureDTO selectPrimaryByUserId(@Param("userId") Long userId);

    // 대표 존재 여부(첫 저장 시 대표 자동 지정용)
    int countPrimary(@Param("userId") Long userId);
}
