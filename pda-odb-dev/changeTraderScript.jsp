<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.changeTraderBean, com.vsb.recordBean" %>
<%@ page import="com.db.PagingBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req"  %>
<%@ taglib uri="http://java.sun.com/jstl/core"                 prefix="c"    %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags"   prefix="if"   %>
<%@ taglib uri="http://java.sun.com/jstl/soaptag"              prefix="do"   %>
<%@ taglib uri="http://java.sun.com/jstl/xml"                  prefix="x"    %>

<jsp:useBean id="changeTraderBean" scope="session" class="com.vsb.changeTraderBean" />
<jsp:useBean id="recordBean"       scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="changeTraderPagingBean" scope="session" class="com.db.PagingBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at beginning --%>
<sess:equalsAttribute name="form" match="changeTrader" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="changeTrader" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="changeTraderBean" property="all" value="clear" />
    <jsp:setProperty name="changeTraderBean" property="*" />

    <%-- Add the new values to the record --%>

  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="changeTraderBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="pitchDetails" >
  <jsp:setProperty name="changeTraderBean" property="action" value="" />
  <jsp:setProperty name="changeTraderBean" property="all" value="clear" />
  <jsp:setProperty name="changeTraderBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- Set the page number to 1 the first time we are viewing the form --%>
<sess:equalsAttribute name="input" match="changeTrader" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals("pitchDetails") %>' >
    <jsp:setProperty name="changeTraderBean" property="page_number" value="1" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>

<%-- Assign tradersList variable for use in the VIEW, but only the first time through the SCRIPT --%>
<sess:equalsAttribute name="input" match="changeTrader" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <% int recordsOnPage = new Integer(application.getInitParameter("records_on_change_trader_list")).intValue(); %>
    <% changeTraderPagingBean.setRecordsOnPage(recordsOnPage); %>
    <do:SOAPrequest url="<%= getServletContext().getInitParameter("soap:endpoint") %>" action="get_traders" id="xmltext">
      <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:dat="http://www.datapro.co.uk/">
        <soapenv:Header/>
        <soapenv:Body>
          <dat:get_traders>
            <pitch_no><%= recordBean.getPitch_no() %></pitch_no>
            <trader_ref></trader_ref>
            <trader_name></trader_name>
            <trader_ta></trader_ta>
            <contact_init></contact_init>
            <contact_name></contact_name>
            <contact_surname></contact_surname>
            <compliant_yn></compliant_yn>
          </dat:get_traders>
        </soapenv:Body>
      </soapenv:Envelope>
    </do:SOAPrequest>
    <%-- Did the SOAP request succeed? --%>
    <if:IfTrue cond='<%= (((String)pageContext.getAttribute("xmltext")).indexOf("<")==-1) %>' >
      <%-- Next commented out command is for testing --%>
      <%-- System.out.println("PA:XML:Error |" + (String)pageContext.getAttribute("xmltext") + "|"); --%>
      <jsp:setProperty name="changeTraderBean" property="error"
        value="The PDA web services are currently unavailable, please try again later." />
      <jsp:forward page="changeTraderView.jsp" />
    </if:IfTrue>
    <%-- tradersList --%>
    <x:parse xml="${xmltext}" var="tradersList" scope="session" />
    <%-- recordCount --%>
    <% int recordCount = 0; %>
    <x:forEach var="n" select="$tradersList//traders/element" >
      <% recordCount++; %>
    </x:forEach>
    <% changeTraderPagingBean.setRecordCount(recordCount); %>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Set the current page number the user is on --%>
<% changeTraderPagingBean.setCurrentPageNum( new Integer(changeTraderBean.getPage_number()).intValue() ); %>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="changeTrader" >
  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= changeTraderBean.getAction().equals("Continue") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%=changeTraderBean.getTrader_ref() == null || changeTraderBean.getTrader_ref().equals("") %>' >
      <jsp:setProperty name="changeTraderBean" property="error"
        value="Please select a trader." />
      <jsp:forward page="changeTraderView.jsp" />
    </if:IfTrue>

    <%-- confirm_trader() web service function call --%>
    <do:SOAPrequest url="<%= getServletContext().getInitParameter("soap:endpoint") %>" action="confirm_trader" id="xmltext">
      <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:dat="http://www.datapro.co.uk/">
        <soapenv:Header/>
        <soapenv:Body>
          <dat:confirm_trader>
            <pitch_no><%= recordBean.getPitch_no() %></pitch_no>
            <trader_ref><%= changeTraderBean.getTrader_ref() %></trader_ref>
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
      <jsp:setProperty name="changeTraderBean" property="error"
        value="The PDA web services are currently unavailable, please try again later." />
      <jsp:forward page="changeTraderView.jsp" />
    </if:IfTrue>

    <%-- Confirmed? --%>
    <x:parse xml="${xmltext}" var="confirmTrader" scope="session" />
    <%-- Next commented out commands are for testing --%>
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
      <jsp:setProperty name="changeTraderBean" property="error"
        value="<%= status_flag + " " + status_text %>" />
      <jsp:forward page="changeTraderView.jsp" />
    </x:if>
    </if:IfTrue>

    <%-- Valid entry --%>

    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="trader_ref" param="trader_ref" />

    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">changeTrader</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">marketDetails</sess:setAttribute>
    <c:redirect url="marketDetailsScript.jsp" />
  </if:IfTrue>
  
  <%-- Next view 2 --%>
  <if:IfTrue cond='<%= changeTraderBean.getAction().equals("|<<") %>' >
    <% changeTraderPagingBean.first(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="changeTraderView.jsp" />
  </if:IfTrue>

  <%-- Next view 3 --%>
  <if:IfTrue cond='<%= changeTraderBean.getAction().equals(">>|") %>' >
    <% changeTraderPagingBean.last(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="changeTraderView.jsp" />
  </if:IfTrue>

  <%-- Next view 4 --%>
  <if:IfTrue cond='<%= changeTraderBean.getAction().equals(" < ") %>' >
    <% changeTraderPagingBean.previous(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="changeTraderView.jsp" />
  </if:IfTrue>

  <%-- Next view 5 --%>
  <if:IfTrue cond='<%= changeTraderBean.getAction().equals(" > ") %>' >
    <% changeTraderPagingBean.next(); %>
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <jsp:forward page="changeTraderView.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= changeTraderBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">changeTrader</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= changeTraderBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">changeTrader</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= changeTraderBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">changeTrader</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= changeTraderBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${changeTraderBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="changeTraderView.jsp" />
