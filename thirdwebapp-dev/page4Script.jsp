<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.page4Bean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="page4Bean" scope="session" class="com.vsb.page4Bean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="page4" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="page4" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="page4Bean" property="all" value="clear" />
    <jsp:setProperty name="page4Bean" property="*" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="page4Bean" property="error" value="" />

<%-- Initialise the forward_direction variable, used in the skip section --%>
<% String forward_direction = "N"; %>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="page3" >
  <jsp:setProperty name="page4Bean" property="action" value="" />
  <jsp:setProperty name="page4Bean" property="all" value="clear" />
  <jsp:setProperty name="page4Bean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <% forward_direction = "Y"; %>
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="page4" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <%-- Code to run --%>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Skip View Section --%>
<%-- Don't skip if coming from the view --%>
<sess:equalsAttribute name="input" match="page4" value="false">
  <%-- Only skip if allowed. --%>
  <if:IfTrue cond='#SOME-SKIP-CHECK#' >
    <%-- skip to the next page, by faking it so that it appears the user --%>
    <%-- has just processd the page and clicked an action page button. --%>
    <%-- Do backwards skip first, as forward skip sets the 'input' session variable --%>
    <if:IfTrue cond='<%= forward_direction.equals("N") %>' >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">page4</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form"><%= page4Bean.getSavedPreviousForm() %></sess:setAttribute>
      <c:redirect url="${page4Bean.savedPreviousForm}Script.jsp" />
    </if:IfTrue>
    <%-- Do forwards skip --%>
    <if:IfTrue cond='<%= forward_direction.equals("Y") %>' >
      <%-- This section mimics the 'input' section at the top of the script --%>
      <%-- manually imitating a user interaction with the view, but without showing the view --%>
  
      <%-- Indicate which form we are in/just-come-from --%>
      <sess:setAttribute name="input">page4</sess:setAttribute>
  
      <%-- Setup the bean with the forms data manually --%>
      <jsp:setProperty name="page4Bean" property="all" value="clear" />
      <jsp:setProperty name="page4Bean" property="action" value="#SOME-ACTION-BUTTON#" />
  
    </if:IfTrue>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="page4" >
  <%-- Next view --%>
  <%-- NON --%>
    
  <%-- Previous view --%>
  <if:IfTrue cond='<%= page4Bean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">page4</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= page4Bean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${page4Bean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="page4View.jsp" />
