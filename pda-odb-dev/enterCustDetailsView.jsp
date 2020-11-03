<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.enterCustDetailsBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="enterCustDetailsBean" scope="session" class="com.vsb.enterCustDetailsBean" />

<app:equalsInitParameter name="use_xhtml" match="Y">
  <?xml version="1.0"?>

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="enterCustDetails" value="false">
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
  <title>enterCustDetails</title>
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
  <form onSubmit="return singleclick();" action="enterCustDetailsScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Customer Details</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="enterCustDetailsBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>
    <table width="100%">
      <tr>
        <td>
          <b>Title</b>
        </td>
        <td>
          <input type="text" name="compl_init" maxlength="10" size="10"
            value="<jsp:getProperty name="enterCustDetailsBean" property="compl_init" />" />
        </td>
      </tr>
      <tr>
        <td>
          <b>1st Name</b>
        </td>
        <td>
          <input type="text" name="compl_name" maxlength="100" size="18"
            value="<jsp:getProperty name="enterCustDetailsBean" property="compl_name" />" />
        </td>
      </tr>
      <tr>
        <td>
          <b>Surname</b>
        </td>
        <td>
          <input type="text" name="compl_surname" maxlength="100" size="18"
            value="<jsp:getProperty name="enterCustDetailsBean" property="compl_surname" />" />
        </td>
      </tr>
      <tr>
        <td>
          <b>Tel. No.</b>
        </td>
        <td>
          <input type="text" name="compl_phone" maxlength="20" size="18"
            value="<jsp:getProperty name="enterCustDetailsBean" property="compl_phone" />" />
        </td>
      </tr>
      <tr>
        <td>
          <b>Email</b>
        </td>
        <td>
          <input type="text" name="compl_email" maxlength="40" size="18"
            value="<jsp:getProperty name="enterCustDetailsBean" property="compl_email" />" />
        </td>
      </tr>
      <tr>
        <td>
          <b>Int/Ext</b>
        </td>
        <td>
          <input type="text" name="int_ext_flag" maxlength="1" size="1"
            value="<jsp:getProperty name="enterCustDetailsBean" property="int_ext_flag" />" />
        </td>
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
      <tr>
        <td>
          <b>Add Address</b>
        </td>
        <td>
          <input type="checkbox" name="address_flag" checked="checked" value="Yes" />
        </td>
      </tr>
    </table>
    <jsp:include page="include/back_continue_buttons.jsp" flush="true" />
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="enterCustDetails" /> 
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
