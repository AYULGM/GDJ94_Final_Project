<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="../includes/admin_header.jsp" />

<!-- Main content -->
<div class="row">
    <div class="col-12">
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">내가 생성한 일정 목록</h3>
            </div>
            <!-- /.card-header -->
            <div class="card-body">
                <table id="eventManageTable" class="table table-bordered table-hover">
                    <thead>
                        <tr>
                            <th>제목</th>
                            <th>유형</th>
                            <th>시작 일시</th>
                            <th>종료 일시</th>
                            <th>상태</th>
                            <th>관리</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty eventList}">
                                <c:forEach var="event" items="${eventList}">
                                    <tr>
                                        <td><c:out value="${event.title}" /></td>
                                        <td><c:out value="${event.scope.displayName}" /></td>
                                        <td><c:set var="startAtStr" value="${event.startAt.toString()}" /><c:out value="${fn:replace(startAtStr, 'T', ' ')}" /></td>
                                        <td><c:set var="endAtStr" value="${event.endAt.toString()}" /><c:out value="${fn:replace(endAtStr, 'T', ' ')}" /></td>
                                        <td><c:out value="${event.statusCode.displayName}" /></td>
                                        <td>
                                            <button class="btn btn-sm btn-primary btn-edit-event" data-event-id="${event.eventId}">수정</button>
                                            <button class="btn btn-sm btn-danger btn-delete-event" data-event-id="${event.eventId}">삭제</button>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="6" class="text-center">표시할 일정이 없습니다.</td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
            <!-- /.card-body -->
        </div>
        <!-- /.card -->
    </div>
</div>

<!-- 일정 등록/수정 Modal -->
                <div class="modal fade" id="eventModal" tabindex="-1" role="dialog" aria-labelledby="eventModalLabel" aria-hidden="true">
                    <div class="modal-dialog" role="document">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title" id="eventModalLabel">일정 등록</h5>
                                <!-- X 버튼 제거 -->
                            </div>
                            <div class="modal-body">
                                <form id="eventForm">
                                    <input type="hidden" id="eventId">
                                    
                                    <div class="form-group">
                                        <label for="eventType">일정 유형</label>
                                        <select class="form-control" id="eventType">
                                            <option value="PERSONAL">개인</option>
                                            <option value="DEPARTMENT">부서</option>
                                            <option value="COMPANY">전사</option>
                                        </select>
                                    </div>

                                    <div class="form-group">
                                        <label for="eventTitle">일정 제목</label>
                                        <input type="text" class="form-control" id="eventTitle" required>
                                    </div>
                                    <div class="form-group">
                                        <label for="eventStart">시작 일시</label>
                                        <input type="datetime-local" class="form-control" id="eventStart" required>
                                    </div>
                                    <div class="form-group">
                                        <label for="eventEnd">종료 일시</label>
                                        <input type="datetime-local" class="form-control" id="eventEnd" required>
                                    </div>
                                    <div class="form-group">
                                        <label for="eventLocation">장소</label>
                                        <input type="text" class="form-control" id="eventLocation">
                                    </div>
                                    <div class="form-group">
                                        <label for="attendeeSearch">참석자</label>
                                        <div id="selected-attendees" class="mb-2">
                                            <!-- Selected attendees will be shown here as pills -->
                                        </div>
                                        <input type="text" class="form-control" id="attendeeSearch" placeholder="이름으로 검색...">
                                        <div id="attendee-search-results" class="list-group" style="position: absolute; z-index: 1000; width: 95%;">
                                            <!-- Search results will be shown here -->
                                        </div>
                                    </div>
                                    <div class="form-group form-check">
                                        <input type="checkbox" class="form-check-input" id="eventRepeating">
                                        <label class="form-check-label" for="eventRepeating">반복 여부</label>
                                    </div>
                                    <div class="form-group">
                                        <label for="eventAttachments">파일 첨부</label>
                                        <input type="file" class="form-control-file" id="eventAttachments" multiple>
                                        <small class="form-text text-muted">다중 파일 첨부 가능. 실제 업로드 로직은 추후 추가 예정입니다.</small>
                                    </div>
                                    <div class="form-group form-check">
                                        <input type="checkbox" class="form-check-input" id="eventNotification">
                                        <label class="form-check-label" for="eventNotification">알림 설정</label>
                                        <small class="form-text text-muted">알림 설정 기능은 추후 추가 예정입니다.</small>
                                    </div>
                                    <div class="form-group">
                                        <label for="eventDescription">내용</label>
                                        <textarea class="form-control" id="eventDescription" rows="3"></textarea>
                                    </div>
                                </form>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
                                <button type="button" id="saveEventBtn" class="btn btn-primary">저장</button>
                            </div>
                        </div>
                    </div>
                </div>

<jsp:include page="../includes/admin_footer.jsp" />

<script>
    var contextPath = "${pageContext.request.contextPath}";
</script>
<!-- Page specific script for FullCalendar -->
<link href='https://cdn.jsdelivr.net/npm/fullcalendar@6.1.19/main.min.css' rel='stylesheet' />
<script src='https://cdn.jsdelivr.net/npm/fullcalendar@6.1.19/index.global.min.js'></script>
<script src="<c:url value='/js/schedules.js'/>"></script>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const tableBody = document.querySelector('#eventManageTable tbody');
    console.log('tableBody element:', tableBody); // Debug log

    if (tableBody) { // Add null check before adding listener
        tableBody.addEventListener('click', function(e) {
            // ... (rest of the code)
        // '삭제' 버튼 클릭 이벤트 위임
        if (e.target && e.target.classList.contains('btn-delete-event')) {
            const button = e.target;
            const eventId = button.dataset.eventId;

            if (confirm('정말 이 일정을 삭제하시겠습니까? 관련된 모든 정보가 삭제됩니다.')) {
                console.log('Deleting event with ID:', eventId); // Debug log
                const deleteUrl = `/schedules/events/${eventId}/delete`; // Directly use absolute path for testing
                console.log('Delete URL (modified):', deleteUrl); // New debug log
                fetch(deleteUrl, {
                    method: 'POST',
                    headers: {
                        // Spring Security CSRF 토큰이 필요할 경우 헤더에 추가
                    }
                })
                .then(response => {
                    if (response.ok) {
                        // UI에서 해당 행 제거
                        button.closest('tr').remove();
                        alert('일정이 삭제되었습니다.');
                    } else {
                        response.text().then(text => {
                            alert('삭제에 실패했습니다: ' + text);
                        });
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('삭제 중 오류가 발생했습니다.');
                });
            }
        }
        
        // '수정' 버튼 클릭 이벤트 처리
        if (e.target && e.target.classList.contains('btn-edit-event')) {
            const eventId = e.target.dataset.eventId;
            console.log('Fetching event for edit with ID:', eventId); // Debug log
            const editUrl = `/schedules/events/${eventId}`; // Directly use absolute path for testing
            console.log('Edit URL (modified):', editUrl); // New debug log

            fetch(editUrl)
                .then(response => {
