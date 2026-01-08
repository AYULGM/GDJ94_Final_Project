package com.health.app.users;

import java.util.UUID;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.health.app.mail.MailService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
@Transactional
public class UserService {

    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;
    private final MailService mailService;
    
    public void withdraw(String loginId) {
        userMapper.withdraw(loginId);
    }

    
    @Transactional(readOnly = true)
    public UserDTO findForPasswordCheck(String loginId) {
        return userMapper.selectForPasswordCheck(loginId);
    }

    
    public void updatePassword(String loginId, String encodedPassword) {
        userMapper.updatePassword(loginId, encodedPassword);
    }

    
    public void updateUser(UserDTO userDTO) {
        userMapper.updateUser(userDTO);
    }

    public void join(UserDTO userDTO) {

        // 아이디 중복 체크
        if (userMapper.countByLoginId(userDTO.getLoginId()) > 0) {
            throw new IllegalStateException("이미 사용중인 아이디입니다.");
        }

        userMapper.insertUser(userDTO);
    }
    
    @Transactional(readOnly = true)
    public boolean existsByLoginIdAndEmail(String loginId, String email) {
        return userMapper.countByLoginIdAndEmail(loginId, email) > 0;
    }

    // 🔥 마이페이지용 사용자 조회
    @Transactional(readOnly = true)
    public UserDTO findByLoginId(String loginId) {
        return userMapper.selectByLoginId(loginId);
    }
    
    // 로그인 창에서 비밀번호 찾기
    public void resetPassword(String loginId) {

        // 1️⃣ 임시 비밀번호 생성
        String tempPassword = UUID.randomUUID()
                                  .toString()
                                  .substring(0, 8);

        // 2️⃣ 암호화
        String encoded = passwordEncoder.encode(tempPassword);

        // 3️⃣ DB 업데이트
        userMapper.updatePassword(loginId, encoded);

        // 4️⃣ 이메일 발송
        mailService.sendTempPassword(loginId, tempPassword);
    }

}
