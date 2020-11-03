<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.pitchDetailsBean, com.vsb.recordBean" %>
<%@ page import="java.util.*" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req"  %>
<%@ taglib uri="http://java.sun.com/jstl/core"                 prefix="c"    %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags"   prefix="if"   %>
<%@ taglib uri="http://java.sun.com/jstl/soaptag"              prefix="do"   %>
<%@ taglib uri="http://java.sun.com/jstl/xml"                  prefix="x"    %>

<jsp:useBean id="pitchDetailsBean" scope="session" class="com.vsb.pitchDetailsBean" />
<jsp:useBean id="recordBean"       scope="session" class="com.vsb.recordBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="pitchDetails" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="pitchDetails" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="pitchDetailsBean" property="all" value="clear" />
    <jsp:setProperty name="pitchDetailsBean" property="*" />

    <%-- Add the new values to the record --%>

  </if:IfParameterEquals>
</req:existsParameter>
    
<%-- clear errors --%>
<jsp:setProperty name="pitchDetailsBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="marketDetails" >
  <jsp:setProperty name="pitchDetailsBean" property="action" value="" />
  <jsp:setProperty name="pitchDetailsBean" property="all" value="clear" />
  <jsp:setProperty name="pitchDetailsBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <jsp:setProperty name="recordBean" property="trader_ref" value="" />
</sess:equalsAttribute>

<%-- Assign pitchRecord variable for use in the VIEW, but only the first time through the SCRIPT --%>
<%-- or if returning from changeTrader having selected a new trader --%>
<% String callSoap = "N"; %>
<sess:equalsAttribute name="input" match="pitchDetails" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <% callSoap = "Y"; %>
  </if:IfTrue>
</sess:equalsAttribute>
<if:IfTrue cond='<%= recordBean.getTrader_ref() != null && !recordBean.getTrader_ref().equals("") %>' >
  <% callSoap = "Y"; %>
</if:IfTrue>

<if:IfTrue cond='<%= (callSoap == "Y") %>' >
  <do:SOAPrequest url="<%= getServletContext().getInitParameter("soap:endpoint") %>" action="get_pitches" id="xmltext">
    <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:dat="http://www.datapro.co.uk/">
      <soapenv:Header/>
      <soapenv:Body>
        <dat:get_pitches>
          <market_ref><%= recordBean.getMarket_ref() %></market_ref>
          <pitch_no><%= recordBean.getPitch_no() %></pitch_no>
          <sort_order></sort_order>
        </dat:get_pitches>
      </soapenv:Body>
    </soapenv:Envelope>
  </do:SOAPrequest>
  <%-- Did the SOAP request succeed? --%>
  <if:IfTrue cond='<%= (((String)pageContext.getAttribute("xmltext")).indexOf("<")==-1) %>' >
    <%-- Next commented out command is for testing --%>
    <%-- System.out.println("PA:XML:Error |" + (String)pageContext.getAttribute("xmltext") + "|"); --%>
    <jsp:setProperty name="pitchDetailsBean" property="error"
      value="The PDA web services are currently unavailable, please try again later." />
    <jsp:forward page="pitchDetailsView.jsp" />
  </if:IfTrue>
  <%-- pitchRecords --%>
  <x:parse xml="${xmltext}" var="pitchRecords" scope="session" />
</if:IfTrue>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="pitchDetails" >
  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= pitchDetailsBean.getAction().equals("Survey") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

      <%-- Temporary code until Survey coding is in place --%>
      <jsp:forward page="pitchDetailsView.jsp" />

    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">pitchDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">pitchDetails</sess:setAttribute>
    <c:redirect url="pitchDetailsScript.jsp" />
  </if:IfTrue>

  <%-- Next view 2 --%>
  <if:IfTrue cond='<%= pitchDetailsBean.getAction().equals("Change") %>' >
    <c:set var="pitch_no"><x:out select="$pitchRecords//element[position()=1]/pitch_no" /></c:set>
    <c:set var="trader_ref"><x:out select="$pitchRecords//element[position()=1]/trader_ref" /></c:set>
    <c:set var="agreement_no"><x:out select="$pitchRecords//element[position()=1]/agreement_no" /></c:set>
    <%
      String pitch_no = (String)pageContext.getAttribute("pitch_no");
      String trader_ref = (String)pageContext.getAttribute("trader_ref");
      String agreement_no = (String)pageContext.getAttribute("agreement_no");
      // Store useful data in bean for changeTrader form
      recordBean.setTrader_ref(trader_ref);
    %>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">pitchDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">changeTrader</sess:setAttribute>
    <c:redirect url="changeTraderScript.jsp" />
  </if:IfTrue>

  <%-- Next view 3 --%>
  <if:IfTrue cond='<%= pitchDetailsBean.getAction().equals("Confirm") %>' >
    <c:set var="pitch_no"><x:out select="$pitchRecords//element[position()=1]/pitch_no" /></c:set>
    <c:set var="trader_ref"><x:out select="$pitchRecords//element[position()=1]/trader_ref" /></c:set>
    <c:set var="agreement_no"><x:out select="$pitchRecords//element[position()=1]/agreement_no" /></c:set>
    <%
      String pitch_no = (String)pageContext.getAttribute("pitch_no");
      String trader_ref = (String)pageContext.getAttribute("trader_ref");
      String agreement_no = (String)pageContext.getAttribute("agreement_no");
    %>
    <do:SOAPrequest url="<%= getServletContext().getInitParameter("soap:endpoint") %>" action="confirm_trader" id="xmltext">
      <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:dat="http://www.datapro.co.uk/">
        <soapenv:Header/>
        <soapenv:Body>
          <dat:confirm_trader>
            <pitch_no><%= pitch_no %></pitch_no>
            <trader_ref><%= trader_ref %></trader_ref>
            <agreement_no></agreement_no>
          </dat:confirm_trader>
        </soapenv:Body>
      </soapenv:Envelope>
    </do:SOAPrequest>

    <%-- Did the SOAP request succeed? --%>

    <%-- Invalid entry --%>

    <%-- Web services error? --%>
    <if:IfTrue cond='<%= (((String)pageContext.getAttribute("xmltext")).indexOf("<")==-1) %>' >
      <%-- Next commented out command is for testing --%>
      <%-- System.out.println("PA:XML:Error |" + (String)pageContext.getAttribute("xmltext") + "|"); --%>
      <jsp:setProperty name="pitchDetailsBean" property="error"
        value="The PDA web services are currently unavailable, please try again later." />
      <jsp:forward page="pitchDetailsView.jsp" />
    </if:IfTrue>
    
    <%-- Confirmed? --%>
    <x:parse xml="${xmltext}" var="confirmTrader" scope="session" />
    <%-- Next commented out commands are for testing--%>
    <%--
    <c:set var="confirmed_yn" ><x:out select="$confirmTrader//confirmed_yn" /></c:set>
    <% String confirmed_yn = (String)pageContext.getAttribute("confirmed_yn"); %>
    <% System.out.println("|" + confirmed_yn + "|"); %>
    --%>
    
    <x:if select="$confirmTrader//.[confirmed_yn!='Y']" >
      <c:set var="status_flag" ><x:out select="$confirmTrader//status_flag" /></c:set>
      <% String status_flag = (String)pageContext.getAttribute("status_flag"); %>
      <c:set var="status_text" ><x:out select="$confirmTrader//status_text" /></c:set>
      <% String status_text = (String)pageContext.getAttribute("status_text"); %>
      <jsp:setProperty name="pitchDetailsBean" property="error"
        value="<%= status_flag + " " + status_text %>" />
      <jsp:forward page="pitchDetailsView.jsp" />
    </x:if>

    <%-- Valid entry --%>

    <%-- Reload the form to pick up the updated confirmation status --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">pitchDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">pitchDetails</sess:setAttribute>
    <c:redirect url="pitchDetailsScript.jsp" />
  </if:IfTrue>
  
  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= pitchDetailsBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">pitchDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= pitchDetailsBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">pitchDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= pitchDetailsBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">pitchDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= pitchDetailsBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${pitchDetailsBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="pitchDetailsView.jsp" />
