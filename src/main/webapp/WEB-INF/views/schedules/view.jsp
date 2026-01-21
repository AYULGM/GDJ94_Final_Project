<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
	<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<!-- FullCalendar CSS는 header 전에 로드 -->
<link href='https://cdn.jsdelivr.net/npm/fullcalendar@6.1.19/main.min.css' rel='stylesheet' />

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
                <button id="addEventBtn" class="btn btn-primary mb-3">일정 등록</button>
                <div id="calendar"></div>

                <!-- 일정 목록 표시 영역 -->
                <div id="event-list-container" class="mt-4">
                    <h4 id="event-list-title">오늘의 일정</h4>
                    <ul id="event-list" class="list-group">
                        <!-- JS will populate this -->
                    </ul>
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
                                        <select class="form-select" id="eventType">
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
                                        <label for="eventStatus">상태</label>
                                        <select class="form-select" id="eventStatus">
                                            <option value="SCHEDULED">예정</option>
                                            <option value="COMPLETED">완료</option>
                                            <option value="CANCELLED">취소</option>
                                        </select>
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
                                    <div class="form-group">
                                        <label>기존 첨부파일</label>
                                        <div id="existingAttachments" class="mb-2">
                                        
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label for="eventAttachments">파일 추가</label>
                                        <input type="file" class="form-control-file" id="eventAttachments" multiple>
                                        <small class="form-text text-muted">다중 파일 첨부 가능</small>
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

                <!-- 일정 상세보기 Modal -->
                <div class="modal fade" id="eventDetailModal" tabindex="-1" role="dialog" aria-labelledby="eventDetailModalLabel" aria-hidden="true">
                    <div class="modal-dialog modal-lg" role="document">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title" id="eventDetailModalLabel">일정 상세보기</h5>
                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                            </div>
                            <div class="modal-body">
                                <div class="container-fluid">
                                    <div class="row mb-3">
                                        <div class="col-md-3"><strong>일정 유형</strong></div>
                                        <div class="col-md-9">
                                            <span id="detailEventType" class="badge"></span>
                                        </div>
                                    </div>
                                    <div class="row mb-3">
                                        <div class="col-md-3"><strong>제목</strong></div>
                                        <div class="col-md-9" id="detailEventTitle"></div>
                                    </div>
                                    <div class="row mb-3">
                                        <div class="col-md-3"><strong>상태</strong></div>
                                        <div class="col-md-9">
                                            <span id="detailEventStatus" class="badge"></span>
                                        </div>
                                    </div>
                                    <div class="row mb-3">
                                        <div class="col-md-3"><strong>시작 일시</strong></div>
                                        <div class="col-md-9" id="detailEventStart"></div>
                                    </div>
                                    <div class="row mb-3">
                                        <div class="col-md-3"><strong>종료 일시</strong></div>
                                        <div class="col-md-9" id="detailEventEnd"></div>
                                    </div>
                                    <div class="row mb-3">
                                        <div class="col-md-3"><strong>장소</strong></div>
                                        <div class="col-md-9" id="detailEventLocation"></div>
                                    </div>
                                    <div class="row mb-3">
                                        <div class="col-md-3"><strong>참석자</strong></div>
                                        <div class="col-md-9" id="detailEventAttendees"></div>
                                    </div>
                                    <div class="row mb-3">
                                        <div class="col-md-3"><strong>등록자</strong></div>
                                        <div class="col-md-9" id="detailEventCreator"></div>
                                    </div>
                                    <div class="row mb-3">
                                        <div class="col-md-3"><strong>참고 파일</strong></div>
                                        <div class="col-md-9" id="detailEventAttachments">
                                            <span class="text-muted">첨부된 파일이 없습니다.</span>
                                        </div>
                                    </div>
                                    <div class="row mb-3">
                                        <div class="col-md-3"><strong>내용</strong></div>
                                        <div class="col-md-9" id="detailEventDescription"></div>
                                    </div>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">닫기</button>
                                <button type="button" id="editEventFromDetailBtn" class="btn btn-primary">수정</button>
                                <button type="button" id="deleteEventFromDetailBtn" class="btn btn-danger">삭제</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Page specific scripts - footer 전에 로드해야 함 -->
<script>
// contextPath 변수 정의 (schedules.js에서 사용)
const contextPath = '${pageContext.request.contextPath}';
</script>
<script src='https://cdn.jsdelivr.net/npm/fullcalendar@6.1.19/index.global.min.js'></script>
<script src="<c:url value='/js/schedules.js'/>"></script>

<jsp:include page="../includes/admin_footer.jsp" />
