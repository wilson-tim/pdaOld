<%@ page errorPage="error.jsp" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat" %>
<%@ page import="com.vsb.taskAgreementBean, com.vsb.recordBean, com.vsb.helperBean, com.vsb.loginBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="taskAgreementBean" scope="session" class="com.vsb.taskAgreementBean" />
<jsp:useBean id="loginBean" scope="session" class="com.vsb.loginBean" />
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
<sess:equalsAttribute name="form" match="taskAgreement" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Set up the date variables --%>
<%-- Set up the date variables --%>
<%
  // Set the default time zone to where we are, as the time zone
  // returned from sco is GMT+00:00 which is fine but doesn't mentioned
  // BST. So the default timezone has to be set to "Europe/London".
  // Any objects which use the timezone (like SimpleDateFormat) will then
  // be using the correct timezone.
  TimeZone dtz = TimeZone.getTimeZone("Europe/London");
  TimeZone.setDefault(dtz);

  SimpleDateFormat formatDate = new SimpleDateFormat(application.getInitParameter("db_date_fmt"));
  Date date;

  // todays date
  Date currentDate = new java.util.Date();
  String date_now = formatDate.format(currentDate);
%>

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
  <title>taskAgreement</title>
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
  <form onSubmit="return singleclick();" action="taskAgreementScript.jsp" method="post">
  
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Agreement Tasks</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr>
        <td>
	        <font color="#ff6565">
	        <b><jsp:getProperty name="taskAgreementBean" property="error" /></b>
	        </font>
	      </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>
    
    <table width="100%">
      <tr>
        <td align="center" colspan="2">
          <b><jsp:getProperty name="recordBean" property="trade_name" /></b>
             - <jsp:getProperty name="recordBean" property="site_name_1" />
        </td>
      </tr>
      <tr>
        <table width="100%">
          <tr>
            <td colspan="2" align="center">
              <b>Agree no</b> - <%= recordBean.getTa_no() %>
            </td>
          </tr>
        </table>
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
      <%-- Get all the associated taskAgreements for this agreement --%>
      <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
        <sql:statement id="stmt" conn="con1">
          <sql:query>
            SELECT agree_task.agree_task_no,
                   agree_task.task_ref,
                   agree_task.exact_locn,
                   lifts.lift_sno,
                   lifts.coll_day,
                   lifts.no_of_bins,
                   lifts.before_after,
                   lifts.time_hr,
                   lifts.time_min,
                   lifts.round_ref
              FROM agree_task, lifts
             WHERE agree_task.agreement_no = <%= recordBean.getTa_no() %>
               AND lifts.agree_task_no = agree_task.agree_task_no
               AND agree_task.status_ref = 'R'
               AND '<%= date_now %>' >= agree_task.start_date
               AND ('<%= date_now %>' < agree_task.close_date
                    OR
                    agree_task.close_date IS NULL
                    OR
                    agree_task.close_date = ''
                   )
               AND '<%= date_now %>' >= lifts.start_date
               ORDER BY lifts.lift_sno ASC
	        </sql:query>
          <sql:resultSet id="rset1">
          <%-- Table row: Radio button, taskAgreement number, lift number --%>
          <%-- Holding the lift number inside the bean as opposed to the task
               agreement number --%>
        <tr colspan="2">
          <table width="100%" 
                 cellspacing="0"
                 cellpadding="2">
            <tr>
              <td width="10">
                <sql:getColumn position="1" to="taskAgreement_no" />               
                <sql:getColumn position="4" to="lift_no" />
                <% 
                  String view_key = ((String)pageContext.getAttribute("taskAgreement_no")).trim() + "|" + 
                                    ((String)pageContext.getAttribute("lift_no")).trim();
                %>                
                <if:IfTrue cond='<%= view_key.equals(taskAgreementBean.getView_key()) %>' >
                  <input type    ="radio" 
                         name    ="view_key" 
                         id      ="<%= view_key %>"  
                         value   ="<%= view_key %>"  
                         checked ="checked" />
                </if:IfTrue>
                <if:IfTrue cond='<%= !view_key.equals(taskAgreementBean.getView_key()) %>' >
                  <input type    ="radio" 
                         name    ="view_key" 
                         id      ="<%= view_key %>" 
                         value   ="<%= view_key %>" />
                </if:IfTrue>
              </td>
              <td bgcolor="#DDDDDD">
                <label for="<%= view_key %>" >
                  <b>
                    No.
                  </b>                  
                  <%= ((String)pageContext.getAttribute("taskAgreement_no")).trim() %>
                </label>
              </td>
              <td bgcolor="#DDDDDD" align="right">
                <label for="<%= view_key %>" >              
                  <b>
                    <%-- Collection day --%>
                    <sql:getColumn position="5" to="collection_day"/>
                    <sql:wasNull>
                    <% pageContext.setAttribute("collection_day", ""); %>
                    </sql:wasNull>
                    <%= helperBean.getDay( ((String)pageContext.getAttribute("collection_day")).trim() ) %>
                  </b>
                </label>
              </td>
            </tr>
          </table>
        </tr>
          <tr colspan="2">
            <table width="100%">
              <%-- task_ref --%>              
              <sql:getColumn position="2" to="task_ref"/>
              <sql:getColumn position="4" to="lift_no"/>              
              <sql:statement id="stmt2" conn="con1">
                <sql:query>
                  SELECT task_desc
                    FROM task
                   WHERE task_ref = '<%= ((String)pageContext.getAttribute("task_ref")).trim() %>'
                </sql:query>
                <sql:resultSet id="rset2">
                <sql:getColumn position="1" to="task_desc"/>
                <tr bgcolor="#ecf5ff">
                  <td>
                    <label for="<%= view_key %>">
                      <b>Task ref</b>
                    </label>   
                  </td>
                  <td>
                    <label for="<%= view_key %>">
                      <%= ((String)pageContext.getAttribute("task_desc")).trim() %>
                    </label>
                  </td>
                </tr>                
                </sql:resultSet>
              </sql:statement>
              <%-- Before/After Time --%>
              <%-- Check to see if a before or after field has been set. If so,
                   display the before/after label, otherwise display the time only. --%>
              <tr bgcolor="#ffffff">
              <sql:getColumn position="7" to="before_after"/>
              <sql:wasNull>
                <% pageContext.setAttribute("before_after","T"); %>
              </sql:wasNull>
              <if:IfTrue cond='<%= ((String)pageContext.getAttribute("before_after")).trim().equals("B") %>'>
                <td>
                  <label for="<%= view_key %>" >
                    <b>Before</b>
                  </label>
                </td>              
              </if:IfTrue>
              <if:IfTrue cond='<%= ((String)pageContext.getAttribute("before_after")).trim().equals("A") %>'>
                <td>
                  <label for="<%= view_key %>" >
                    <b>After</b>
                  </label>
                </td>              
              </if:IfTrue>
              <if:IfTrue cond='<%= ((String)pageContext.getAttribute("before_after")).trim().equals("S") %>'>
                <td>
                  <label for="<%= view_key %>" >
                    <b>Scheduled</b>
                  </label>
                </td>              
              </if:IfTrue>
              <if:IfTrue cond='<%= ((String)pageContext.getAttribute("before_after")).trim().equals("T") %>'>
                <td>
                  <label for="<%= view_key %>" >
                    <b>Time</b>
                  </label>
                </td>              
              </if:IfTrue>
              <%-- Check the time field is not null --%>
              <sql:getColumn position="8" to="time_h"/>
              <sql:wasNull>
                  <td>
                    &nbsp;
                  </td>  
              </sql:wasNull>
              <sql:wasNotNull>
                <td>
                  <label for="<%= view_key %>" >                  
                    <sql:getColumn position="8"/>:<sql:getColumn position="9"/>
                  </label>
                </td>              
              </sql:wasNotNull>
              </tr>
              <%-- Number of Bins --%>
              <sql:getColumn position="6" to="num_bins"/>
              <sql:wasNull>
                <% pageContext.setAttribute("num_bins", ""); %>
              </sql:wasNull>
              <tr bgcolor="#ecf5ff">              
                <td>
                  <label for="<%= view_key %>" >                
                    <b>Num Bins</b>
                  </label>
                </td>
                <td>
                  <label for="<%= view_key %>" >
                    <%= ((String)pageContext.getAttribute("num_bins")).trim() %>
                  </label>
                </td>
              </tr>
              <%-- Round ref --%>
              <sql:getColumn position="10" to="round_ref"/>
              <sql:wasNull>
                <% pageContext.setAttribute("round_ref", ""); %>
              </sql:wasNull>
              <tr bgcolor="#ffffff">              
                <td>
                  <label for="<%= view_key %>" >
                    <b>Round ref</b>
                  </label>
                </td>
                <td>
                  <label for="<%= view_key %>" >                
                    <%= ((String)pageContext.getAttribute("round_ref")).trim() %>
                  </label>
                </td>
              </tr>
              <%-- Exact Location --%>
              <tr bgcolor="#ecf5ff">
                <td>
                  <label for="<%= view_key %>" >
                    <b>Exact Locn</b>
                  </label>
                </td>
                <td>
                  <label for="<%= view_key %>" >
                    <sql:getColumn position="3" />
                  </label>
                </td>
              </tr>              
            </table>
          </tr>
          </sql:resultSet>
          <%-- If there are no Agreements tasks--%>
          <sql:wasEmpty>
            <tr>
              <td colspan="2">
                No tasks found for this agreement.  
              </td>
            </tr>
          </sql:wasEmpty>
          <sql:wasNotEmpty>
            <tr>
              <td colspan="2">
                <span class="subscript"><sql:rowCount /> task(s)</span>
              </td>
            </tr>
          </sql:wasNotEmpty>
        </sql:statement>    
      <sql:closeConnection conn="con1"/>
    </table>
    <jsp:include page="include/back_default_buttons.jsp" flush="true" />
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="taskAgreement" /> 
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
