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
    <div class="UserInput">
        <table>
            <tr class="TableHeader">
            <td>Date</td>
            <td>Service</td>
            <td>Item</td>
            <td>Issue</td>
            </tr>
            <x:forEach var="n" select="$SiteHistory//history/element">
            <c:set var="item_ref"><x:out select="$n/item_ref"/></c:set>
            <c:set var="comp_code"><x:out select="$n/comp_code"/></c:set>
            <c:set var="contract_ref"><x:out select="$n/contract_ref"/></c:set>
            <c:set var="feature_ref"><x:out select="$n/feature_ref"/></c:set>
                <tr>
                <td><x:out select="$n/date_raised"/></td>
                <td><x:out select="$serviceList//services/element[service_c=$contract_ref]/service_desc"/></td>
                <td><x:out select="$ItemCompCode//codes/element[item_ref=$item_ref]/item_desc"/><x:out select="$SiteItems//items/element[item_ref=$item_ref]/item_desc"/></td>
                <td><x:out select="$ItemCompCode//codes/element[comp_code=$comp_code]/comp_code_desc"/></td>
                </tr>
            </x:forEach> 
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
