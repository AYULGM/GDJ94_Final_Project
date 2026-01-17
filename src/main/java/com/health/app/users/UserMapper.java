package com.health.app.users;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface UserMapper {
	
	// 회원탈퇴 기능
//	int withdraw(String loginId);
	
	UserDTO selectForPasswordCheck(String loginId);
	
	int updatePassword(String loginId, String password);
	
	int updateUser(UserDTO userDTO);

    int countByLoginId(String loginId);

    int insertUser(UserDTO userDTO);
    
    UserDTO selectByLoginId(String loginId);
    
    int countByLoginIdAndEmail(@Param("loginId") String loginId,
            @Param("email") String email);

}
