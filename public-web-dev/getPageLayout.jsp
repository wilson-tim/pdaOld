<%@ page import="com.vsb.incidentBean" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jstl/soaptag" prefix="do" %>
<%@ taglib uri="http://java.sun.com/jstl/xml" prefix="x" %>
<%@ taglib uri="http://java.sun.com/jstl/domtag"  prefix="dom" %>
<jsp:useBean id="incidentBean" scope="session" class="com.vsb.incidentBean" />

<%-- dunny soap response, these will filled via soap requests latter --%>
<do:SOAPrequest url="<%=getServletContext().getInitParameter("soap:endpoint") %>" action="get_web_access_header" id="xmltext"> 
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:dat="http://www.datapro.co.uk/">
   <soapenv:Header/>
   <soapenv:Body>
      <dat:get_web_access_header>
         <web_type  ><%= incidentBean.getWebType() %></web_type>
      </dat:get_web_access_header>
   </soapenv:Body>
</soapenv:Envelope>
</do:SOAPrequest>
<% if(((String)pageContext.getAttribute("xmltext")).indexOf("<")==-1){System.out.println("PA:XML:Error |" + (String)pageContext.getAttribute("xmltext") + "|" );%><jsp:forward page="noWebServices.jsp" /><%} %>
<x:parse xml="${xmltext}" var="WAHeader" scope="session"/>
<c:set var="TempPath" scope="session"><x:out select="$WAHeader//headers/element/download_path" /></c:set>
<c:set var="maxattachmentsize" scope="session"><x:out select="$WAHeader//headers/element/max_file_size" /></c:set>
<c:set var="allowedfiletypes" scope="session"><x:out select="$WAHeader//headers/element/allowed_file_types" /></c:set>

<do:SOAPrequest url="<%=getServletContext().getInitParameter("soap:endpoint") %>" action="get_web_access_links" id="xmltext">
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:dat="http://www.datapro.co.uk/">
   <soapenv:Header/>
   <soapenv:Body>
      <dat:get_web_access_links>
         <web_type  ><%= incidentBean.getWebType() %></web_type>
      </dat:get_web_access_links>
   </soapenv:Body>
</soapenv:Envelope> 
</do:SOAPrequest>
<% if(((String)pageContext.getAttribute("xmltext")).indexOf("<")==-1){System.out.println("PA:XML:Error |" + (String)pageContext.getAttribute("xmltext") + "|" );%><jsp:forward page="noWebServices.jsp" /><%} %>
<x:parse xml="${xmltext}" var="PALinks" scope="session"/>

<do:SOAPrequest url="<%=getServletContext().getInitParameter("soap:endpoint") %>" action="get_web_access_path" id="xmltext">
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:dat="http://www.datapro.co.uk/">
   <soapenv:Header/>
   <soapenv:Body>
      <dat:get_web_access_path>
         <web_type  ><%= incidentBean.getWebType() %></web_type>
         <service_code  ></service_code>
      </dat:get_web_access_path>
   </soapenv:Body>
</soapenv:Envelope>
</do:SOAPrequest>
<% if(((String)pageContext.getAttribute("xmltext")).indexOf("<")==-1){System.out.println("PA:XML:Error |" + (String)pageContext.getAttribute("xmltext") + "|" );%><jsp:forward page="noWebServices.jsp" /><%} %>
<x:parse xml="${xmltext}" var="WAWorkFlow" scope="session"/>
