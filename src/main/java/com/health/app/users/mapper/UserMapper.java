package com.health.app.users.mapper;

import com.health.app.users.dto.UserDTO;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface UserMapper {
	
	int withdraw(String loginId);
	
	UserDTO selectForPasswordCheck(String loginId);
	
	int updatePassword(String loginId, String password);
	
	int updateUser(UserDTO userDTO);

    int countByLoginId(String loginId);

    int insertUser(UserDTO userDTO);
    
    UserDTO selectByLoginId(String loginId);
}
