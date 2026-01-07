package com.health.app.user;

import java.util.List;
import java.util.Objects;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UserAdminService {

    private final UserAdminMapper userAdminMapper;
    private final PasswordEncoder passwordEncoder;

    public List<UserAdminDTO> getUserAdminList() {
        return userAdminMapper.selectUserAdminList();
    }
    
    public UserAdminDTO getUserAdminDetail(Long userId) {
        return userAdminMapper.selectUserAdminDetail(userId);
    }

    public void addUser(UserAdminDTO dto) {

        // 초기 상태
        dto.setUserStatusCode("US001");
        dto.setFailCount(0);

        // 🔥 초기 비밀번호 생성 (로그인 id에 !123을 더한게 패스워드)
        String rawPassword = dto.getLoginId() + "!123";

        // 🔥 반드시 암호화
        String encodedPassword = passwordEncoder.encode(rawPassword);
        dto.setPassword(encodedPassword);

        userAdminMapper.insertUser(dto);
    }
    
    @Transactional
    public void updateUser(UserAdminDTO dto) {

        // 1. 수정 전 데이터
        UserAdminDTO before = userAdminMapper.selectUserAdminDetail(dto.getUserId());

        // 2. 지점 변경
        if (!Objects.equals(before.getBranchId(), dto.getBranchId())) {
            userAdminMapper.insertUserBranchLog(
                dto.getUserId(),
                before.getBranchId(),
                dto.getBranchId(),
                dto.getUpdateUser(),
                "관리자에 의한 지점 변경"
            );
        }

        // 3. 권한 변경
        if (!Objects.equals(before.getRoleCode(), dto.getRoleCode())) {
            userAdminMapper.insertRoleChangeLog(
                dto.getUserId(),
                before.getRoleCode(),
                dto.getRoleCode(),
                dto.getUpdateUser(),
                "관리자에 의한 권한 변경"
            );
        }

        // 4. 일반 정보 변경 (name/email/phone/address/department)
        insertUserHistoryIfChanged("name", before.getName(), dto.getName(), dto);
        insertUserHistoryIfChanged("email", before.getEmail(), dto.getEmail(), dto);
        insertUserHistoryIfChanged("phone", before.getPhone(), dto.getPhone(), dto);
        insertUserHistoryIfChanged("post_no", before.getPostNo(), dto.getPostNo(), dto);
        insertUserHistoryIfChanged("base_address", before.getBaseAddress(), dto.getBaseAddress(), dto);
        insertUserHistoryIfChanged("detail_address", before.getDetailAddress(), dto.getDetailAddress(), dto);
        insertUserHistoryIfChanged("department_code", before.getDepartmentCode(), dto.getDepartmentCode(), dto);

        // 5. users 테이블 업데이트
        userAdminMapper.updateUser(dto);
    }

    private void insertUserHistoryIfChanged(
            String changeType,
            String beforeValue,
            String afterValue,
            UserAdminDTO dto) {

        if (!Objects.equals(beforeValue, afterValue)) {
            userAdminMapper.insertUserHistory(
                dto.getUserId(),
                changeType,
                beforeValue,
                afterValue,
                "관리자 수정",
                dto.getUpdateUser()
            );
        }
    }

    // 상태 변경 로직
    @Transactional
    public void changeUserStatus(Long userId,
                                 String newStatusCode,
                                 Long loginUserId) {

        // 1. 기존 상태 조회
        UserAdminDTO before =
            userAdminMapper.selectUserAdminDetail(userId);

        // 동일 상태면 처리 안 함
        if (Objects.equals(before.getUserStatusCode(), newStatusCode)) {
            return;
        }

        // 2. users 테이블 UPDATE
        userAdminMapper.updateUserStatus(userId, newStatusCode, loginUserId);

        // 3. user_history 기록
        userAdminMapper.insertUserHistory(
            userId,
            "status_code",
            before.getUserStatusCode(),
            newStatusCode,
            "관리자에 의한 상태 변경",
            loginUserId
        );
    }

    // 관리자 비밀번호 초기화 처리
    @Transactional
    public void resetPassword(Long userId, Long adminUserId) {

        // 1. 대상 사용자 조회
        UserAdminDTO user = userAdminMapper.selectUserAdminDetail(userId);

        // 2. 초기 비밀번호 정책
        String rawPassword = user.getLoginId() + "!123";
        String encodedPassword = passwordEncoder.encode(rawPassword);

        // 3. users 업데이트
        userAdminMapper.updatePassword(userId, encodedPassword, adminUserId);

        // 4. 이력 기록
        userAdminMapper.insertUserHistory(
            userId,
            "password",
            "********",
            "RESET",
            "관리자에 의한 비밀번호 초기화",
            adminUserId
        );
    }

    // 이력조회 메서드
    public List<UserHistoryDTO> getUserHistory(Long userId) {
        return userAdminMapper.selectUserHistory(userId);
    }
    
	 // 이력조회 메서드
    public List<UserBranchLogDTO> getUserBranchLogs(Long userId) {
        return userAdminMapper.selectUserBranchLogs(userId);
    }
    
	 // 이력조회 메서드
    public List<RoleChangeLogDTO> getRoleChangeLogs(Long userId) {
        return userAdminMapper.selectRoleChangeLogs(userId);
    }

}
