package com.health.app.files;

import com.health.app.security.model.LoginUser;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jakarta.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

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
    public String handleFileUpload(@RequestParam("file") List<MultipartFile> files,
                                   Authentication authentication,
                                   RedirectAttributes redirectAttributes) {
        // 로그인한 사용자 ID 가져오기
        LoginUser loginUser = (LoginUser) authentication.getPrincipal();
        Long userId = loginUser.getUserId();

        List<String> uploadedFiles = new ArrayList<>();
        List<String> failedFiles = new ArrayList<>();

        for (MultipartFile file : files) {
            if (file.isEmpty()) continue;
            try {
                Long fileId = fileService.storeFile(file, userId);
                uploadedFiles.add(file.getOriginalFilename() + " (ID: " + fileId + ")");
            } catch (Exception e) {
                failedFiles.add(file.getOriginalFilename());
            }
        }

        if (!uploadedFiles.isEmpty()) {
            redirectAttributes.addFlashAttribute("message",
                    "파일 업로드 성공: " + uploadedFiles.stream().collect(Collectors.joining(", ")));
        }
        if (!failedFiles.isEmpty()) {
            // 실패 메시지를 별도의 속성으로 추가하여 성공 메시지와 함께 표시될 수 있도록 함
            redirectAttributes.addFlashAttribute("errorMessage",
                    "파일 업로드 실패: " + failedFiles.stream().collect(Collectors.joining(", ")));
        }

        return "redirect:/files/upload";
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
    
    @GetMapping("/preview/{fileId}")
    @ResponseBody
    public ResponseEntity<Resource> previewFile(@PathVariable Long fileId, HttpServletRequest request) {
        // 1) DB에서 파일 메타 조회(콘텐츠 타입, storageKey 등)
        Attachment attachment = fileService.getAttachment(fileId);

        // 2) 실제 파일 리소스 로드
        Resource resource = fileService.loadFileAsResource(fileId);

        // 3) Content-Type 결정 (DB contentType 우선, 없으면 servlet mimeType)
        String contentType = attachment.getContentType();
        if (contentType == null || contentType.isBlank()) {
            try {
                contentType = request.getServletContext().getMimeType(resource.getFile().getAbsolutePath());
            } catch (IOException ignored) {}
        }
        if (contentType == null || contentType.isBlank()) {
            contentType = "application/octet-stream";
        }

        // 4) 미리보기는 attachment 헤더를 넣지 않는다 (중요)
        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(contentType))
                .body(resource);
    }

}
