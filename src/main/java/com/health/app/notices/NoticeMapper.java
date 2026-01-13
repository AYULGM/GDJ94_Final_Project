package com.health.app.notices;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.health.app.branch.BranchDTO;

import java.util.List;

@Mapper
public interface NoticeMapper {

    int insertNotice(NoticeDTO dto);
    int updateNotice(NoticeDTO dto);

    int softDelete(@Param("noticeId") Long noticeId,
                   @Param("updateUser") Long updateUser);

    NoticeDTO selectOne(@Param("noticeId") Long noticeId);

    List<NoticeDTO> selectList(@Param("branchId") Long branchId);

    int incrementViewCount(@Param("noticeId") Long noticeId);

    int deleteTargets(@Param("noticeId") Long noticeId,
            @Param("updateUser") Long updateUser);

int insertTarget(@Param("noticeId") Long noticeId,
           @Param("branchId") Long branchId,
           @Param("createUser") Long createUser);

List<BranchDTO> selectTargetBranches(@Param("noticeId") Long noticeId);
    // 수정 이력
    int insertHistory(NoticeHistoryDTO h);
}
