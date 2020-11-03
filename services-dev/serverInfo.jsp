<%@ page errorPage="error.jsp" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat, java.net.*" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
  <title>serverInfo</title>
  <style type="text/css">
    @import URL("global.css");
  </style>
</head>

<body onUnload="">
  <form action="serverInfo.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Server Info.</b></font></h2>
        </td>
      </tr>
      <tr><td>&nbsp;</td></tr>
    </table>
    <table width="100%">
      <tr><td>&nbsp;</td></tr>
      <tr>
        <td>
          <b>Server Type:</b> <%= application.getServerInfo() %></br>
          </br>
          <%
            NetworkInterface iface = null;
            for(Enumeration ifaces = NetworkInterface.getNetworkInterfaces();ifaces.hasMoreElements();){
              iface = (NetworkInterface)ifaces.nextElement();
          %>
          </br><b>Interface:</b> <%= iface.getDisplayName()%></br>
          <%
              InetAddress ia = null;
              for(Enumeration ips = iface.getInetAddresses();ips.hasMoreElements();){
                ia = (InetAddress)ips.nextElement();
          %>
          &nbsp;&nbsp;&nbsp;<b><i><%= ia.getCanonicalHostName() %></i></b> <%= ia.getHostAddress() %></br>
          <%
              }
            }
          %>
        </td>
      </tr>
    </table>
    <jsp:include page="include/refresh_button.jsp" flush="true" />
    <jsp:include page="include/footer.jsp" flush="true" />
  </form>
</body>
</html>
