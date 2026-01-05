package com.health.app.branch;

import java.util.List;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface BranchMapper {

    List<BranchDTO> selectBranchList();
    
    BranchDTO selectBranchDetail(Long branchId);
}
