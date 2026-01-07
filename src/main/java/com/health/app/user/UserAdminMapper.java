package com.health.app.user;

import java.util.List;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface UserAdminMapper {

    List<UserAdminDTO> selectUserAdminList();
}
