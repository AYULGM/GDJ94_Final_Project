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
                <div class="card-tools">
                    <button type="button" class="btn btn-primary btn-sm" id="addEventBtn">
                        <i class="bi bi-plus-circle"></i> 일정 등록
                    </button>
                </div>
            </div>
            <!-- /.card-header -->
            <div class="card-body">
                <!-- 상태 필터 -->
                <div class="mb-3">
                    <div class="btn-group" role="group" aria-label="상태 필터">
                        <button type="button" class="btn btn-outline-primary status-filter active" data-status="all">
                            전체
                        </button>
                        <button type="button" class="btn btn-outline-success status-filter" data-status="SCHEDULED">
                            예정
                        </button>
                        <button type="button" class="btn btn-outline-secondary status-filter" data-status="COMPLETED">
                            완료
                        </button>
                        <button type="button" class="btn btn-outline-danger status-filter" data-status="CANCELLED">
                            취소
                        </button>
                    </div>
                </div>

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
                                    <tr data-status="${event.statusCode}">
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
                                        <label for="eventStatus">상태</label>
                                        <select class="form-control" id="eventStatus">
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
                                    <div class="form-group form-check">
                                        <input type="checkbox" class="form-check-input" id="eventAllDay">
                                        <label class="form-check-label" for="eventAllDay">종일</label>
                                    </div>
                                    <div class="form-group form-check">
                                        <input type="checkbox" class="form-check-input" id="eventRepeating">
                                        <label class="form-check-label" for="eventRepeating">반복 여부</label>
                                    </div>
                                    <div class="form-group">
                                        <label>기존 첨부파일</label>
                                        <div id="existingAttachments" class="mb-2">
                                            <!-- 기존 첨부파일 목록이 여기에 표시됩니다 -->
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

<!-- Page specific scripts - footer 전에 로드해야 함 -->
<script>
// contextPath 변수 정의 (schedules.js에서 사용)
const contextPath = '${pageContext.request.contextPath}';
</script>
<script src="<c:url value='/js/schedules.js'/>"></script>

<jsp:include page="../includes/admin_footer.jsp" />
