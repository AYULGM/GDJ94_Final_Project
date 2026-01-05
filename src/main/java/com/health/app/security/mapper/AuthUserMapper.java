package com.health.app.security.mapper;

import com.health.app.security.dto.AuthUserDto;
import com.health.app.security.dto.LoginHistoryDto;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;

@Mapper
public interface AuthUserMapper {

    AuthUserDto findByLoginId(@Param("loginId") String loginId);

    int increaseFailCount(@Param("userId") Long userId);

    int lockUser(@Param("userId") Long userId, @Param("lockUntil") LocalDateTime lockUntil);

    int resetFailCount(@Param("userId") Long userId);

    int insertLoginHistory(LoginHistoryDto dto);
}
