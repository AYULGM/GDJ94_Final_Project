// Global variables
let currentScope = 'all'; // 현재 필터 scope 저장 변수 (캘린더 필터링에 사용)
let selectedAttendees = []; // {userId, name, departmentName} 객체의 배열 (모달 참석자 관리용)
let calendarInstance; // FullCalendar 인스턴스를 저장할 변수 (캘린더 인스턴스를 전역에서 접근하기 위해)
let filesToDelete = []; // 삭제할 첨부파일 ID 목록

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
        eventClick: function(info) {
            // 일정 클릭 시 상세보기 모달 표시
            const eventId = info.event.id;
            showEventDetail(eventId);
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
    console.log('========== initEventModalLogic 함수 실행됨 ==========');
    const addEventBtn = document.getElementById('addEventBtn');
    const sidebarAddBtn = document.getElementById('sidebar-add-event');
    const saveEventBtn = document.getElementById('saveEventBtn');
    const eventModal = document.getElementById('eventModal');

    console.log('addEventBtn:', addEventBtn);
    console.log('saveEventBtn:', saveEventBtn);
    console.log('eventModal:', eventModal);

    // saveEventBtn과 eventModal만 필수, addEventBtn은 선택적
    if (!saveEventBtn || !eventModal) {
        console.log('필수 요소(saveEventBtn, eventModal)를 찾지 못해 initEventModalLogic 종료');
        return;
    }

    console.log('필수 요소 발견, 이벤트 리스너 등록 시작');

    // "일정 등록" 버튼 (상단) 클릭 시 모달 표시 (버튼이 있을 때만)
    if (addEventBtn) {
        addEventBtn.addEventListener('click', function() {
        document.getElementById('eventForm').reset();
        selectedAttendees = [];
        const selectedAttendeesContainer = document.getElementById('selected-attendees');
        renderSelectedAttendees(selectedAttendeesContainer); // 컨테이너 전달
        document.getElementById('eventId').value = '';
        document.getElementById('eventModalLabel').textContent = '일정 등록';
        document.getElementById('eventStatus').value = 'SCHEDULED'; // 기본값 설정
        document.getElementById('eventAllDay').checked = false; // 기본값 설정
        const now = new Date();
        now.setMinutes(now.getMinutes() - now.getTimezoneOffset());
        document.getElementById('eventStart').value = now.toISOString().slice(0, 16);
        now.setHours(now.getHours() + 1);
        document.getElementById('eventEnd').value = now.toISOString().slice(0, 16);

        // 첨부파일 관련 초기화
        filesToDelete = [];
        const existingAttachmentsContainer = document.getElementById('existingAttachments');
        if (existingAttachmentsContainer) {
            existingAttachmentsContainer.innerHTML = '<span class="text-muted">기존 첨부파일이 없습니다.</span>';
        }

        const modal = new bootstrap.Modal(document.getElementById('eventModal'));
        modal.show();
        });
    }

    // "일정 등록" 메뉴 (사이드바) 클릭 시 모달 표시
    if (sidebarAddBtn && addEventBtn) {
        sidebarAddBtn.addEventListener('click', function(e) {
            e.preventDefault();
            addEventBtn.click();
        });
    }

    console.log('저장 버튼 이벤트 리스너 등록 완료');

    // 저장 버튼 클릭 시 이벤트 처리
    saveEventBtn.addEventListener('click', function() {
        console.log('========== 저장 버튼 클릭됨 ==========');
        const attendeeIds = selectedAttendees.map(user => user.userId);
        const isEditMode = document.getElementById('eventId').value ? true : false;
        const eventData = {
            eventId: document.getElementById('eventId').value || null,
            scope: document.getElementById('eventType').value,
            title: document.getElementById('eventTitle').value,
            startAt: document.getElementById('eventStart').value,
            endAt: document.getElementById('eventEnd').value,
            location: document.getElementById('eventLocation').value,
            statusCode: document.getElementById('eventStatus').value,
            allDay: document.getElementById('eventAllDay').checked,
            description: document.getElementById('eventDescription').value,
            attendeeIds: attendeeIds,
            repeating: document.getElementById('eventRepeating').checked,
            useYn: true,
            createUser: isEditMode ? null : 1,  // 신규 등록 시에만 설정
            updateUser: isEditMode ? 1 : null   // 수정 시에만 설정
        };

        console.log('eventData:', eventData);
        console.log('수정 모드:', eventData.eventId ? 'PUT' : 'POST');

        // 유효성 검사
        if (!eventData.title || !eventData.startAt || !eventData.endAt) {
            console.log('유효성 검사 실패: 필수 항목 누락');
            alert('제목, 시작 일시, 종료 일시는 필수 입력 항목입니다.');
            return;
        }

        if (new Date(eventData.startAt) >= new Date(eventData.endAt)) {
            console.log('유효성 검사 실패: 시작/종료 시간 오류');
            alert('종료 일시는 시작 일시보다 이후여야 합니다.');
            return;
        }

        console.log('유효성 검사 통과, FormData 생성 중...');

        const eventAttachmentsInput = document.getElementById('eventAttachments');
        const files = eventAttachmentsInput ? eventAttachmentsInput.files : null;

        const formData = new FormData();
        // JSON을 Blob으로 감싸서 전송 (PUT 요청의 multipart 처리를 위해)
        const eventBlob = new Blob([JSON.stringify(eventData)], { type: 'application/json' });
        formData.append('event', eventBlob, 'event.json');

        if (files && files.length > 0) {
            for (let i = 0; i < files.length; i++) {
                formData.append('files', files[i]);
            }
        }

        // 삭제할 파일 ID 목록 추가
        if (filesToDelete && filesToDelete.length > 0) {
            filesToDelete.forEach(fileId => {
                formData.append('filesToDelete', fileId);
            });
        }

        const saveUrl = contextPath + '/schedules/events';
        const method = eventData.eventId ? 'PUT' : 'POST';
        console.log('Save event URL:', saveUrl);
        console.log('HTTP Method:', method);
        console.log('FormData 전송 시작...');

        fetch(saveUrl, {
            method: method,
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
                // response body를 한 번만 읽기 위해 text()로 먼저 읽음
                return response.text().then(text => {
                    try {
                        const errorBody = JSON.parse(text);
                        throw new Error(errorBody.message || '알 수 없는 오류가 발생했습니다.');
                    } catch (e) {
                        // JSON 파싱 실패 시 원본 텍스트 사용
                        throw new Error(text || '서버 오류가 발생했습니다.');
                    }
                });
            }
            return response.json();
        })
        .then(data => {
            console.log('Success:', data);
            const modal = bootstrap.Modal.getInstance(document.getElementById('eventModal'));
            if (modal) {
                modal.hide();
            }
            if (calendarInstance) {
                calendarInstance.refetchEvents();
            }
            alert('일정이 성공적으로 저장되었습니다!');
            // 일정 관리 페이지인 경우 페이지 새로고침
            if (window.location.pathname.includes('/manage')) {
                location.reload();
            }
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
                const deleteUrl = contextPath + `/schedules/events/${eventId}/delete`;
                console.log('Delete URL:', deleteUrl);
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
            const editUrl = contextPath + `/schedules/events/${eventId}`;
            console.log('Edit URL:', editUrl);

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
                    document.getElementById('eventStatus').value = event.statusCode || 'SCHEDULED';
                    document.getElementById('eventAllDay').checked = event.allDay || false;
                    document.getElementById('eventDescription').value = event.description || '';
                    document.getElementById('eventRepeating').checked = event.repeating;

                    selectedAttendees = event.attendees || [];
                    const selectedAttendeesContainer = document.getElementById('selected-attendees');
                    renderSelectedAttendees(selectedAttendeesContainer); // 컨테이너 전달

                    // 기존 첨부파일 표시 및 삭제 목록 초기화
                    filesToDelete = [];
                    renderExistingAttachments(event.attachments || []);

                    const modal = new bootstrap.Modal(document.getElementById('eventModal'));
                    modal.show();
                })
                .catch(error => {
                    console.error('Error fetching event for edit:', error);
                    alert('일정 정보를 불러오는 데 실패했습니다: ' + error.message);
                });
        }
    });

    // 상태 필터 버튼 이벤트 리스너
    const statusFilters = document.querySelectorAll('.status-filter');
    if (statusFilters.length > 0) {
        statusFilters.forEach(button => {
            button.addEventListener('click', function() {
                // 활성 버튼 스타일 변경
                statusFilters.forEach(btn => btn.classList.remove('active'));
                this.classList.add('active');

                const selectedStatus = this.dataset.status;
                const rows = tableBody.querySelectorAll('tr');

                rows.forEach(row => {
                    const rowStatus = row.dataset.status;
                    if (selectedStatus === 'all' || rowStatus === selectedStatus) {
                        row.style.display = '';
                    } else {
                        row.style.display = 'none';
                    }
                });
            });
        });
    }
}


/**
 * 일정 상세보기 모달을 표시합니다.
 * @param {number} eventId - 조회할 이벤트 ID
 */
function showEventDetail(eventId) {
    const detailUrl = contextPath + `/schedules/events/${eventId}`;

    fetch(detailUrl)
        .then(response => {
            if (!response.ok) {
                return response.text().then(text => { throw new Error(text) });
            }
            return response.json();
        })
        .then(event => {
            // 일정 유형 표시
            const typeMap = {
                'PERSONAL': { text: '개인', class: 'bg-primary' },
                'DEPARTMENT': { text: '부서', class: 'bg-success' },
                'COMPANY': { text: '전사', class: 'bg-danger' }
            };
            const typeInfo = typeMap[event.scope] || { text: event.scope, class: 'bg-secondary' };
            document.getElementById('detailEventType').textContent = typeInfo.text;
            document.getElementById('detailEventType').className = `badge ${typeInfo.class}`;

            // 상태 표시
            const statusMap = {
                'SCHEDULED': { text: '예정', class: 'bg-info' },
                'COMPLETED': { text: '완료', class: 'bg-success' },
                'CANCELLED': { text: '취소', class: 'bg-secondary' }
            };
            const statusInfo = statusMap[event.statusCode] || { text: event.statusCode, class: 'bg-secondary' };
            document.getElementById('detailEventStatus').textContent = statusInfo.text;
            document.getElementById('detailEventStatus').className = `badge ${statusInfo.class}`;

            // 기본 정보 표시
            document.getElementById('detailEventTitle').textContent = event.title || '';
            document.getElementById('detailEventStart').textContent = event.startAt ? event.startAt.replace('T', ' ') : '';
            document.getElementById('detailEventEnd').textContent = event.endAt ? event.endAt.replace('T', ' ') : '';
            document.getElementById('detailEventAllDay').textContent = event.allDay ? '예' : '아니오';
            document.getElementById('detailEventLocation').textContent = event.location || '-';
            document.getElementById('detailEventRepeating').textContent = event.repeating ? '예' : '아니오';
            document.getElementById('detailEventDescription').textContent = event.description || '-';

            // 참석자 표시
            const attendeesContainer = document.getElementById('detailEventAttendees');
            if (event.attendees && event.attendees.length > 0) {
                attendeesContainer.innerHTML = '';
                event.attendees.forEach(attendee => {
                    const badge = document.createElement('span');
                    badge.className = 'badge bg-info me-1';
                    badge.textContent = `${attendee.name} (${attendee.departmentName || '부서없음'})`;
                    attendeesContainer.appendChild(badge);
                });
            } else {
                attendeesContainer.innerHTML = '<span class="text-muted">참석자가 없습니다.</span>';
            }

            // 첨부파일 표시 (참고 파일)
            const attachmentsContainer = document.getElementById('detailEventAttachments');
            if (event.attachments && event.attachments.length > 0) {
                attachmentsContainer.innerHTML = '';
                event.attachments.forEach(file => {
                    const fileLink = document.createElement('div');
                    fileLink.className = 'mb-1';
                    fileLink.innerHTML = `
                        <i class="bi bi-file-earmark-arrow-down"></i>
                        <a href="${contextPath}/files/download/${file.fileId}" target="_blank">
                            ${file.originalName}
                        </a>
                        <span class="text-muted ms-2">(${formatFileSize(file.fileSize)})</span>
                    `;
                    attachmentsContainer.appendChild(fileLink);
                });
            } else {
                attachmentsContainer.innerHTML = '<span class="text-muted">첨부된 파일이 없습니다.</span>';
            }

            // 수정/삭제 버튼에 이벤트 ID 저장
            document.getElementById('editEventFromDetailBtn').dataset.eventId = eventId;
            document.getElementById('deleteEventFromDetailBtn').dataset.eventId = eventId;

            // 모달 표시
            const modal = new bootstrap.Modal(document.getElementById('eventDetailModal'));
            modal.show();
        })
        .catch(error => {
            console.error('Error fetching event detail:', error);
            alert('일정 상세 정보를 불러오는 데 실패했습니다: ' + error.message);
        });
}

/**
 * 파일 크기를 읽기 쉬운 형식으로 변환합니다.
 * @param {number} bytes - 바이트 단위 파일 크기
 * @returns {string} 포맷된 파일 크기
 */
function formatFileSize(bytes) {
    if (!bytes) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
}

/**
 * 기존 첨부파일 목록을 표시합니다.
 * @param {Array} attachments - 첨부파일 배열
 */
function renderExistingAttachments(attachments) {
    const container = document.getElementById('existingAttachments');
    if (!container) return;

    container.innerHTML = '';

    if (!attachments || attachments.length === 0) {
        container.innerHTML = '<span class="text-muted">기존 첨부파일이 없습니다.</span>';
        return;
    }

    attachments.forEach(file => {
        const fileItem = document.createElement('div');
        fileItem.className = 'd-flex align-items-center mb-2 p-2 border rounded';
        fileItem.dataset.fileId = file.fileId;
        fileItem.innerHTML = `
            <i class="bi bi-file-earmark me-2"></i>
            <span class="flex-grow-1">${file.originalName}</span>
            <span class="text-muted me-2">(${formatFileSize(file.fileSize)})</span>
            <button type="button" class="btn btn-sm btn-danger delete-attachment-btn" data-file-id="${file.fileId}">
                <i class="bi bi-trash"></i> 삭제
            </button>
        `;
        container.appendChild(fileItem);
    });

    // 삭제 버튼에 이벤트 리스너 추가
    container.querySelectorAll('.delete-attachment-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            const fileId = parseInt(this.dataset.fileId);
            // 삭제 목록에 추가
            if (!filesToDelete.includes(fileId)) {
                filesToDelete.push(fileId);
            }
            // UI에서 제거
            const fileItem = this.closest('div[data-file-id]');
            fileItem.remove();

            // 파일이 모두 삭제되었으면 안내 메시지 표시
            if (container.querySelectorAll('div[data-file-id]').length === 0) {
                container.innerHTML = '<span class="text-muted">기존 첨부파일이 없습니다.</span>';
            }
        });
    });
}

// DOMContentLoaded 이벤트 리스너
document.addEventListener('DOMContentLoaded', function() {
    console.log('========== DOMContentLoaded 이벤트 발생 ==========');
    console.log('현재 페이지 경로:', window.location.pathname);

    // 페이지별 기능 초기화
    console.log('1. initAttendeeSearch 호출');
    initAttendeeSearch();

    console.log('2. initFullCalendar 호출');
    initFullCalendar();

    console.log('3. initEventModalLogic 호출');
    initEventModalLogic();

    console.log('4. initManagePageLogic 호출');
    initManagePageLogic();

    console.log('5. 상세보기 모달 버튼 이벤트 리스너 등록');
    // 상세보기 모달에서 수정 버튼 클릭 시
    const editFromDetailBtn = document.getElementById('editEventFromDetailBtn');
    if (editFromDetailBtn) {
        editFromDetailBtn.addEventListener('click', function() {
            const eventId = this.dataset.eventId;
            // 상세보기 모달 닫기
            const detailModal = bootstrap.Modal.getInstance(document.getElementById('eventDetailModal'));
            if (detailModal) {
                detailModal.hide();
            }
            // 수정 모달 열기 (manage.jsp의 수정 로직 재사용)
            const editUrl = contextPath + `/schedules/events/${eventId}`;
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
                    document.getElementById('eventStatus').value = event.statusCode || 'SCHEDULED';
                    document.getElementById('eventAllDay').checked = event.allDay || false;
                    document.getElementById('eventDescription').value = event.description || '';
                    document.getElementById('eventRepeating').checked = event.repeating;

                    selectedAttendees = event.attendees || [];
                    const selectedAttendeesContainer = document.getElementById('selected-attendees');
                    renderSelectedAttendees(selectedAttendeesContainer);

                    // 기존 첨부파일 표시 및 삭제 목록 초기화
                    filesToDelete = [];
                    renderExistingAttachments(event.attachments || []);

                    const modal = new bootstrap.Modal(document.getElementById('eventModal'));
                    modal.show();
                })
                .catch(error => {
                    console.error('Error fetching event for edit:', error);
                    alert('일정 정보를 불러오는 데 실패했습니다: ' + error.message);
                });
        });
    }

    // 상세보기 모달에서 삭제 버튼 클릭 시
    const deleteFromDetailBtn = document.getElementById('deleteEventFromDetailBtn');
    if (deleteFromDetailBtn) {
        deleteFromDetailBtn.addEventListener('click', function() {
            const eventId = this.dataset.eventId;
            if (confirm('정말 이 일정을 삭제하시겠습니까? 관련된 모든 정보가 삭제됩니다.')) {
                const deleteUrl = contextPath + `/schedules/events/${eventId}/delete`;
                fetch(deleteUrl, {
                    method: 'POST',
                })
                .then(response => {
                    if (response.ok) {
                        alert('일정이 삭제되었습니다.');
                        // 상세보기 모달 닫기
                        const detailModal = bootstrap.Modal.getInstance(document.getElementById('eventDetailModal'));
                        if (detailModal) {
                            detailModal.hide();
                        }
                        // 캘린더 새로고침
                        if (calendarInstance) {
                            calendarInstance.refetchEvents();
                        }
                        // 일정 관리 페이지인 경우 페이지 새로고침
                        if (window.location.pathname.includes('/manage')) {
                            location.reload();
                        }
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
        });
    }

    console.log('========== 모든 초기화 함수 호출 완료 ==========');
});