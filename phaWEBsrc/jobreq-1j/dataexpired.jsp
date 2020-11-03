<%@ page errorPage="error.jsp" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/datetime-1.0" prefix="date" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>

<%-- Create unique ID --%>
<sess:session id="ss"/>
<sess:setAttribute name="uniqueId"><jsp:getProperty name="ss" property="sessionId"/><date:currentTime/></sess:setAttribute>

<html>
<head>
  <title>Pharaoh - Request logging: Data Expired</title>
  <jsp:include page="style-include.jsp" flush="true" />
</head>

<body>

  <table>
    <tr>
      <td align="center" colspan="2"><h1>Data Expired</h1></td>
    </tr>
    <tr>
      <td bgcolor="#259225" colspan="2">&nbsp;</td>
    </tr>
    <tr><td>&nbsp;</td></tr>
    <tr>
      <td colspan="2"><b>Attempt to use expired data</b></td>
    </tr>
    <tr>
      <td colspan="2"><b>Please create a new request</b></td>
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