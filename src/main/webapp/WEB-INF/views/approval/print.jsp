
<%@ page contentType="text/html; charset=UTF-8" %>
<%
  // 1) doc 세팅 (jspf가 ${doc.xxx}를 쓰기 때문에 필수)
  Object printObj = request.getAttribute("print");
  request.setAttribute("doc", printObj);

  // 2) 배경/필드 경로
  String bg = (String) request.getAttribute("bgImageUrl");
  String fields = (String) request.getAttribute("fieldsJspf");

  // "/WEB-INF/views/approval/..."로 들어와도 정규화
  if (fields != null && fields.startsWith("/WEB-INF/views/approval/")) {
      fields = fields.substring("/WEB-INF/views/approval/".length());
  }
%>

<style>
  /* _fields_*.jspf 가정: 좌표 기반 absolute 배치 */
  .field { position:absolute; font-size:20px; line-height:1.4; color:#111; }
  .field-sm { font-size:13px; }
  .field-lg { font-size:16px; font-weight:600; }
  .center { text-align:center; }
  .right { text-align:right; }
  .pre { white-space:pre-wrap; }
</style>

<div style="position:relative; width:1250px; margin:0 auto; background:#fff;">

	<img src="<%= bg %>"
	     style="width:100%; height:auto; display:block;
	            position:relative; z-index:1;" />


				<div style="position:absolute;
				            left:0; top:0;
				            width:100%; height:100%;
				            z-index:10;">

    <%
      // 공통(서명/결재선 등) 먼저 올리고, 이후 양식별 필드 overlay
      request.getRequestDispatcher("/WEB-INF/views/approval/print/_fields_common.jspf")
             .include(request, response);

      if (fields != null) {
          request.getRequestDispatcher("/WEB-INF/views/approval/" + fields).include(request, response);
      } else {
          out.print("fieldsJspf is null");
      }
    %>
  </div>
</div>
