<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.enfFpnRefBean, com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="enfFpnRefBean" scope="session" class="com.vsb.enfFpnRefBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />

<app:equalsInitParameter name="use_xhtml" match="Y">
  <?xml version="1.0"?>

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="enfFpnRef" value="false">
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
  <title>enfFpnRef</title>
  <style type="text/css">
    @import URL("global.css");
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
  <form onSubmit="return singleclick();" action="enfFpnRefScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>FPN Reference</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="enfFpnRefBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade /></td></tr>
    </table>
    <%-- Coming to the view with the auto generate flag being set to 'Y' can only mean an --%>
    <%-- error has occured during the FPN auto generation --%>
    <%-- If the FPN number has been auto generated, do not display the input text field --%>
    <if:IfTrue cond='<%= recordBean.getEnf_fpn_autogen_ref().equals("N") %>'>
      <table width="100%">
        <tr>
          <td align="center">
            Enter FPN Reference Number:
          </td>
        </tr>
        <tr>
          <td align="center">
            <input type="text" name="fpn_ref" value="<%= enfFpnRefBean.getFpn_ref() %>" size="20"/>
          </td>
        </tr>
      </table>
    </if:IfTrue>
    <%-- If the FPN number has been auto generated, only display the back button, --%>
    <%-- as an error has occured --%>
    <if:IfTrue cond='<%= recordBean.getEnf_fpn_autogen_ref().equals("Y") %>'>
      <jsp:include page="include/back_button.jsp" flush="true" />
    </if:IfTrue>
    <if:IfTrue cond='<%= recordBean.getEnf_fpn_autogen_ref().equals("N") %>'>
      <jsp:include page="include/back_submit_buttons.jsp" flush="true" />
    </if:IfTrue>
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="enfFpnRef" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
