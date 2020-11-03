<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.serviceBean, com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="serviceBean" scope="session" class="com.vsb.serviceBean" />
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
<sess:equalsAttribute name="form" match="service" value="false">
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
  <title>service</title>
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
  <form onSubmit="return singleclick();" action="serviceScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Service</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="serviceBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>
    <% String color="#ffffff"; %>
    <table cellpadding="2" cellspacing="0" width="100%">
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con">
      <sql:query>
        select distinct service_c, service_c_desc
        from pda_lookup
        where role_name = '<%= recordBean.getPda_role() %>'
        order by service_c
      </sql:query>
      <sql:resultSet id="rset">
        <%
          if(color=="#ffffff") {
            color = "#ecf5ff";
          } else if (color=="#ecf5ff") {
            color = "#ffffff";
          }
        %>

        <if:IfTrue cond='<%= recordBean.getService_count().equals("1") %>' >
          <tr bgcolor="<%= color %>" >
            <td valign="top" width="10">
              <sql:getColumn position="1" to="service_c" />
              <input type="radio" name="service_c" id="<sql:getColumn position="1" />" value="<sql:getColumn position="1" />"  checked="checked" />
            </td>
            <td valign="top">
              <label for="<sql:getColumn position="1" />"><b><sql:getColumn position="1" /></b></label>
            </td>
            <td valign="top">
              <label for="<sql:getColumn position="1" />"><sql:getColumn position="2" /></label>
            </td>
          </tr>
        </if:IfTrue>
        <if:IfTrue cond='<%= !(recordBean.getService_count().equals("1")) %>' >
          <tr bgcolor="<%= color %>" >
            <td valign="top" width="10">
              <sql:getColumn position="1" to="service_c" />
              <if:IfTrue cond='<%= ((String)pageContext.getAttribute("service_c")).trim().equals(serviceBean.getService_c()) %>' >
                <input type="radio" name="service_c" id="<sql:getColumn position="1" />" value="<sql:getColumn position="1" />"  checked="checked" />
              </if:IfTrue>
              <if:IfTrue cond='<%= !((String)pageContext.getAttribute("service_c")).trim().equals(serviceBean.getService_c()) %>' >
                <input type="radio" name="service_c" id="<sql:getColumn position="1" />" value="<sql:getColumn position="1" />" />
              </if:IfTrue>
            </td>
            <td valign="top">
              <label for="<sql:getColumn position="1" />"><b><sql:getColumn position="1" /></b></label>
            </td>
            <td valign="top">
              <label for="<sql:getColumn position="1" />"><sql:getColumn position="2" /></label>
            </td>
          </tr>
        </if:IfTrue>
       </sql:resultSet>
       <sql:wasEmpty>
         <tr>
           <td>
             <b>No services available</b>
           </td>
         </tr>
       </sql:wasEmpty>
       <sql:wasNotEmpty>
         <tr>
          <td colspan="2">
            <span class="subscript"><sql:rowCount /> services</span>
          </td>
         </tr>
       </sql:wasNotEmpty>
    </sql:statement>
    <sql:closeConnection conn="con"/>
    </table>
    <jsp:include page="include/back_item_buttons.jsp" flush="true" />
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="service" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
