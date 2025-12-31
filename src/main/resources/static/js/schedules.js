// Global variables
let currentScope = 'all'; // 현재 필터 scope 저장 변수 (캘린더 필터링에 사용)
let selectedAttendees = []; // {userId, name, departmentName} 객체의 배열 (모달 참석자 관리용)
let calendarInstance; // FullCalendar 인스턴스를 저장할 변수 (캘린더 인스턴스를 전역에서 접근하기 위해)

// --- Helper Functions ---

/**
 * 선택된 참석자 UI를 렌더링합니다.
 * @param {HTMLElement} container - 선택된 참석자를 표시할 DOM 요소
 */
const renderSelectedAttendees = (container) => {
    if (container) {
        container.innerHTML = '';
        selectedAttendees.forEach(user => {
            const pill = document.createElement('span');
            pill.className = 'badge bg-primary me-1';
            pill.innerHTML = `${user.name} (${user.departmentName || '부서없음'}) <span class="badge bg-danger" data-remove-id="${user.userId}" style="cursor:pointer;">X</span>`;
            container.appendChild(pill);
        });
    }
};

/**
 * 날짜를 한국어 형식으로 포맷합니다.
 * @param {Date | string} date - 포맷할 날짜 또는 날짜 문자열
 * @returns {string} 포맷된 날짜 문자열
 */
const formatDate = (date) => {
    return new Date(date).toLocaleDateString('ko-KR', {
        year: 'numeric', month: 'long', day: 'numeric', weekday: 'long'
    });
};

/**
 * 캘린더 하단의 이벤트 목록을 업데이트합니다.
 * 이 함수는 FullCalendar가 로드된 페이지에서만 의미가 있습니다.
 * @param {Date} date - 현재 선택된 날짜
 * @param {Array<Object>} allEvents - FullCalendar에서 가져온 모든 이벤트 데이터
 */
const updateEventList = (date, allEvents) => {
    const eventList = document.getElementById('event-list');
    const eventListTitle = document.getElementById('event-list-title');

    if (!eventList || !eventListTitle) return;

    eventList.innerHTML = '';
    const targetDate = new Date(date);
    targetDate.setHours(0, 0, 0, 0);

    const eventsForDate = allEvents.filter(event => {
        const eventStart = new Date(event.start);
        eventStart.setHours(0, 0, 0, 0);

        if (!event.end) {
            return eventStart.getTime() === targetDate.getTime();
        } else {
            const eventEnd = new Date(event.end);
            return targetDate >= eventStart && targetDate < eventEnd;
        }
    });

    eventListTitle.textContent = `${formatDate(date)}의 일정`;

    if (eventsForDate.length === 0) {
        eventList.innerHTML = '<li class="list-group-item">일정이 없습니다.</li>';
        return;
    }

    eventsForDate.forEach(event => {
        const li = document.createElement('li');
        li.className = 'list-group-item';
        
        const start = new Date(event.start);
        const timeString = event.allDay ? '종일' : start.toLocaleTimeString('ko-KR', { hour: '2-digit', minute: '2-digit', hour12: false });

        li.innerHTML = `<strong>${timeString}</strong> - ${event.title}`;
        
        let eventBorderColor = event.borderColor;
        if (event.rendering === 'background') {
            eventBorderColor = '#6c757d'; 
        }
        li.style.borderLeft = '5px solid ' + eventBorderColor;
        eventList.appendChild(li);
    });
};


// --- Page-Specific Initializers ---

/**
 * 참석자 검색 및 선택 기능을 초기화합니다.
 * #attendeeSearch 입력 필드가 있는 페이지에서 실행됩니다.
 */
function initAttendeeSearch() {
    const attendeeSearchInput = document.getElementById('attendeeSearch');
    const searchResultsContainer = document.getElementById('attendee-search-results');
    const selectedAttendeesContainer = document.getElementById('selected-attendees');

    // 필수 요소가 없으면 초기화하지 않음
    if (!attendeeSearchInput || !searchResultsContainer || !selectedAttendeesContainer) return;

    // 참석자 검색 및 결과 표시
    attendeeSearchInput.addEventListener('keyup', (e) => {
        const query = e.target.value.trim();
        searchResultsContainer.innerHTML = '';
        if (query.length < 1) return;

        const searchUrl = contextPath + '/schedules/users/search?name=' + encodeURIComponent(query);
        fetch(searchUrl)
            .then(response => response.json())
            .then(users => {
                searchResultsContainer.innerHTML = '';
                const unselectedUsers = users.filter(user => !selectedAttendees.some(su => su.userId === user.userId));
                
                unselectedUsers.forEach(user => {
                    const item = document.createElement('a');
                    item.href = '#';
                    item.className = 'list-group-item list-group-item-action';
                    item.textContent = `${user.name} (${user.departmentName || '부서없음'})`;
                    item.addEventListener('click', (e) => {
                        e.preventDefault();
                        selectedAttendees.push(user);
                        renderSelectedAttendees(selectedAttendeesContainer); // 컨테이너 전달
                        attendeeSearchInput.value = '';
                        searchResultsContainer.innerHTML = '';
                    });
                    searchResultsContainer.appendChild(item);
                });
            })
            .catch(error => console.error('Error fetching users:', error));
    });

    // 선택된 참석자 제거
    selectedAttendeesContainer.addEventListener('click', (e) => {
        if (e.target.dataset.removeId) {
            const userIdToRemove = parseInt(e.target.dataset.removeId, 10);
            selectedAttendees = selectedAttendees.filter(user => user.userId !== userIdToRemove);
            renderSelectedAttendees(selectedAttendeesContainer); // 컨테이너 전달
        }
    });
}

/**
 * FullCalendar를 초기화하고 관련 이벤트 핸들러를 설정합니다.
 * #calendar 요소가 있는 페이지에서 실행됩니다.
 */
function initFullCalendar() {
    const calendarEl = document.getElementById('calendar');
    if (!calendarEl) return; // 캘린더 요소가 없으면 초기화하지 않음

    calendarInstance = new FullCalendar.Calendar(calendarEl, {
        initialView: 'dayGridMonth',
        locale: 'ko',
        headerToolbar: {
            left: 'prev,next today',
            center: 'title',
            right: 'dayGridMonth,timeGridWeek,timeGridDay'
        },
        events: function(fetchInfo, successCallback, failureCallback) {
            let fetchUrl = contextPath + '/schedules/events?start=' + fetchInfo.startStr + '&end=' + fetchInfo.endStr;
            if (currentScope !== 'all') { fetchUrl += '&scope=' + currentScope; }
            console.log('FullCalendar fetch URL:', fetchUrl);
            fetch(fetchUrl)
                .then(response => response.json())
                .then(data => {
                    const formattedEvents = data.map(event => ({
                        id: event.eventId,
                        title: event.title,
                        start: event.startAt,
                        end: event.endAt,
                        allDay: event.allDay,
                        color: event.scope === 'PERSONAL' ? '#007bff' : (event.scope === 'DEPARTMENT' ? '#28a745' : '#dc3545'),
                        borderColor: event.scope === 'PERSONAL' ? '#007bff' : (event.scope === 'DEPARTMENT' ? '#28a745' : '#dc3545')
                    }));
                    successCallback(formattedEvents);
                })
                .catch(error => failureCallback(error));
        },
        dateClick: function(info) {
            updateEventList(info.date, calendarInstance.getEvents());
        },
        eventsSet: function(events) {
            updateEventList(new Date(), events);
        }
    });
    calendarInstance.render();

    // 사이드바 필터 링크 클릭 시 이벤트 처리
    document.querySelectorAll('.schedule-filter').forEach(filterLink => {
        filterLink.addEventListener('click', function(e) {
            e.preventDefault();
            currentScope = this.dataset.scope;
            document.querySelectorAll('.schedule-filter').forEach(link => link.classList.remove('active'));
            this.classList.add('active');
            calendarInstance.refetchEvents();
        });
    });
}

/**
 * 이벤트 등록/수정 모달과 관련된 로직을 초기화합니다.
 * #eventModal, #addEventBtn, #saveEventBtn 등의 요소가 있는 페이지에서 실행됩니다.
 */
function initEventModalLogic() {
    const addEventBtn = document.getElementById('addEventBtn');
    const sidebarAddBtn = document.getElementById('sidebar-add-event');
    const saveEventBtn = document.getElementById('saveEventBtn');
    const eventModal = document.getElementById('eventModal');
    
    if (!addEventBtn || !saveEventBtn || !eventModal) return;

    // "일정 등록" 버튼 (상단) 클릭 시 모달 표시
    addEventBtn.addEventListener('click', function() {
        document.getElementById('eventForm').reset();
        selectedAttendees = [];
        const selectedAttendeesContainer = document.getElementById('selected-attendees');
        renderSelectedAttendees(selectedAttendeesContainer); // 컨테이너 전달
        document.getElementById('eventId').value = '';
        document.getElementById('eventModalLabel').textContent = '일정 등록';
        const now = new Date();
        now.setMinutes(now.getMinutes() - now.getTimezoneOffset());
        document.getElementById('eventStart').value = now.toISOString().slice(0, 16);
        now.setHours(now.getHours() + 1);
        document.getElementById('eventEnd').value = now.toISOString().slice(0, 16);
        $('#eventModal').modal('show');
    });

    // "일정 등록" 메뉴 (사이드바) 클릭 시 모달 표시
    if(sidebarAddBtn) {
        sidebarAddBtn.addEventListener('click', function(e) {
            e.preventDefault();
            addEventBtn.click();
        });
    }

    // 저장 버튼 클릭 시 이벤트 처리
    saveEventBtn.addEventListener('click', function() {
        const attendeeIds = selectedAttendees.map(user => user.userId);
        const eventData = {
            eventId: document.getElementById('eventId').value || null,
            scope: document.getElementById('eventType').value,
            title: document.getElementById('eventTitle').value,
            startAt: document.getElementById('eventStart').value,
            endAt: document.getElementById('eventEnd').value,
            location: document.getElementById('eventLocation').value,
            description: document.getElementById('eventDescription').value,
            attendeeIds: attendeeIds,
            repeating: document.getElementById('eventRepeating').checked
        };

        const eventAttachmentsInput = document.getElementById('eventAttachments');
        const files = eventAttachmentsInput ? eventAttachmentsInput.files : null;
        
        const formData = new FormData();
        formData.append('event', JSON.stringify(eventData));

        if (files && files.length > 0) {
            for (let i = 0; i < files.length; i++) {
                formData.append('files', files[i]);
            }
        }

        const saveUrl = contextPath + '/schedules/events';
        console.log('Save event URL:', saveUrl);
        fetch(saveUrl, {
            method: eventData.eventId ? 'PUT' : 'POST',
            body: formData,
        })
        .then(response => {
            if (response.status === 409) {
                return response.json().then(errorBody => {
                    let errorMessage = errorBody.message + '\n\n';
                    errorBody.conflicts.forEach(conflict => {
                        errorMessage += `${conflict.userName}님의 충돌 일정:\n`;
                        conflict.conflictingEvents.forEach(event => {
                            errorMessage += `- ${event.title} (${event.startAt.substring(0, 16)} ~ ${event.endAt.substring(0, 16)})\n`;
                        });
                        errorMessage += '\n';
                    });
                    throw new Error(errorMessage);
                });
            } else if (!response.ok) {
                return response.text().then(text => { throw new Error(text) });
            }
            return response.json();
        })
        .then(data => {
            console.log('Success:', data);
            $('#eventModal').modal('hide');
            if (calendarInstance) {
                 calendarInstance.refetchEvents();
            }
            alert('일정이 성공적으로 저장되었습니다!');
        })
        .catch((error) => {
            console.error('Error:', error);
            alert('일정 저장에 실패했습니다: ' + error.message);
        });
    });
}

/**
 * 일정 관리 페이지 (#eventManageTable)에 특화된 로직을 초기화합니다.
 */
function initManagePageLogic() {
    const tableBody = document.querySelector('#eventManageTable tbody');
    // console.log('tableBody element:', tableBody); // Debug log (moved to initManagePageLogic)

    if (!tableBody) return;

    tableBody.addEventListener('click', function(e) {
        if (e.target && e.target.classList.contains('btn-delete-event')) {
            const button = e.target;
            const eventId = button.dataset.eventId;

            if (confirm('정말 이 일정을 삭제하시겠습니까? 관련된 모든 정보가 삭제됩니다.')) {
                console.log('Deleting event with ID:', eventId);
                const deleteUrl = `/schedules/events/${eventId}/delete`; // Directly use absolute path for testing
                console.log('Delete URL (modified):', deleteUrl);
                fetch(deleteUrl, {
                    method: 'POST',
                    headers: {
                        // Spring Security CSRF 토큰이 필요할 경우 헤더에 추가
                    }
                })
                .then(response => {
                    if (response.ok) {
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
        
        if (e.target && e.target.classList.contains('btn-edit-event')) {
            const eventId = e.target.dataset.eventId;
            console.log('Fetching event for edit with ID:', eventId);
            const editUrl = `/schedules/events/${eventId}`; // Directly use absolute path for testing
            console.log('Edit URL (modified):', editUrl);

            fetch(editUrl)
                .then(response => {
                    if (!response.ok) {
                        return response.text().then(text => { throw new Error(text) });
                    }
                    return response.json();
                })
                .then(event => {
                    document.getElementById('eventModalLabel').textContent = '일정 수정';
                    document.getElementById('eventId').value = event.eventId;
                    document.getElementById('eventType').value = event.scope;
                    document.getElementById('eventTitle').value = event.title;
                    document.getElementById('eventStart').value = event.startAt.slice(0, 16);
                    document.getElementById('eventEnd').value = event.endAt.slice(0, 16);
                    document.getElementById('eventLocation').value = event.location || '';
                    document.getElementById('eventDescription').value = event.description || '';
                    document.getElementById('eventRepeating').checked = event.repeating;

                    selectedAttendees = event.attendees || [];
                    const selectedAttendeesContainer = document.getElementById('selected-attendees');
                    renderSelectedAttendees(selectedAttendeesContainer); // 컨테이너 전달

                    $('#eventModal').modal('show');
                })
                .catch(error => {
                    console.error('Error fetching event for edit:', error);
                    alert('일정 정보를 불러오는 데 실패했습니다: ' + error.message);
                });
        }
    });
}


// DOMContentLoaded 이벤트 리스너
document.addEventListener('DOMContentLoaded', function() {
    // 페이지별 기능 초기화
    initAttendeeSearch();
    initFullCalendar();
    initEventModalLogic();
    initManagePageLogic();
});