package com.health.app.approval;

import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface ApprovalUserMapper {

    // ✅ 결재 파트 전용: 내 정보(지점/role) 조회
    ApprovalUserMiniDTO selectMyInfo(@Param("userId") Long userId);

    // ✅ 결재 파트 전용: 인수인계자 후보 조회
    List<HandoverCandidateDTO> selectHandoverCandidates(
            @Param("branchId") Long branchId,
            @Param("roleCode") String roleCode,
            @Param("excludeUserId") Long excludeUserId
    );
}
