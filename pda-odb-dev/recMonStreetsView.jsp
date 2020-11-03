<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.recMonStreetsBean, com.vsb.loginBean" %>
<%@ page import="com.db.*, java.util.*" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="recMonStreetsBean" scope="session" class="com.vsb.recMonStreetsBean" />
<jsp:useBean id="loginBean" scope="session" class="com.vsb.loginBean" />

<app:equalsInitParameter name="use_xhtml" match="Y">
  <?xml version="1.0"?>

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="recMonStreets" value="false">
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
  <title>recMonStreets</title>
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
  <form onSubmit="return singleclick();" action="recMonStreetsScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b><app:initParameter name="monitoring_title"/> Streets</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="recMonStreetsBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td>&nbsp;</td></tr>      
    </table>

    <%-- Set the initial colour--%>
    <% String color="#ffffff"; %>    

    <%-- Create boolean to know if the result set was empty for the buttons below --%>
    <% boolean isResultSetEmpty = true; %> 
    
  <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
  <sql:statement id="stmt" conn="con">
  
    <%-- Create an array to store the site_refs --%>
    <% ArrayList location_c = new ArrayList();     %>
  
    <%-- Run the query to get all the sites with monitoring items --%>
    <%-- Store the site_refs of each site to use later --%>
    <sql:query>
      SELECT DISTINCT location_c
        FROM mon_list
       WHERE (state = 'A' OR state = 'P')
         AND action_flag = 'P'
         AND user_name in (
             SELECT user_name
             FROM pda_cover_list
             WHERE covered_by = '<%= loginBean.getUser_name() %>'
         )
         AND recvd_by = '<%= recMonStreetsBean.getMonitor_source() %>' 
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="location_c" />
      <% location_c.add( ((String)pageContext.getAttribute("location_c")).trim() );%>
    </sql:resultSet>
    <sql:wasEmpty>
      <% isResultSetEmpty = true; %>
      <table cellpadding="2" cellspacing="0" width="100%">
        <tr>
          <td colspan="2">
            <b>No streets have recycling surveys scheduled</b>
          </td>
        </tr>
        <tr><td>&nbsp;</td></tr>      
      </table>
    </sql:wasEmpty>
    
    <%-- If we have results in the array, get the location name for each site  --%>
    <%-- We will display these names to the user so they can select the street --%>
    <if:IfTrue cond='<%= location_c.size() > 0 %>'>
      <% Iterator locationIterator = location_c.iterator(); %>
      <sql:query>
        SELECT DISTINCT location_name, location_c
          FROM locn
         WHERE location_c IN (
         <% while( locationIterator.hasNext() ){ %>
         <%= "'" + (String)locationIterator.next() + "'"  %>
         <%   if( locationIterator.hasNext() ) { %>
         <%= ", " %>
         <%   } %>        
         <% } %>
         )
      </sql:query>
      <table cellpadding="2" cellspacing="0" width="100%">
      <sql:resultSet id="rset">
        <% isResultSetEmpty = false; %>
        <sql:getColumn position="1" to="location_name" />
        <% String location_name = ((String)pageContext.getAttribute("location_name")).trim(); %>
        <sql:getColumn position="2" to="location_c" />
        <% String loc_c = ((String)pageContext.getAttribute("location_c")).trim(); %>
        <%-- Alter the colour for each row  --%>
        <%   if(color=="#ffffff") {           %>
        <%     color = "#ecf5ff";             %>
        <%   } else if (color=="#ecf5ff") {   %>
        <%     color = "#ffffff";             %>
        <%   }                                %>
        <%-- Create table row for each location_name using the location_c as the    --%>
        <%-- radio button key                                                       --%>
        <tr bgcolor="<%= color %>" >
          <td valign="top" width="10">
        <%-- If the location is the one that was previously selected, set checked  --%>
            <if:IfTrue cond='<%= loc_c.equals(recMonStreetsBean.getLocation_c()) %>' >
              <input type="radio" 
                     name="location_c" 
                     id="<%= loc_c %>" 
                     value="<%= loc_c %>"  
                     checked="checked" />
            </if:IfTrue>
        <%-- If the location is not the one that was previously selected           --%>
            <if:IfTrue cond='<%= !(loc_c.equals(recMonStreetsBean.getLocation_c())) %>' >
              <input type="radio" 
                     name="location_c" 
                     id="<%= loc_c %>" 
                     value="<%= loc_c %>" />
            </if:IfTrue>
          </td> 
          <td valign="top">
            <label for="<%= loc_c %>"><%= location_name %></label>
          </td>    
        </tr>      
      </sql:resultSet>
      </table>          
    </if:IfTrue>
  </sql:statement>
  <sql:closeConnection conn="con"/>

  <%-- Give the property option button if we have any results --%>
  <if:IfTrue cond='<%= !isResultSetEmpty %>'>
    <jsp:include page="include/missed_button.jsp" flush="true" />
    <jsp:include page="include/back_properties_buttons.jsp" flush="true" />
  </if:IfTrue>
  <%-- Otherwise only offer the back button as there are no properties --%>
  <if:IfTrue cond='<%= isResultSetEmpty %>'>
    <jsp:include page="include/back_button.jsp" flush="true" />
  </if:IfTrue>
  <%@ include file="include/insp_sched_buttons.jsp" %>
  <jsp:include page="include/footer.jsp" flush="true" />
  <input type="hidden" name="input" value="recMonStreets" />
  <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>

