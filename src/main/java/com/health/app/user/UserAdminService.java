package com.health.app.user;

import java.util.List;
import org.springframework.stereotype.Service;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UserAdminService {

    private final UserAdminMapper userAdminMapper;

    public List<UserAdminDTO> getUserAdminList() {
        return userAdminMapper.selectUserAdminList();
    }
}
