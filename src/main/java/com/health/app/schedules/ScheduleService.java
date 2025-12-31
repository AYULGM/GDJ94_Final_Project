package com.health.app.schedules;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import com.health.app.schedules.ScheduleStatus;
import com.health.app.schedules.search.AttendeeSearchDto;
import com.health.app.schedules.AttendanceStatus;
import com.health.app.files.FileService;
import com.health.app.attachments.AttachmentLinkRepository; // AttachmentLinkRepository 임포트

import java.util.List;
import java.util.Map;
import java.util.Collections; // Collections 임포트 추가

/**
 * 일정 관련 비즈니스 로직을 처리하는 서비스 클래스
 */
@Service
public class ScheduleService {

    private final CalendarEventMapper calendarEventMapper;
    private final ScheduleAttendeeMapper scheduleAttendeeMapper;
    private final FileService fileService;
    private final AttachmentLinkRepository attachmentLinkRepository; // AttachmentLinkRepository 주입

    @Autowired
    public ScheduleService(CalendarEventMapper calendarEventMapper, ScheduleAttendeeMapper scheduleAttendeeMapper, FileService fileService, AttachmentLinkRepository attachmentLinkRepository) {
        this.calendarEventMapper = calendarEventMapper;
        this.scheduleAttendeeMapper = scheduleAttendeeMapper;
        this.fileService = fileService;
        this.attachmentLinkRepository = attachmentLinkRepository; // 초기화
    }

    /**
     * 파라미터에 맞는 캘린더 이벤트 목록을 조회합니다.
     *
     * @param params 필터링을 위한 파라미터 맵
     * @return 캘린더 이벤트 DTO 목록
     */
    public List<CalendarEventDto> getCalendarEvents(Map<String, Object> params) {
        return calendarEventMapper.selectCalendarEvents(params);
    }
    
    /**
     * 새로운 캘린더 이벤트를 생성하고 저장합니다.
     *
     * @param calendarEvent 생성할 이벤트 데이터
     * @param files 첨부 파일 목록
     * @return 생성된 캘린더 이벤트 DTO (ID 포함)
     */
    @Transactional
    public CalendarEventDto createCalendarEvent(CalendarEventDto calendarEvent, List<MultipartFile> files) {
        // ... (createCalendarEvent 내용 유지)
        if (calendarEvent.getCreateUser() == null) {
            calendarEvent.setCreateUser(1L);
        }
        calendarEvent.setCreateDate(LocalDateTime.now());
        calendarEvent.setUseYn(true);
        calendarEvent.setStatusCode(ScheduleStatus.SCHEDULED);

        if (calendarEvent.getAllDay() == null) {
            calendarEvent.setAllDay(false);
        }
        if (calendarEvent.getRepeating() == null) {
            calendarEvent.setRepeating(false);
        }

        calendarEventMapper.insertCalendarEvent(calendarEvent);
        Long eventId = calendarEvent.getEventId();

        if (calendarEvent.getAttendeeIds() != null && !calendarEvent.getAttendeeIds().isEmpty()) {
            for (Long attendeeUserId : calendarEvent.getAttendeeIds()) {
                ScheduleAttendeeDto attendee = new ScheduleAttendeeDto();
                attendee.setEventId(eventId);
                attendee.setUserId(attendeeUserId);
                attendee.setAcceptanceStatus(AttendanceStatus.PENDING);
                attendee.setCreateUser(calendarEvent.getCreateUser());
                scheduleAttendeeMapper.insertScheduleAttendee(attendee);
            }
        }

        if (files != null && !files.isEmpty()) {
            for (MultipartFile file : files) {
                if (!file.isEmpty()) {
                    Long fileId = fileService.storeFile(file);
                    fileService.linkFileToEntity(fileId, "CALENDAR_EVENT", eventId, "reference", calendarEvent.getCreateUser());
                }
            }
        }
        
        return calendarEvent;
    }
    
    /**
     * 특정 사용자가 생성한 모든 일정을 조회합니다.
     * @param ownerUserId 사용자 ID
     * @return 캘린더 이벤트 DTO 목록
     */
    public List<CalendarEventDto> getEventsByOwner(Long ownerUserId) {
        return calendarEventMapper.selectEventsByOwner(ownerUserId);
    }

    /**
     * 특정 이벤트를 논리적으로 삭제합니다. 관련 참석자 및 파일 링크도 함께 삭제 처리합니다.
     * @param eventId 삭제할 이벤트의 ID
     */
    @Transactional
    public void deleteCalendarEvent(Long eventId) {
        // TODO: 삭제 권한 확인 로직 추가 필요
        
        // 1. 연결된 파일 링크 논리적 삭제
        attachmentLinkRepository.logicalDeleteByEntityTypeAndEntityId("CALENDAR_EVENT", eventId);

        // 2. 연결된 참석자 논리적 삭제
        scheduleAttendeeMapper.deleteAttendeesByEventId(eventId);

        // 3. 메인 이벤트 논리적 삭제
        calendarEventMapper.deleteCalendarEvent(eventId);
    }

    /**
     * 특정 ID의 캘린더 이벤트를 조회합니다.
     * @param eventId 조회할 이벤트의 ID
     * @return 캘린더 이벤트 DTO
     * @throws RuntimeException 이벤트가 없을 경우
     */
    public CalendarEventDto getEventById(Long eventId) {
        return calendarEventMapper.selectCalendarEventById(eventId);
    }

    /**
     * 특정 ID 목록에 해당하는 사용자들을 조회합니다.
     * @param userIds 조회할 사용자 ID 목록
     * @return AttendeeSearchDto 리스트
     */
//    public List<AttendeeSearchDto> getUsersByIds(List<Long> userIds) {
//        if (userIds == null || userIds.isEmpty()) {
//            return Collections.emptyList();
//        }
//        return attendeeSearchMapper.findUsersByIds(userIds);
//    }
}