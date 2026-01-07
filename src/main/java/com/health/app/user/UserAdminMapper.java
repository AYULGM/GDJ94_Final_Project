package com.health.app.user;

import java.util.List;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface UserAdminMapper {

    List<UserAdminDTO> selectUserAdminList();
    
    UserAdminDTO selectUserAdminDetail(Long userId);

    void insertUser(UserAdminDTO dto);

    void updateUser(UserAdminDTO dto);

    void insertUserBranchLog(Long userId, Long beforeBranchId, Long afterBranchId,
            Long createUser, String reason);

	void insertRoleChangeLog(Long userId, String beforeRoleCode, String afterRoleCode,
	            Long createUser, String reason);
	
	void insertUserHistory(Long userId, String changeType,
	          String beforeValue, String afterValue,
	          String reason, Long createUser);

	void updateUserStatus(Long userId,
            String statusCode,
            Long updateUser);

	void updatePassword(Long userId, String password, Long updateUser);

	List<UserHistoryDTO> selectUserHistory(Long userId);

	List<UserBranchLogDTO> selectUserBranchLogs(Long userId);

	List<RoleChangeLogDTO> selectRoleChangeLogs(Long userId);

}
