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

    public void join(UserDTO userDTO) {

        // 아이디 중복 체크
        if (userMapper.countByLoginId(userDTO.getLoginId()) > 0) {
            throw new IllegalStateException("이미 사용중인 아이디입니다.");
        }

        userMapper.insertUser(userDTO);
    }
}
