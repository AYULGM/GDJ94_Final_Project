package com.health.app.commoncode;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface CommonCodeMapper {
    List<CommonCodeDTO> selectByGroup(@Param("codeGroup") String codeGroup);
}
