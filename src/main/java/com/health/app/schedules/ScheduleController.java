package com.health.app.schedules;

import com.health.app.security.model.LoginUser;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.multipart.MultipartFile;
import com.health.app.schedules.search.AttendeeSearchDto;
import com.health.app.schedules.search.AttendeeSearchMapper;
import org.springframework.web.bind.annotation.PutMapping;


import com.health.app.schedules.TimeConflictException; // TimeConflictException 임포트
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/schedules")
public class ScheduleController {

    private final ScheduleService scheduleService;
    private final AttendeeSearchMapper attendeeSearchMapper;
    private final com.health.app.schedules.helper.ScheduleUserMapper scheduleUserMapper;

    @Autowired
    public ScheduleController(ScheduleService scheduleService, AttendeeSearchMapper attendeeSearchMapper, com.health.app.schedules.helper.ScheduleUserMapper scheduleUserMapper) {
        this.scheduleService = scheduleService;
        this.attendeeSearchMapper = attendeeSearchMapper;
        this.scheduleUserMapper = scheduleUserMapper;
    }

    @GetMapping
    public String scheduleView(Model model) {
        model.addAttribute("pageTitle", "일정");
        return "schedules/view";
    }

    @GetMapping("/events")
    @ResponseBody
    public List<CalendarEventDto> getEvents(
            @RequestParam String start,
            @RequestParam String end,
            @RequestParam(value = "scope", required = false) String scope,
            Authentication authentication) {

        Map<String, Object> params = new HashMap<>();
        params.put("start", start);
        params.put("end", end);

        // 항상 현재 로그인한 사용자의 정보를 가져와 쿼리 파라미터에 추가
        LoginUser loginUser = (LoginUser) authentication.getPrincipal();
        params.put("currentUserId", loginUser.getUserId());
        String departmentCode = scheduleUserMapper.selectDepartmentCodeByUserId(loginUser.getUserId());
        if (departmentCode != null) {
            params.put("currentUserDepartmentCode", departmentCode);
        } else {
            params.put("currentUserDepartmentCode", "NO_DEPARTMENT");
        }

        if (scope != null && !scope.equalsIgnoreCase("all")) {
            // '내 일정' 필터링
            if ("my".equalsIgnoreCase(scope)) {
                params.put("scope", "PERSONAL");
                // ownerUserId는 currentUserId를 사용하므로 별도 설정 불필요
            }
            // '부서 일정' 필터링
            else if ("department".equalsIgnoreCase(scope)) {
                params.put("scope", "DEPARTMENT");
                // currentUserDepartmentCode가 이미 설정되어 있으므로 별도 설정 불필요
            }
            // '전사 일정' 등 다른 scope 값들은 DB에 저장된 값과 일치해야 함
            else {
                params.put("scope", scope.toUpperCase());
            }
        }
        // scope가 'all'이거나 null인 경우, scope 파라미터를 설정하지 않음
        // -> 매퍼에서 이 경우를 처리하여 기본 권한을 적용


        return scheduleService.getCalendarEvents(params);
    }

    @PostMapping("/events")
    public ResponseEntity<?> createEvent(
            @RequestPart("event") String eventJson,
            @RequestPart(value = "files", required = false) List<MultipartFile> files,
            Authentication authentication) {

        try {
            // JSON 문자열을 수동으로 파싱
            com.fasterxml.jackson.databind.ObjectMapper objectMapper = new com.fasterxml.jackson.databind.ObjectMapper();
            objectMapper.registerModule(new com.fasterxml.jackson.datatype.jsr310.JavaTimeModule());
            CalendarEventDto calendarEvent = objectMapper.readValue(eventJson, CalendarEventDto.class);

            // 로그인한 사용자 정보 설정
            LoginUser loginUser = (LoginUser) authentication.getPrincipal();
            calendarEvent.setCreateUser(loginUser.getUserId());

            // 부서 일정인 경우 부서 코드 설정
            if (calendarEvent.getScope() == ScheduleType.DEPARTMENT) {
                String departmentCode = scheduleUserMapper.selectDepartmentCodeByUserId(loginUser.getUserId());
                if (departmentCode != null) {
                    calendarEvent.setDepartmentCode(departmentCode);
                }
            }

            CalendarEventDto createdEvent = scheduleService.createCalendarEvent(calendarEvent, files);
            return new ResponseEntity<>(createdEvent, HttpStatus.CREATED);
        } catch (TimeConflictException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("message", e.getMessage());
            errorResponse.put("conflicts", e.getConflicts());
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            return new ResponseEntity<>(errorResponse, headers, HttpStatus.CONFLICT);
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("message", "일정 생성 중 오류가 발생했습니다: " + e.getMessage());
            return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
        }
    }

    @PutMapping("/events")
    public ResponseEntity<?> updateEvent(
            @RequestPart("event") String eventJson,
            @RequestPart(value = "files", required = false) List<MultipartFile> files,
            @RequestParam(value = "filesToDelete", required = false) List<Long> filesToDelete,
            Authentication authentication) {

        try {
            // JSON 문자열을 수동으로 파싱
            com.fasterxml.jackson.databind.ObjectMapper objectMapper = new com.fasterxml.jackson.databind.ObjectMapper();
            objectMapper.registerModule(new com.fasterxml.jackson.datatype.jsr310.JavaTimeModule());
            CalendarEventDto calendarEvent = objectMapper.readValue(eventJson, CalendarEventDto.class);

            // 로그인한 사용자 정보 설정
            LoginUser loginUser = (LoginUser) authentication.getPrincipal();
            calendarEvent.setUpdateUser(loginUser.getUserId());

            // 부서 일정인 경우 부서 코드 설정
            if (calendarEvent.getScope() == ScheduleType.DEPARTMENT) {
                String departmentCode = scheduleUserMapper.selectDepartmentCodeByUserId(loginUser.getUserId());
                if (departmentCode != null) {
                    calendarEvent.setDepartmentCode(departmentCode);
                }
            }

            CalendarEventDto updatedEvent = scheduleService.updateCalendarEvent(calendarEvent, files, filesToDelete);
            return new ResponseEntity<>(updatedEvent, HttpStatus.OK);
        } catch (TimeConflictException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("message", e.getMessage());
            errorResponse.put("conflicts", e.getConflicts());
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            return new ResponseEntity<>(errorResponse, headers, HttpStatus.CONFLICT);
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("message", "일정 수정 중 오류가 발생했습니다: " + e.getMessage());
            return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("/users/search")
    @ResponseBody
    public List<AttendeeSearchDto> searchAttendees(@RequestParam("name") String name) {
        return attendeeSearchMapper.findByName(name);
    }

    @GetMapping("/manage")
    public String scheduleManageView(Model model, Authentication authentication) {
        model.addAttribute("pageTitle", "일정 관리");

        // 로그인한 사용자의 일정만 조회
        LoginUser loginUser = (LoginUser) authentication.getPrincipal();
        Long userId = loginUser.getUserId();

        List<CalendarEventDto> eventList = scheduleService.getEventsByOwner(userId);
        model.addAttribute("eventList", eventList);
        return "schedules/manage";
    }

    /**
     * 특정 이벤트를 삭제하는 API 엔드포인트
     * @param eventId 삭제할 이벤트 ID
     * @param authentication Spring Security 인증 객체
     * @return HTTP 상태 코드
     */
    @PostMapping("/events/{eventId}/delete")
    public ResponseEntity<Void> deleteEvent(@PathVariable Long eventId, Authentication authentication) {
        // TODO: 삭제 권한 확인 로직 추가
        LoginUser loginUser = (LoginUser) authentication.getPrincipal();
        Long userId = loginUser.getUserId();

        scheduleService.deleteCalendarEvent(eventId, userId);
        return ResponseEntity.ok().build();
    }

    /**
     * 특정 ID의 캘린더 이벤트를 조회하는 API 엔드포인트
     * @param eventId 조회할 이벤트 ID
     * @return 캘린더 이벤트 DTO와 HTTP 상태 코드
     */
    @GetMapping("/events/{eventId}")
    public ResponseEntity<CalendarEventDto> getEventById(@PathVariable Long eventId) {
        CalendarEventDto event = scheduleService.getEventById(eventId);
        return ResponseEntity.ok(event);
    }

    /**
     * 특정 ID 목록에 해당하는 사용자들의 상세 정보를 반환하는 API 엔드포인트
     * @param ids 조회할 사용자 ID 목록
     * @return AttendeeSearchDto 리스트
    @GetMapping("/users/details")
    @ResponseBody
    public List<AttendeeSearchDto> getUsersDetails(@RequestParam("ids") List<Long> ids) {
        return scheduleService.getUsersByIds(ids);
    }
     */
}