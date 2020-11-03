<%@ page import="com.vsb.incidentBean" %>

<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jstl/soaptag" prefix="do" %>
<%@ taglib uri="http://java.sun.com/jstl/xml" prefix="x" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>

<jsp:useBean id="incidentBean" scope="session" class="com.vsb.incidentBean" />

<do:SOAPrequest url="<%=getServletContext().getInitParameter("soap:endpoint") %>" action="get_history" id="xmltext">
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:dat="http://www.datapro.co.uk/">
   <soapenv:Header/>
   <soapenv:Body>
      <dat:get_history>
         <uprn  ><%= incidentBean.getIncidentuprn() %></uprn>
         <service_code  ><%= incidentBean.getIncident_service() %></service_code>
         <item_ref  ></item_ref>
         <comp_code  ></comp_code>
      </dat:get_history>
   </soapenv:Body>
</soapenv:Envelope>
</do:SOAPrequest>
<% if(((String)pageContext.getAttribute("xmltext")).indexOf("<")==-1){System.out.println("PA:XML:Error |" + (String)pageContext.getAttribute("xmltext") + "|" );%><jsp:forward page="noWebServices.jsp" /><%} %>
<x:parse xml="${xmltext}" var="SiteHistory" scope="session"/>
<%-- skip auto backup and advance controls if the user had pressed the back button --%>
<if:IfTrue cond='<%= ((String)session.getAttribute("backingup")).equals("true") %>'>
    <jsp:forward page="publicaccess.jsp?input=none&action=Back" />
</if:IfTrue>
<if:IfTrue cond='<%= ((String)session.getAttribute("backingup")).equals("false") %>'>
    <c:set var="backingup" scope="session" value="false" />
    <%-- check for no items, if so back up a page and redisplay --%>
    <x:if select="$SiteHistory//status_flag='N'" >
        <jsp:forward page="publicaccess.jsp?input=none&action=Next" />
    </x:if>
    <x:if select="$SiteHistory//history[count(element)=0]" >
        <jsp:forward page="publicaccess.jsp?input=none&action=Next" />
    </x:if>
</if:IfTrue>
<do:SOAPrequest url="<%=getServletContext().getInitParameter("soap:endpoint") %>" action="get_item_comp_codes_full" id="xmltext"> 
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:dat="http://www.datapro.co.uk/">
   <soapenv:Header/>
   <soapenv:Body>
      <dat:get_item_comp_codes_full>
          <web_type><%= incidentBean.getWebType() %></web_type>
         <item_ref  ></item_ref>
         <service_code  ><%= incidentBean.getIncident_service() %></service_code>
      </dat:get_item_comp_codes_full>
   </soapenv:Body>
</soapenv:Envelope>
</do:SOAPrequest>
<% if(((String)pageContext.getAttribute("xmltext")).indexOf("<")==-1){System.out.println("PA:XML:Error get_item_comp_codes_full|" + (String)pageContext.getAttribute("xmltext") + "|" );%><jsp:forward page="noWebServices.jsp" /><%} %>
<x:parse xml="${xmltext}" var="ItemCompCode" scope="session"/>
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
<% if(((String)pageContext.getAttribute("xmltext")).indexOf("<")==-1){System.out.println("PA:XML:Error get_items|" + (String)pageContext.getAttribute("xmltext") + "|" );%><jsp:forward page="noWebServices.jsp" /><%} %>
<x:parse xml="${xmltext}" var="SiteItems" scope="session"/>
<jsp:forward page="getHistoryView.jsp" />
