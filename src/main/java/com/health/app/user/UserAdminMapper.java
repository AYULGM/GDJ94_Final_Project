package com.health.app.user;

import java.util.List;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface UserAdminMapper {

    List<UserAdminDTO> selectUserAdminList();
    
    // 지점별 사용자 조회 (ADMIN용)
    List<UserAdminDTO> selectUserAdminListByBranch(Long branchId);

    UserAdminDTO selectUserAdminDetail(Long userId);

    void insertUser(UserAdminDTO dto);

    void updateUser(UserAdminDTO dto);

    void insertUserBranchLog(Long userId, Long beforeBranchId, Long afterBranchId,
            Long createUser, String reason);

	void insertRoleChangeLog(Long userId, String beforeRoleCode, String afterRoleCode,
	            Long createUser, String reason);
	
	// 이력 저장
	void insertUserHistory(Long userId, String changeType,
	          String beforeValue, String afterValue,
	          String reason, Long createUser);

	void updateUserStatus(Long userId,
            String statusCode,
            Long updateUser);

	void updatePassword(Long userId, String password, Long updateUser);

	List<UserBranchLogDTO> selectUserAllHistory(Long userId);
	
    // 탈퇴 처리
    int updateUseYn(Long userId, Long updateUser);

}
