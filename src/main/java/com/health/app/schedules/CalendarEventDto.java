package com.health.app.schedules;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

import java.time.LocalDateTime;
import java.util.List;

import com.health.app.schedules.search.AttendeeSearchDto;

/**
 * calendar_events 테이블에 매핑되는 DTO 클래스
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CalendarEventDto {
    private Long eventId;
    private ScheduleType scope;
    private String title;
    private String description;
    private LocalDateTime startAt;
    private LocalDateTime endAt;
    private String location;
    private ScheduleStatus statusCode;
    private Boolean allDay;
    private Boolean repeating;
    private String repeatInfo;
    private String departmentCode;
    private Long ownerUserId;
    private Long branchId;

    // --- 추가 필드 ---
    private List<Long> attendeeIds; // 참석자 ID 목록
    private List<AttendeeSearchDto> attendees; // 참석자 상세 정보 목록

    private Long createUser;
    private LocalDateTime createDate;
    private Long updateUser;
    private LocalDateTime updateDate;
    private Boolean useYn;
}
