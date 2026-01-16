package com.health.app.user;

import java.util.List;
import java.util.Objects;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.health.app.security.model.LoginUser;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UserAdminService {

    private final UserAdminMapper userAdminMapper;
    private final PasswordEncoder passwordEncoder;

    public List<UserAdminDTO> getUserAdminList() {
        return userAdminMapper.selectUserAdminList();
    }
    
 // ADMIN용 - 본인 지점 사용자만
    public List<UserAdminDTO> getUserAdminListByBranch(Long branchId) {
        return userAdminMapper.selectUserAdminListByBranch(branchId);
    }

    
    // 만약 URL로 사용자 상세를 접근하려 한다면.
    public UserAdminDTO getUserAdminDetail(Long userId, LoginUser loginUser) {

        UserAdminDTO user =
            userAdminMapper.selectUserAdminDetail(userId);

        // 1. 없는 사용자
        if (user == null) {
            throw new IllegalArgumentException("존재하지 않는 사용자입니다.");
        }

        // 2. 탈퇴 사용자
        if (!user.getUseYn()) {
            throw new IllegalStateException("탈퇴 처리된 사용자입니다.");
        }
        
        // 3. ADMIN이면 본인 지점만 허용
        if ("RL003".equals(loginUser.getRoleCode())) { // ADMIN

            if (!user.getBranchId().equals(loginUser.getBranchId())) {
                throw new SecurityException("접근 권한이 없습니다.");
            }
        }

        return user;
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
    public void updateUser(UserAdminDTO dto, String reason) {

        UserAdminDTO before =
            userAdminMapper.selectUserAdminDetail(dto.getUserId());

        // 1. 지점 변경
        if (!Objects.equals(before.getBranchId(), dto.getBranchId())) {
        	// 혹시라도 변경전 branchId가 없을경우
            if (before.getBranchId() == null) {

                userAdminMapper.insertUserBranchLog(
                    dto.getUserId(),
                    0L,
                    dto.getBranchId(),
                    dto.getUpdateUser(),
                    "관리자에 의한 최초 지점 배정"
                );

            } else {

                userAdminMapper.insertUserBranchLog(
                    dto.getUserId(),
                    before.getBranchId(),
                    dto.getBranchId(),
                    dto.getUpdateUser(),
                    reason
                );
            }
        }

        // 2. 권한 변경
        if (!Objects.equals(before.getRoleCode(), dto.getRoleCode())) {
            userAdminMapper.insertRoleChangeLog(
                dto.getUserId(),
                before.getRoleCode(),
                dto.getRoleCode(),
                dto.getUpdateUser(),
                reason
            );
        }

        // 3. 일반 정보 변경 (change_type 한글로 저장)
        insertUserHistoryIfChanged("이름",
            before.getName(), dto.getName(), dto, reason);

        insertUserHistoryIfChanged("이메일",
            before.getEmail(), dto.getEmail(), dto, reason);

        insertUserHistoryIfChanged("핸드폰 번호",
            before.getPhone(), dto.getPhone(), dto, reason);

        insertUserHistoryIfChanged("우편번호",
            before.getPostNo(), dto.getPostNo(), dto, reason);

        insertUserHistoryIfChanged("기본주소",
            before.getBaseAddress(), dto.getBaseAddress(), dto, reason);

        insertUserHistoryIfChanged("상세주소",
            before.getDetailAddress(), dto.getDetailAddress(), dto, reason);

//        insertUserHistoryIfChanged("부서",
//            before.getDepartmentCode(), dto.getDepartmentCode(), dto, reason);
//
//        insertUserHistoryIfChanged("사용자 상태",
//            before.getUserStatusCode(), dto.getUserStatusCode(), dto, reason);

        // 4. 실제 UPDATE
        userAdminMapper.updateUser(dto);
    }



    private void insertUserHistoryIfChanged(
            String changeType,
            String beforeValue,
            String afterValue,
            UserAdminDTO dto,
            String reason) {

        if (!Objects.equals(beforeValue, afterValue)) {
            userAdminMapper.insertUserHistory(
                dto.getUserId(),
                changeType,
                beforeValue,
                afterValue,
                reason,
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
            "비밀번호",
            "********",
            "RESET",
            "관리자에 의한 비밀번호 초기화",
            adminUserId
        );
    }

    public List<UserBranchLogDTO> getUserAllHistory(Long userId) {
        return userAdminMapper.selectUserAllHistory(userId);
    }
    
    // 회원탈퇴 기능
    @Transactional
    public void withdrawUser(Long userId,
                             Long adminId,
                             String reason) {

        UserAdminDTO before =
            userAdminMapper.selectUserAdminDetail(userId);

        // 이미 탈퇴면 종료
        if (!before.getUseYn()) return;

        // 1. 실제 탈퇴 처리
        userAdminMapper.updateUseYn(userId, adminId);

        // 2. 이력 저장
        userAdminMapper.insertUserHistory(
            userId,
            "회원 탈퇴",
            "사용중",
            "탈퇴",
            reason,      // 🔥 모달 입력 사유
            adminId
        );
    }


}
