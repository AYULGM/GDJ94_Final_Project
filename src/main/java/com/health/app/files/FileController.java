package com.health.app.files;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jakarta.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

import com.health.app.attachments.Attachment;

@Controller
@RequestMapping("/files")
public class FileController {

    private final FileService fileService;

    @Autowired
    public FileController(FileService fileService) {
        this.fileService = fileService;
    }

    // 파일 업로드 폼을 보여주는 GET 요청 처리
    @GetMapping("/upload")
    public String showUploadForm() {
        // views/files/upload.jsp 와 같은 뷰를 반환
        return "files/upload"; 
    }

    // 파일 업로드를 처리하는 POST 요청 처리
    @PostMapping("/upload")
    public String handleFileUpload(@RequestParam("file") MultipartFile file,
                                   RedirectAttributes redirectAttributes) {
        try {
            Long fileId = fileService.storeFile(file); // Long 타입의 fileId를 반환받음
            redirectAttributes.addFlashAttribute("message",
                    "파일 업로드 성공: " + file.getOriginalFilename() + " (파일 ID: " + fileId + ")");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("message",
                    "파일 업로드 실패: " + file.getOriginalFilename() + " 에러: " + e.getMessage());
        }

        return "redirect:/files/upload"; // 업로드 폼으로 리다이렉트
    }

    // 파일 다운로드를 처리하는 GET 요청 처리
    @GetMapping("/download/{fileId}") // fileId를 경로 변수로 받음
    @ResponseBody
    public ResponseEntity<Resource> downloadFile(@PathVariable Long fileId, HttpServletRequest request) {
        // 데이터베이스에서 파일 정보 조회
        Attachment attachment = fileService.getAttachment(fileId);
        
        // 실제 파일 로드
        Resource resource = fileService.loadFileAsResource(fileId); // fileId를 사용하여 파일 로드

        // 파일의 MIME 타입 결정
        String contentType = null;
        try {
            contentType = request.getServletContext().getMimeType(resource.getFile().getAbsolutePath());
        } catch (IOException ex) {
            // MIME 타입을 결정할 수 없는 경우 기본값 설정
        }

        if (contentType == null) {
            contentType = "application/octet-stream";
        }
        
        // 파일명 인코딩 (한글 파일명 처리)
        String originalName = attachment.getOriginalName();
        String encodedFileName = URLEncoder.encode(originalName, StandardCharsets.UTF_8).replace("+", "%20");

        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(contentType))
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename*=UTF-8''" + encodedFileName)
                .body(resource);
    }
}
