package com.health.app.schedules;

import lombok.Data;
import java.util.List;

@Data
public class AttendeeConflictDto {
    private Long userId;
    private String userName; // 사용자의 이름을 저장하기 위한 필드
    private List<CalendarEventDto> conflictingEvents;
}
