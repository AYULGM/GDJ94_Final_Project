package com.health.app.notifications;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;

/**
 * WebSocket 연결 및 실시간 알림 푸시를 처리하는 핸들러
 */
@Component
public class NotificationWebSocketHandler extends TextWebSocketHandler {

    // 사용자별 WebSocket 세션을 저장하는 맵 (userId -> List of WebSocketSession)
    // 한 사용자가 여러 탭/디바이스에서 접속 가능
    private final Map<Long, List<WebSocketSession>> userSessions = new ConcurrentHashMap<>();
    private final ObjectMapper objectMapper;

    public NotificationWebSocketHandler() {
        this.objectMapper = new ObjectMapper();
        this.objectMapper.registerModule(new JavaTimeModule());
        this.objectMapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
    }

    /**
     * 클라이언트가 WebSocket 연결을 수립할 때 호출됩니다.
     * URL 쿼리 파라미터에서 userId를 읽어 세션을 등록합니다.
     * 예: ws://localhost:8080/ws/notifications?userId=1
     */
    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        // 쿼리 파라미터에서 userId 추출
        String query = session.getUri().getQuery();
        Long userId = extractUserId(query);

        if (userId != null) {
            // 사용자별 세션 목록에 추가
            userSessions.computeIfAbsent(userId, k -> new CopyOnWriteArrayList<>()).add(session);
        } else {
            session.close();
        }
    }

    /**
     * 클라이언트로부터 메시지를 수신할 때 호출됩니다.
     * (현재는 서버 -> 클라이언트 단방향 푸시만 사용)
     */
    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        // 필요시 클라이언트로부터의 메시지 처리 (예: ping/pong)
        System.out.println("메시지 수신: " + message.getPayload());
    }

    /**
     * WebSocket 연결이 종료될 때 호출됩니다.
     */
    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        // 모든 사용자 세션 목록에서 해당 세션 제거
        userSessions.values().forEach(sessions -> sessions.remove(session));
    }

    /**
     * 특정 사용자들에게 알림을 실시간으로 푸시합니다.
     * @param recipientUserIds 수신자 사용자 ID 목록
     * @param notification 전송할 알림 객체
     */
    public void pushNotification(List<Long> recipientUserIds, Notification notification) {
        for (Long userId : recipientUserIds) {
            List<WebSocketSession> sessions = userSessions.get(userId);
            if (sessions != null && !sessions.isEmpty()) {
                for (WebSocketSession session : sessions) {
                    if (session.isOpen()) {
                        try {
                            // 알림을 JSON으로 변환하여 전송
                            String jsonMessage = objectMapper.writeValueAsString(notification);
                            session.sendMessage(new TextMessage(jsonMessage));
                            System.out.println("알림 푸시 성공: userId=" + userId + ", notifId=" + notification.getNotifId());
                        } catch (IOException e) {
                            System.err.println("알림 푸시 실패: userId=" + userId + ", error=" + e.getMessage());
                        }
                    }
                }
            }
        }
    }

    /**
     * 쿼리 문자열에서 userId를 추출합니다.
     * @param query 쿼리 문자열 (예: "userId=1")
     * @return userId 또는 null
     */
    private Long extractUserId(String query) {
        if (query == null || query.isEmpty()) {
            return null;
        }
        String[] params = query.split("&");
        for (String param : params) {
            String[] keyValue = param.split("=");
            if (keyValue.length == 2 && "userId".equals(keyValue[0])) {
                try {
                    return Long.parseLong(keyValue[1]);
                } catch (NumberFormatException e) {
                    return null;
                }
            }
        }
        return null;
    }
}
