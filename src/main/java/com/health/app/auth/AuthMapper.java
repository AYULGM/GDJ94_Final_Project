package com.health.app.auth;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface AuthMapper {
    UserLoginView selectLoginUser(@Param("loginId") String loginId);
}
