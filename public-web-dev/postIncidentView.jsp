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
    <script src="cSuggest.js"></script> 
    <link rel="stylesheet" type="text/css" href="cSuggest.css" /> 
  </head>
  <body class="<c:out value="${requiredPage}"/>">

<form action="publicaccess.jsp" method="post">
    <h2 class="PageTitle"><x:out select="$WAWorkFlow//services/element[service_code=$service_c]/paths/element[component_page = $requiredPage]/component_title" /></h2>
    <input type="hidden" name="input" value="<c:out value="${requiredPage}"/>" >
    <input type="hidden" name="webtype" value="<%= incidentBean.getWebType() %>" >
<x:if select="$incidentResult//.[status_flag='Y']">
    <div class="UserInput">
    <h2>The incident has been recorded</h2>
    <p>Your reference number is <x:out select="$incidentResult//contender_id" /></p>
    </div>
    <div class="Controls">
        <input type="hidden" name="action" value="JumpTo" >
        <input type="hidden" name="page" value="getService" >
        <div class="Back"> </div>
        <div class="Next"><input class="control" type="submit" name="nullaction" value="Done" /></div>
    </div>
</x:if>
<x:if select="$incidentResult//.[status_flag != 'Y']">
    <div class="UserInput">
    <p>Sorry but an error was encountered while recording your details.</p>
    <p>The error code is '<x:out select="$incidentResult//status_text" />'</p>
    </div>
    <div class="Controls">
        <input type="hidden" name="action" value="JumpTo" >
        <input type="hidden" name="page" value="getService" >
        <div class="Back"><input class="control" type="submit" name="action" value="Back" /></div>
        <div class="Next"> </div>
    </div>
</x:if>
</form>
<div class="HelpText"><x:out select="$WAWorkFlow//services/element[service_code=$service_c]/paths/element[component_page = $requiredPage]/component_help" /></div>
<div class="error"><c:out value="${errorMessage}" /></div>
    <jsp:include page="include/footer.jsp" flush="true" />
  </body>
</html>
