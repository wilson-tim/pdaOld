<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.cwtnDetailsBean, com.vsb.agreementBean, com.vsb.recordBean, com.vsb.helperBean" %>
<%@ page import="javax.sql.*, java.util.*" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="cwtnDetailsBean" scope="session" class="com.vsb.cwtnDetailsBean" />
<jsp:useBean id="agreementBean" scope="session" class="com.vsb.agreementBean" />
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
<sess:equalsAttribute name="form" match="cwtnDetails" value="false">
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
  <title>cwtnDetails</title>
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
  <form onSubmit="return singleclick();" action="cwtnDetailsScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>CWTN Details</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="cwtnDetailsBean" property="error" /></b></font></td></tr>
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
      <tr bgcolor="#ecf5ff">
        <td><b>Agreement No.</b></td>
        <td><%= agreementBean.getAgreement_no() %></td>
      </tr>
      <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
      <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
        <sql:statement id="stmt" conn="con1">
          <sql:query>
            SELECT cwtn_sno,
                   start_date,
                   end_date
              FROM cwtn
             WHERE cwtn_sno = (
              SELECT latest_cwtn
              FROM agreement
              WHERE agreement_no = <%= agreementBean.getAgreement_no() %>
              AND allow_cwtn = 'Y'
             )
	        </sql:query>
          <sql:resultSet id="rset1">
            <sql:getColumn position="1" to="cwtn_sno" />
            <tr bgcolor="#ecf5ff">
              <td><b>CWTN Ref.</b></td>
              <td><sql:getColumn position="1" /></td>
            </tr>
            <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
            <sql:getColumn position="2" to="start_date" />
            <tr bgcolor="#ecf5ff">
              <td><b>Start Date</b></td>
              <td><%= helperBean.dispDate(((String)pageContext.getAttribute("start_date")).trim(), application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %></td>
            </tr>
            <sql:getColumn position="3" to="end_date" />
            <tr bgcolor="#ffffff">
              <td><b>End Date</b></td>
              <td><%= helperBean.dispDate(((String)pageContext.getAttribute("end_date")).trim(), application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) %></td>
            </tr>
          </sql:resultSet>
          <%-- Details found --%>
          <sql:wasNotEmpty>
            <%-- Waste type and description --%>
            <sql:query>
              SELECT waste_type, (SELECT waste_desc FROM waste_type WHERE waste_type.waste_type = agreement.waste_type) wdesc
                FROM agreement
              WHERE agreement_no = <%= agreementBean.getAgreement_no() %>
            </sql:query>
            <sql:resultSet id="rset2">
              <sql:getColumn position="1" to="waste_type" />
            <tr><td colspan="2"><hr size="1" noshade="noshade" /></td></tr>
              <tr bgcolor="#ecf5ff">
                <td><b>Waste Type</b></td>
                <td><sql:getColumn position="1" /></td>
              </tr>
                <sql:getColumn position="2" to="waste_desc" />
                <tr bgcolor="#ffffff">
                  <td><sql:getColumn position="2" /></td>
              </tr>
            </sql:resultSet>
          </sql:wasNotEmpty>
          <%-- If there are no details--%>
          <sql:wasEmpty>
          <tr>
            <td colspan="2">
              No CWTN details found for this agreement.
            </td>
          </tr>
          </sql:wasEmpty>
        </sql:statement>    
      <sql:closeConnection conn="con1"/>
    </table>

    <table>
      <tr><td colspan="2">&nbsp;</td></tr>
    </table>

    <jsp:include page="include/back_button.jsp" flush="true" />
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="cwtnDetails" /> 
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
