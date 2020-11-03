<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.changeFaultLookupBean, com.vsb.helperBean, com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="changeFaultLookupBean" scope="session" class="com.vsb.changeFaultLookupBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="changeFaultLookup" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="changeFaultLookup" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="changeFaultLookupBean" property="all" value="clear" />
    <jsp:setProperty name="changeFaultLookupBean" property="*" />

    <% recordBean.setChanged_comp_code(changeFaultLookupBean.getLookup_code()); %>
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="changeFaultLookupBean" property="error" value="" />

<%-- Initialise the forward_direction variable, used in the skip section --%>
<% String forward_direction = "N"; %>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="changeItemLookup" >
  <jsp:setProperty name="changeFaultLookupBean" property="action" value="" />
  <jsp:setProperty name="changeFaultLookupBean" property="all" value="clear" />
  <jsp:setProperty name="changeFaultLookupBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <% forward_direction = "Y"; %>
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="changeFaultLookup" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <%-- Code to run --%>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Skip View Section --%>
<%-- Don't skip if coming from the view --%>
<sess:equalsAttribute name="input" match="changeFaultLookup" value="false">
  <%-- Only skip if allowed. --%>
  <if:IfTrue cond='#SOME-SKIP-CHECK#' >
    <%-- skip to the next page, by faking it so that it appears the user --%>
    <%-- has just processd the page and clicked an action page button. --%>
    <%-- Do backwards skip first, as forward skip sets the 'input' session variable --%>
    <if:IfTrue cond='<%= forward_direction.equals("N") %>' >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">changeFaultLookup</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form"><%= changeFaultLookupBean.getSavedPreviousForm() %></sess:setAttribute>
      <c:redirect url="${changeFaultLookupBean.savedPreviousForm}Script.jsp" />
    </if:IfTrue>
    <%-- Do forwards skip --%>
    <if:IfTrue cond='<%= forward_direction.equals("Y") %>' >
      <%-- This section mimics the 'input' section at the top of the script --%>
      <%-- manually imitating a user interaction with the view, but without showing the view --%>
  
      <%-- Indicate which form we are in/just-come-from --%>
      <sess:setAttribute name="input">changeFaultLookup</sess:setAttribute>
  
      <%-- Setup the bean with the forms data manually --%>
      <jsp:setProperty name="changeFaultLookupBean" property="all" value="clear" />
      <jsp:setProperty name="changeFaultLookupBean" property="action" value="#SOME-ACTION-BUTTON#" />
  
    </if:IfTrue>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="changeFaultLookup" >
  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= changeFaultLookupBean.getAction().equals("Finish") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= changeFaultLookupBean.getLookup_code() == null || changeFaultLookupBean.getLookup_code().equals("") %>' >
      <jsp:setProperty name="changeFaultLookupBean" property="error"
        value="Please choose a fault." />
      <jsp:forward page="changeFaultLookupView.jsp" />
    </if:IfTrue>
    
    <%-- Valid entry --%>
    <%-- Change item and fault. This will also add text into the compSampDetailsBean 'Text' field. --%>
    <sess:setAttribute name="form">changeItemFaultDateFunc</sess:setAttribute>
    <c:import url="changeItemFaultDateFunc.jsp" var="webPage" />
    <% helperBean.throwException("changeItemFaultDateFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- We will be updateing the complaint text, with what we are changing so indicate to the --%>
    <%-- addTextFunc that we are updateing the text only. --%>
    <% recordBean.setUpdate_text("Y"); %>

    <%-- add complaint text --%>
    <sess:setAttribute name="form">addTextFunc</sess:setAttribute>
    <c:import url="addTextFunc.jsp" var="webPage" />
    <% helperBean.throwException("addTextFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- run the veolia link if required --%>
    <sess:setAttribute name="form">veoliaLinkFunc</sess:setAttribute>
    <c:import url="veoliaLinkFunc.jsp" var="webPage" />
    <% helperBean.throwException("veoliaLinkFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">changeFaultLookup</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">updateStatus</sess:setAttribute>
    <c:redirect url="updateStatusScript.jsp" />
  </if:IfTrue>

  <%-- Next view 2 --%>
  <%-- 11/05/2010  TW  New conditional code --%>
  <if:IfTrue cond='<%= changeFaultLookupBean.getAction().equals("Inspection Date") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= changeFaultLookupBean.getLookup_code() == null || changeFaultLookupBean.getLookup_code().equals("") %>' >
      <jsp:setProperty name="changeFaultLookupBean" property="error"
        value="Please choose a fault." />
      <jsp:forward page="changeFaultLookupView.jsp" />
    </if:IfTrue>
    
    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">changeFaultLookup</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">changeInspDate</sess:setAttribute>
    <c:redirect url="changeInspDateScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= changeFaultLookupBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">changeFaultLookup</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= changeFaultLookupBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">changeFaultLookup</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= changeFaultLookupBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">changeFaultLookup</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= changeFaultLookupBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${changeFaultLookupBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="changeFaultLookupView.jsp" />
