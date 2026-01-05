package com.health.app.schedules;

import org.apache.ibatis.annotations.Mapper;
import com.health.app.schedules.search.AttendeeSearchDto;
import java.util.List;

// schedule_attendees 테이블에 대한 MyBatis 매퍼 인터페이스
@Mapper
public interface ScheduleAttendeeMapper {
    void insertScheduleAttendee(ScheduleAttendeeDto scheduleAttendee);
    List<ScheduleAttendeeDto> selectScheduleAttendeesByEventId(Long eventId);
    List<AttendeeSearchDto> selectAttendeesByEventId(Long eventId);
    void updateScheduleAttendee(ScheduleAttendeeDto scheduleAttendee);
    void deleteScheduleAttendee(Long attendeeId); // 논리적 삭제를 위한 update
    void deleteAttendeesByEventId(Long eventId); // 특정 이벤트의 모든 참석자를 논리적으로 삭제
}
