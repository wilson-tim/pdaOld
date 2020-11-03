<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.offenceBean, com.vsb.lawBean, com.vsb.systemKeysBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="offenceBean" scope="session" class="com.vsb.offenceBean" />
<jsp:useBean id="lawBean" scope="session" class="com.vsb.lawBean" />
<jsp:useBean id="systemKeysBean" scope="session" class="com.vsb.systemKeysBean" />

<app:equalsInitParameter name="use_xhtml" match="Y">
  <?xml version="1.0"?>

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="offence" value="false">
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
  <title>offence</title>
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
  <form onSubmit="return singleclick();" action="offenceScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Offence Lookup</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="offenceBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>
    <% String color="#ffffff"; %>
    <table cellpadding="2" cellspacing="0" width="100%">
      <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
      <sql:statement id="stmt" conn="con">
        <%-- Find out what version of contender is being run against the database --%>
        <%-- 10/05/2010  TW  Read contender_version from systemKeysBean --%>
        <% String contender_version = systemKeysBean.getContender_version(); %>

        <%-- Find out whether the LAW and OFFENCE are linked --%>
        <% String linked = "N"; %>
        <sql:query>
          select c_field
          from keys
          where service_c = 'ALL'
          and   keyname = 'OFFENCE>LAW LINK'
        </sql:query>
        <sql:resultSet id="rset1">
          <sql:getColumn position="1" to="c_field" />
          <sql:wasNotNull>
            <% linked = ((String) pageContext.getAttribute("c_field")).trim(); %>
          </sql:wasNotNull>
        </sql:resultSet>

        <sql:query>
          <if:IfTrue cond='<%= contender_version.equals("v7") || contender_version.equals("") %>' >
            select lookup_code, lookup_text
            from allk
            where lookup_func = 'ENFDET'
            and   status_yn = 'Y'
            order by lookup_code
          </if:IfTrue>
          <if:IfTrue cond='<%= contender_version.equals("v8") %>' >
            <if:IfTrue cond='<%= linked.equals("N") %>' >
              select offence_ref, offence_desc
              from enf_offence
              where active_yn = 'Y'
              order by offence_ref
            </if:IfTrue>
            <if:IfTrue cond='<%= linked.equals("Y") %>' >
              select enf_offence.offence_ref, enf_offence.offence_desc
              from enf_offence, enf_law_offence
              where enf_law_offence.law_ref = '<%= lawBean.getLaw() %>'
              and   enf_offence.offence_ref = enf_law_offence.offence_ref
              and   enf_offence.active_yn = 'Y'
              order by enf_offence.offence_ref
            </if:IfTrue>
          </if:IfTrue>
        </sql:query>
        <sql:resultSet id="rset">
          <%
            if(color=="#ffffff") {
              color = "#ecf5ff";
            } else if (color=="#ecf5ff") {
              color = "#ffffff";
            }
          %>
          <tr bgcolor="<%= color %>" >
            <td valign="top" width="10">
              <sql:getColumn position="1" to="lookup_code" />
              <if:IfTrue cond='<%= ((String)pageContext.getAttribute("lookup_code")).trim().equals(offenceBean.getOffence()) %>' >
                <input type="radio" name="offence" id="<sql:getColumn position="1" />" value="<sql:getColumn position="1" />"  checked="checked" />
              </if:IfTrue>
              <if:IfTrue cond='<%= !((String)pageContext.getAttribute("lookup_code")).trim().equals(offenceBean.getOffence()) %>' >
                <input type="radio" name="offence" id="<sql:getColumn position="1" />"  value="<sql:getColumn position="1" />" />
              </if:IfTrue>
            </td>
            <td valign="top">
              <label for="<sql:getColumn position="1" />"><b><sql:getColumn position="1" /></b></label>
            </td>
            <td valign="top">
              <label for="<sql:getColumn position="1" />"><sql:getColumn position="2" /></label>
            </td>
          </tr>
        </sql:resultSet>
        <sql:wasEmpty>
          <tr>
           <td colspan="3">
             <b>No codes available</b>
           </td>
         </tr>
        </sql:wasEmpty>
        <sql:wasNotEmpty>
          <tr>
            <td colspan="3">
              <span class="subscript"><sql:rowCount /> codes</span>
            </td>
          </tr>
        </sql:wasNotEmpty>
      </sql:statement>
      <sql:closeConnection conn="con"/>
    </table>
    <jsp:include page="include/back_details_buttons.jsp" flush="true" />
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="offence" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
