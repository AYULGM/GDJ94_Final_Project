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
}
