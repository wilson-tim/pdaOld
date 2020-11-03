<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.addGraffDetailsBean, com.vsb.faultLookupBean, com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="addGraffDetailsBean" scope="session" class="com.vsb.addGraffDetailsBean" />
<jsp:useBean id="faultLookupBean" scope="session" class="com.vsb.faultLookupBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="addGraffDetails" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="addGraffDetails" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="addGraffDetailsBean" property="all" value="clear" />
    <jsp:setProperty name="addGraffDetailsBean" property="*" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="addGraffDetailsBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="faultLookup" >
  <jsp:setProperty name="addGraffDetailsBean" property="action" value="" />
  <jsp:setProperty name="addGraffDetailsBean" property="all" value="clear" />
  <jsp:setProperty name="addGraffDetailsBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="addDefect" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <%-- Code to run --%>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="addGraffDetails" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= addGraffDetailsBean.getAction().equals("Continue") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>
    
    <%-- Valid entry --%>
    <%-- Check to see if the last action flag was set, and if so revert back to that value --%>
    <if:IfTrue cond='<%= !recordBean.getLast_action_flag().equals("") %>'>
      <% recordBean.setAction_flag( recordBean.getLast_action_flag() ); %>
    </if:IfTrue>

    <if:IfTrue cond='<%= addGraffDetailsBean.getConfirm().equals("Yes") %>' >
      <% recordBean.setDart_graff_flag("Y"); %>
      
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">addGraffDetails</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">graffDetails</sess:setAttribute>
      <c:redirect url="graffDetailsScript.jsp" />
    </if:IfTrue>
    
    <if:IfTrue cond='<%= addGraffDetailsBean.getConfirm().equals("No") %>' >
      <% recordBean.setDart_graff_flag("N"); %>

      <if:IfTrue cond='<%= recordBean.getAction_flag().equals("W") %>' >
        <%-- Change Works Order to Inspect --%>
        <% recordBean.setAction_flag("I"); %>
      </if:IfTrue>

      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">addGraffDetails</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">addEnforcement</sess:setAttribute>
      <c:redirect url="addEnforcementScript.jsp" />
    </if:IfTrue>
  </if:IfTrue>
  
  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= addGraffDetailsBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">addGraffDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= addGraffDetailsBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">addGraffDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= addGraffDetailsBean.getAction().equals("Back") %>' >
    <% recordBean.setDart_graff_flag("N"); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">addGraffDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= addGraffDetailsBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${addGraffDetailsBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="addGraffDetailsView.jsp" />
