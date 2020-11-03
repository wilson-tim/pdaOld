<%@ page import="com.vsb.incidentBean" %>
<%@ taglib uri="http://java.sun.com/jstl/xml" prefix="x" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<jsp:useBean id="incidentBean" scope="session" class="com.vsb.incidentBean" />

<script>window.history.go(1);</script>
<x:if select="$WAHeader//.[map_type = 'yahoo']">
<script type="text/javascript" src="http://api.maps.yahoo.com/ajaxymap?v=3.8&appid=YD-eQRpTl0_JX2E95l_xAFs5UwZUlNQhhn7lj1H"></script>
<script type="text/javascript" src="yahoomap.js"></script>
</x:if>
<SCRIPT LANGUAGE="javascript">
<!--
function OnChange()
{
    var dropdown = document.getElementById( "uprnCode" )
    var myindex  = dropdown.selectedIndex;
    var SelValue = dropdown.options[myindex].text;
<x:if select="$WAHeader//.[map_type = 'ghybrid']">
    document.getElementById( "gmap" ).src="http://maps.google.com/maps/api/staticmap?center=" + escape(SelValue) + "&zoom=20&size=512x256&maptype=hybrid&sensor=false";
</x:if>
<x:if select="$WAHeader//.[map_type = 'google']">
    document.getElementById( "gmap" ).src="http://maps.google.com/maps/api/staticmap?center=" + escape(SelValue) + "&zoom=18&size=512x256&maptype=road&sensor=false";
</x:if>
<x:if select="$WAHeader//.[map_type = 'yahoo']">
    drawYMap(SelValue,"");
</x:if>
    return true;
}
//-->
</SCRIPT>

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
        <label class="input-name" style="vertical-align: top;">Select an address</label> <select name="uprnCode" id="uprnCode" onChange='OnChange();' onClick='OnChange();' size="4">
        <c:set var="uprn"><%= incidentBean.getIncidentuprn() %></c:set>
        <x:forEach var="n" select="$addressList//addresses/element">
                <option
                value="<x:out select="$n/uprn"/>|<x:out select="$n/usrn"/>|<x:out select="$n/postcode"/>|<x:out select="$n/site_name_1"/>"
                <x:if select="$n/.[uprn = $uprn]">
                    selected
                </x:if>
                easting="<x:out select="$n/easting" />"
                northing="<x:out select="$n/northing" />"
                buildsubno="<x:out select="$n/build_sub_no" />"
                ><x:out select="$n/build_sub_name" /> <x:out select="$n/build_name" /> <x:out select="$n/build_no" /><x:out select="$n/build_sub_no" /> <x:out select="$n/street_name" />, <x:out select="$n/townname" />, <x:out select="$n/postcode" /></option>
        </x:forEach>
        </select><br /><br />
        <x:if select="$WAHeader//.[map_type = 'ghybrid']">
                <img src="nomap.jpg" id="gmap" name="gmap" /><br />
        </x:if>
        <x:if select="$WAHeader//.[map_type = 'google']">
                <img src="nomap.jpg" id="gmap" name="gmap" /><br />
        </x:if>
        <x:if select="$WAHeader//.[map_type = 'yahoo']">
                <div id="map"></div>
        </x:if>
    </div>
    <div class="Controls">
        <div class="Back"><input class="control" type="submit" name="action" value="Back" /></div>
        <div class="Next"><input class="control" type="submit" name="action" value="Next" /></div>
    </div>
</form>
<div class="HelpText"><x:out select="$WAWorkFlow//services/element[service_code=$service_c]/paths/element[component_page = $requiredPage]/component_help" /></div>
<div class="error"><c:out value="${errorMessage}" /></div>
    <jsp:include page="include/footer.jsp" flush="true" />
<script>
document.getElementById( "uprnCode" ).selectedIndex=1;
OnChange();
</script>
  </body>
</html>
