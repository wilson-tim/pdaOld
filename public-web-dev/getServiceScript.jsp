<%@ page import="com.vsb.incidentBean" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jstl/soaptag" prefix="do" %>
<%@ taglib uri="http://java.sun.com/jstl/xml" prefix="x" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<jsp:useBean id="incidentBean" scope="session" class="com.vsb.incidentBean" />

<do:SOAPrequest url="<%=getServletContext().getInitParameter("soap:endpoint") %>" action="get_items" id="xmltext">
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:dat="http://www.datapro.co.uk/">
   <soapenv:Header/>
   <soapenv:Body>
      <dat:get_web_access_services>
         <web_type  ><%= incidentBean.getWebType() %></web_type>
      </dat:get_web_access_services>
   </soapenv:Body>
</soapenv:Envelope>
</do:SOAPrequest>
<% if(((String)pageContext.getAttribute("xmltext")).indexOf("<")==-1){System.out.println("PA:XML:Error |" + (String)pageContext.getAttribute("xmltext") + "|" );%><jsp:forward page="noWebServices.jsp" /><%} %>
<x:parse xml="${xmltext}" var="serviceList" scope="session"/>
<%-- skip auto backup and advance controls if the user had pressed the back button --%>
<if:IfTrue cond='<%= ((String)session.getAttribute("backingup")).equals("false") %>'>
    <c:set var="backingup" scope="session" value="false" />
    <%-- check for only item, if so select it and move on to the next page --%>
    <x:if select="$serviceList//services[count(element)=1]" >
        <c:set var="service_c" scope="session"/><x:out select="$serviceList//services/element[1]/service_code"/></c:set>
        <% incidentBean.setIncident_service((String)session.getAttribute("service_c")); %>
        <c:set var="errorMessage" scope="session" value="" />
        <jsp:forward page="publicaccess.jsp?input=none&action=Next" />
    </x:if>
</if:IfTrue>

<jsp:forward page="getServiceView.jsp" />
