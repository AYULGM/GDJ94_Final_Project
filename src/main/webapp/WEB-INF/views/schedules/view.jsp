<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
	<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<jsp:include page="../includes/admin_header.jsp" />

<!-- Main content for schedule view -->
<div class="row">
    <div class="col-12">
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">월간 일정</h3>
            </div>
            <div class="card-body">
                <p>이곳에 전체 일정을 볼 수 있는 캘린더가 표시됩니다.</p>
                <!-- FullCalendar will be initialized here -->
                <div id="calendar"></div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../includes/admin_footer.jsp" />

<!-- Page specific script for FullCalendar -->
<link href='https://cdn.jsdelivr.net/npm/fullcalendar@6.1.19/main.min.css' rel='stylesheet' />
<script src='https://cdn.jsdelivr.net/npm/fullcalendar@6.1.19/index.global.min.js'></script>
<script>
document.addEventListener('DOMContentLoaded', function() {
    var calendarEl = document.getElementById('calendar');
    var calendar = new FullCalendar.Calendar(calendarEl, {
        initialView: 'dayGridMonth',
        locale: 'ko', // Korean
        headerToolbar: {
            left: 'prev,next today',
            center: 'title',
            right: 'dayGridMonth,timeGridWeek,timeGridDay'
        },
        // Example events
        events: [
            {
                title: '팀 전체 회의',
                start: '2025-12-25T10:30:00',
                end: '2025-12-25T12:30:00'
            },
            {
                title: '프로젝트 마감일',
                start: '2025-12-31'
            }
        ]
    });
    calendar.render();
});
</script>
