<%@ page import="com.vsb.incidentBean" %>

<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jstl/soaptag" prefix="do" %>
<%@ taglib uri="http://java.sun.com/jstl/xml" prefix="x" %>

<jsp:useBean id="incidentBean" scope="session" class="com.vsb.incidentBean" />

<do:SOAPrequest url="<%=getServletContext().getInitParameter("soap:endpoint") %>" action="get_survey_questions" id="xmltext">
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:dat="http://www.datapro.co.uk/">
   <soapenv:Header/>
   <soapenv:Body>
      <dat:get_survey_questions>
         <web_type><%=incidentBean.getWebType() %></web_type>
         <service_code><%=incidentBean.getIncident_service() %></service_code>
      </dat:get_survey_questions>
   </soapenv:Body>
</soapenv:Envelope> 
</do:SOAPrequest>
<x:parse xml="${xmltext}" var="survey_questions" scope="session"/>
<do:SOAPrequest url="<%=getServletContext().getInitParameter("soap:endpoint") %>" action="get_survey_answers" id="xmltext">
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:dat="http://www.datapro.co.uk/">
   <soapenv:Header/>
   <soapenv:Body>
      <dat:get_survey_answers>
         <question_ref></question_ref>
         <web_type><%=incidentBean.getWebType() %></web_type>
         <service_code><%=incidentBean.getIncident_service() %></service_code>
      </dat:get_survey_answers>
   </soapenv:Body>
</soapenv:Envelope>
</do:SOAPrequest>
<x:parse xml="${xmltext}" var="survey_answers" scope="session"/>

<x:if select="$survey_questions//questions[count(element)=0]" >
    <if:IfTrue cond='<%= ((String)session.getAttribute("backingup")).equals("false") %>'>
        <jsp:forward page="publicaccess.jsp?input=none&action=Next" />
    </if:IfTrue>
    <if:IfTrue cond='<%= ((String)session.getAttribute("backingup")).equals("true") %>'>
        <jsp:forward page="publicaccess.jsp?input=none&action=Back" />
    </if:IfTrue>
</x:if>
<jsp:forward page="takeSurveyView.jsp" />
