package com.health.app.users;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface UserMapper {
	
	int withdraw(String loginId);
	
	UserDTO selectForPasswordCheck(String loginId);
	
	int updatePassword(String loginId, String password);
	
	int updateUser(UserDTO userDTO);

    int countByLoginId(String loginId);

    int insertUser(UserDTO userDTO);
    
    UserDTO selectByLoginId(String loginId);
    
    int countByLoginIdAndEmail(@Param("loginId") String loginId,
            @Param("email") String email);

}
