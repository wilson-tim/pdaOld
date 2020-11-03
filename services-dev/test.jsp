<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<img src="http://developer.multimap.com/API/map/1.2/OA09092210083834439?lat=52.21666796901128&lon=0.13466217480302425&zoomFactor=13&width=400&height=400&output=png&locale=en-GB&mapType=map" />

<c:catch var="caughtError">
  <c:import url="http://217.205.172.21/services-dev/mapImageMultimap.jsp" var="webPage" >
    <c:param name="E" value="545929.00" />
    <c:param name="N" value="259753.00" />
    <c:param name="Z" value="13" />
    <c:param name="X" value="400" />
    <c:param name="Y" value="400" />
    <c:param name="M" value="map" />
  </c:import>
</c:catch>

<%--
  String returnedValue = "";
  Exception caughtError = (Exception)pageContext.getAttribute("caughtError");
  if (caughtError == null) {
    // No caught error so use value returned from web service
    returnedValue = ((String)pageContext.getAttribute("webPage")).trim();
  } else {
    // There is a caught error so use that value
    returnedValue = caughtError.toString().trim();
  }
  pageContext.setAttribute("returnedValue", returnedValue);
--%>

<%--
<c:out value="${returnedValue}" escapeXml="false" />
--%>

<c:out value="${webPage}" escapeXml="false" />
