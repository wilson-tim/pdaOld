<%@ page errorPage="error.jsp" %>
<%@ page import ="com.vsb.recMonStreetsBean, com.vsb.loginBean, com.vsb.recordBean" %>
<%@ page import ="com.db.*, java.util.ArrayList, java.util.Iterator" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags"      prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags"   prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core"                 prefix="c" %>

<jsp:useBean id="recordBean"        scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="recMonStreetsBean" scope="session" class="com.vsb.recMonStreetsBean" />
<jsp:useBean id="loginBean"         scope="session" class="com.vsb.loginBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="recMonStreets" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="recMonStreets" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>

    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="recMonStreetsBean" property="all" value="clear" />
    <jsp:setProperty name="recMonStreetsBean" property="*" />    

    <%-- Clear the previous record --%>
    <jsp:setProperty name="recordBean" property="all" value="clear" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="recMonStreetsBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="mainMenu" >
  <jsp:setProperty name="recMonStreetsBean" property="action" value="" />
  <jsp:setProperty name="recMonStreetsBean" property="all"    value="clear" />
  <jsp:setProperty name="recMonStreetsBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
<sql:statement id="stmt" conn="con">
  <%-- Get the monitor source --%>
  <sql:query>
    SELECT c_field
    FROM keys
    WHERE service_c = 'ALL'
    AND   keyname = 'MONITOR_SOURCE'
  </sql:query>
  <sql:resultSet id="rset">
     <sql:getColumn position="1" to="monitor_source" />
     <% recMonStreetsBean.setMonitor_source((String) pageContext.getAttribute("monitor_source")); %>
  </sql:resultSet> 
</sql:statement>
<sql:closeConnection conn="con"/>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="recMonStreets" >
  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= recMonStreetsBean.getAction().equals("Properties") %>' >
    <%-- Invalid entry --%>
    <%-- make sure the user has selected a location to view --%>
    <if:IfTrue cond='<%= recMonStreetsBean.getLocation_c().equals("") %>' >
      <jsp:setProperty name="recMonStreetsBean" property="error"
        value="Please select a street to view." />
      <jsp:forward page="recMonStreetsView.jsp" />
    </if:IfTrue>
    
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">recMonStreets</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">recMonProperties</sess:setAttribute>
    <c:redirect url="recMonPropertiesScript.jsp" />
  </if:IfTrue>

  <%-- Next view 22--%>
  <if:IfTrue cond='<%= recMonStreetsBean.getAction().equals("Street Missed") %>' >
    <%-- Invalid entry --%>
    <%-- make sure the user has selected a location to view --%>
    <if:IfTrue cond='<%= recMonStreetsBean.getLocation_c().equals("") %>' >
      <jsp:setProperty name="recMonStreetsBean" property="error"
        value="Please select a street to flag as missed." />
      <jsp:forward page="recMonStreetsView.jsp" />
    </if:IfTrue>
    
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">recMonStreets</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">recMonMissed</sess:setAttribute>
    <c:redirect url="recMonMissedScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= recMonStreetsBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">recMonStreets</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>
  
  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= recMonStreetsBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">recMonStreets</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= recMonStreetsBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">recMonStreets</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= recMonStreetsBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${recMonStreetsBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="recMonStreetsView.jsp" />
