<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.avHistBean, com.vsb.recordBean, com.vsb.helperBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="avHistBean" scope="session" class="com.vsb.avHistBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
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
<sess:equalsAttribute name="form" match="avHist" value="false">
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
  <title>avHist</title>
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
  <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
  <sql:statement id="stmt" conn="con">
  <form onSubmit="return singleclick();" action="avHistScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>AV History</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="avHistBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td align="center" colspan="2"><b><jsp:getProperty name="recordBean" property="site_name_1" /></b></td></tr>
      <tr><td><hr size="1" noshade="noshade" /></td></tr>
    </table>
    <%-- Get the Abandoned Vehicles complaint Initial Date/Time --%>
    <sql:query>
      SELECT doa,
             toa_h,
             toa_m
        FROM comp_av_hist
       WHERE complaint_no = '<%= recordBean.getComplaint_no() %>'
         AND seq = 1
    </sql:query>
    <%-- Setup page variables --%>
    <sql:resultSet id="rset">
      <sql:getDate position="1"  to="doa" format="<%= application.getInitParameter("db_date_fmt") %>" />
      <sql:getColumn position="2"  to="toa_h" />
      <sql:getColumn position="3"  to="toa_m" />
    </sql:resultSet>
    <sql:wasNotEmpty>
      <table width="100%">
        <%-- Display the complaints number row --%>
        <tr>
          <td bgcolor="#DDDDDD">
            <b>Complaint No.</b>
          </td>
          <td  bgcolor="#DDDDDD">
            <%= recordBean.getComplaint_no() %>
          </td>
        </tr>
        <%-- Display Date --%>
        <tr>
          <td  bgcolor="#DDDDDD">
            <b>Entered</b>
          </td>
          <td  bgcolor="#DDDDDD">
            <%= helperBean.dispDate( ((String)pageContext.getAttribute("doa")).trim(), application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %>
            &nbsp;@&nbsp;
            <%= ((String)pageContext.getAttribute("toa_h")).trim() %>:<%= 
                ((String)pageContext.getAttribute("toa_m")).trim() %>
          </td>
        </tr>
        <tr><td colspan="2"><hr size="2" noshade="noshade" /></td></tr>
      </table>
      <%-- Get the Abandoned Vehicles History using the complaint ID --%>
      <sql:query>
        SELECT status_ref,
               seq,
               username,
               status_date,
               status_time_h,
               status_time_m,
               vehicle_position,
               notes
          FROM comp_av_hist
         WHERE complaint_no = '<%= recordBean.getComplaint_no() %>'
      </sql:query>
      <%-- Setup page variables --%>
      <%-- Display the AV's History in the table below --%>
      <table width="100%">
      <sql:resultSet id="rset">
        <sql:getColumn position="1"  to="status_ref" />
        <sql:getColumn position="2"  to="seq" />
        <sql:getColumn position="3"  to="username" />
  
        <sql:getDate position="4"  to="status_date" format="<%= application.getInitParameter("db_date_fmt") %>" />
        <sql:wasNull>
          <% pageContext.setAttribute("status_date", ""); %>
        </sql:wasNull>
  
        <sql:getColumn position="5"  to="status_time_h" />
        <sql:wasNull>
          <% pageContext.setAttribute("status_time_h", ""); %>
        </sql:wasNull>
  
        <sql:getColumn position="6"  to="status_time_m" />
        <sql:wasNull>
          <% pageContext.setAttribute("status_time_m", ""); %>
        </sql:wasNull>
  
        <sql:getColumn position="7"  to="position" />
        <sql:wasNull>
          <% pageContext.setAttribute("position", ""); %>
        </sql:wasNull>
  
        <sql:getColumn position="8"  to="notes" />
        <sql:wasNull>
          <% pageContext.setAttribute("notes", ""); %>
        </sql:wasNull>
  
        <sql:statement id="stmt1" conn="con">
          <%-- Get the status description from the av_status table --%>
          <sql:query>
            SELECT description
              FROM av_status
             WHERE status_ref = '<%= ((String)pageContext.getAttribute("status_ref")).trim() %>'
          </sql:query>
          <sql:resultSet id="rset">
            <sql:getColumn position="1"  to="status_description" />
          </sql:resultSet>
        </sql:statement>
  
          <%-- Sequence Number Row --%>
          <tr bgcolor="#ecf5ff">
            <td>
              <b>Sequence No.</b>
            </td>
            <td>
              <%-- Check that the value is valid --%>
              <if:IfTrue cond='<%= helperBean.isValid( pageContext.getAttribute("seq") ) %>'>
                <%= ((String)pageContext.getAttribute("seq")).trim() %>
              </if:IfTrue>
            </td>
          </tr>
          <%-- Status_ref Row --%>
          <tr bgcolor="#ffffff">
            <td>
              <b>Status</b>
            </td>
            <td>
              <%-- Check that the value is valid --%>
              <if:IfTrue cond='<%= helperBean.isValid( pageContext.getAttribute("status_description") ) %>'>
                <%= ((String)pageContext.getAttribute("status_description")).trim() %>
              </if:IfTrue>
            </td>
          </tr>
          <%-- Status_description Row --%>
          <tr bgcolor="#ffffff">
            <td colspan="2" align="center">
  
            </td>
          </tr>
          <%-- Username Row --%>
          <tr bgcolor="#ecf5ff">
            <td>
              <b>Username</b>
            </td>
            <td>
              <%-- Check that the value is valid --%>
              <if:IfTrue cond='<%= helperBean.isValid( pageContext.getAttribute("username") ) %>'>
                <%= ((String)pageContext.getAttribute("username")).trim() %>
              </if:IfTrue>
            </td>
          </tr>
          <%-- Status Date/Time Row --%>
          <tr bgcolor="#ffffff">
            <td>
              <b>Date</b>
            </td>
            <td>
              <%-- Check that the value is valid --%>
              <if:IfTrue cond='<%= helperBean.isValid( pageContext.getAttribute("status_date") ) %>'>
                <%= helperBean.dispDate( ((String)pageContext.getAttribute("status_date")).trim(), application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %>
                &nbsp;@&nbsp;
                <%= ((String)pageContext.getAttribute("status_time_h")).trim() %>:<%=
                    ((String)pageContext.getAttribute("status_time_m")).trim() %>
              </if:IfTrue>
            </td>
          </tr>
          <%-- Position Row --%>
          <tr bgcolor="#ecf5ff">
            <td>
              <b>Position</b>
            </td>
            <td>
              <%-- Check that the value is valid --%>
              <if:IfTrue cond='<%= helperBean.isValid( pageContext.getAttribute("position") ) %>'>
                <%= ((String)pageContext.getAttribute("position")).trim() %>
              </if:IfTrue>
            </td>
          </tr>
          <%-- Status Notes if available --%>
          <if:IfTrue cond='<%= helperBean.isValid( pageContext.getAttribute("notes") ) %>'>
          <tr>
            <td colspan="2" bgcolor="#ffffff">
              <b>Previous Notes</b>
              <br/>
                <textarea rows="4" cols="28" name="notes" readonly="readonly" ><%= 
                  ((String)pageContext.getAttribute("notes")).trim() 
                %></textarea>
            </td>
          </tr>
          </if:IfTrue>
          <%-- Otherwise display 'None' --%> 
          <if:IfTrue cond='<%= helperBean.isNotValid( pageContext.getAttribute("notes") ) %>'>
          <tr>
            <td bgcolor="#ffffff">
              <b>Notes</b>
            </td>
            <td bgcolor="#ffffff">
              None
            </td>
          </tr>
          </if:IfTrue>
          <tr><td colspan="2"><hr size="2" noshade="noshade" /></td></tr>   
      </sql:resultSet>
      </table>
    </sql:wasNotEmpty>
    <sql:wasEmpty>
      <table width="100%">
        <tr>
          <td bgcolor="#DDDDDD">
            <b>No history available</b>
          </td>
        </tr>
      </table>
    </sql:wasEmpty>
    <br/>
    <jsp:include page="include/back_button.jsp" flush="true" />
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="avHist" /> 
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
  </sql:statement>
  <sql:closeConnection conn="con"/>
</body>
</html>
