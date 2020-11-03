<%@ page import="com.vsb.incidentBean" %>

<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jstl/soaptag" prefix="do" %>
<%@ taglib uri="http://java.sun.com/jstl/xml" prefix="x" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>

<jsp:useBean id="incidentBean" scope="session" class="com.vsb.incidentBean" />

<do:SOAPrequest url="<%=getServletContext().getInitParameter("soap:endpoint") %>" action="get_item_comp_codes_full" id="xmltext">
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:dat="http://www.datapro.co.uk/">
   <soapenv:Header/>
   <soapenv:Body>
      <dat:get_av_makes>
         <vehicle_make></vehicle_make>
      </dat:get_av_makes>
   </soapenv:Body>
</soapenv:Envelope> 
</do:SOAPrequest>
<% if(((String)pageContext.getAttribute("xmltext")).indexOf("<")==-1){System.out.println("PA:XML:Error |" + (String)pageContext.getAttribute("xmltext") + "|" );%><jsp:forward page="noWebServices.jsp" /><%} %>
<x:parse xml="${xmltext}" var="AVMakes" scope="session"/>
<%-- skip auto backup and advance controls if the user had pressed the back button --%>
<if:IfTrue cond='<%= ((String)session.getAttribute("backingup")).equals("false") %>'>
    <%-- check for no items, if so back up a page and redisplay --%>
    <x:if select="$AVMakes//vehicles[count(element)=0]" >
        <c:set var="errorMessage" scope="session" value="There are no vechicle makes in the system" />
        <jsp:forward page="publicaccess.jsp?input=none&action=Back" />
    </x:if>
    <%-- check for only item, if so select it and move on to the next page --%>
    <x:if select="$AVMakes//vehicles[count(element)=1]" >
        <c:set var="vehicle_make" ><x:out select="$AVMakes//vehicles/element[1]/vehicle_make"/></c:set>
        <% incidentBean.setVehicle_make((String)pageContext.getAttribute("vehicle_make")); %>
        <c:set var="errorMessage" scope="session" value="" />
        <jsp:forward page="publicaccess.jsp?input=none&action=Next" />
    </x:if>
</if:IfTrue>
<c:set var="backingup" scope="session" value="false" />
<jsp:forward page="getAvMakeView.jsp" />
