package com.health.app.branch;

import java.util.List;
import org.springframework.stereotype.Service;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class BranchService {

    private final BranchMapper branchMapper;

    public List<BranchDTO> getBranchList() {
        return branchMapper.selectBranchList();
    }
    
    public BranchDTO getBranchDetail(Long branchId) {
        return branchMapper.selectBranchDetail(branchId);
    }
}
