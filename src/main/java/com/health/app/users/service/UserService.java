package com.health.app.users.service;

import com.health.app.users.dto.UserDTO;
import com.health.app.users.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class UserService {

    private final UserMapper userMapper;
    
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
    
    // 🔥 마이페이지용 사용자 조회
    @Transactional(readOnly = true)
    public UserDTO findByLoginId(String loginId) {
        return userMapper.selectByLoginId(loginId);
    }
}
