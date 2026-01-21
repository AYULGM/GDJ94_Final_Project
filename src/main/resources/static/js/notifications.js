/**
 * 알림 시스템 클라이언트
 * WebSocket을 통한 실시간 알림 수신 및 HTTP API를 통한 알림 관리
 */

class NotificationClient {
    constructor() {
        this.ws = null;
        this.userId = null;
        this.contextPath = '';
        this.reconnectInterval = 5000; // 재연결 시도 간격 (5초)
        this.maxReconnectAttempts = 10;
        this.reconnectAttempts = 0;
        this.onNewNotificationCallback = null;
    }

    /**
     * WebSocket 연결 초기화
     * @param {number} userId - 현재 로그인한 사용자 ID
     * @param {string} contextPath - 컨텍스트 경로
     */
    init(userId, contextPath = '') {
        this.userId = userId;
        this.contextPath = contextPath;
        this.connect();
        this.loadUnreadCount();
        this.setupEventHandlers();
    }

    /**
     * WebSocket 연결 수립
     */
    connect() {
        if (this.ws && this.ws.readyState === WebSocket.OPEN) {
            console.log('WebSocket already connected');
            return;
        }

        const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
        const host = window.location.host;
        const wsUrl = `${protocol}//${host}${this.contextPath}/ws/notifications?userId=${this.userId}`;

        //console.log('WebSocket 연결 시도:', wsUrl);

        this.ws = new WebSocket(wsUrl);

        this.ws.onopen = () => {
            //console.log('WebSocket 연결 성공');
            this.reconnectAttempts = 0; // 연결 성공 시 재연결 카운터 리셋
        };

        this.ws.onmessage = (event) => {
            //console.log('알림 수신:', event.data);
            const notification = JSON.parse(event.data);
            this.handleNewNotification(notification);
        };

        this.ws.onerror = (error) => {
            //console.error('WebSocket 에러:', error);
        };

        this.ws.onclose = () => {
            //console.log('WebSocket 연결 종료');
            this.attemptReconnect();
        };
    }

    /**
     * WebSocket 재연결 시도
     */
    attemptReconnect() {
        if (this.reconnectAttempts < this.maxReconnectAttempts) {
            this.reconnectAttempts++;
            //console.log(`WebSocket 재연결 시도 중... (${this.reconnectAttempts}/${this.maxReconnectAttempts})`);
            setTimeout(() => this.connect(), this.reconnectInterval);
        } else {
            console.error('WebSocket 재연결 최대 시도 횟수 초과');
        }
    }

    /**
     * 새로운 알림 수신 처리
     * @param {object} notification - 알림 객체
     */
    async handleNewNotification(notification) {
        // 읽지 않은 알림 개수 업데이트
        this.loadUnreadCount();

        // 브라우저 알림 표시 (권한이 있는 경우)
        this.showBrowserNotification(notification);

        // 알림 드롭다운이 열려있으면 목록 다시 로드
        const notificationMenu = document.getElementById('notification-menu');
        if (notificationMenu && notificationMenu.classList.contains('show')) {
            const notifications = await this.loadNotifications();
            this.renderNotifications(notifications);
        }

        // 커스텀 콜백 실행
        if (this.onNewNotificationCallback) {
            this.onNewNotificationCallback(notification);
        }
    }

    /**
     * 브라우저 푸시 알림 표시
     * @param {object} notification - 알림 객체
     */
    showBrowserNotification(notification) {
        if ('Notification' in window && Notification.permission === 'granted') {
            new Notification(notification.title, {
                body: notification.message,
                icon: '/images/notification-icon.png' // 아이콘 경로는 실제 경로로 수정 필요
            });
        }
    }

    /**
     * 읽지 않은 알림 개수 로드
     */
    async loadUnreadCount() {
        try {
            const response = await fetch(`${this.contextPath}/api/notifications/unread-count`);
            const data = await response.json();
            this.updateUnreadBadge(data.count);
        } catch (error) {
            console.error('읽지 않은 알림 개수 로드 실패:', error);
        }
    }

    /**
     * 알림 목록 로드
     * @returns {Promise<Array>} 알림 목록
     */
    async loadNotifications() {
        try {
            const response = await fetch(`${this.contextPath}/api/notifications`);
            return await response.json();
        } catch (error) {
            console.error('알림 목록 로드 실패:', error);
            return [];
        }
    }

    /**
     * 특정 알림을 읽음 처리
     * @param {number} notifId - 알림 ID
     */
    async markAsRead(notifId) {
        try {
            await fetch(`${this.contextPath}/api/notifications/${notifId}/read`, {
                method: 'POST'
            });
            this.loadUnreadCount();
        } catch (error) {
            console.error('알림 읽음 처리 실패:', error);
        }
    }

    /**
     * 특정 알림을 삭제
     * @param {number} notifId - 알림 ID
     */
    async deleteNotification(notifId) {
        try {
            await fetch(`${this.contextPath}/api/notifications/${notifId}`, {
                method: 'DELETE'
            });
            this.loadUnreadCount();
        } catch (error) {
            console.error('알림 삭제 실패:', error);
        }
    }

    /**
     * 모든 알림을 읽음 처리
     */
    async markAllAsRead() {
        try {
            await fetch(`${this.contextPath}/api/notifications/read-all`, {
                method: 'POST'
            });
            this.loadUnreadCount();
        } catch (error) {
            console.error('모든 알림 읽음 처리 실패:', error);
        }
    }

    /**
     * 읽지 않은 알림 개수 배지 업데이트
     * @param {number} count - 읽지 않은 알림 개수
     */
    updateUnreadBadge(count) {
        const badge = document.getElementById('notification-badge');
        const countText = document.getElementById('notification-count-text');
        const markAllBtn = document.getElementById('mark-all-read-btn');

        if (badge) {
            if (count > 0) {
                badge.textContent = count > 99 ? '99+' : count;
                badge.style.display = 'inline-block';
            } else {
                badge.style.display = 'none';
            }
        }

        if (countText) {
            countText.textContent = count;
        }

        if (markAllBtn) {
            markAllBtn.style.display = count > 0 ? 'inline-block' : 'none';
        }
    }

    /**
     * 알림 목록을 UI에 렌더링
     * @param {Array} notifications - 알림 목록
     */
    renderNotifications(notifications) {
        const listContainer = document.getElementById('notification-list');
        if (!listContainer) return;

        if (!notifications || notifications.length === 0) {
            listContainer.innerHTML = '<div class="dropdown-item text-center text-secondary">알림이 없습니다</div>';
            return;
        }

        listContainer.innerHTML = '';

        notifications.forEach(notification => {
            const item = document.createElement('a');
            item.href = '#';
            item.className = `dropdown-item ${notification.isRead ? '' : 'bg-light'}`;
            item.dataset.notifId = notification.notifId;
            item.dataset.relatedUrl = notification.relatedUrl || '#';

            const icon = this.getNotificationIcon(notification.notifType);
            const time = this.formatNotificationTime(notification.createdAt);

            item.innerHTML = `
                <div class="d-flex">
                    <div class="flex-shrink-0">
                        <i class="${icon} fs-4 me-3"></i>
                    </div>
                    <div class="flex-grow-1">
                        <h6 class="mb-1">${notification.title}</h6>
                        <p class="mb-1 small text-muted">${notification.message}</p>
                        <p class="mb-0 small text-secondary">
                            <i class="bi bi-clock me-1"></i>${time}
                        </p>
                    </div>
                    ${!notification.isRead ? '<div class="flex-shrink-0"><span class="badge bg-primary">New</span></div>' : ''}
                </div>
            `;

            // 클릭 이벤트
            item.addEventListener('click', async (e) => {
                e.preventDefault();
                console.log('[알림 클릭] notifId:', notification.notifId);

                try {
                    // 알림 삭제 처리
                    console.log('[알림 삭제 시작]');
                    await this.deleteNotification(notification.notifId);
                    console.log('[알림 삭제 완료]');

                    // 알림 목록에서 제거
                    item.remove();
                    console.log('[UI에서 제거 완료]');

                    // 목록이 비었으면 "알림이 없습니다" 표시
                    if (listContainer.children.length === 0) {
                        listContainer.innerHTML = '<div class="dropdown-item text-center text-secondary">알림이 없습니다</div>';
                    }

                    // 관련 페이지로 이동
                    if (notification.relatedUrl && notification.relatedUrl !== '#') {
                        console.log('[페이지 이동]', notification.relatedUrl);
                        window.location.href = notification.relatedUrl;
                    }
                } catch (error) {
                    console.error('[알림 클릭 오류]', error);
                }
            });

            listContainer.appendChild(item);
        });
    }

    /**
     * 알림 타입에 따른 아이콘 반환
     * @param {string} notifType - 알림 타입
     * @returns {string} Bootstrap Icons 클래스
     */
    getNotificationIcon(notifType) {
        const icons = {
            'EVENT_CREATED': 'bi bi-calendar-plus text-success',
            'EVENT_UPDATED': 'bi bi-calendar-event text-primary',
            'EVENT_CANCELLED': 'bi bi-calendar-x text-danger',
            'ANNOUNCEMENT': 'bi bi-megaphone text-info',
            'SETTLEMENT': 'bi bi-cash-coin text-warning',
            'FILE_UPLOAD': 'bi bi-file-earmark-arrow-up text-secondary',
            'SYSTEM': 'bi bi-gear text-dark'
        };
        return icons[notifType] || 'bi bi-bell text-secondary';
    }

    /**
     * 알림 시간을 사용자 친화적 형식으로 변환
     * @param {string} timestamp - ISO 8601 타임스탬프
     * @returns {string} 포맷된 시간 문자열
     */
    formatNotificationTime(timestamp) {
        const time = new Date(timestamp);

        // 유효하지 않은 날짜인 경우 빈 문자열 반환
        if (isNaN(time.getTime())) {
            return '';
        }

        const year = time.getFullYear();
        const month = String(time.getMonth() + 1).padStart(2, '0');
        const day = String(time.getDate()).padStart(2, '0');
        const hours = String(time.getHours()).padStart(2, '0');
        const minutes = String(time.getMinutes()).padStart(2, '0');
        const seconds = String(time.getSeconds()).padStart(2, '0');

        return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
    }

    /**
     * UI 이벤트 핸들러 설정
     */
    setupEventHandlers() {
        // 알림 드롭다운 열릴 때 알림 목록 로드
        const notificationToggle = document.getElementById('notification-toggle');
        if (notificationToggle) {
            notificationToggle.addEventListener('click', async () => {
                const notifications = await this.loadNotifications();
                this.renderNotifications(notifications);
            });
        }

        // "모두 읽음" 버튼
        const markAllBtn = document.getElementById('mark-all-read-btn');
        if (markAllBtn) {
            markAllBtn.addEventListener('click', async (e) => {
                e.preventDefault();
                await this.markAllAsRead();

                // 알림 목록 다시 로드
                const notifications = await this.loadNotifications();
                this.renderNotifications(notifications);
            });
        }
    }

    /**
     * 새로운 알림 수신 시 호출될 콜백 함수 등록
     * @param {function} callback - 콜백 함수
     */
    onNewNotification(callback) {
        this.onNewNotificationCallback = callback;
    }

    /**
     * 브라우저 알림 권한 요청
     */
    requestNotificationPermission() {
        if ('Notification' in window && Notification.permission === 'default') {
            Notification.requestPermission().then(permission => {
                console.log('브라우저 알림 권한:', permission);
            });
        }
    }

    /**
     * WebSocket 연결 종료
     */
    disconnect() {
        if (this.ws) {
            this.ws.close();
            this.ws = null;
        }
    }
}

// 전역 인스턴스 생성 (window 객체에 명시적으로 할당)
window.notificationClient = new NotificationClient();

// 하위 호환성을 위해 const도 유지
const notificationClient = window.notificationClient;
