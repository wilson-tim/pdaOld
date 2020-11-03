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
            <td><label class="input-name">Registration Number</label></td>
            <td><input class="input-field" name="vehicle_registration" type="text" maxlength="100" size="10" value="<%= incidentBean.getVehicle_registration() %>"/></td>
            </tr>
            <tr>
            <td><label class="input-name">Vin Number</label></td>
            <td><input class="input-field" name="vin" type="text" maxlength="17" size="17" value="<%= incidentBean.getVin() %>"/></td>
            </tr>
            <tr>
            <td><label class="input-name">Vehicle Condition</label></td>
            <td><input class="input-field" name="vehicle_condition" type="text" maxlength="100" size="20" value="<%= incidentBean.getVehicle_condition() %>"/></td>
            </tr>
            <tr>
            <td><label class="input-name">Vehicle Colour</label></td>
            <td>
                <c:set var="vc"><%= incidentBean.getVehicle_colour() %></c:set>
                <select class="input-field" name="vehicle_colour">
                <x:forEach var="n" select="$AVcolour//colours/element">
                    <option value="<x:out select="$n/colour_desc"/>"
                    <x:if select="$n/.[colour_desc = $vc]">
                        selected
                    </x:if>
                    ><x:out select="$n/colour_desc"/></option>
                </x:forEach> 
                </select>
            </td>
            </tr>
            <tr>
            <td><label class="input-name">Tax Disc Shown</label></td>
            <td>
                <select class="input-field" name="road_fund_flag">
                    <option value=" ">Unknown</option>
                    <option value="Y" <% if(incidentBean.getRoad_fund_flag().equals("Y")){%>selected<%} %>>Yes</option>
                    <option value="N" <% if(incidentBean.getRoad_fund_flag().equals("N")){%>selected<%} %>>No</option>
                </select>
            </td>
            </tr>
            <tr>
            <td>
                <label class="input-name">Tax Disc Valid</label>
            </td>
            <td>
                <select class="input-field" name="road_fund_valid">
                    <option value=" ">Unknown</option>
                    <option value="Y" <% if(incidentBean.getRoad_fund_valid().equals("Y")){%>selected<%} %>>Yes</option>
                    <option value="N" <% if(incidentBean.getRoad_fund_valid().equals("N")){%>selected<%} %>>No</option>
                </select>
            </td>
            </tr>
            <tr>
            <td><label class="input-name">How long there</label></td>
            <td><input class="input-field" name="how_long_there" type="text" maxlength="10" size="10" value="<%= incidentBean.getHow_long_there() %>"/></td>
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
