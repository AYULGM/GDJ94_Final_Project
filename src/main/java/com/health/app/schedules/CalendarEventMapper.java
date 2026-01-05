package com.health.app.schedules;

import org.apache.ibatis.annotations.Mapper;
import java.util.List;
import java.util.Map;

/**
 * calendar_events 테이블에 대한 MyBatis 매퍼 인터페이스
 */
@Mapper
public interface CalendarEventMapper {
    void insertCalendarEvent(CalendarEventDto calendarEvent);
    CalendarEventDto selectCalendarEventById(Long eventId);
    List<CalendarEventDto> selectCalendarEvents(Map<String, Object> params);
    void updateCalendarEvent(CalendarEventDto calendarEvent);
    void deleteCalendarEvent(Long eventId); // 논리적 삭제를 위한 update
    List<CalendarEventDto> selectEventsByOwner(Long ownerUserId);
    List<CalendarEventDto> selectConflictingEventsForAttendee(Map<String, Object> params);

    /**
     * 종료 시간이 지난 SCHEDULED 일정을 자동으로 COMPLETED로 변경합니다.
     * @return 업데이트된 행의 수
     */
    int updatePastEventsToCompleted();
}
