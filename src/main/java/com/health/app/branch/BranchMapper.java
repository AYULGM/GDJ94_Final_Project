package com.health.app.branch;

import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface BranchMapper {

    List<BranchDTO> selectBranchList();
    
    BranchDTO selectBranchDetail(Long branchId);
    
    void insertBranch(BranchDTO branchDTO);

    int updateBranch(BranchDTO dto);

    int insertBranchUpdateLog(
        Long branchId,
        String changeField,
        String beforeValue,
        String afterValue,
        String reason,
        Long createUser
    );
    
    /** 지점 상태 변경 */
    int updateBranchStatus(
        @Param("branchId") Long branchId,
        @Param("statusCode") String statusCode,
        @Param("updateUser") Long updateUser
    );

    /** 지점 상태 변경 로그 */
    int insertBranchStatusLog(
        @Param("branchId") Long branchId,
        @Param("beforeStatus") String beforeStatus,
        @Param("afterStatus") String afterStatus,
        @Param("reason") String reason,
        @Param("createUser") Long createUser
    );
}
