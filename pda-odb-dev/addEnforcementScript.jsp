<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.addEnforcementBean, com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="addEnforcementBean" scope="session" class="com.vsb.addEnforcementBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="addEnforcement" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="addEnforcement" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="addEnforcementBean" property="all" value="clear" />
    <jsp:setProperty name="addEnforcementBean" property="*" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="addEnforcementBean" property="error" value="" />

<%-- Initialise the forward_direction variable, used in the skip section --%>
<% String forward_direction = "N"; %>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="faultLookup" >
  <jsp:setProperty name="addEnforcementBean" property="action" value="" />
  <jsp:setProperty name="addEnforcementBean" property="all" value="clear" />
  <jsp:setProperty name="addEnforcementBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <% forward_direction = "Y"; %>
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="addFlyCapture" >
  <jsp:setProperty name="addEnforcementBean" property="action" value="" />
  <jsp:setProperty name="addEnforcementBean" property="all" value="clear" />
  <jsp:setProperty name="addEnforcementBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <% forward_direction = "Y"; %>
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="addDartGraffDetails" >
  <jsp:setProperty name="addEnforcementBean" property="action" value="" />
  <jsp:setProperty name="addEnforcementBean" property="all" value="clear" />
  <jsp:setProperty name="addEnforcementBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <% forward_direction = "Y"; %>
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="addDartDetails" >
  <jsp:setProperty name="addEnforcementBean" property="action" value="" />
  <jsp:setProperty name="addEnforcementBean" property="all" value="clear" />
  <jsp:setProperty name="addEnforcementBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <% forward_direction = "Y"; %>
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="addGraffDetails" >
  <jsp:setProperty name="addEnforcementBean" property="action" value="" />
  <jsp:setProperty name="addEnforcementBean" property="all" value="clear" />
  <jsp:setProperty name="addEnforcementBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <% forward_direction = "Y"; %>
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="dartDetails" >
  <jsp:setProperty name="addEnforcementBean" property="action" value="" />
  <jsp:setProperty name="addEnforcementBean" property="all" value="clear" />
  <jsp:setProperty name="addEnforcementBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <% forward_direction = "Y"; %>
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="graffDetails" >
  <jsp:setProperty name="addEnforcementBean" property="action" value="" />
  <jsp:setProperty name="addEnforcementBean" property="all" value="clear" />
  <jsp:setProperty name="addEnforcementBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <% forward_direction = "Y"; %>
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="doorstepSurvey" >
  <jsp:setProperty name="addEnforcementBean" property="action" value="" />
  <jsp:setProperty name="addEnforcementBean" property="all" value="clear" />
  <jsp:setProperty name="addEnforcementBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <% forward_direction = "Y"; %>
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="doorstepFault" >
  <jsp:setProperty name="addEnforcementBean" property="action" value="" />
  <jsp:setProperty name="addEnforcementBean" property="all" value="clear" />
  <jsp:setProperty name="addEnforcementBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <% forward_direction = "Y"; %>
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="woDetails" >
  <jsp:setProperty name="addEnforcementBean" property="action" value="" />
  <jsp:setProperty name="addEnforcementBean" property="all" value="clear" />
  <jsp:setProperty name="addEnforcementBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <% forward_direction = "Y"; %>
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="avStatus" >
  <jsp:setProperty name="addEnforcementBean" property="action" value="" />
  <jsp:setProperty name="addEnforcementBean" property="all" value="clear" />
  <jsp:setProperty name="addEnforcementBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <% forward_direction = "Y"; %>
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="addDefect" >
  <jsp:setProperty name="addEnforcementBean" property="action" value="" />
  <jsp:setProperty name="addEnforcementBean" property="all" value="clear" />
  <jsp:setProperty name="addEnforcementBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <% forward_direction = "Y"; %>
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Skip View Section --%>
<%-- Don't skip if coming from the view --%>
<sess:equalsAttribute name="input" match="addEnforcement" value="false">
  <%-- Only allow skip if allowed i.e. use_enforcement does not equal "Y" and --%>
  <%-- enforcement installed (todo) --%>
  <app:equalsInitParameter name="use_enforcement" match="Y" value="false">
    <%-- skip to the next page, by faking it so that it appears the user --%>
    <%-- has just selected "No" and clicked the next page button. --%>
    <%-- Do backwards skip first, as forward skip sets the 'input' session variable --%>
    <if:IfTrue cond='<%= forward_direction.equals("N") %>' >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">addEnforcement</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form"><%= addEnforcementBean.getSavedPreviousForm() %></sess:setAttribute>
      <c:redirect url="${addEnforcementBean.savedPreviousForm}Script.jsp" />
    </if:IfTrue>
    <%-- Do forwards skip --%>
    <if:IfTrue cond='<%= forward_direction.equals("Y") %>' >
      <%-- This section mimics the 'input' section at the top of the script --%>
      <%-- manually imitating a user interaction with the view, but without showing the view --%>
  
      <%-- Indicate which form we are in/just-come-from --%>
      <sess:setAttribute name="input">addEnforcement</sess:setAttribute>
  
      <%-- Setup the bean with the forms data manually --%>
      <jsp:setProperty name="addEnforcementBean" property="all" value="clear" />
      <jsp:setProperty name="addEnforcementBean" property="action" value="Continue" />
      <jsp:setProperty name="addEnforcementBean" property="confirm" value="No" />
  
      <% recordBean.setEnforce_flag("N"); %>
    </if:IfTrue>
  </app:equalsInitParameter>
</sess:equalsAttribute>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="addEnforcement" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= addEnforcementBean.getAction().equals("Continue") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>
    
    <%-- Valid entry --%>
    <if:IfTrue cond='<%= addEnforcementBean.getConfirm().equals("Yes") %>' >
      <% recordBean.setEnforce_flag("Y"); %>
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">addEnforcement</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">law</sess:setAttribute>
      <c:redirect url="lawScript.jsp" />
    </if:IfTrue>
    
    <if:IfTrue cond='<%= addEnforcementBean.getConfirm().equals("No") %>' >
      <% recordBean.setEnforce_flag("N"); %>
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">addEnforcement</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">text</sess:setAttribute>
      <c:redirect url="textScript.jsp" />
    </if:IfTrue>
  </if:IfTrue>
  
  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= addEnforcementBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">addEnforcement</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= addEnforcementBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">addEnforcement</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= addEnforcementBean.getAction().equals("Back") %>' >
    <% recordBean.setEnforce_flag("N"); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">addEnforcement</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= addEnforcementBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${addEnforcementBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="addEnforcementView.jsp" />
