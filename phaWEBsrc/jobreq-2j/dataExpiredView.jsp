<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.dataExpiredBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>

<jsp:useBean id="dataExpiredBean" scope="session" class="com.vsb.dataExpiredBean" />

<!-- Disable the browser back button -->
<script>window.history.go(1);</script>

<%-- Make sure this is the form we are supposed to be on --%>
<sess:equalsAttribute name="form" match="dataExpired" value="false">
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<html>
<head>
	<title>dataExpired</title>
  <style type="text/css">
		@import URL("global.css");
	</style>
</head>

<body>
  <form action="dataExpiredScript.jsp" method="post">
    <table>
      <tr>
        <td align="center" colspan="2"><h1>Data Expired</h1></td>
      </tr>
  		<tr><td colspan="2"><hr></td></tr>
      <tr><td>&nbsp;</td></tr>
      <tr>
        <td colspan="2"><b>Attempt to use expired data</b></td>
      </tr>
      <tr>
        <td colspan="2"><b>Please create a new request</b></td>
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

	  <input type="hidden" name="input" value="dataExpired" > 
  </form>
</body>
</html>
