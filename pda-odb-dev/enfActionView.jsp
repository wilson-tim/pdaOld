<%@ page errorPage="error.jsp" %>
<%@ page import="java.util.*, java.text.*, java.text.SimpleDateFormat" %>
<%@ page import="com.vsb.enfActionBean, com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="enfActionBean" scope="session" class="com.vsb.enfActionBean" />
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
<sess:equalsAttribute name="form" match="enfAction" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

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

  // Set up time
  String time_h;
  String time_m;
  SimpleDateFormat formatTime_h = new SimpleDateFormat("HH");
  SimpleDateFormat formatTime_m = new SimpleDateFormat("mm");
 
  // set the correct date to use in the form
  if (recordBean.getAction_date().equals("")) {
    // set the date to todays date
    date = new java.util.Date();
  } else {
    // set the date to the stored date as it exists
    date = formatDate.parse(recordBean.getAction_date());
  }
 
  time_h = formatTime_h.format(date);
  time_m = formatTime_m.format(date);

  GregorianCalendar gregDate = new GregorianCalendar();
  gregDate.setTime(date);
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
  <title>enfAction</title>
  <style type="text/css">
    @import URL("global.css");
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
  <form onSubmit="return singleclick();" action="enfActionScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Enforcement Action</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="enfActionBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade /></td></tr>
    </table>
    <% String color="#ffffff"; %>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con">
    <table cellpadding="2" cellspacing="0" width="100%">
      <sql:query>
        select distinct enfact_action_link.next_action_code, enf_act.description
        from enfact_action_link, enf_act
        where enfact_action_link.action_code = '<%= enfActionBean.getEnf_list_action_code() %>'
        and   enf_act.action_code = enfact_action_link.next_action_code
        and   enf_act.pda = 'Y'
        order by enfact_action_link.next_action_code
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
            <sql:getColumn position="1" to="action_code" />
            <if:IfTrue cond='<%= ((String)pageContext.getAttribute("action_code")).trim().equals(enfActionBean.getAction_code()) %>' >
              <input type="radio" name="action_code" id="<sql:getColumn position="1" />" value="<sql:getColumn position="1" />"  checked="checked" />
            </if:IfTrue>
            <if:IfTrue cond='<%= !((String)pageContext.getAttribute("action_code")).trim().equals(enfActionBean.getAction_code()) %>' >
              <input type="radio" name="action_code" id="<sql:getColumn position="1" />" value="<sql:getColumn position="1" />" />
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
          <td>
            <b>No actions available</b>
          </td>
        </tr>
        <tr><td><hr size="1" noshade="noshade" /></td></tr>
      </sql:wasEmpty>
      <sql:wasNotEmpty>
        <tr>
          <td colspan="3">
            <span class="subscript"><sql:rowCount /> action(s)</span>
          </td>
        </tr>
        <tr><td colspan="3"><hr size="1" noshade="noshade" /></td></tr>
      </sql:wasNotEmpty>
    </table>
    <table width="100%" border="0">
      <sql:query>
        select distinct po_code, full_name
        from pda_user
        where po_code in (
          select lookup_code
          from allk
          where lookup_func = 'ENFOFF'
          and status_yn = 'Y'
        )
        order by full_name
      </sql:query>
      <tr>
        <td>
          <b>Authorising Officer:</b>
        </td>
      </tr>
      <tr>
        <td>
          <select name="autOff">
            <sql:resultSet id="rset">
              <sql:getColumn position="1" to="autOff" />

              <% String fullname = ""; %>
              <sql:getColumn position="2" to="fullname" />
              <sql:wasNotNull>
                <% fullname = ((String)pageContext.getAttribute("fullname")).trim(); %>
              </sql:wasNotNull>

              <if:IfTrue cond='<%= ((String)pageContext.getAttribute("autOff")).trim().equals(enfActionBean.getAutOff().trim()) %>' >
                <if:IfTrue cond='<%= ! fullname.equals("") %>' >
                  <option value="<sql:getColumn position="1" />" selected="selected" ><sql:getColumn position="2" /></option>
                </if:IfTrue>
                <if:IfTrue cond='<%= fullname.equals("") %>' >
                  <option value="<sql:getColumn position="1" />" selected="selected" >No Name</option>
                </if:IfTrue>
              </if:IfTrue>
              <if:IfTrue cond='<%= ! ((String)pageContext.getAttribute("autOff")).trim().equals(enfActionBean.getAutOff().trim()) %>' >
                <if:IfTrue cond='<%= ! fullname.equals("") %>' >
                  <option value="<sql:getColumn position="1" />"><sql:getColumn position="2" /></option>
                </if:IfTrue>
                <if:IfTrue cond='<%= fullname.equals("") %>' >
                  <option value="<sql:getColumn position="1" />" selected="selected" >No Name</option>
                </if:IfTrue>
              </if:IfTrue>
            </sql:resultSet>
          </select>
        </td>
      </tr>
      <tr>
        <td>
          <b>Action Date:</b>
        </td>
      </tr>
      <tr>
        <td>
          <select name="action_day">
          <%  for (int i=1; i<32; i++) { 
                if (i == gregDate.get(gregDate.DATE)) { %>
                   <option value="<% out.print(i); %>" selected="selected" ><% out.print(i); %></option>
          <%    } else { %>
                   <option value="<% out.print(i); %>" ><% out.print(i); %></option>
          <%     }   
               } %>
          </select>

          <select name="action_month">
          <%  for (int i=1; i<13; i++) {
                if (i == gregDate.get(gregDate.MONTH) + 1) { %>
                   <option value="<% out.print(i); %>" selected="selected" ><% out.print(i); %></option>
          <%     } else { %>
                   <option value="<% out.print(i); %>" ><% out.print(i); %></option>
          <%    } 
              } %>
          </select>

          <select name="action_year">
            <% int i = gregDate.get(gregDate.YEAR); %>
            <option value="<% out.print(i); %>" selected="selected" ><% out.print(i); %></option>
          </select>
        </td>
      </tr>
      <tr>
        <td>
          <b>Action Time:</b>
        </td>
      </tr>
      <tr>
        <td>
          <if:IfTrue cond='<%= enfActionBean.getAction_time_h().equals("") %>' >
            <input type="text" name="action_time_h" size="2" maxlength="2" value="<%= time_h %>" />
          </if:IfTrue>
          <if:IfTrue cond='<%= ! enfActionBean.getAction_time_h().equals("") %>' >
            <input type="text" name="action_time_h" size="2" maxlength="2" value="<%= enfActionBean.getAction_time_h()%>" />
          </if:IfTrue>
          :
          <if:IfTrue cond='<%= enfActionBean.getAction_time_m().equals("") %>' >
            <input type="text" name="action_time_m" size="2" maxlength="2" value="<%= time_m %>" />
          </if:IfTrue>
          <if:IfTrue cond='<%= ! enfActionBean.getAction_time_m().equals("") %>' >
            <input type="text" name="action_time_m" size="2" maxlength="2" value="<%= enfActionBean.getAction_time_m()%>" />
          </if:IfTrue>
        </td>
      </tr>
      <tr>
        <td>
          <b>Action Text:</b>
        </td>
      </tr>
      <tr>
        <td>
          <textarea rows="4" cols="28" name="action_text" ><%= enfActionBean.getAction_text() %></textarea>
        </td>
      </tr>
    </table>
    <br/>
    </sql:statement>
    <sql:closeConnection conn="con"/>

    <if:IfTrue cond='<%= enfActionBean.getSavedPreviousForm().equals("text") %>' >
      <jsp:include page="include/status_button.jsp" flush="true" />
    </if:IfTrue>
    <if:IfTrue cond='<%= ! enfActionBean.getSavedPreviousForm().equals("text") %>' >
      <jsp:include page="include/back_status_buttons.jsp" flush="true" />
    </if:IfTrue>

    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="enf_list_action_code" value="<%= enfActionBean.getEnf_list_action_code() %>" />
    <input type="hidden" name="input" value="enfAction" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
