<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.pickAbsentOfficerBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>

<jsp:useBean id="pickAbsentOfficerBean" scope="session" class="com.vsb.pickAbsentOfficerBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="pickAbsentOfficer" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="pickAbsentOfficer" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="pickAbsentOfficerBean" property="all" value="clear" />
    <jsp:setProperty name="pickAbsentOfficerBean" property="*" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="pickAbsentOfficerBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="officerMenu" >
  <jsp:setProperty name="pickAbsentOfficerBean" property="action" value="" />
  <jsp:setProperty name="pickAbsentOfficerBean" property="all" value="clear" />
  <jsp:setProperty name="pickAbsentOfficerBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="pickAbsentOfficer" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <%-- Code to run --%>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="pickAbsentOfficer" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= pickAbsentOfficerBean.getAction().equals("Assign Cover") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%=pickAbsentOfficerBean.getUser_name() == null || pickAbsentOfficerBean.getUser_name().equals("") %>' >
      <jsp:setProperty name="pickAbsentOfficerBean" property="error"
        value="Please choose an officer." />
      <jsp:forward page="pickAbsentOfficerView.jsp" />
    </if:IfTrue>

    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">pickAbsentOfficer</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">officerCover</sess:setAttribute>
    <c:redirect url="officerCoverScript.jsp" />
  </if:IfTrue>
  
  <%-- Previous view --%>
  <if:IfTrue cond='<%= pickAbsentOfficerBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">pickAbsentOfficer</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= pickAbsentOfficerBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${pickAbsentOfficerBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="pickAbsentOfficerView.jsp" />