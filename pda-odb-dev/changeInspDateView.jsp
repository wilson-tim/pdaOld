<%@ page errorPage="error.jsp" %>
<%@ page import="java.util.*, java.text.*, java.text.SimpleDateFormat" %>
<%@ page import="com.vsb.changeInspDateBean, com.vsb.helperBean, com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="changeInspDateBean" scope="session" class="com.vsb.changeInspDateBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />
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
<sess:equalsAttribute name="form" match="changeInspDate" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Set up the date variables --%>
<sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
<sql:statement id="stmt" conn="con">
  <% int complaint_no = Integer.parseInt(recordBean.getComplaint_no()); %>
  <% String diry_date_due = ""; %>
  <sql:query>
    select date_due
    from diry
    where source_flag = 'C'
    and   source_ref = '<%= complaint_no %>'
  </sql:query>
  <sql:resultSet id="rset">
    <sql:getDate position="1" to="date_due" format="<%= application.getInitParameter("db_date_fmt") %>" />
    <sql:wasNotNull>
      <% diry_date_due = ((String)pageContext.getAttribute("date_due")).trim(); %>
    </sql:wasNotNull>
  </sql:resultSet>
</sql:statement>
<sql:closeConnection conn="con"/>
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

    // set the correct date to use in the form
    String diry_date_due = ((String)pageContext.getAttribute("date_due")).trim();
    if (diry_date_due.equals("")) {
      // set the date to todays date
      date = new java.util.Date();
    } else {
      // set the date to the stored date as it exists
      date = formatDate.parse(diry_date_due);
    }
    
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
  <title>changeInspDate</title>
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
  <form onSubmit="return singleclick();" action="changeInspDateScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Change Inspection Date</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="changeInspDateBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>
    <table width="100%">
      <tr>
        <td colspan="2">
          <b>Inspection Date:</b>
        </td>
      </tr>
      <tr>
        <td colspan="2">
          <table>
            <tr>
              <td width="33%"><b>Day</b></td>
              <td width="33%"><b>Month</b></td>
              <td width="33%"><b>Year</b></td>
            </tr>
            <tr>
              <td>
                <select name="day">
                <%  for (int i=1; i<32; i++) { 
                      if (i == gregDate.get(gregDate.DATE)) { %>
                         <option value="<% out.print(i); %>" selected="selected" ><% out.print(i); %></option>
                <%    } else { %>
                         <option value="<% out.print(i); %>" ><% out.print(i); %></option>
                <%     }   
                     } %>
                </select>
              </td>
              <td>
                <select name="month">
                <%  for (int i=1; i<13; i++) {
                      if (i == gregDate.get(gregDate.MONTH) + 1) { %>
                         <option value="<% out.print(i); %>" selected="selected" ><% out.print(i); %></option>
                <%     } else { %>
                         <option value="<% out.print(i); %>" ><% out.print(i); %></option>
                <%    } 
                    } %>
                </select>
              </td>
              <td>
                <select name="year">
                <%  for (int i=gregDate.get(gregDate.YEAR), k=i+2; i <= k; i++) {
                      if (i == gregDate.get(gregDate.YEAR)) { %>
                         <option value="<% out.print(i); %>" selected="selected" ><% out.print(i); %></option>
                <%     } else { %>
                        <option value="<% out.print(i); %>" ><% out.print(i); %></option>
                <%   } 
                   } 
                %>
                </select>
              </td>
            </tr>
          </table>
        </td>
      </tr>
      <tr><td>&nbsp;</td></tr>
    </table>
    <jsp:include page="include/back_finish_buttons.jsp" flush="true" />
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="changeInspDate" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
