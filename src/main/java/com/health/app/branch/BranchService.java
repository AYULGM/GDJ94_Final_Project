package com.health.app.branch;

import java.util.List;
import java.util.Objects;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.health.app.security.model.LoginUser;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class BranchService {

    private final BranchMapper branchMapper;

    public List<BranchDTO> getBranchList(LoginUser loginUser) {

        String role = loginUser.getRoleCode();

        // GRANDMASTER, MASTER → 전체
        if (role.equals("RL001") || role.equals("RL002")) {
            return branchMapper.selectBranchList();
        }

        // ADMIN → 본인 지점만
        if (role.equals("RL003")) {
            return branchMapper.selectBranchById(
                loginUser.getBranchId()
            );
        }

        return List.of(); // 접근 불가
    }
    
    // 지점 상세 조회
    public BranchDTO getBranchDetail(Long branchId) {
        return branchMapper.selectBranchDetail(branchId);
    }
    
    // 지점 이력 조회
    public List<BranchHistoryDTO> getBranchHistoryList(Long branchId) {
        return branchMapper.selectBranchHistoryList(branchId);
    }
    
    public void registerBranch(BranchDTO branchDTO, Long loginUserId) {
        branchDTO.setStatusCode("BS001"); // 운영중
        branchDTO.setCreateUser(loginUserId);

        branchMapper.insertBranch(branchDTO);
    }
    
    @Transactional
    public void updateBranch(BranchDTO dto, String reason, Long loginUserId) {

        // 1️⃣ 수정자 세팅 (필수)
        dto.setUpdateUser(loginUserId);

        // 2️⃣ 수정 전 데이터 조회
        BranchDTO before = branchMapper.selectBranchDetail(dto.getBranchId());

        // 3️⃣ branch UPDATE
        branchMapper.updateBranch(dto);

        // 4️⃣ 변경 이력 저장 (null-safe)
        
        if (!Objects.equals(before.getBranchName(), dto.getBranchName())) {
            branchMapper.insertBranchUpdateLog(
                dto.getBranchId(),
                "지점 이름",
                before.getBranchName(),
                dto.getBranchName(),
                reason,
                loginUserId
            );
        }
        
        if (!Objects.equals(before.getBaseAddress(), dto.getBaseAddress())) {
            branchMapper.insertBranchUpdateLog(
                dto.getBranchId(),
                "지점 기본 주소",
                before.getBaseAddress(),
                dto.getBaseAddress(),
                reason,
                loginUserId
            );
        }
        
        if (!Objects.equals(before.getDetailAddress(), dto.getDetailAddress())) {
            branchMapper.insertBranchUpdateLog(
                dto.getBranchId(),
                "지점 상세 주소",
                before.getDetailAddress(),
                dto.getDetailAddress(),
                reason,
                loginUserId
            );
        }
        
        if (!Objects.equals(before.getManagerName(), dto.getManagerName())) {
            branchMapper.insertBranchUpdateLog(
                dto.getBranchId(),
                "담당자명",
                before.getManagerName(),
                dto.getManagerName(),
                reason,
                loginUserId
            );
        }

        if (!Objects.equals(before.getManagerPhone(), dto.getManagerPhone())) {
            branchMapper.insertBranchUpdateLog(
                dto.getBranchId(),
                "지점관리자 연락처",
                before.getManagerPhone(),
                dto.getManagerPhone(),
                reason,
                loginUserId
            );
        }

        if (!Objects.equals(before.getOperatingHours(), dto.getOperatingHours())) {
            branchMapper.insertBranchUpdateLog(
                dto.getBranchId(),
                "운영 시간",
                before.getOperatingHours(),
                dto.getOperatingHours(),
                reason,
                loginUserId
            );
        }
    }

    // 지점상태변경
    @Transactional
    public void changeStatus(
            Long branchId,
            String newStatus,
            String reason,
            Long loginUserId
    ) {
        BranchDTO before = branchMapper.selectBranchDetail(branchId);

        // 1️⃣ 상태 변경
        branchMapper.updateBranchStatus(
            branchId,
            newStatus,
            loginUserId
        );

        // 2️⃣ 상태 변경 로그
        branchMapper.insertBranchStatusLog(
            branchId,
            before.getStatusCode(),
            newStatus,
            reason,
            loginUserId
        );
    }

}
