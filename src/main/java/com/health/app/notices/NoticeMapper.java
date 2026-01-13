package com.health.app.notices;

import com.health.app.branch.BranchDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface NoticeMapper {

    // 공지 CRUD
    int insertNotice(NoticeDTO dto);
    int updateNotice(NoticeDTO dto);
    int softDelete(@Param("noticeId") Long noticeId, @Param("updateUser") Long updateUser);

    // 조회
    NoticeDTO selectOne(@Param("noticeId") Long noticeId);
    List<NoticeDTO> selectList(@Param("branchId") Long branchId);
    List<NoticeDTO> selectAdminList();

    // 조회수
    int incrementViewCount(@Param("noticeId") Long noticeId);

    // 대상 지점
    int deleteTargets(@Param("noticeId") Long noticeId, @Param("updateUser") Long updateUser);
    int insertTarget(@Param("noticeId") Long noticeId, @Param("branchId") Long branchId, @Param("createUser") Long createUser);
    List<Long> selectTargetBranchIds(@Param("noticeId") Long noticeId);
    List<BranchDTO> selectTargetBranches(@Param("noticeId") Long noticeId);

    // 만료 종료
    int closeExpiredNotices(@Param("updateUser") Long updateUser);

    // 변경 이력
    int insertHistory(NoticeHistoryDTO h);
}
