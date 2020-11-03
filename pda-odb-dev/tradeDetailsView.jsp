<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.tradeDetailsBean, com.vsb.recordBean, com.vsb.helperBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags"          prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags"       prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0"     prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="tradeDetailsBean" scope="session" class="com.vsb.tradeDetailsBean" />
<jsp:useBean id="recordBean"       scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean"       scope="session" class="com.vsb.helperBean" />

<app:equalsInitParameter name="use_xhtml" match="Y">
  <?xml version="1.0"?>

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="tradeDetails" value="false">
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
  <title>tradeDetails</title>
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
  <form onSubmit="return singleclick();" action="tradeDetailsScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Trade Complaint Details</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="tradeDetailsBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>
    <%-- Display the Agreement name and Trade name like Contender does --%>
    <table width="100%">
      <tr bgcolor="#ecf5ff">
        <td><b>Agreement</b></td>
      <tr>
      <tr bgcolor="#ffffff">
        <td><jsp:getProperty name="tradeDetailsBean" property="agreement_name" /></td>
      </tr>
      <tr bgcolor="#ecf5ff">
        <td><b>Trade Site</b></td>
      <tr>
      <tr bgcolor="#ffffff">
        <td><jsp:getProperty name="recordBean" property="ta_name" /></td>
      </tr>
      <tr><td><hr size="1" noshade="noshade" /></td></tr>
      <tr bgcolor="#259225" align="center">
        <td><font color="white"><b>Tasks / Requests</b></font></td>
      <tr>
    </table>
    <table width="100%">
      <%-- Get all of the rows in the comp_tr table for this complaint that have a fault code --%>
      <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
      <sql:statement id="stmt" conn="con">
        <sql:query>
          SELECT task_ref,
                 exact_locn,
                 comp_code,
                 coll_day,
                 time_hr,
                 time_min,
                 round_ref,
                 before_after
            FROM comp_tr
           WHERE complaint_no = <%= recordBean.getComplaint_no() %>
             AND comp_code IS NOT NULL
             AND comp_code <> ''
        </sql:query>
        <sql:resultSet id="rset1">
          <%-- Declare Varaibles --%>
          <% String task_ref     = ""; %>
          <% String exact_locn   = ""; %>
          <% String comp_code    = ""; %>
          <% String coll_day     = ""; %>
          <% String time_hr      = ""; %>
          <% String time_min     = ""; %>
          <% String round_ref    = ""; %>
          <% String before_after = ""; %>
          <% String lookup_text  = ""; %>
          <% String task_desc    = ""; %>
          <% String due_date     = ""; %>
          <%-- Assign the query results to the variables --%>
          <sql:getColumn position="1" to="task_ref" />
          <sql:wasNotNull>
            <% task_ref = ((String)pageContext.getAttribute("task_ref")).trim(); %>
          </sql:wasNotNull>
          <sql:getColumn position="2" to="exact_locn" />
          <sql:wasNotNull>
            <% exact_locn = ((String)pageContext.getAttribute("exact_locn")).trim(); %>
          </sql:wasNotNull>
          <sql:getColumn position="3" to="comp_code" />
          <sql:wasNotNull>
            <% comp_code = ((String)pageContext.getAttribute("comp_code")).trim(); %>
          </sql:wasNotNull>
          <sql:getColumn position="4" to="coll_day" />
          <sql:wasNotNull>
            <% coll_day = ((String)pageContext.getAttribute("coll_day")).trim(); %>
          </sql:wasNotNull>
          <sql:getColumn position="5" to="time_hr" />
          <sql:wasNotNull>
            <% time_hr = ((String)pageContext.getAttribute("time_hr")).trim(); %>
          </sql:wasNotNull>
          <sql:getColumn position="6" to="time_min" />
          <sql:wasNotNull>
            <% time_min = ((String)pageContext.getAttribute("time_min")).trim(); %>
          </sql:wasNotNull>
          <sql:getColumn position="7" to="round_ref" />
          <sql:wasNotNull>
            <% round_ref = ((String)pageContext.getAttribute("round_ref")).trim(); %>
          </sql:wasNotNull>
          <sql:getColumn position="8" to="before_after" />
          <sql:wasNotNull>
            <% before_after = ((String)pageContext.getAttribute("before_after")).trim(); %>
          </sql:wasNotNull>
          <%-- Create the due date in the form: MONDAY @ 10:30           --%>
          <% due_date  = helperBean.getDay(coll_day);                      %>
          <% due_date += " " + helperBean.getBefore_after( before_after ); %>
          <% due_date += " " + time_hr + ":" + time_min;                   %>
            <%-- Do an internal query to collect the task_ref description and the comp_code description --%>
            <sql:statement id="stmt2" conn="con">
              <%-- Fault code lookup text --%>
              <sql:query>
                SELECT lookup_text
                  FROM allk
                 WHERE lookup_code = '<%= comp_code %>'
                 <if:IfTrue cond='<%= ! recordBean.getComp_action_flag().equals("D") %>' >
                   AND lookup_func = 'COMPLA'
                 </if:IfTrue>
                 <if:IfTrue cond='<%= recordBean.getComp_action_flag().equals("D") %>' >
                   AND lookup_func = 'DEFRN'
                 </if:IfTrue>
              </sql:query>
              <sql:resultSet id="rset2">
                <sql:getColumn position="1" to="lookup_text" />
                <sql:wasNotNull>
                  <% lookup_text = ((String)pageContext.getAttribute("lookup_text")).trim(); %>
                </sql:wasNotNull>
              </sql:resultSet>
              <%-- Task reference lookup text --%>
              <sql:query>
                SELECT task_desc
                  FROM task
                 WHERE task_ref = '<%= task_ref %>'
              </sql:query>
              <sql:resultSet id="rset2">
                <sql:getColumn position="1" to="task_desc" />
                <sql:wasNotNull>
                  <% task_desc = ((String)pageContext.getAttribute("task_desc")).trim(); %>
                </sql:wasNotNull>
              </sql:resultSet>
            </sql:statement>
          <%-- Create a row in the table for each comp_tr row returned --%>
          <tr bgcolor="#ecf5ff">
            <td><b>Task Ref</b></td>
            <td><%= task_ref %></td>
          </tr>
          <tr bgcolor="#ffffff">
            <td colspan="2"><%= task_desc %></td>
          </tr>
          <tr bgcolor="#ecf5ff">
            <td><b>Fault</b></td>
            <td><%= comp_code %></td>
          </tr>
          <tr bgcolor="#ffffff">
            <td colspan="2"><%= lookup_text %></td>
          </tr>
          <tr bgcolor="#ecf5ff">
            <td><b>Loc</b></td>
            <td><%= exact_locn %></td>
          </tr>
          <tr bgcolor="#ffffff">
            <td><b>Due Date</b></td>
            <td><%= due_date %></td>
          </tr>
          <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
        </sql:resultSet>
      </sql:statement>
      <sql:closeConnection conn="con"/>
    </table>
    <jsp:include page="include/back_button.jsp" flush="true" />    
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="tradeDetails" /> 
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
