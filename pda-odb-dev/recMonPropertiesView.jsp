<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.schedOrCompBean, com.vsb.recMonPropertiesBean" %>
<%@ page import="com.vsb.recMonStreetsBean, com.vsb.loginBean, com.vsb.helperBean" %>
<%@ page import="com.db.*, java.util.*" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="loginBean" scope="session" class="com.vsb.loginBean" />
<jsp:useBean id="recMonPropertiesBean" scope="session" class="com.vsb.recMonPropertiesBean" />
<jsp:useBean id="recMonStreetsBean" scope="session" class="com.vsb.recMonStreetsBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<app:equalsInitParameter name="use_xhtml" match="Y">
  <?xml version="1.0"?>

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="recMonProperties" value="false">
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
  <title>recMonProperties</title>
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
  <form onSubmit="return singleclick();" action="recMonPropertiesScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b><app:initParameter name="monitoring_title"/> Properties</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr>
        <td>
          <font color="#ff6565">
            <b><jsp:getProperty name="recMonPropertiesBean" property="error" /></b>
          </font>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>

    <%-- Set the initial colour--%>
    <% String color="#ffffff"; %>    
    
    <table cellpadding="2" cellspacing="0" width="100%">
      <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
      <sql:statement id="stmt" conn="con">
        <%-- Run the query to get all the properties with monitoring items --%>
        <%-- Store the complaint_no's of each item to use when constructing the view --%>
        <sql:query>
          SELECT complaint_no, site_name_1, do_date
            FROM mon_list
           WHERE location_c = '<%= recMonStreetsBean.getLocation_c() %>'
             AND (state = 'A' OR state = 'P')
             AND action_flag = 'P'
             AND user_name in (
                 SELECT user_name
                 FROM pda_cover_list
                 WHERE covered_by = '<%= loginBean.getUser_name() %>'
             )
             AND recvd_by = '<%= recMonStreetsBean.getMonitor_source() %>'
             ORDER BY do_date, site_name_1
        </sql:query>
        <%-- varialbe to store which date group we are currently in --%>
        <% String current_do_date = ""; %>
        <sql:resultSet id="rset">
          <%-- Get the results as variables --%>
          <sql:getColumn position="1" to="complaint_no" />
          <% String complaint_no = ((String)pageContext.getAttribute("complaint_no")).trim(); %>
          <sql:getColumn position="2" to="site_name_1" />
          <% String site_name_1 = ((String)pageContext.getAttribute("site_name_1")).trim(); %>
          <sql:getDate position="3" to="do_date" format="<%= application.getInitParameter("db_date_fmt") %>" />
          <% String do_date = ((String)pageContext.getAttribute("do_date")).trim(); %>
          <%-- If the date group has changed, add another row with the new date header --%>
          <if:IfTrue cond='<%= !current_do_date.equals( do_date ) %>'>
            <% current_do_date = do_date; %>        
            <tr bgcolor="orange">
              <td colspan="2">
                &nbsp;<b><%= helperBean.dispDate( current_do_date, application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %></b>
              </td>
            </tr>
          </if:IfTrue>
          <%-- Alter the colour for each row --%>
          <%   if(color=="#ffffff") {          %>
          <%     color = "#ecf5ff";            %>
          <%   } else if (color=="#ecf5ff") {  %>
          <%     color = "#ffffff";            %>
          <%   }                               %>
          <tr bgcolor="<%= color %>" >
            <td valign="top" width="10">
              <%-- If the property is the one that was previously selected, set checked  --%>
              <if:IfTrue cond='<%= complaint_no.equals(recMonPropertiesBean.getComplaint_no()) %>' >
              <input type="radio" 
                     name="complaint_no" 
                     id="<%= complaint_no %>" 
                     value="<%= complaint_no %>"  
                     checked="checked" />
              </if:IfTrue>
              <%-- If the location is not the one that was previously selected           --%>
              <if:IfTrue cond='<%= !(complaint_no.equals(recMonPropertiesBean.getComplaint_no())) %>' >
              <input type="radio" 
                     name="complaint_no" 
                     id="<%= complaint_no %>" 
                     value="<%= complaint_no %>" />
              </if:IfTrue>
            </td> 
            <td valign="top">
              <label for="<%= complaint_no %>"><%= site_name_1 %></label>
            </td>    
          </tr>
        </sql:resultSet>      
        <sql:wasEmpty>
          <tr>
            <td colspan="2">
              <b><%= "No more properties available" %></b>
            </td>
          </tr>
          <tr><td>&nbsp;</td></tr>
        </sql:wasEmpty>
      </sql:statement>
      <sql:closeConnection conn="con"/>        
    </table>

    <jsp:include page="include/back_survey_buttons.jsp" flush="true" />
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="recMonProperties" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>

