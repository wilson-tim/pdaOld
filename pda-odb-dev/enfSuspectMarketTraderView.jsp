<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.enfSuspectMarketTraderBean" %>

<%@ taglib uri="http://www.servletsuite.com/servlets/iftags"       prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0"     prefix="sess" %>
<%@ taglib uri="http://java.sun.com/jstl/xml"                      prefix="x" %>
<%@ taglib uri="http://java.sun.com/jstl/core"                     prefix="c"    %>

<jsp:useBean id="enfSuspectMarketTraderBean" scope="session" class="com.vsb.enfSuspectMarketTraderBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="enfSuspectMarketTrader" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

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
  <title>enfSuspectMarketTrader</title>
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

<body onUnload="" onLoad="update()">
  <form onSubmit="return singleclick();" action="enfSuspectMarketTraderScript.jsp" method="post">
    <%-- Title --%>
    <table width="100%">
      <tr>
        <td>
          <h2>Add Suspect</h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="enfSuspectMarketTraderBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>

    <x:set var="traderRecord" select="$traderRecords//element[position()=1]" />

    <%-- Pitch Details --%>
    <table width="100%">
      <tr bgcolor="#ecf5ff">
        <td><b>Trader</b></td>
        <td colspan="3"><x:out select="$traderRecord/trader_name" /></td>
      </tr>
      <tr bgcolor="#ffffff">
        <td><b>Contact</b></td>
        <td colspan="3"><x:out select="$traderRecord/contact_name" /></td>
      </tr>
      <tr bgcolor="#ecf5ff">
        <td><b>Telephone</b></td>
        <td><x:out select="$traderRecord/contact_tel" /></td>
        <td><b>Mobile</b></td>
        <td><x:out select="$traderRecord/contact_mobile" /></td>
      </tr>
      <tr bgcolor="#ffffff">
        <% String site_name = ""; %>
        <c:set var="site_name_1"><x:out select="$traderRecord/trader_site_name_1" /></c:set>
        <% String site_name_1 = (String)pageContext.getAttribute("site_name_1"); %>
        <c:set var="site_name_2"><x:out select="$traderRecord/trader_site_name_2" /></c:set>
        <% String site_name_2 = (String)pageContext.getAttribute("site_name_2"); %>
        <%
        site_name = site_name_1;
        if (!site_name_1.equals("") & !site_name_2.equals("")) {
          site_name = site_name + " " + site_name_2;
        }
        %>
        <td><b>Address</b></td>
        <td colspan="3"><%= site_name %></td>
      </tr>
    </table>

    <table width="100%">
      <tr>
        <td>
          <b>Notes</b><br/>
          <textarea rows="4" cols="28" name="traderNotes" readonly="readonly" ><x:out select="$traderRecord/trader_notes" /></textarea>
        </td>
      </tr>
      <tr><td>&nbsp;</td></tr>
    </table>

    <jsp:include page="include/back_change_continue_buttons.jsp" flush="true" />
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="enfSuspectMarketTrader" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>

</html>
