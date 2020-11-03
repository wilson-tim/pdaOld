<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.enfSuspectNewCoBean, com.vsb.enfSuspectNewBean, com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="enfSuspectNewCoBean" scope="session" class="com.vsb.enfSuspectNewCoBean" />
<jsp:useBean id="enfSuspectNewBean" scope="session" class="com.vsb.enfSuspectNewBean" />

<app:equalsInitParameter name="use_xhtml" match="Y">
  <?xml version="1.0"?>

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="enfSuspectNewCo" value="false">
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
  <title>enfSuspectNewCo</title>
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
  <form onSubmit="return singleclick();" action="enfSuspectNewCoScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Choose Company</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="enfSuspectNewCoBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>
    <% String color="#ffffff"; %>
    <table cellpadding="2" cellspacing="0" width="100%">
      <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
      <sql:statement id="stmt" conn="con">
        <sql:query>
          select company_ref, company_name
          from enf_company
          where company_name like '<%= enfSuspectNewBean.getSus_company().toUpperCase().replace('*','%')%>'
          order by company_name
        </sql:query>
        <sql:resultSet id="rset">
          <%
            if(color=="#ffffff") {
              color = "#ecf5ff";
            } else if (color=="#ecf5ff") {
              color = "#ffffff";
            }
          %>
          <sql:getColumn position="1" to="company_ref" />
          <tr bgcolor="<%= color %>">
            <td width="10" valign="top">
              <if:IfTrue cond='<%= ((String)pageContext.getAttribute("company_ref")).trim().equals(enfSuspectNewCoBean.getEnfcompany()) %>' >
                <input type="radio" name="enfcompany" id="<sql:getColumn position="1" />" value="<sql:getColumn position="1" />"  checked="checked" />
              </if:IfTrue>
              <if:IfTrue cond='<%= ! ((String)pageContext.getAttribute("company_ref")).trim().equals(enfSuspectNewCoBean.getEnfcompany()) %>' >
                <input type="radio" name="enfcompany" id="<sql:getColumn position="1" />" value="<sql:getColumn position="1" />" />
              </if:IfTrue>
            </td>
            <td valign="top">
              <label for="<sql:getColumn position="1" />"><sql:getColumn position="2" /></label>
            </td>
          </tr>
        </sql:resultSet>
        <sql:wasNotEmpty>
          <%
            if(color=="#ffffff") {
              color = "#ecf5ff";
            } else if (color=="#ecf5ff") {
              color = "#ffffff";
            }
          %>
          <tr bgcolor="<%= color %>" >
            <td valign="top">
              <if:IfTrue cond='<%= enfSuspectNewCoBean.getEnfcompany().equals("new") %>' >
                <input type="radio" name="enfcompany" id="new" value="new" checked="checked" />
              </if:IfTrue>
              <if:IfTrue cond='<%= ! enfSuspectNewCoBean.getEnfcompany().equals("new") %>' >
                <input type="radio" name="enfcompany" id="new" value="new" />
              </if:IfTrue>
            </td>
            <td valign="top">
              <label for="new"><b>OR enter a new company name:</b> </label>
            </td>
          </tr>
          <tr bgcolor="<%= color %>" >
            <td>&nbsp;</td>
            <td>
              <if:IfTrue cond='<%= enfSuspectNewCoBean.getSus_newco().equals("") %>' >
                <input type="text" name="sus_newco" maxlength="50"
                  value="<%= enfSuspectNewBean.getSus_company().replace('*',' ') %>" />
              </if:IfTrue>
              <if:IfTrue cond='<%= ! enfSuspectNewCoBean.getSus_newco().equals("") %>' >
                <input type="text" name="sus_newco" maxlength="50"
                  value="<%= enfSuspectNewCoBean.getSus_newco() %>" />
              </if:IfTrue>
            </td>
          </tr>
        </sql:wasNotEmpty>
        <sql:wasEmpty>
          <tr>
            <td colspan="2">
              There were no matches. Enter a <b>new company name</b>:</b>
            </td>
          </tr>
          <tr>
            <td>
              <input type="radio" name="enfcompany" value="new" checked="checked" />
            </td>
            <td align="center">
              <if:IfTrue cond='<%= enfSuspectNewCoBean.getSus_newco().equals("") %>' >
                <input type="text" name="sus_newco" maxlength="50"
                  value="<%= enfSuspectNewBean.getSus_company().replace('*',' ') %>" />
              </if:IfTrue>
              <if:IfTrue cond='<%= ! enfSuspectNewCoBean.getSus_newco().equals("") %>' >
                <input type="text" name="sus_newco" maxlength="50"
                  value="<%= enfSuspectNewCoBean.getSus_newco() %>" />
              </if:IfTrue>
            </td>
          </tr>
          </sql:wasEmpty>
        </sql:statement>
      <sql:closeConnection conn="con"/>
    </table>
    <jsp:include page="include/back_continue_buttons.jsp" flush="true" />
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="enfSuspectNewCo" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>