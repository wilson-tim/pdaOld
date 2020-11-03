<%@ page import="com.vsb.locationSearchBean" %>
<%@ page import="com.vsb.incidentBean" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jstl/soaptag" prefix="do" %>
<%@ taglib uri="http://java.sun.com/jstl/xml" prefix="x" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if"   %>

<jsp:useBean id="locationSearchBean" scope="session" class="com.vsb.locationSearchBean" />
<jsp:useBean id="incidentBean" scope="session" class="com.vsb.incidentBean" />

<do:SOAPrequest url="<%=getServletContext().getInitParameter("soap:endpoint") %>" action="get_address" id="xmltext">
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:dat="http://www.datapro.co.uk/">
   <soapenv:Header/>
   <soapenv:Body>
      <dat:get_address>
         <build_no><%= locationSearchBean.getHouseno() %></build_no>
         <build_name></build_name>
         <street_name><%= locationSearchBean.getStreetname() %></street_name>
         <postcode><%= locationSearchBean.getPostcode() %></postcode>
         <townname><%= locationSearchBean.getTownname() %></townname>
         <address_string>?</address_string>
      </dat:get_address>
   </soapenv:Body>
</soapenv:Envelope> 
</do:SOAPrequest>
<% if(((String)pageContext.getAttribute("xmltext")).indexOf("<")==-1){System.out.println("PA:XML:Error |" + (String)pageContext.getAttribute("xmltext") + "|" );%><jsp:forward page="noWebServices.jsp" /><%} %>
<x:parse xml="${xmltext}" var="addressList" scope="session"/>
<%-- skip auto backup and advance controls if the user had pressed the back button --%>
<if:IfTrue cond='<%= ((String)session.getAttribute("backingup")).equals("false") %>'>
    <c:set var="backingup" scope="session" value="false" />
    <%-- check for no items, if so back up a page and redisplay --%>
    <x:if select="$addressList//addresses[count(element)=0]" >
        <c:set var="errorMessage" scope="session" value="There are no addresses matching this selection" />
        <jsp:forward page="publicaccess.jsp?input=none&action=Back" />
    </x:if>
    <%-- check for only item, if so select it and move on to the next page --%>
    <x:if select="$addressList//addresses[count(element)=1]" >
        <c:set var="uprnCode" ><x:out select="$addressList//addresses/element[1]/uprn"/>|<x:out select="$addressList//addresses/element[1]/usrn"/>|<x:out select="$addressList//addresses/element[1]/postcode"/>|<x:out select="$addressList//addresses/element[1]/site_name_1"/></c:set>
        <% incidentBean.setUprnCode((String)pageContext.getAttribute("uprnCode")); %>
        <c:set var="errorMessage" scope="session" value="" />
        <jsp:forward page="publicaccess.jsp?input=none&action=Next" />
    </x:if>
</if:IfTrue>

<jsp:forward page="getAddressView.jsp" />
