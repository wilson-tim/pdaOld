<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.page1Bean" %>
<%@ page import="com.vsb.helperBean" %>
<%@ page import="com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="page1Bean" scope="session" class="com.vsb.page1Bean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="page1" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="page1" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="page1Bean" property="all" value="clear" />
    <jsp:setProperty name="page1Bean" property="*" />
     
    <%-- First page so clear recordBean --%>
    <% recordBean.setAll(""); %>

    <%-- Now update recordBean with new input --%>
    <% recordBean.setComplaint_no(page1Bean.getComplaint_no()); %>
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="page1Bean" property="error" value="" />

<%-- Initialise the forward_direction variable, used in the skip section --%>
<% String forward_direction = "N"; %>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="index" >
  <jsp:setProperty name="page1Bean" property="action" value="" />
  <jsp:setProperty name="page1Bean" property="all" value="clear" />
  <jsp:setProperty name="page1Bean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <% forward_direction = "Y"; %>
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="updateStatus" >
  <jsp:setProperty name="page1Bean" property="action" value="" />
  <jsp:setProperty name="page1Bean" property="all" value="clear" />
  <jsp:setProperty name="page1Bean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <% forward_direction = "Y"; %>
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="page1" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <%-- Code to run --%>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Skip View Section --%>
<%-- Don't skip if coming from the view --%>
<sess:equalsAttribute name="input" match="page1" value="false">
  <%-- Only skip if allowed. --%>
  <if:IfTrue cond='#SOME-SKIP-CHECK#' >
    <%-- skip to the next page, by faking it so that it appears the user --%>
    <%-- has just processd the page and clicked an action page button. --%>
    <%-- Do backwards skip first, as forward skip sets the 'input' session variable --%>
    <if:IfTrue cond='<%= forward_direction.equals("N") %>' >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">page1</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form"><%= page1Bean.getSavedPreviousForm() %></sess:setAttribute>
      <c:redirect url="${page1Bean.savedPreviousForm}Script.jsp" />
    </if:IfTrue>
    <%-- Do forwards skip --%>
    <if:IfTrue cond='<%= forward_direction.equals("Y") %>' >
      <%-- This section mimics the 'input' section at the top of the script --%>
      <%-- manually imitating a user interaction with the view, but without showing the view --%>
  
      <%-- Indicate which form we are in/just-come-from --%>
      <sess:setAttribute name="input">page1</sess:setAttribute>
  
      <%-- Setup the bean with the forms data manually --%>
      <jsp:setProperty name="page1Bean" property="all" value="clear" />
      <jsp:setProperty name="page1Bean" property="action" value="#SOME-ACTION-BUTTON#" />
  
    </if:IfTrue>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="page1" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= page1Bean.getAction().equals("Submit") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= helperBean.isValid(page1Bean.getComplaint_no()) && !helperBean.isStringInt(page1Bean.getComplaint_no()) %>' >
      <jsp:setProperty name="page1Bean" property="error" 
        value="Complaint No. must be a number" />
      <jsp:forward page="page1View.jsp" />
    </if:IfTrue>
    
    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">page1</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">page2</sess:setAttribute>
    <c:redirect url="page2Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="page1View.jsp" />
