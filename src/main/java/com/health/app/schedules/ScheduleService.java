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
import com.health.app.schedules.search.AttendeeSearchDto;
import com.health.app.schedules.search.AttendeeSearchMapper; // AttendeeSearchMapper 임포트

import java.util.List;
import java.util.Map;
import java.util.Collections; // Collections 임포트 추가
import java.util.HashMap;
import java.util.ArrayList;
import com.health.app.schedules.TimeConflictException;

/**
 * 일정 관련 비즈니스 로직을 처리하는 서비스 클래스
 */
@Service
public class ScheduleService {

    private final CalendarEventMapper calendarEventMapper;
    private final ScheduleAttendeeMapper scheduleAttendeeMapper;
    private final FileService fileService;
    private final AttachmentLinkRepository attachmentLinkRepository;
    private final AttendeeSearchMapper attendeeSearchMapper; // AttendeeSearchMapper 주입

    @Autowired
    public ScheduleService(CalendarEventMapper calendarEventMapper, ScheduleAttendeeMapper scheduleAttendeeMapper, FileService fileService, AttachmentLinkRepository attachmentLinkRepository, AttendeeSearchMapper attendeeSearchMapper) {
        this.calendarEventMapper = calendarEventMapper;
        this.scheduleAttendeeMapper = scheduleAttendeeMapper;
        this.fileService = fileService;
        this.attachmentLinkRepository = attachmentLinkRepository;
        this.attendeeSearchMapper = attendeeSearchMapper; // 초기화
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

        // 1. 시간 충돌 확인
        List<AttendeeConflictDto> conflicts = checkTimeConflicts(null, calendarEvent.getStartAt(), calendarEvent.getEndAt(), calendarEvent.getAttendeeIds());
        if (!conflicts.isEmpty()) {
            throw new TimeConflictException("참석자들의 일정에 충돌이 발생했습니다.", conflicts);
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
        CalendarEventDto event = calendarEventMapper.selectCalendarEventById(eventId);
        if (event != null) {
            // 참석자 정보 조회 및 설정
            List<AttendeeSearchDto> attendees = scheduleAttendeeMapper.selectAttendeesByEventId(eventId);
            event.setAttendees(attendees);
        }
        return event;
    }

    /**
     * 캘린더 이벤트를 업데이트하고 관련 참석자 및 파일 링크를 처리합니다.
     * @param calendarEvent 업데이트할 이벤트 데이터
     * @param files 첨부 파일 목록
     * @return 업데이트된 캘린더 이벤트 DTO
     */
    @Transactional
    public CalendarEventDto updateCalendarEvent(CalendarEventDto calendarEvent, List<MultipartFile> files) {
        if (calendarEvent.getEventId() == null) {
            throw new IllegalArgumentException("Event ID cannot be null for update operation.");
        }
        
        // TODO: 수정 권한 확인 로직 추가 필요 (현재는 임시로 사용자 ID 1L로 설정)
        // calendarEvent.setUpdateUser(로그인한 사용자 ID);
        calendarEvent.setUpdateDate(LocalDateTime.now());

        // 1. 시간 충돌 확인 (수정 중인 이벤트 제외)
        List<AttendeeConflictDto> conflicts = checkTimeConflicts(calendarEvent.getEventId(), calendarEvent.getStartAt(), calendarEvent.getEndAt(), calendarEvent.getAttendeeIds());
        if (!conflicts.isEmpty()) {
            throw new TimeConflictException("참석자들의 일정에 충돌이 발생했습니다.", conflicts);
        }

        // 1. 캘린더 이벤트 업데이트
        calendarEventMapper.updateCalendarEvent(calendarEvent);

        // 2. 참석자 업데이트: 기존 참석자 논리적 삭제 후 새로 삽입
        // TODO: 추후 참석자별 업데이트 로직으로 개선 필요 (현재는 전체 삭제 후 재삽입)
        scheduleAttendeeMapper.deleteAttendeesByEventId(calendarEvent.getEventId()); // 기존 참석자 논리적 삭제
        if (calendarEvent.getAttendeeIds() != null && !calendarEvent.getAttendeeIds().isEmpty()) {
            for (Long attendeeUserId : calendarEvent.getAttendeeIds()) {
                ScheduleAttendeeDto attendee = new ScheduleAttendeeDto();
                attendee.setEventId(calendarEvent.getEventId());
                attendee.setUserId(attendeeUserId);
                attendee.setAcceptanceStatus(AttendanceStatus.PENDING); // 수정 시에도 초기 PENDING
                attendee.setCreateUser(calendarEvent.getCreateUser()); // 생성자는 변경 없음
                scheduleAttendeeMapper.insertScheduleAttendee(attendee);
            }
        }

        // 3. 파일 첨부 업데이트: 새로 추가된 파일 처리
        // TODO: 기존 파일 삭제/수정 로직 추가 필요 (현재는 새로 첨부된 파일만 처리)
        if (files != null && !files.isEmpty()) {
            for (MultipartFile file : files) {
                if (!file.isEmpty()) {
                    Long fileId = fileService.storeFile(file);
                    fileService.linkFileToEntity(fileId, "CALENDAR_EVENT", calendarEvent.getEventId(), "reference", calendarEvent.getCreateUser());
                }
            }
        }

        return calendarEvent;
    }

        /**

         * 특정 ID 목록에 해당하는 사용자들을 조회합니다.

         * @param userIds 조회할 사용자 ID 목록

         * @return AttendeeSearchDto 리스트

         */

        public List<AttendeeSearchDto> getUsersByIds(List<Long> userIds) {

            if (userIds == null || userIds.isEmpty()) {

                return Collections.emptyList();

            }

            return attendeeSearchMapper.findUsersByIds(userIds);

        }

    

        /**

         * 주어진 참석자들의 일정 중 제안된 이벤트 시간과 겹치는 일정이 있는지 확인합니다.

         * @param proposedEventId 새로 생성되거나 업데이트될 이벤트의 ID (수정 시 제외, 생성 시 null)

         * @param proposedStart 제안된 이벤트의 시작 시간

         * @param proposedEnd 제안된 이벤트의 종료 시간

         * @param attendeeUserIds 제안된 이벤트의 참석자 ID 목록

         * @return 충돌하는 일정이 있는 참석자 목록 (AttendeeConflictDto)

         */

        public List<AttendeeConflictDto> checkTimeConflicts(Long proposedEventId, LocalDateTime proposedStart, LocalDateTime proposedEnd, List<Long> attendeeUserIds) {

            List<AttendeeConflictDto> conflicts = new ArrayList<>();

    

            if (attendeeUserIds == null || attendeeUserIds.isEmpty()) {

                return conflicts; // 참석자가 없으면 충돌도 없음

            }

    

            // 참석자 상세 정보를 미리 조회하여 매핑 성능 향상

            List<AttendeeSearchDto> allAttendeesDetails = attendeeSearchMapper.findUsersByIds(attendeeUserIds);

            Map<Long, AttendeeSearchDto> attendeeDetailsMap = new HashMap<>();

            for (AttendeeSearchDto dto : allAttendeesDetails) {

                attendeeDetailsMap.put(dto.getUserId(), dto);

            }

    

            for (Long attendeeUserId : attendeeUserIds) {

                Map<String, Object> params = new HashMap<>();

                params.put("userId", attendeeUserId);

                params.put("proposedStart", proposedStart);

                params.put("proposedEnd", proposedEnd);

                // 수정 중인 이벤트는 충돌 확인에서 제외 (자기 자신과의 충돌 방지)

                if (proposedEventId != null) {

                    params.put("excludeEventId", proposedEventId);

                }

    

                List<CalendarEventDto> conflictingEvents = calendarEventMapper.selectConflictingEventsForAttendee(params);

    

                if (!conflictingEvents.isEmpty()) {

                    AttendeeConflictDto conflictDto = new AttendeeConflictDto();

                    conflictDto.setUserId(attendeeUserId);

                    

                    // 참석자 이름 설정

                    AttendeeSearchDto details = attendeeDetailsMap.get(attendeeUserId);

                    if (details != null) {

                        conflictDto.setUserName(details.getName());

                    } else {

                        conflictDto.setUserName("알 수 없는 사용자"); // 기본값

                    }

                    

                    conflictDto.setConflictingEvents(conflictingEvents);

                    conflicts.add(conflictDto);

                }

            }

            return conflicts;

        }

    }

    