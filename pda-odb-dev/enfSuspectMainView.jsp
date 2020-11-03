<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.enfSuspectMainBean, com.vsb.recordBean, com.vsb.systemKeysBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="systemKeysBean" scope="session" class="com.vsb.systemKeysBean" />
<jsp:useBean id="enfSuspectMainBean" scope="session" class="com.vsb.enfSuspectMainBean" />

<app:equalsInitParameter name="use_xhtml" match="Y">
  <?xml version="1.0"?>

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="enfSuspectMain" value="false">
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
  <title>enfSuspectMain</title>
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
  <form onSubmit="return singleclick();" action="enfSuspectMainScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <%-- Change the forms title if coming from the enfList --%>
          <if:IfTrue cond='<%= ! recordBean.getEnf_list_flag().equals("Y") %>' >
            <h2><font color="white"><b>Add Suspect</b></font></h2>
          </if:IfTrue>
          <if:IfTrue cond='<%= recordBean.getEnf_list_flag().equals("Y") %>' >
            <h2><font color="white"><b>Suspect</b></font></h2>
          </if:IfTrue>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="enfSuspectMainBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>
    <table width="100%" border="0">
      <tr>
        <td><b>Company</b></td>
        <td>
           <input type="text" name="suspect_company" maxlength="50" size="16"
            value="<%= enfSuspectMainBean.getSuspect_company().replace('%','*') %>" />
        </td>
      </tr>
      <tr>
        <td><b>Surname</b></td>
        <td>
           <input type="text" name="suspect_surname" maxlength="30" size="16"
            value="<%= enfSuspectMainBean.getSuspect_surname().replace('%','*') %>" />
        </td>
      </tr>
    </table>
    <%-- 05/07/2010  TW  Check for default suspect reference --%>
    <%-- Default suspect reference not available --%>
    <if:IfTrue cond='<%= systemKeysBean.getDefault_suspect_ref().equals("") %>' >
        <jsp:include page="include/back_newsus_searchsus_button.jsp" flush="true" />
    </if:IfTrue>
    <%-- Default suspect reference available, display Default button --%>
    <if:IfTrue cond='<%= !systemKeysBean.getDefault_suspect_ref().equals("") %>' >
        <jsp:include page="include/back_newsus_defaultsus_searchsus_button.jsp" flush="true" />
    </if:IfTrue>
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="enfSuspectMain" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
