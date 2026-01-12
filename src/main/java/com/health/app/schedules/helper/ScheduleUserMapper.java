package com.health.app.schedules.helper;

import org.apache.ibatis.annotations.Mapper;

/**
 * 일정 관리에서 사용자 정보를 조회하기 위한 Mapper
 * (users 패키지를 건드리지 않기 위해 schedules 패키지 내에 생성)
 */
@Mapper
public interface ScheduleUserMapper {

    /**
     * 사용자 ID로 부서 코드를 조회합니다.
     * @param userId 사용자 ID
     * @return 부서 코드 (department_code)
     */
    String selectDepartmentCodeByUserId(Long userId);
}
