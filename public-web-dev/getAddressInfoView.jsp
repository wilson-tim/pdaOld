<%@ page import="com.vsb.incidentBean" %>
<%@ page import="com.vsb.locationSearchBean" %>
<%@ taglib uri="http://java.sun.com/jstl/xml" prefix="x" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<jsp:useBean id="incidentBean" scope="session" class="com.vsb.incidentBean" />
<jsp:useBean id="locationSearchBean" scope="session" class="com.vsb.locationSearchBean" />
<script>window.history.go(1);</script>
<html>
  <head>
    <meta http-equiv="Refresh" content="<app:initParameter name='refreshInterval' />" />
    <title><x:out select="$WAHeader//headers/element/web_type_desc"  /></title>
    <style type="text/css">@import url(publicaccess.css);</style>
    <script src="cSuggest.js"></script> 
    <link rel="stylesheet" type="text/css" href="cSuggest.css" /> 
  </head>
  <body class="<c:out value="${requiredPage}"/>"  onresize='redraw()' ondblclick='clearSuggest()'>

<form action="publicaccess.jsp" method="post">
    <h2 class="PageTitle"><x:out select="$WAWorkFlow//services/element[service_code=$service_c]/paths/element[component_page = $requiredPage]/component_title" /></h2>
    <input type="hidden" name="input" value="<c:out value="${requiredPage}"/>" >
    <input type="hidden" name="webtype" value="<%= incidentBean.getWebType() %>" >
    <div class="UserInput">
        <table>
            <tr>
            <td>
                <label class="input-name">Building Number</label>
            </td>
            <td>
                <input class="input-field" id="houseno" name="houseno" type="text" maxlength="10" size="5" value="<%= locationSearchBean.getHouseno() %>"  onfocus='clearSuggest()'/>
            </td>
            </tr>
            <tr>
            <td>
                <label class="input-name">Street Name</label> 
            </td>
            <td>
                <input class="suggest" id="streetname" name="streetname" type="text" maxlength="40" size="20" value="<%= locationSearchBean.getStreetname() %>" 
                    onfocus='clearAndShow(this.value, "streetname")'
                    onkeyup='showHint(this.value, "streetname");' 
                    autocomplete="off" />
                <div class="cSuggest" id="cSuggest"></div>
            </td>
            </tr>
            <tr>
            <td>
                <label class="input-name">Town</label>
            </td>
            <td>
                <input class="input-field" id="townname" name="townname" type="text" maxlength="40" size="20" value="<%= locationSearchBean.getTownname() %>"  onfocus='clearSuggest()'/>
            </td>
            </tr>
            <tr>
            <td>
                <label class="input-name">Post Code</label>
            </td>
            <td>
                <input class="input-field" id="postcode" name="postcode" type="text" maxlength="40" size="20" value="<%= locationSearchBean.getPostcode() %>"  onfocus='clearSuggest()'/>
            </td>
            </tr>
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
