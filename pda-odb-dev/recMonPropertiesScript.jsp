<%@ page errorPage="error.jsp" %>
<%@ page import ="com.vsb.recMonPropertiesBean, com.vsb.loginBean, com.vsb.recMonStreetsBean" %>
<%@ page import ="com.vsb.recordBean" %>
<%@ page import ="com.db.*, java.util.ArrayList, java.util.Iterator" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags"      prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags"   prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core"                 prefix="c" %>

<jsp:useBean id="recordBean"           scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="recMonPropertiesBean" scope="session" class="com.vsb.recMonPropertiesBean" />
<jsp:useBean id="recMonStreetsBean"    scope="session" class="com.vsb.recMonStreetsBean" />
<jsp:useBean id="loginBean"            scope="session" class="com.vsb.loginBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="recMonProperties" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="recMonProperties" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>

    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="recMonPropertiesBean" property="all" value="clear" />
    <jsp:setProperty name="recMonPropertiesBean" property="*" />   

    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="complaint_no" param="complaint_no" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="recMonPropertiesBean" property="error" value="" />
  
<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="recMonStreets" >
  <jsp:setProperty name="recMonPropertiesBean" property="action" value="" />
  <jsp:setProperty name="recMonPropertiesBean" property="all"    value="clear" />
  <jsp:setProperty name="recMonPropertiesBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="recMonProperties" >
  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= recMonPropertiesBean.getAction().equals("Survey") %>' >
    <%-- Invalid entry --%>
    <%-- make sure the user has selected a location to view --%>
    <if:IfTrue cond='<%= recMonPropertiesBean.getComplaint_no().equals("") %>' >
      <jsp:setProperty name="recMonPropertiesBean" property="error"
        value="Please select a property to survey." />
      <jsp:forward page="recMonPropertiesView.jsp" />
    </if:IfTrue>
    
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">recMonProperties</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">recMonSurvey</sess:setAttribute>
    <c:redirect url="recMonSurveyScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= recMonPropertiesBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">recMonProperties</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>
  
  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= recMonPropertiesBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">recMonProperties</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= recMonPropertiesBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">recMonProperties</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= recMonPropertiesBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${recMonPropertiesBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="recMonPropertiesView.jsp" />
