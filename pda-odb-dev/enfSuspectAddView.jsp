<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.enfSuspectAddBean, com.vsb.enfSuspectMainBean" %>
<%@ page import="com.db.*, java.util.*, com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="enfSuspectAddBean" scope="session" class="com.vsb.enfSuspectAddBean" />
<jsp:useBean id="enfSuspectMainBean" scope="session" class="com.vsb.enfSuspectMainBean" />
<jsp:useBean id="enfSuspectAddPageSet" scope="session" class="com.db.PageSet" />

<app:equalsInitParameter name="use_xhtml" match="Y">
  <?xml version="1.0"?>

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="enfSuspectAdd" value="false">
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
  <title>enfSuspectAdd</title>
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
  <form onSubmit="return singleclick();" action="enfSuspectAddScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Choose Suspect</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b>
        <jsp:getProperty name="enfSuspectAddBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>

    <jsp:include page="include/rowset_nav_buttons.jsp" flush="true" />
    <% String color="#ffffff"; %>
    <table cellpadding="2" cellspacing="0" width="100%">
      <tr>
        <td colspan="2">
          <span class="subscript">sites <%= enfSuspectAddPageSet.getMinRecordInPage() %> - <%= enfSuspectAddPageSet.getMaxRecordInPage() %> of <%= enfSuspectAddPageSet.getRecordCount() %></span>
        </td>
      </tr>
      <%-- If comming from enfList flag the current suspect in red if it exists. --%>
      <if:IfTrue cond='<%= recordBean.getEnf_list_flag().equals("Y") %>' >
        <tr>
          <td colspan="2">
            <b>If the current enforcement's suspect is in the list below, it will be flagged in red.</b>
          </td>
        </tr>
      </if:IfTrue>

      <% Page thePage = enfSuspectAddPageSet.getCurrentPage(); %>
      <%
        while (thePage.next()) {
          if(color=="#ffffff") {
            color = "#ecf5ff";
          } else if (color=="#ecf5ff") {
            color = "#ffffff";
          }
      %>
        <%-- If comming from enfList flag the current suspect in red if it exists. --%>
        <if:IfTrue cond='<%= ! recordBean.getEnf_list_flag().equals("Y") %>' >
          <tr bgcolor="<%= color %>" valign="top">
        </if:IfTrue>
        <if:IfTrue cond='<%= recordBean.getEnf_list_flag().equals("Y") %>' >
          <if:IfTrue cond='<%= !recordBean.getEnf_list_suspect_ref().equals("") %>' >
            <if:IfTrue cond='<%= thePage.getField(1).equals(recordBean.getEnf_list_suspect_ref()) %>' >
              <tr bgcolor="#ff6565" valign="top">
            </if:IfTrue>
            <if:IfTrue cond='<%= !thePage.getField(1).equals(recordBean.getEnf_list_suspect_ref()) %>' >
              <tr bgcolor="<%= color %>" valign="top">
            </if:IfTrue>
          </if:IfTrue>
          <if:IfTrue cond='<%= recordBean.getEnf_list_suspect_ref().equals("") %>' >
            <tr bgcolor="<%= color %>" valign="top">
          </if:IfTrue>
        </if:IfTrue>
          <td width="10">
            <if:IfTrue cond='<%= thePage.getField(1).equals(enfSuspectAddBean.getSuspect_ref()) %>' >
              <input type="radio" name="suspect_ref" id="<%= thePage.getField(1) %>" value="<%= thePage.getField(1) %>"  checked="checked" />
            </if:IfTrue>
            <if:IfTrue cond='<%= !(thePage.getField(1).equals(enfSuspectAddBean.getSuspect_ref())) %>' >
              <input type="radio" name="suspect_ref" id="<%= thePage.getField(1) %>" value="<%= thePage.getField(1) %>" />
            </if:IfTrue>
          </td>
          <td>
          	<label for="<%= thePage.getField(1) %>">
							<if:IfTrue cond='<%= thePage.getField(4) != null %>' ><%= thePage.getField(4) %></if:IfTrue>
							<if:IfTrue cond='<%= thePage.getField(4) != null && thePage.getField(2) != null %>' >, </if:IfTrue>
							<if:IfTrue cond='<%= thePage.getField(2) != null %>' ><%= thePage.getField(2) %> </if:IfTrue>
							<if:IfTrue cond='<%= thePage.getField(3) != null %>' ><%= thePage.getField(3) %> </if:IfTrue>
							<if:IfTrue cond='<%= thePage.getField(5) != null && !((String)thePage.getField(5)).equals("")%>' ><br /><b><%= thePage.getField(5) %></b> </if:IfTrue>
          	</label>
          </td>
        </tr>
      <% } %>

      <%-- If there are no sites found --%>
      <if:IfTrue cond='<%= enfSuspectAddPageSet.getRecordCount() == 0 %>' >
        <tr>
          <td colspan="2">
            <b>No suspects available</b>
          </td>
        </tr>
      </if:IfTrue>

      <tr>
       <td colspan="2">
         <span class="subscript">sites <%= enfSuspectAddPageSet.getMinRecordInPage() %> - <%= enfSuspectAddPageSet.getMaxRecordInPage() %> of <%= enfSuspectAddPageSet.getRecordCount() %></span>
       </td>
      </tr>
    </table>
    <jsp:include page="include/rowset_nav_buttons.jsp" flush="true" />
    <jsp:include page="include/back_details_continue_buttons.jsp" flush="true" />
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="enfSuspectAdd" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
