package com.health.app.approval;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/approval/*")
public class ApprovalController {

    @GetMapping("list")
    public void approvalList() {
    }

    @GetMapping("form")
    public void approvalForm() {
    }
    
    @GetMapping("signature")
    public void approvalSignature() {
     
    }
    
    @GetMapping("print")
    public void approvalPrint() {
     
    }
    
}
