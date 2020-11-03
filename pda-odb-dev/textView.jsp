<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.textBean, com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="textBean" scope="session" class="com.vsb.textBean" />
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
<sess:equalsAttribute name="form" match="text" value="false">
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
  <title>text</title>
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
  <form onSubmit="return singleclick();" action="textScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Text</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="textBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>
    <table width="100%">
      <tr>
        <td align="center"><b><jsp:getProperty name="recordBean" property="site_name_1" /></b></td>
      </tr>
      <tr><td><hr size="1" noshade="noshade" /></td></tr>
      <tr>
        <td>
          <%-- Get the name for the position field, default to 'Exact Location' --%>
          <% String position = "Exact Location"; %>
          <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
          <sql:statement id="stmt" conn="con">
            <sql:query>
              select c_field
              from keys
              where service_c = 'ALL'
              and   keyname = 'POSITION_TITLE'
            </sql:query>
            <sql:resultSet id="rset">
              <sql:getColumn position="1" to="c_field" />
              <sql:wasNotNull>
                <% position = (String)pageContext.getAttribute("c_field"); %>
              </sql:wasNotNull>
              <sql:wasNull>
                <% position = "Exact Location"; %>
              </sql:wasNull>
            </sql:resultSet>
            <sql:wasEmpty>
              <% position = "Exact Location"; %>
            </sql:wasEmpty>
          </sql:statement>
          <sql:closeConnection conn="con"/>

          <b><%= position %></b><br/>
          <input type="text" name="exact_location" maxlength="70" size="24"
            value="<%= textBean.getExact_location() %>" />
        </td>
      </tr>
      <tr>
        <td>
          <b>Remarks</b><br/>
          <input type="text" name="remarks" maxlength="210" size="24"
            value="<%= textBean.getRemarks() %>" />
        </td>
      </tr>
      <tr>
        <td>
          <b>Text Notes</b><br/>
          <textarea rows="4" cols="28" name="text" ><jsp:getProperty name="textBean" property="text" /></textarea>
        </td>
      </tr>
    </table>
    <%-- Use Map Module --%>
    <app:equalsInitParameter name="use_map" match="Y" >
      <jsp:include page="include/back_map_finish_buttons.jsp" flush="true" />
    </app:equalsInitParameter>
    <%-- Do not show map module button --%>
    <app:equalsInitParameter name="use_map" match="N" >
      <jsp:include page="include/back_finish_buttons.jsp" flush="true" />
    </app:equalsInitParameter>
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="text" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>