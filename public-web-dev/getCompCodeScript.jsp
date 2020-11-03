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
      <dat:get_item_comp_codes_full>
         <web_type  ><%= incidentBean.getWebType() %></web_type>
         <item_ref><%= incidentBean.getItem_ref() %></item_ref>
         <service_code><%= incidentBean.getIncident_service() %></service_code>
      </dat:get_item_comp_codes_full>
   </soapenv:Body>
</soapenv:Envelope> 
</do:SOAPrequest>
<% if(((String)pageContext.getAttribute("xmltext")).indexOf("<")==-1){System.out.println("PA:XML:Error |" + (String)pageContext.getAttribute("xmltext") + "|" );%><jsp:forward page="noWebServices.jsp" /><%} %>
<x:parse xml="${xmltext}" var="ItemCompCode" scope="session"/>
<%-- skip auto backup and advance controls if the user had pressed the back button --%>
<if:IfTrue cond='<%= ((String)session.getAttribute("backingup")).equals("false") %>'>
    <%-- check for no items, if so back up a page and redisplay --%>
    <x:if select="$ItemCompCode//codes[count(element)=0]" >
        <c:set var="errorMessage" scope="session" value="There are no complaint codes matching this selection" />
        <jsp:forward page="publicaccess.jsp?input=none&action=Back" />
    </x:if>
    <%-- check for only item, if so select it and move on to the next page --%>
    <x:if select="$ItemCompCode//codes[count(element)=1]" >
        <c:set var="fault_code" ><x:out select="$ItemCompCode//codes/element[1]/comp_code"/></c:set>
        <% incidentBean.setFault_code((String)pageContext.getAttribute("fault_code")); %>
        <c:set var="action_type"><x:out select="$ItemCompCode//codes/element[1]/action_flag" /></c:set>
        <% incidentBean.setAction_type((String)pageContext.getAttribute("action_type")); %>
        <c:set var="errorMessage" scope="session" value="" />
        <jsp:forward page="publicaccess.jsp?input=none&action=Next" />
    </x:if>
</if:IfTrue>
<c:set var="backingup" scope="session" value="false" />

<jsp:forward page="getCompCodeView.jsp" />
