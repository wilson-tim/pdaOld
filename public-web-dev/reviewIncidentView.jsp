<%@ page import="com.vsb.incidentBean" %>
<%@ page import="com.vsb.savedPublicDescriptionBean" %>
<%@ taglib uri="http://java.sun.com/jstl/xml" prefix="x" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<jsp:useBean id="incidentBean" scope="session" class="com.vsb.incidentBean" />
<jsp:useBean id="savedPublicDescriptionBean" scope="session" class="com.vsb.savedPublicDescriptionBean" />

<script>window.history.go(1);</script>
<html>
  <head>
    <meta http-equiv="Refresh" content="<app:initParameter name='refreshInterval' />" />
    <title><x:out select="$WAHeader//headers/element/web_type_desc"  /></title>
    <style type="text/css">@import url(publicaccess.css);</style>
    <script src="cSuggest.js"></script> 
    <link rel="stylesheet" type="text/css" href="cSuggest.css" /> 
  </head>
  <body class="<c:out value="${requiredPage}"/>">

<form action="publicaccess.jsp" method="post">
    <h2 class="PageTitle"><x:out select="$WAWorkFlow//services/element[service_code=$service_c]/paths/element[component_page = $requiredPage]/component_title" /></h2>
    <input type="hidden" name="input" value="reviewIncident" >
    <input type="hidden" name="webtype" value="<%= incidentBean.getWebType() %>" >
    <div class="UserInput">
        <table>
            <%
                for(int i=0;i<savedPublicDescriptionBean.size();i++){
            %>
            <tr><td><%= savedPublicDescriptionBean.getValueByIndex(i) %></td><td><a href="publicaccess.jsp?input=none&action=JumpTo&page=<%= savedPublicDescriptionBean.getPageByIndex(i) %>">Change</a></td></tr>
            <%
                }
            %>
        </table>
    </div>
    <div class="Controls">
        <div class="Back"><input class="control" type="submit" name="action" value="Back" /></div>
        <div class="Next"><input class="control" type="submit" name="action" value="Next" /></div>
    </div>
</form>
<div class="HelpText"><x:out select="$WAWorkFlow//services/element[service_code=$service_c]/paths/element[component_page = $requiredPage]/component_help" /></div>
<div class="error"><c:out value="${errorMessage}" /></div>
    <jsp:include page="include/footer.jsp" flush="true" />
  </body>
</html>
