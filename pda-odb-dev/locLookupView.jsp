<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.schedOrCompBean, com.vsb.locLookupBean" %>
<%@ page import="com.db.*, java.util.*" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="schedOrCompBean" scope="session" class="com.vsb.schedOrCompBean" />
<jsp:useBean id="locLookupBean" scope="session" class="com.vsb.locLookupBean" />
<jsp:useBean id="locLookupPageSet" scope="session" class="com.db.PageSet" />

<app:equalsInitParameter name="use_xhtml" match="Y">
  <?xml version="1.0"?>

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="locLookup" value="false">
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
  <title>locLookup</title>
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
  <form onSubmit="return singleclick();" action="locLookupScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Location Lookup</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="locLookupBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <if:IfTrue cond='<%= schedOrCompBean.getAction().equals("Property") || 
                           schedOrCompBean.getAction().equals("Search") %>'>
        <tr>
          <td bgcolor="#259225" align="center">
            <h3><font color="white"><b>Property</b></font></h3>
          </td>
        </tr>
      </if:IfTrue>
      <if:IfTrue cond='<%= schedOrCompBean.getAction().equals("Trade") %>'>
        <tr>
          <td bgcolor="#259225" align="center">
            <h3><font color="white"><b>Trade</b></font></h3>
          </td>
        </tr>
      </if:IfTrue>
      <tr><td>&nbsp;</td></tr>      
    </table>
    <jsp:include page="include/rowset_nav_buttons.jsp" flush="true" />

    <% String color="#ffffff"; %>

    <table cellpadding="2" cellspacing="0" width="100%">
      <tr>
        <td colspan="2">
          <span class="subscript">sites <%= locLookupPageSet.getMinRecordInPage() %> - <%= locLookupPageSet.getMaxRecordInPage() %> of <%= locLookupPageSet.getRecordCount() %></span>
        </td>
      </tr>

      <%-- Show all the sites matching the search criteria --%>
      <%-- select site_ref, site_name_1 --%>
      <%-- from site --%>
      <%-- where ... --%>

      <% Page thePage = locLookupPageSet.getCurrentPage(); %>
      <% while (thePage.next()) {
           if(color=="#ffffff") {
             color = "#ecf5ff";
           } else if (color=="#ecf5ff") {
             color = "#ffffff";
           }
      %>
      <tr bgcolor="<%= color %>" >
        <td valign="top" width="10">
          <if:IfTrue cond='<%= thePage.getField(1).trim().equals(locLookupBean.getSite_ref()) %>' >
            <input type="radio" name="site_ref" id="<%= thePage.getField(1) %>" value="<%= thePage.getField(1) %>"  checked="checked" />
          </if:IfTrue>
          <if:IfTrue cond='<%= !(thePage.getField(1).trim().equals(locLookupBean.getSite_ref())) %>' >
            <input type="radio" name="site_ref" id="<%= thePage.getField(1) %>" value="<%= thePage.getField(1) %>" />
          </if:IfTrue>
        </td>
        <if:IfTrue cond='<%= schedOrCompBean.getAction().equals("Property") ||
                             schedOrCompBean.getAction().equals("Search") %>'>        
          <td valign="top">
            <label for="<%= thePage.getField(1) %>"><%= thePage.getField(2) %></label>
          </td>
        </if:IfTrue>
        <if:IfTrue cond='<%= schedOrCompBean.getAction().equals("Trade") %>'>
          <if:IfTrue cond='<%= !(thePage.getField(3) == null) && !(thePage.getField(3).trim().equals("")) %>'>
            <td valign="top">
              <label for="<%= thePage.getField(1) %>"><b><%= thePage.getField(3) %></b> - <%= thePage.getField(2) %></label>
            </td>          
          </if:IfTrue>
          <if:IfTrue cond='<%= (thePage.getField(3) == null) || (thePage.getField(3).trim().equals("")) %>'>
            <td valign="top">
              <label for="<%= thePage.getField(1) %>"><b><%= thePage.getField(4) %></b> - <%= thePage.getField(2) %></label>
            </td>          
          </if:IfTrue>
        </if:IfTrue>        
      </tr>
      <% } %>

      <%-- If there are no sites found --%>
      <if:IfTrue cond='<%= locLookupPageSet.getRecordCount() == 0 %>' >
        <tr>
           <td colspan="2">
             <b>No sites available</b>
           </td>
         </tr>
       </if:IfTrue>
       <tr><td>&nbsp;</td></tr>
       <tr>
        <td colspan="2">
          <span class="subscript">sites <%= locLookupPageSet.getMinRecordInPage() %> - <%= locLookupPageSet.getMaxRecordInPage() %> of <%= locLookupPageSet.getRecordCount() %></span>
        </td>
      </tr>
    </table>

    <jsp:include page="include/rowset_nav_buttons.jsp" flush="true" />
    <if:IfTrue cond='<%= schedOrCompBean.getAction().equals("Property") ||
                         schedOrCompBean.getAction().equals("Search") %>'>    
      <jsp:include page="include/collect_detail_buttons.jsp" flush="true" />
      <jsp:include page="include/back_service_buttons.jsp" flush="true" />
    </if:IfTrue>
    <if:IfTrue cond='<%= schedOrCompBean.getAction().equals("Trade") %>'>
      <jsp:include page="include/back_detail_agreement_buttons.jsp" flush="true" />    
    </if:IfTrue>
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="locLookup" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>