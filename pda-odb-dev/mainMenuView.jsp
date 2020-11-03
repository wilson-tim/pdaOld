<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.mainMenuBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="mainMenuBean" scope="session" class="com.vsb.mainMenuBean" />

<app:equalsInitParameter name="use_xhtml" match="Y">
  <?xml version="1.0"?>
  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at beginning --%>
<sess:equalsAttribute name="form" match="mainMenu" value="false">
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
  <meta name = "viewport" content = "width = device-width"/>

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
  <title>mainMenu</title>
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
  <form onSubmit="return singleclick();" action="mainMenuScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Main Menu</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="mainMenuBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>
    <table width="100%" >
      <tr>
        <td align="center">
          <b><input type="submit" name="action" value="Inspect"
            style="font-weight:bold; width: 15em; font-size:85%" /></b>
        </td>
      </tr>
      <tr>
        <td align="center">
          <b><input type="submit" name="action" value="Schedules / Complaints"
            style="font-weight:bold; width: 15em; font-size: 85%" /></b>
        </td>
      </tr>

      <%-- Only display if the environmental variable is set --%>
      <app:equalsInitParameter name="use_enf_list" match="Y" >
        <tr>
          <td align="center">
            <b><input type="submit" name="action" value="Enforcement List"
              style="font-weight:bold; width: 15em; font-size: 85%" /></b>
          </td>
        </tr>
      </app:equalsInitParameter>
      
      <%-- Only display if the environmental variable is set --%>
      <app:equalsInitParameter name="use_con_sum" match="Y" >
        <tr>
          <td align="center">
            <b><input type="submit" name="action" value="Contractor Summary"
              style="font-weight:bold; width: 15em; font-size: 85%" /></b>
          </td>
        </tr>
      </app:equalsInitParameter>
      
      <%-- Only display if the environmental variable is set --%>
      <app:equalsInitParameter name="use_con_schd" match="Y" >
        <tr>
          <td align="center">
            <b><input type="submit" name="action" value="Contractor Schedules"
              style="font-weight:bold; width: 15em; font-size: 85%" /></b>
          </td>
        </tr>
      </app:equalsInitParameter>      

      <%-- Only display if the environmental variable is set --%>
      <app:equalsInitParameter name="use_recmon" match="Y" >
        <tr>
          <td align="center">
            <b><input type="submit" name="action" value="<app:initParameter name="monitoring_title"/>"
              style="font-weight:bold; width: 15em; font-size: 85%" /></b>
          </td>
        </tr>
      </app:equalsInitParameter>

      <%-- Only display if the environmental variable is set --%>
      <app:equalsInitParameter name="use_markets" match="Y" >
        <tr>
          <td align="center">
            <b><input type="submit" name="action" value="Markets"
              style="font-weight:bold; width: 15em; font-size: 85%" /></b>
          </td>
        </tr>
      </app:equalsInitParameter>

      <%-- Only display if the environmental variable is set --%>
      <app:equalsInitParameter name="use_todo" match="Y" >
        <tr>
          <td align="center">
            <b><input type="submit" name="action" value="Todo List"
              style="font-weight:bold; width: 15em; font-size: 85%" /></b>
          </td>
        </tr>
      </app:equalsInitParameter>

      <%-- Only display Ad-Hoc button for the inspector module --%>
      <app:equalsInitParameter name="module" match="pda-in" >
        <%-- This section is only allowed to be accessed if bv199 has been installed. --%>
        <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
        <sql:statement id="stmt" conn="con">
          <sql:query>
          select c_field
          from keys
          where service_c = 'ALL'
          and   keyname = 'BV199_INSTALLED'
          </sql:query>
          <sql:resultSet id="rset">
            <sql:getColumn position="1" to="bv199_installed" />
          </sql:resultSet>
          <if:IfTrue cond='<%= ((String)pageContext.getAttribute("bv199_installed")).trim().equals("Y") %>' >
            <tr>
              <td align="center">
                <b><input type="submit" name="action" value="Ad-Hoc Surveys"
                style="font-weight:bold; width: 15em; font-size: 85%" /></b>
              </td>
            </tr>
          </if:IfTrue>
        </sql:statement>
        <sql:closeConnection conn="con"/>
      </app:equalsInitParameter>
      <tr>
        <td align="center">
          <b><input type="submit" name="action" value="Officer Maintenance"
            style="font-weight:bold; width: 15em; font-size: 85%" /></b>
        </td>
      </tr>
      <tr><td>&nbsp;</td></tr>
    </table>
    <jsp:include page="include/logout_button.jsp" flush="true" />
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="mainMenu" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
