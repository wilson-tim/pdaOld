<%@ page import="com.vsb.incidentBean" %>
<%@ taglib uri="http://java.sun.com/jstl/xml" prefix="x" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<jsp:useBean id="incidentBean" scope="session" class="com.vsb.incidentBean" />
<script>window.history.go(1);</script>
<html>
  <head>
    <meta http-equiv="Refresh" content="<app:initParameter name='refreshInterval' />" />
    <title><x:out select="$WAHeader//headers/element/web_type_desc"  /></title>
    <style type="text/css">@import url(publicaccess.css);</style>
  </head>
  <body class="<c:out value="${requiredPage}"/>">

<form action="publicaccess.jsp" method="post">
    <h2 class="PageTitle"><x:out select="$WAWorkFlow//services/element[1]/paths/element[component_page = $requiredPage]/component_title" /></h2>
    <input type="hidden" name="input" value="getService" >
    <input type="hidden" name="webtype" value="<%= incidentBean.getWebType() %>" >
    <div class="UserInput">
        <x:forEach var="n" select="$serviceList//services/element">
            <input type="radio" name="incident_service" value="<x:out select="$n/service_code"/>"
            <x:if select="$n/.[service_code = $service_c]">
                checked="checked"
            </x:if>
            ><x:out select="$n/public_description" /></input><br />
        </x:forEach> 
    </div>
    <div class="Controls">
        <div class="Back"></div>
        <div class="Next"><input class="control" type="submit" name="action" value="Next" /></div>
    </div>
</form>
<div class="HelpText"><x:out select="$WAWorkFlow//services/element[1]/paths/element[component_page = $requiredPage]/component_help" /></div>
<div class="error"><c:out value="${errorMessage}" /></div>
    <jsp:include page="include/footer.jsp" flush="true" />
  </body>
</html>
