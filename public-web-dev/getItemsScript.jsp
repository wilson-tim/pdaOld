<%@ page import="com.vsb.incidentBean" %>

<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jstl/soaptag" prefix="do" %>
<%@ taglib uri="http://java.sun.com/jstl/xml" prefix="x" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>

<jsp:useBean id="incidentBean" scope="session" class="com.vsb.incidentBean" />

<do:SOAPrequest url="<%=getServletContext().getInitParameter("soap:endpoint") %>" action="get_site_items_all" id="xmltext">
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:dat="http://www.datapro.co.uk/">
   <soapenv:Header/>
   <soapenv:Body>
      <dat:get_items>
         <item_ref  ></item_ref>
         <service_c  ><%= incidentBean.getIncident_service() %></service_c>
      </dat:get_items>
   </soapenv:Body>
</soapenv:Envelope> 
</do:SOAPrequest>
<% if(((String)pageContext.getAttribute("xmltext")).indexOf("<")==-1){System.out.println("PA:XML:Error |" + (String)pageContext.getAttribute("xmltext") + "|" );%><jsp:forward page="noWebServices.jsp" /><%} %>
<x:parse xml="${xmltext}" var="SiteItems" scope="session"/>
<%-- skip auto backup and advance controls if the user had pressed the back button --%>
<if:IfTrue cond='<%= ((String)session.getAttribute("backingup")).equals("false") %>'>
    <c:set var="backingup" scope="session" value="false" />
    <%-- check for no items, if so back up a page and redisplay --%>
    <x:if select="$SiteItems//items[count(element)=0]" >
        <c:set var="errorMessage" scope="session" value="There are no item codes matching this selection" />
        <jsp:forward page="publicaccess.jsp?input=none&action=Back" />
    </x:if>
    <%-- check for only item, if so select it and move on to the next page --%>
    <x:if select="$SiteItems//items[count(element)=1]" >
        <c:set var="item_ref"><x:out select="$SiteItems//items/element[1]/item_ref"/></c:set>
        <% incidentBean.setItem_ref((String)pageContext.getAttribute("item_ref")); %>
        <jsp:forward page="publicaccess.jsp?input=none&action=Next" />
    </x:if>
</if:IfTrue>

<jsp:forward page="getItemsView.jsp" />
