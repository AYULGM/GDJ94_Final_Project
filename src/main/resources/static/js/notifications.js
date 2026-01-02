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

        console.log('WebSocket 연결 시도:', wsUrl);

        this.ws = new WebSocket(wsUrl);

        this.ws.onopen = () => {
            console.log('WebSocket 연결 성공');
            this.reconnectAttempts = 0; // 연결 성공 시 재연결 카운터 리셋
        };

        this.ws.onmessage = (event) => {
            console.log('알림 수신:', event.data);
            const notification = JSON.parse(event.data);
            this.handleNewNotification(notification);
        };

        this.ws.onerror = (error) => {
            console.error('WebSocket 에러:', error);
        };

        this.ws.onclose = () => {
            console.log('WebSocket 연결 종료');
            this.attemptReconnect();
        };
    }

    /**
     * WebSocket 재연결 시도
     */
    attemptReconnect() {
        if (this.reconnectAttempts < this.maxReconnectAttempts) {
            this.reconnectAttempts++;
            console.log(`WebSocket 재연결 시도 중... (${this.reconnectAttempts}/${this.maxReconnectAttempts})`);
            setTimeout(() => this.connect(), this.reconnectInterval);
        } else {
            console.error('WebSocket 재연결 최대 시도 횟수 초과');
        }
    }

    /**
     * 새로운 알림 수신 처리
     * @param {object} notification - 알림 객체
     */
    handleNewNotification(notification) {
        // 읽지 않은 알림 개수 업데이트
        this.loadUnreadCount();

        // 브라우저 알림 표시 (권한이 있는 경우)
        this.showBrowserNotification(notification);

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
        if (badge) {
            if (count > 0) {
                badge.textContent = count > 99 ? '99+' : count;
                badge.style.display = 'inline-block';
            } else {
                badge.style.display = 'none';
            }
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

// 전역 인스턴스 생성
const notificationClient = new NotificationClient();
