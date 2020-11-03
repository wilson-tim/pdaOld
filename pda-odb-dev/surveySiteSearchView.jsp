<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.surveySiteSearchBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="surveySiteSearchBean" scope="session" class="com.vsb.surveySiteSearchBean" />

<app:equalsInitParameter name="use_xhtml" match="Y">
  <?xml version="1.0"?>

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
</app:equalsInitParameter>
<app:equalsInitParameter name="use_xhtml" match="Y" value="false">
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
</app:equalsInitParameter>

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="surveySiteSearch" value="false">
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
  <!-- Check to see if the suggest module is on -->
  <app:equalsInitParameter name="use_suggest" match="Y" >
    <script src="cSuggest.js"></script>
    <link rel="stylesheet" type="text/css" href="cSuggest.css" />
  </app:equalsInitParameter>
  <title>surveySiteSearch</title>
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

<body onUnload=""
  <%-- Check to see if the suggest module is on --%>
  <app:equalsInitParameter name="use_suggest" match="Y" >
    <%= "onresize='redraw()' ondblclick='clearSuggest()'" %>
  </app:equalsInitParameter>
>
  <form onSubmit="return singleclick();" action="surveySiteSearchScript.jsp" method="post">
    <table width="100%">
      <tr>
        <td bgcolor="#259225" align="center">
          <h2><font color="white"><b>Location Search</b></font></h2>
        </td>
      </tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
      <tr><td><font color="#ff6565"><b><jsp:getProperty name="surveySiteSearchBean" property="error" /></b></font></td></tr>
      <tr><td><hr size="2" noshade="noshade" /></td></tr>
    </table>
    <table width="100%">
      <tr>
        <td>
          <b>Postcode</b>
        </td>
        <td>
          <input type="text" name="surveyPostCode" size="8"
            value="<%=surveySiteSearchBean.getSurveyPostCode()%>"
            <%-- Check to see if the suggest module is on --%>
            <app:equalsInitParameter name="use_suggest" match="Y" >
              <%= "onfocus='clearSuggest()'" %>
            </app:equalsInitParameter>
          />
        </td>
      </tr>
      <tr>
        <td>
          <b>Street Name</b>
        </td>
        <td>
          <input id="surveyLocation"
                 type="text" 
                 name="surveyLocation" 
                 size="18"
                 class="suggest"
                 <app:equalsInitParameter name="use_suggest" match="Y" >
                   autocomplete="off"
                 </app:equalsInitParameter>
                 value="<jsp:getProperty name="surveySiteSearchBean" property="surveyLocation" />"
                 <%-- Check to see if the suggest module is on --%>
                 <app:equalsInitParameter name="use_suggest" match="Y" >
                   <%= "onfocus='clearAndShow(this.value, \"surveyLocation\")' " %>
                   <%= "onkeyup='showHint(this.value, \"surveyLocation\");'" %>
                 </app:equalsInitParameter>
          />
        </td>
      </tr>
    </table>
    <div class="cSuggest" id="cSuggest"></div>    
    <jsp:include page="include/back_search_buttons.jsp" flush="true" />
    <%@ include file="include/insp_sched_buttons.jsp" %>
    <jsp:include page="include/footer.jsp" flush="true" />
    <input type="hidden" name="input" value="surveySiteSearch" />
    <input type="hidden" name="jsessionid" value="<%= session.getId() %>" />
  </form>
</body>
</html>
