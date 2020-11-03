<%@ page errorPage="error.jsp" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

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

  <title>about</title>
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
  <form action="about.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>About</b></font></h2>
        </td>
      </tr>
      <tr><td>&nbsp;</td></tr>
    </table>

    <table width="100%">
      <tr>
        <td width="20%">
          <b>PDA version</b>
        </td>
        <td>
          <jsp:include page=".version" flush="true" />
        </td>
      </tr>
      <tr>
        <td width="20%">
          <b>Server version</b>
        </td>
        <td>
          <%= application.getServerInfo() %>
        </td>
      </tr>
      <tr>
        <td width="20%">
          <b>Servlet specification</b>
        </td>
        <td>
          <%= application.getMajorVersion() %>.<%= application.getMinorVersion() %>
        </td>
      </tr>
      <tr>
        <td width="20%">
          <b>JSP version</b>
        </td>
        <td>
          <%= JspFactory.getDefaultFactory().getEngineInfo().getSpecificationVersion() %>
        </td>
      </tr>
    </table>

    <jsp:include page="include/footer.jsp" flush="true" />
  </form>
</body>
</html>
