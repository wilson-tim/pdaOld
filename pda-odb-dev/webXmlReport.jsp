<%@ page errorPage="error.jsp" %>
<%@ page import="java.util.ArrayList, java.util.Enumeration" %>
<%@ page import="java.util.Collections, java.util.Iterator" %>

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

<title>webXmlReport</title>
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
  <form action="webXmlReport.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Parameter Report</b></font></h2>
        </td>
      </tr>
      <tr><td>&nbsp;</td></tr>
    </table>
    
    <table width="100%">
      <tr><td colspan="2">&nbsp;</td></tr>
      <tr>
        <td><b>Parameter</b></td>
        <td><b>Value</b></td>
      </tr>

      <%
      ArrayList paramnames = new ArrayList();
      Enumeration enum = application.getInitParameterNames();
      String paramname = "";
      String paramvalue = "";
      String colour = "#ffffff";
      while (enum.hasMoreElements()){
        paramname = (String)enum.nextElement();
        paramnames.add(paramname);
      }
      Collections.sort(paramnames);
      Iterator stepper = paramnames.iterator();
      while (stepper.hasNext()) {
        paramname  = (String)stepper.next();
        paramvalue = application.getInitParameter(paramname);
        if(colour == "#ffffff") {
          colour = "#ecf5ff";
        } else if (colour == "#ecf5ff") {
          colour = "#ffffff";
        }
      %>
        <tr bgcolor="<%= colour %>" >
          <td width="20%"><%= paramname  %></td>
          <td            ><%= paramvalue %></td>
        </tr>
      <%
      }
      %>
    </table>

    <jsp:include page="include/footer.jsp" flush="true" />
  </form>
</body>
</html>
