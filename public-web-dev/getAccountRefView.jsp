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
    <h2 class="PageTitle"><x:out select="$WAWorkFlow//services/element[service_code=$service_c]/paths/element[component_page = $requiredPage]/component_title" /></h2>
    <input type="hidden" name="input" value="<c:out value="${requiredPage}"/>" >
    <input type="hidden" name="webtype" value="<%= incidentBean.getWebType() %>" >
    <div class="UserInput">
        <table>
            <tr>
            <td>
                <label class="input-name">Account Code</label>
            </td>
            <td>
                <input class="input-field" name="account_ref" type="text" maxlength="70" size="20" value="<%= incidentBean.getAccount_ref() %>"/>
            </td>
            </tr>
            <tr>
            <td>
                <label class="input-name">Password</label>
            </td>
            <td>
                <input class="input-field" name="account_password" type="password" maxlength="70" size="20" value=""/>
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