package com.health.app.mail;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class MailService {

    public void sendTempPassword(String to, String tempPassword) {
        System.out.println("====== 임시 비밀번호 발급 ======");
        System.out.println("EMAIL : " + to);
        System.out.println("PASSWORD : " + tempPassword);
        System.out.println("================================");
    }
}
