package com.health.app.notice;

import java.util.List;

import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;

public class NoticeService {
	@GetMapping("list")
	public String list( Model model) throws Exception{
		List<NoticeDTO> list = noticeService.list();
		model.addAttribute("list", list);
		
		return "board/list";
	}
	
	@GetMapping("add")
	public String add(NoticeDTO noticeDTO) {
		return "board/add";
	}
	
	@PostMapping("add")
	public String add(NoticeDTO noticeDTO, Model model, MultipartFile[] attach) throws Exception {
		
			return "board/add";
	}
	
	@GetMapping("detail")
	public String detail( Model model) throws Exception {
		
		model.addAttribute("notice", noticeDTO);
		return "board/detail";
	}
	
	@PostMapping("delete")
	public String delete(NoticeDTO noticeDTO) throws Exception {
		int result = noticeService.delete(noticeDTO);
		return "redirect:./list";
	}
	
	@GetMapping("update")
	public String update(NoticeDTO noticeDTO, Model model) throws Exception {
		
		return "board/add";
	}
	
	@PostMapping("update")
	public String update(NoticeDTO noticeDTO) throws Exception {
		int result = noticeService.update(noticeDTO);
		return "redirect:./detail?boardNum="+noticeDTO.getBoardNum();
	}
	
	@GetMapping("fileDown")
	public String fileDown(BoardFileDTO boardFileDTO, Model model) throws Exception {
		boardFileDTO = noticeService.fileDetail(boardFileDTO);
		model.addAttribute("file", boardFileDTO);
		
		
		return "fileDownView";
	}
}
