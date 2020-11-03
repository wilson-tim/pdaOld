<%@ page errorPage="error.jsp" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/datetime-1.0" prefix="date" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>

<%-- Create unique ID --%>
<sess:session id="ss"/>
<sess:setAttribute name="uniqueId"><jsp:getProperty name="ss" property="sessionId"/><date:currentTime/></sess:setAttribute>

<html>
<head>
  <title>Pharaoh - Request logging: New Request</title>
  <jsp:include page="style-include.jsp" flush="true" />
</head>

<body>

  <table>
    <tr>
      <td align="center" colspan="2"><h1>Request reported</h1></td>
    </tr>
    <tr>
      <td bgcolor="#259225" colspan="2">&nbsp;</td>
    </tr>
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
            <td><req:parameter name="cwJobId" /></td>
          </tr>
          <tr><td>&nbsp;</td></tr>
          <tr>
            <td><b>Problem Details:</b></td>
          </tr>
          <tr>
            <td colspan="2"><req:parameter name="text" /></td>
          </tr>
        </table>
      <td>
    </tr>
    <tr><td>&nbsp;</td></tr>
    <tr>
      <td bgcolor="#259225" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td>
        <table>
          <tr>
            <td>
              <a href="reqform.jsp"><img src="pharaoh-arrow-web.gif" alt="back" border="0"></a>
            </td>
            <td>
              <b>New<br>Request</b>
            </td>
          </tr>
        </table>
      </td>
    </tr>
    <jsp:include page="footer-include.jsp" flush="true" />
  </table>
  
</body>
</html>
