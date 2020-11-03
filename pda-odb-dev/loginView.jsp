<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.loginBean" %>
<%@ page import="java.util.Enumeration" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="loginBean" scope="session" class="com.vsb.loginBean" />

<app:equalsInitParameter name="use_xhtml" match="Y">
  <?xml version="1.0"?>
  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

<app:equalsInitParameter name="use_xhtml" match="Y">
  <html xmlns="http://www.w3.org/1999/xhtml">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <html>
</app:equalsInitParameter>
<head>
  <!-- Set iPhone OS Safari attributes -->
  <meta name = "viewport" content = "width = device-width"/>

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
  <title>login</title>
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
  <form onSubmit="return singleclick();" action="loginScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Login</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="loginBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>
    <table width="100%">
      <%-- If ISA server authentication is being used then gte the --%>
      <%-- user name and redirect to the next page --%>
      <app:equalsInitParameter name="isa_authorization" match="Y" >
        <%-- make sure the appropriate HTTP header element is there before --%>
        <%-- processing the isa_authorization --%>
        <req:existsHeader name="authorization">
          <tr>
            <td>
              <b>ISA Server Authentication is being used. The user </b>
              <%= loginBean.getUser_name() %>
              <b> has just failed to login to the webapp.</b>
            </td>
          </tr>
          <input type="hidden" name="user_name" value="<%= loginBean.getUser_name() %>" /> 
          <input type="hidden" name="user_pass" value="" />
        </req:existsHeader>
        <req:existsHeader name="authorization" value="false">
          <tr>
            <td colspan="2">
              <b>ISA Server Authentication is being used, but there is no</b> authorization <b> header section!</b>
            </td>
          </tr>
          <tr><td colspan="2">&nbsp;</td></tr>
          <tr>
            <td><b>User Name</b></td>
            <td><input type="text" name="user_name" size="16" /></td>
          </tr>
          <tr>
            <td><b>Password</b></td>
            <td><input type="password" name="user_pass" size="16" /></td>
          </tr>  
        </req:existsHeader>
      </app:equalsInitParameter>
      <app:equalsInitParameter name="isa_authorization" match="Y" value="false">
        <tr>
          <td><b>User Name</b></td>
          <td><input type="text" name="user_name" size="16" /></td>
        </tr>
        <tr>
          <td><b>Password</b></td>
          <td><input type="password" name="user_pass" size="16" /></td>
        </tr>  
      </app:equalsInitParameter>
    </table>
    <jsp:include page="include/login_button.jsp" flush="true" />    
    
    <%-- The offsite URL section --%>
    <table width="100%">
      <tr>
        <td>
          <p align="left">
            <a href="<app:initParameter name="urlTag"/>" ><app:initParameter name="urlTagName"/></a>
          </p>
        </td>
      </tr>
    </table>

    <%-- Request Information. Only show if application init parameter set --%>
    <app:equalsInitParameter name="debug_header" match="Y" >
      <table width="100%">
        <tr><td colspan="2"><hr size="2" noshade="noshade" /></td></tr>
        <tr bgcolor="#259225" align="center">        
          <td colspan="2">
            <font color="white">
              <h3>Request Information</h3>
            </font>
          </td>        
        </tr>
        <tr bgcolor="#ecf5ff">
          <td>Method</td><td><%= request.getMethod() %></td>
        </tr>
        <tr>
          <td>URI</td><td><%= request.getRequestURI() %></td>
        </tr>
        <tr bgcolor="#ecf5ff">
          <td>Protocol</td><td><%= request.getProtocol() %></td>
        </tr>
        <tr bgcolor="#DDDDDD" align="center">        
            <td><b>Header Name</b></td>
            <td><b>Value</b></td>
        </tr>
          <%
            Enumeration headerNames = request.getHeaderNames();
            boolean colorChange = false;
            String color = "#ffffff";
            while(headerNames.hasMoreElements()) {            
          %>
            <tr bgcolor="<%= color %>">
              <td>
                <% String headerName = (String)headerNames.nextElement(); %>
                <%= headerName %>
              </td>
              <td>
                <%= request.getHeader(headerName) %>
              </td>
            </tr>      
          <%
            if(colorChange){ color="#ffffff"; colorChange=false; }
            else{ color="#ecf5ff"; colorChange=true; }
            }
          %>
      </table>
    </app:equalsInitParameter>

    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="login" /> 
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
