package com.health.app.schedules;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
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

    @Autowired
    public ScheduleController(ScheduleService scheduleService, AttendeeSearchMapper attendeeSearchMapper) {
        this.scheduleService = scheduleService;
        this.attendeeSearchMapper = attendeeSearchMapper;
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
            @RequestParam(value = "scope", required = false) String scope) {
        
        Map<String, Object> params = new HashMap<>();
        params.put("start", start);
        params.put("end", end);
        
        if (scope != null && !scope.equalsIgnoreCase("all")) {
            params.put("scope", scope);
        }
        
        return scheduleService.getCalendarEvents(params);
    }

    @PostMapping("/events")
    public ResponseEntity<?> createEvent( // ResponseEntity의 제네릭 타입을 와일드카드로 변경
            @RequestPart("event") CalendarEventDto calendarEvent,
            @RequestPart(value = "files", required = false) List<MultipartFile> files) {
        
        try {
            CalendarEventDto createdEvent = scheduleService.createCalendarEvent(calendarEvent, files);
            return new ResponseEntity<>(createdEvent, HttpStatus.CREATED);
        } catch (TimeConflictException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("message", e.getMessage());
            errorResponse.put("conflicts", e.getConflicts());
            // Content-Type을 application/json으로 명시하여 프론트엔드에서 파싱할 수 있도록 함
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            return new ResponseEntity<>(errorResponse, headers, HttpStatus.CONFLICT); // 409 Conflict
        }
    }

    @PutMapping("/events")
    public ResponseEntity<?> updateEvent( // ResponseEntity의 제네릭 타입을 와일드카드로 변경
            @RequestPart("event") CalendarEventDto calendarEvent,
            @RequestPart(value = "files", required = false) List<MultipartFile> files) {
        
        try {
            CalendarEventDto updatedEvent = scheduleService.updateCalendarEvent(calendarEvent, files);
            return new ResponseEntity<>(updatedEvent, HttpStatus.OK);
        } catch (TimeConflictException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("message", e.getMessage());
            errorResponse.put("conflicts", e.getConflicts());
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            return new ResponseEntity<>(errorResponse, headers, HttpStatus.CONFLICT); // 409 Conflict
        }
    }

    @GetMapping("/users/search")
    @ResponseBody
    public List<AttendeeSearchDto> searchAttendees(@RequestParam("name") String name) {
        return attendeeSearchMapper.findByName(name);
    }

    @GetMapping("/manage")
    public String scheduleManageView(Model model) {
        model.addAttribute("pageTitle", "일정 관리");
        Long tempUserId = 1L; 
        List<CalendarEventDto> eventList = scheduleService.getEventsByOwner(tempUserId);
        model.addAttribute("eventList", eventList);
        return "schedules/manage";
    }

    /**
     * 특정 이벤트를 삭제하는 API 엔드포인트
     * @param eventId 삭제할 이벤트 ID
     * @return HTTP 상태 코드
     */
    @PostMapping("/events/{eventId}/delete")
    public ResponseEntity<Void> deleteEvent(@PathVariable Long eventId) {
        // TODO: 삭제 권한 확인 로직 추가
        scheduleService.deleteCalendarEvent(eventId);
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
     */
    @GetMapping("/users/details")
    @ResponseBody
    public List<AttendeeSearchDto> getUsersDetails(@RequestParam("ids") List<Long> ids) {
        return scheduleService.getUsersByIds(ids);
    }
}