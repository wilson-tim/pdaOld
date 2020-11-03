<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.reqformBean, com.vsb.newreqBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>

<jsp:useBean id="reqformBean" scope="session" class="com.vsb.reqformBean" />
<jsp:useBean id="newreqBean" scope="session" class="com.vsb.newreqBean" />

<!-- Disable the browser back button -->
<script>window.history.go(1);</script>

<%-- Make sure this is the form we are supposed to be on --%>
<sess:equalsAttribute name="form" match="newreq" value="false">
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<html>
<head>
	<title>newreq</title>
  <style type="text/css">
		@import URL("global.css");
	</style>
</head>

<body>
  <form action="newreqScript.jsp" method="post">
    <table>
      <tr>
        <td align="center" colspan="2"><h1>Request reported</h1></td>
      </tr>
  		<tr><td colspan="2"><hr></td></tr>
      <tr><td>&nbsp;</td></tr>
      <app:equalsInitParameter name="useMail" match="yes">
        <tr>
          <td colspan="2"><b>An email has been sent to the helpdesk</b></td>
        </tr>
      </app:equalsInitParameter>
      <tr>
        <td colspan="2"><b>Your job request has been sent to Pharaoh</b></td>
      </tr>
      <tr><td>&nbsp;</td></tr>
      <tr>
        <td colspan="2">
          <table>
            <tr>
              <td><b>Job Id & Reference No.:</b></td>
              <td><%=reqformBean.getNextCwJobId()%></td>
            </tr>
            <tr><td>&nbsp;</td></tr>
            <tr>
              <td><b>Problem Details:</b></td>
            </tr>
            <tr>
              <td colspan="2"><%=reqformBean.getProblemDetails1()%></td>
            </tr>
            <tr>
              <td colspan="2"><%=reqformBean.getProblemDetails2()%></td>
            </tr>
            <tr>
              <td colspan="2"><%=reqformBean.getProblemDetails3()%></td>
            </tr>
            <tr>
              <td colspan="2"><%=reqformBean.getProblemDetails4()%></td>
            </tr>
          </table>
        <td>
      </tr>
      <tr><td>&nbsp;</td></tr>
  	  <tr><td colspan="2"><hr></td></tr>
      <tr><td>&nbsp;</td></tr>
      <tr>
        <td colspan="2">
          <jsp:include page="include/new_button.jsp" flush="true" />
        <td>
      <tr>
      <tr>
        <td colspan="2" align="right">
          <jsp:include page="include/footer.jsp" flush="true" />
        <td>
      <tr>
    </table>

	  <input type="hidden" name="input" value="newreq" > 
  </form>
</body>
</html>
