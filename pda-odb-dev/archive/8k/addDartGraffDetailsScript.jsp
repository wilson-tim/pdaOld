<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.addDartGraffDetailsBean, com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="addDartGraffDetailsBean" scope="session" class="com.vsb.addDartGraffDetailsBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="addDartGraffDetails" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="addDartGraffDetails" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="addDartGraffDetailsBean" property="all" value="clear" />
    <jsp:setProperty name="addDartGraffDetailsBean" property="*" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="addDartGraffDetailsBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="faultLookup" >
  <jsp:setProperty name="addDartGraffDetailsBean" property="action" value="" />
  <jsp:setProperty name="addDartGraffDetailsBean" property="all" value="clear" />
  <jsp:setProperty name="addDartGraffDetailsBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="addDartGraffDetails" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= addDartGraffDetailsBean.getAction().equals("Continue") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>
    
    <%-- Valid entry --%>
    <if:IfTrue cond='<%= addDartGraffDetailsBean.getConfirm().equals("Yes") %>' >
      <% recordBean.setDart_graff_flag("Y"); %>

      <if:IfTrue cond='<%= recordBean.getService_c().equals(recordBean.getDart_service()) %>' >
        <%-- Indicate which form we are coming from when we forward to another form --%>
        <sess:setAttribute name="previousForm">addDartGraffDetails</sess:setAttribute>
        <%-- Indicate which form we are going to next --%>
        <sess:setAttribute name="form">dartDetails</sess:setAttribute>
        <c:redirect url="dartDetailsScript.jsp" />
      </if:IfTrue>
      <if:IfTrue cond='<%= recordBean.getService_c().equals(recordBean.getGraffiti_service()) %>' >
        <%-- Indicate which form we are coming from when we forward to another form --%>
        <sess:setAttribute name="previousForm">addDartGraffDetails</sess:setAttribute>
        <%-- Indicate which form we are going to next --%>
        <sess:setAttribute name="form">graffDetails</sess:setAttribute>
        <c:redirect url="graffDetailsScript.jsp" />
      </if:IfTrue>
    </if:IfTrue>
    
    <if:IfTrue cond='<%= addDartGraffDetailsBean.getConfirm().equals("No") %>' >
      <% recordBean.setDart_graff_flag("N"); %>
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">addDartGraffDetails</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">addEnforcement</sess:setAttribute>
      <c:redirect url="addEnforcementScript.jsp" />
    </if:IfTrue>
  </if:IfTrue>
  
  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= addDartGraffDetailsBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">addDartGraffDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= addDartGraffDetailsBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">addDartGraffDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= addDartGraffDetailsBean.getAction().equals("Back") %>' >
    <% recordBean.setDart_graff_flag("N"); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">addDartGraffDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= addDartGraffDetailsBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${addDartGraffDetailsBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="addDartGraffDetailsView.jsp" />
