<%@ page errorPage="error.jsp" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat" %>
<%@ page import="com.vsb.agreementBean, com.vsb.recordBean, com.vsb.helperBean, com.vsb.loginBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="agreementBean" scope="session" class="com.vsb.agreementBean" />
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
<sess:equalsAttribute name="form" match="agreement" value="false">
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
  <title>agreement</title>
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
  <form onSubmit="return singleclick();" action="agreementScript.jsp" method="post">
  
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Agreements</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr>
        <td>
	        <font color="#ff6565">
	        <b><jsp:getProperty name="agreementBean" property="error" /></b>
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
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
      <%-- Get all the associated agreements for this trade site --%>
      <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
        <sql:statement id="stmt" conn="con1">
          <sql:query>
            SELECT agreement_no,
                   agreement_name,
                   waste_type,
                   contractor_ref,
                   status_ref
              FROM agreement
             WHERE site_ref = <%= recordBean.getTrade_site_no() %>
             AND '<%= date_now %>' >= start_date
             AND ('<%= date_now %>' < close_date
                  OR
                    close_date IS NULL
                  OR
                    close_date = ''
                 )
             ORDER BY agreement_no ASC
	        </sql:query>
          <sql:resultSet id="rset1">
          <%-- Table row: Radio button, agreement number, status --%>  
          <tr>
            <td width="10">
              <sql:getColumn position="1" to="agreement_no" />
              <if:IfTrue cond='<%= ((String)pageContext.getAttribute("agreement_no")).trim().equals(agreementBean.getAgreement_no()) %>' >
                <input type    ="radio" 
                       name    ="agreement_no" 
                       id      ="<sql:getColumn position="1" />"  
                       value   ="<sql:getColumn position="1" />"  
                       checked ="checked" />
              </if:IfTrue>
              <if:IfTrue cond='<%= !((String)pageContext.getAttribute("agreement_no")).trim().equals(agreementBean.getAgreement_no()) %>' >
                <input type    ="radio" 
                       name    ="agreement_no" 
                       id      ="<sql:getColumn position="1" />" 
                       value   ="<sql:getColumn position="1" />" />
              </if:IfTrue>
            </td>
            <td bgcolor="#259225" width="100%">
              <label for="<sql:getColumn position='1' />">
                <b><font color="white">Agreement No. <%= ((String)pageContext.getAttribute("agreement_no")).trim() %></font></b>
              </label>
            </td>
          </tr>
          <tr>
            <td colspan="2" bgcolor="#3366cc">
              <label for="<sql:getColumn position='1' />">
                <b><font color="white"><sql:getColumn position="2" /></font></b> 
              </label>
            </td>
          </tr>
          <tr>
            <td colspan="2">
              <table width="100%">
                <%-- contractor_ref --%>
                <tr bgcolor="#ffffff">
                  <td>
                    <label for="<sql:getColumn position='1' />">
                      <b>Contractor</b>
                    </label>
                  </td>
                  <td>
                    <label for="<sql:getColumn position='1' />">                
                      <sql:getColumn position="4" />
                    </label>
                  </td>
                </tr>
                <%-- waste_type --%>
                <tr bgcolor="#ecf5ff">
                  <td>
                    <label for="<sql:getColumn position='1' />">                
                      <b>Waste type</b>
                    </label>
                  </td>
                  <td>
                    <label for="<sql:getColumn position='1' />">                
                      <sql:getColumn position="3" />
                    </label>                    
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          </sql:resultSet>
          <%-- If there are no agreements--%>
          <sql:wasEmpty>
          <tr>
            <td colspan="2">
              No agreements found for this trade site.  
            </td>
          </tr>
          </sql:wasEmpty>
          <sql:wasNotEmpty>
            <tr>
              <td colspan="2">
                <span class="subscript"><sql:rowCount /> agreement(s)</span>
              </td>
            </tr>
          </sql:wasNotEmpty>
        </sql:statement>    
      <sql:closeConnection conn="con1"/>
    </table>
    <jsp:include page="include/back_cwtn_tasks_buttons.jsp" flush="true" />
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="agreement" /> 
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
