package com.health.app.branch;

import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface BranchMapper {

    List<BranchDTO> selectBranchList();
    
    // ADMIN은 지점관리를 눌렀을때 본인 지점만 보이게
    List<BranchDTO> selectBranchById(Long branchId);
    
    // detail.jsp
    BranchDTO selectBranchDetail(Long branchId);
    
    // detail.jsp 밑부분에 지점 이력 조회
    List<BranchHistoryDTO> selectBranchHistoryList(@Param("branchId") Long branchId);
    
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
