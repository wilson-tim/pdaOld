<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.addDartDetailsBean, com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="addDartDetailsBean" scope="session" class="com.vsb.addDartDetailsBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="addDartDetails" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="addDartDetails" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="addDartDetailsBean" property="all" value="clear" />
    <jsp:setProperty name="addDartDetailsBean" property="*" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="addDartDetailsBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="faultLookup" >
  <jsp:setProperty name="addDartDetailsBean" property="action" value="" />
  <jsp:setProperty name="addDartDetailsBean" property="all" value="clear" />
  <jsp:setProperty name="addDartDetailsBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="addDartDetails" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= addDartDetailsBean.getAction().equals("Continue") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>
    
    <%-- Valid entry --%>
    <if:IfTrue cond='<%= addDartDetailsBean.getConfirm().equals("Yes") %>' >
      <% recordBean.setDart_graff_flag("Y"); %>
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">addDartDetails</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">dartDetails</sess:setAttribute>
      <c:redirect url="dartDetailsScript.jsp" />
    </if:IfTrue>
    
    <if:IfTrue cond='<%= addDartDetailsBean.getConfirm().equals("No") %>' >
      <% recordBean.setDart_graff_flag("N"); %>
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">addDartDetails</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">addEnforcement</sess:setAttribute>
      <c:redirect url="addEnforcementScript.jsp" />
    </if:IfTrue>
  </if:IfTrue>
  
  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= addDartDetailsBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">addDartDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= addDartDetailsBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">addDartDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= addDartDetailsBean.getAction().equals("Back") %>' >
    <% recordBean.setDart_graff_flag("N"); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">addDartDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= addDartDetailsBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${addDartDetailsBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="addDartDetailsView.jsp" />
