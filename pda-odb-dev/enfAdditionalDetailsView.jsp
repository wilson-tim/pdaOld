<%@ page errorPage="error.jsp" %>
<%@ page import="java.util.*, java.text.*, java.text.SimpleDateFormat" %>
<%@ page import="com.vsb.enfAdditionalDetailsBean, com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="enfAdditionalDetailsBean" scope="session" class="com.vsb.enfAdditionalDetailsBean" />

<app:equalsInitParameter name="use_xhtml" match="Y">
  <?xml version="1.0"?>

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="enfAdditionalDetails" value="false">
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
  if (recordBean.getOffence_date().equals("")) {
    // set the date to todays date
    date = new java.util.Date();
  } else {
    // set the date to the stored date as it exists
    date = formatDate.parse(recordBean.getOffence_date());
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
  <title>enfAdditionalDetails</title>
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
  <form onSubmit="return singleclick();" action="enfAdditionalDetailsScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Additional Details</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="enfAdditionalDetailsBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>
    <table width="100%" border="0">
      <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
      <sql:statement id="stmt" conn="con">
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
          <b>Investigative Officer:</b>
        </td>
      </tr>
      <tr>
        <td>
          <select name="invOff">
            <sql:resultSet id="rset">
              <sql:getColumn position="1" to="invOff" />

              <% String fullname = ""; %>
              <sql:getColumn position="2" to="fullname" />
              <sql:wasNotNull>
                <% fullname = ((String)pageContext.getAttribute("fullname")).trim(); %>
              </sql:wasNotNull>

              <if:IfTrue cond='<%= ((String)pageContext.getAttribute("invOff")).trim().equals(enfAdditionalDetailsBean.getInvOff().trim()) %>' >
                
                <if:IfTrue cond='<%= ! fullname.equals("") %>' >
                  <option value="<sql:getColumn position="1" />" selected="selected" ><sql:getColumn position="2" /></option>
                </if:IfTrue>
                <if:IfTrue cond='<%=  fullname.equals("") %>' >
                  <option value="<sql:getColumn position="1" />" selected="selected" >No Name</option>
                </if:IfTrue>
              </if:IfTrue>
              <if:IfTrue cond='<%= ! ((String)pageContext.getAttribute("invOff")).trim().equals(enfAdditionalDetailsBean.getInvOff().trim()) %>' >
                <if:IfTrue cond='<%= ! fullname.equals("") %>' >
                  <option value="<sql:getColumn position="1" />"><sql:getColumn position="2" /></option>
                </if:IfTrue>
                <if:IfTrue cond='<%=  fullname.equals("") %>' >
                  <option value="<sql:getColumn position="1" />" selected="selected" >No Name</option>
                </if:IfTrue>
              </if:IfTrue>
            </sql:resultSet>
          </select>
        </td>
      </tr>
      <tr>
        <td>
          <b>Enforcement Officer:</b>
        </td>
      </tr>
      <tr>
        <td>
          <select name="enfOff">
            <sql:resultSet id="rset">
              <sql:getColumn position="1" to="enfOff" />

              <% String fullname = ""; %>
              <sql:getColumn position="2" to="fullname" />
              <sql:wasNotNull>
                <% fullname = ((String)pageContext.getAttribute("fullname")).trim(); %>
              </sql:wasNotNull>

              <if:IfTrue cond='<%= ((String)pageContext.getAttribute("enfOff")).trim().equals(enfAdditionalDetailsBean.getEnfOff().trim()) %>' >
                <if:IfTrue cond='<%= ! fullname.equals("") %>' >
                  <option value="<sql:getColumn position="1" />" selected="selected" ><sql:getColumn position="2" /></option>
                </if:IfTrue>
                <if:IfTrue cond='<%= fullname.equals("") %>' >
                  <option value="<sql:getColumn position="1" />" selected="selected" >No Name</option>
                </if:IfTrue>
              </if:IfTrue>
              <if:IfTrue cond='<%= ! ((String)pageContext.getAttribute("enfOff")).trim().equals(enfAdditionalDetailsBean.getEnfOff().trim()) %>' >
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
      </sql:statement>
      <sql:closeConnection conn="con"/>
      <tr>
        <td>
          <b>Vehicle Registration:</b>
        </td>
      </tr>
      <tr>
        <td>
          <input type="text" name="vehicle_reg" size="17" maxlength="12" value="<%= enfAdditionalDetailsBean.getVehicle_reg()%>" />
        </td>
      </tr>
      <tr>
        <td>
          <b>Offence Date:</b>
        </td>
      </tr>
      <tr>
        <td>
          <select name="offence_day">
          <%  for (int i=1; i<32; i++) { 
                if (i == gregDate.get(gregDate.DATE)) { %>
                   <option value="<% out.print(i); %>" selected="selected" ><% out.print(i); %></option>
          <%    } else { %>
                   <option value="<% out.print(i); %>" ><% out.print(i); %></option>
          <%     }   
               } %>
          </select>

          <select name="offence_month">
          <%  for (int i=1; i<13; i++) {
                if (i == gregDate.get(gregDate.MONTH) + 1) { %>
                   <option value="<% out.print(i); %>" selected="selected" ><% out.print(i); %></option>
          <%     } else { %>
                   <option value="<% out.print(i); %>" ><% out.print(i); %></option>
          <%    } 
              } %>
          </select>

          <select name="offence_year">
          <%  for (int i=gregDate.get(gregDate.YEAR), k=i-1; i >= k; i--) {
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
      <tr>
        <td>
          <b>Offence Time:</b>
        </td>
      </tr>
      <tr>
        <td>
          <if:IfTrue cond='<%= enfAdditionalDetailsBean.getOffence_time_h().equals("") %>' >
            <input type="text" name="offence_time_h" size="2" maxlength="2" value="<%= time_h %>" />
          </if:IfTrue>
          <if:IfTrue cond='<%= ! enfAdditionalDetailsBean.getOffence_time_h().equals("") %>' >
            <input type="text" name="offence_time_h" size="2" maxlength="2" value="<%= enfAdditionalDetailsBean.getOffence_time_h()%>" />
          </if:IfTrue>
          :
          <if:IfTrue cond='<%= enfAdditionalDetailsBean.getOffence_time_m().equals("") %>' >
            <input type="text" name="offence_time_m" size="2" maxlength="2" value="<%= time_m %>" />
          </if:IfTrue>
          <if:IfTrue cond='<%= ! enfAdditionalDetailsBean.getOffence_time_m().equals("") %>' >
            <input type="text" name="offence_time_m" size="2" maxlength="2" value="<%= enfAdditionalDetailsBean.getOffence_time_m()%>" />
          </if:IfTrue>
        </td>
      </tr>
    </table>
    <br/>
    <jsp:include page="include/back_addtext_susevd_buttons.jsp" flush="true" />
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="enfAdditionalDetails" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
