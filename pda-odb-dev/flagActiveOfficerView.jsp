<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.flagActiveOfficerBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>

<jsp:useBean id="flagActiveOfficerBean" scope="session" class="com.vsb.flagActiveOfficerBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="flagActiveOfficer" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<app:equalsInitParameter name="use_xhtml" match="Y">
  <?xml version="1.0"?>

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

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
  <title>flagActiveOfficer</title>
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
  <form onSubmit="return singleclick();" action="flagActiveOfficerScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Pick Absent Officer</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="flagActiveOfficerBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>
    <table width="100%">
      <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
      <sql:statement id="stmt" conn="con">
        <sql:query>
          select pda_cover_list.user_name, pda_user.full_name, pda_cover_list.covered_by
          from pda_cover_list, pda_user
          where pda_cover_list.user_name = pda_user.user_name
          and pda_cover_list.absent = 'Y'
          order by pda_cover_list.user_name
         </sql:query>
        <sql:resultSet id="rset">
          <tr>
            <td valign="top" width="10">
              <sql:getColumn position="1" to="user_name" />
              <if:IfTrue cond='<%= ((String)pageContext.getAttribute("user_name")).trim().equals(flagActiveOfficerBean.getUser_name()) %>' >
                <input type="radio" name="user_name" id="<sql:getColumn position="1" />" value="<sql:getColumn position="1" />"  checked="checked" />
              </if:IfTrue>
              <if:IfTrue cond='<%= !((String)pageContext.getAttribute("user_name")).trim().equals(flagActiveOfficerBean.getUser_name()) %>' >
                <input type="radio" name="user_name" id="<sql:getColumn position="1" />" value="<sql:getColumn position="1" />" />
              </if:IfTrue>
            </td>
            <td valign="top">
              <label for="<sql:getColumn position="1" />"><b><sql:getColumn position="1" /></b></label>
            </td>
            <td>
              <label for="<sql:getColumn position="1" />"><sql:getColumn position="2" /></label>
            </td>
          </tr>
          <tr>
            <sql:getColumn position="3" to="covered_by" />
            <if:IfTrue cond='<%= ((String)pageContext.getAttribute("covered_by")).trim().equals("") %>' >
              <td colspan="3" bgcolor="#ff6565" align="center">
                <font color="white"><b>Requires cover</b></font>
              </td>
            </if:IfTrue>
            <if:IfTrue cond='<%= !((String)pageContext.getAttribute("covered_by")).trim().equals("") %>' >
              <sql:statement id="stmt2" conn="con">
                <sql:query>
                  select pda_user.full_name, pda_user.user_name
                  from pda_user
                  where pda_user.user_name = '<%= ((String)pageContext.getAttribute("covered_by")).trim() %>'
                </sql:query>
                <sql:resultSet id="rset2">
                  <sql:getColumn position="1" to="full_name" />
                  <sql:wasNotNull>
                    <td colspan="3" bgcolor="#259225" align="center">
                      <font color="white"><b>Covered by <sql:getColumn position="1" /></b></font>
                    </td>
                  </sql:wasNotNull>
                  <sql:wasNull>
                    <td colspan="3" bgcolor="#259225" align="center">
                      <font color="white"><b>Covered by <sql:getColumn position="2" /></b></font>
                    </td>
                  </sql:wasNull>
                </sql:resultSet>
              </sql:statement>
            </if:IfTrue>
          </tr>
        </sql:resultSet>
        <sql:wasEmpty>
          <tr>
           <td colspan="3">
             <b>No officers available</b>
           </td>
         </tr>
        </sql:wasEmpty>
        <tr>
          <td colspan="3">
            <span class="subscript"><sql:rowCount /> Absent Officers</span>
          </td>
        </tr>
      </sql:statement>
      <sql:closeConnection conn="con"/>
    </table>
    <jsp:include page="include/back_flag_active_buttons.jsp" flush="true" />
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="flagActiveOfficer" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
