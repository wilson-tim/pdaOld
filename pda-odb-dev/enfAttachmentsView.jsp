<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.enfAttachmentsBean, com.vsb.recordBean, com.vsb.helperBean" %>
<%@ page import="javax.sql.*, java.util.*" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="enfAttachmentsBean" scope="session" class="com.vsb.enfAttachmentsBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<app:equalsInitParameter name="use_xhtml" match="Y">
  <?xml version="1.0"?>

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="enfAttachments" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<app:equalsInitParameter name="use_xhtml" match="Y">
  <html xmlns="http://www.w3.org/1999/xhtml">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <html>
</app:equalsInitParameter>
<head>
  <!-- Set iPhone OS Safari attributes -->
  <meta name = "viewport" content = "width = device-width">

  <%-- Stop the browser from caching the page --%>
  <meta http-equiv="Cache-Control" content="no-cache"/>
  <meta http-equiv="Pragma" content="no-cache"/>
  <%-- Stop any proxy servers from caching the page --%>
  <% response.addHeader("Cache-Control", "no-cache"); %>

  <meta http-equiv="Refresh" content="<app:initParameter name="refreshInterval"/>" />
  <app:equalsInitParameter name="use_xhtml" match="Y">
    <meta http-equiv="Content-Type" content="application/xhtml+xml" />
    <% response.setContentType("application/xhtml+xml"); %>
  </app:equalsInitParameter>
  <app:equalsInitParameter name="use_xhtml" match="Y" value="false">
    <meta http-equiv="Content-Type" content="text/html" />
  </app:equalsInitParameter>
  <title>enfAttachments</title>
  <style type="text/css">
    @import url("global.css");
  </style>
  <!-- Disable the browser back button -->
  <script type="text/javascript">window.history.go(1);</script>
  <!-- Make all submit buttons single click only -->
  <script type="text/javascript">
    var allowed = true;
    function singleclick() {
      if (allowed == true ) {
        allowed = false;
        return true;
      } else {
        return false;
      }
    }
  </script>
</head>

<body onUnload="">
  <form onSubmit="return singleclick();" action="enfAttachmentsScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Attachments</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="enfAttachmentsBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>
    <table width="100%">
      <tr bgcolor="#DDDDDD">
        <td width="12%">
          <b>File ref</b>
        </td>
        <td width="12%">
          <b>Date added</b>
        </td>
        <td width="76%">
          <b>Comment</b>
        </td>
      </tr>

      <% int    recCount = 0; %>
      <% String color="#ffffff"; %>

      <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
      <sql:statement id="stmt" conn="con">
        <sql:query>
          select attach_no, doa, comment
          from attachments
          where source_no = <%= recordBean.getComplaint_no() %>
          order by doa desc
        </sql:query>
        <sql:resultSet id="rset1">
          <%
           if(color=="#ffffff") {
             color = "#ecf5ff";
           } else if (color=="#ecf5ff") {
             color = "#ffffff";
           }
          %>
          <tr bgcolor="<%= color %>" valign="top">
            <sql:getColumn position="1" to="attach_no" />
            <td width="12%">
              <b><sql:getColumn position="1" /></b>
            </td>
            <sql:getDate position="2" to="doa" format="<%= application.getInitParameter("db_date_fmt") %>" />
            <td width="12%">
              <b><%= helperBean.dispDate(((String)pageContext.getAttribute("doa")).trim(), application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %></b>
            </td>
            <sql:getColumn position="3" to="comment" />
            <td width="76%">
              <b><sql:getColumn position="3" /></b>
            </td>
          </tr>
          <% recCount++; %>
        </sql:resultSet>
        <%-- was empty --%>
        <if:IfTrue cond='<%= recCount == 0 %>' >
          <tr>
             <td colspan="3">
               <b>No attachments found</b>
             </td>
           </tr>
        </if:IfTrue>
        <%-- was not empty --%>
        <if:IfTrue cond='<%= recCount > 0 %>' >
          <tr>
            <td colspan="3">
              <span class="subscript"><%= recCount %> attachment(s)</span>
            </td>
          </tr>
        </if:IfTrue>
      </sql:statement>
      <sql:closeConnection conn="con"/>
    </table>

    <jsp:include page="include/back_button.jsp" flush="true" />
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="enfAttachments" /> 
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
