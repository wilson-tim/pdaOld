<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.addFlyCaptureBean, com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="addFlyCaptureBean" scope="session" class="com.vsb.addFlyCaptureBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="addFlyCapture" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="addFlyCapture" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="addFlyCaptureBean" property="all" value="clear" />
    <jsp:setProperty name="addFlyCaptureBean" property="*" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="addFlyCaptureBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="faultLookup" >
  <jsp:setProperty name="addFlyCaptureBean" property="action" value="" />
  <jsp:setProperty name="addFlyCaptureBean" property="all" value="clear" />
  <jsp:setProperty name="addFlyCaptureBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="addFlyCapture" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= addFlyCaptureBean.getAction().equals("Continue") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>
    
    <%-- Valid entry --%>
    <if:IfTrue cond='<%= addFlyCaptureBean.getConfirm().equals("Yes") %>' >
      <% recordBean.setFly_cap_flag("Y"); %>
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">addFlyCapture</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">flyCapDetails</sess:setAttribute>
      <c:redirect url="flyCapDetailsScript.jsp" />
    </if:IfTrue>
    
    <if:IfTrue cond='<%= addFlyCaptureBean.getConfirm().equals("No") %>' >
      <% recordBean.setFly_cap_flag("N"); %>
      <if:IfTrue cond='<%= !recordBean.getAction_flag().equals("W") %>'>
        <%-- Indicate which form we are coming from when we forward to another form --%>
        <sess:setAttribute name="previousForm">addFlyCapture</sess:setAttribute>
        <%-- Indicate which form we are going to next --%>
        <sess:setAttribute name="form">addEnforcement</sess:setAttribute>
        <c:redirect url="addEnforcementScript.jsp" />
      </if:IfTrue>
      <if:IfTrue cond='<%= recordBean.getAction_flag().equals("W") %>'>
        <%-- Indicate which form we are coming from when we forward to another form --%>
        <sess:setAttribute name="previousForm">addFlyCapture</sess:setAttribute>
        <%-- Indicate which form we are going to next --%>
        <sess:setAttribute name="form">contract</sess:setAttribute>
        <c:redirect url="contractScript.jsp" />
      </if:IfTrue>
    </if:IfTrue>
  </if:IfTrue>
  
  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= addFlyCaptureBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">addFlyCapture</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= addFlyCaptureBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">addFlyCapture</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= addFlyCaptureBean.getAction().equals("Back") %>' >
    <% recordBean.setFly_cap_flag("N"); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">addFlyCapture</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= addFlyCaptureBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${addFlyCaptureBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="addFlyCaptureView.jsp" />
