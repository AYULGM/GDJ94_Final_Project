
package com.health.app.common.error;

import jakarta.servlet.http.HttpServletRequest; import
org.springframework.http.HttpStatus; import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import org.springframework.web.method.annotation.
MethodArgumentTypeMismatchException; import
org.springframework.web.servlet.NoHandlerFoundException;

@ControllerAdvice public class GlobalExceptionHandler {

//========================= 400 Bad Request =========================

@ExceptionHandler(MethodArgumentTypeMismatchException.class) public String
handle400(Exception e, Model model) {

model.addAttribute("status", 400); model.addAttribute("message",
"잘못된 요청입니다."); model.addAttribute("detail", e.getMessage());

return "error/common"; }

//========================= 403 Forbidden =========================

@ExceptionHandler(SecurityException.class) public String handle403(Exception
e, Model model) {

model.addAttribute("status", 403); model.addAttribute("message",
"접근 권한이 없습니다."); model.addAttribute("detail", e.getMessage());

return "error/common"; }

//========================= 404 Not Found =========================
 
@ExceptionHandler(NoHandlerFoundException.class) public String
handle404(Exception e, Model model) {

model.addAttribute("status", 404); model.addAttribute("message",
"요청하신 페이지를 찾을 수 없습니다."); model.addAttribute("detail", e.getMessage());

return "error/common"; }

//========================= 500 Internal Server Error =========================

@ExceptionHandler(Exception.class) public String handle500(Exception e, Model
model) {

model.addAttribute("status", 500); model.addAttribute("message",
"서버 오류가 발생했습니다."); model.addAttribute("detail", e.getMessage());
 
return "error/common"; } }
 