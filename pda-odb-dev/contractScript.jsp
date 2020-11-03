<%@ page errorPage="error.jsp" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat" %>
<%@ page import="com.vsb.contractBean, com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="contractBean" scope="session" class="com.vsb.contractBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />

<%-- Set up the date variables --%>
<%
  // Set the default time zone to where we are, as the time zone
  // returned from sco is GMT+00:00 which is fine but doesn't mentioned
  // BST. So the default timezone has to be set to "Europe/London".
  // Any objects which use the timezone (like SimpleDateFormat) will then
  // be using the correct timezone.
  TimeZone dtz = TimeZone.getTimeZone("Europe/London");
  TimeZone.setDefault(dtz);

  String date;
  String time;
  String time_h;
  String time_m;
  SimpleDateFormat formatDate = new SimpleDateFormat(application.getInitParameter("db_date_fmt"));
  SimpleDateFormat formatTime = new SimpleDateFormat("HH:mm");
  SimpleDateFormat formatTime_h = new SimpleDateFormat("HH");
  SimpleDateFormat formatTime_m = new SimpleDateFormat("mm");

  Date currentDate = new java.util.Date();
  date = formatDate.format(currentDate);
  time = formatTime.format(currentDate);
  time_h = formatTime_h.format(currentDate);
  time_m = formatTime_m.format(currentDate);
%>

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="contract" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="contract" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="contractBean" property="all" value="clear" />
    <jsp:setProperty name="contractBean" property="*" />
    
    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="wo_contract_ref" param="wo_contract_ref" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- Create variable to be used to know when moving backward --%>
<% boolean goingBackward = true; %>

<%-- clear errors --%>
<jsp:setProperty name="contractBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="dartDetails" >
  <jsp:setProperty name="contractBean" property="action" value="" />
  <jsp:setProperty name="contractBean" property="all" value="clear" />
  <jsp:setProperty name="contractBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <% goingBackward = false; %>
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="graffDetails" >
  <jsp:setProperty name="contractBean" property="action" value="" />
  <jsp:setProperty name="contractBean" property="all" value="clear" />
  <jsp:setProperty name="contractBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <% goingBackward = false; %>
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="avStatus" >
  <jsp:setProperty name="contractBean" property="action" value="" />
  <jsp:setProperty name="contractBean" property="all" value="clear" />
  <jsp:setProperty name="contractBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <% goingBackward = false; %>
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="avDetails" >
  <jsp:setProperty name="contractBean" property="action" value="" />
  <jsp:setProperty name="contractBean" property="all" value="clear" />
  <jsp:setProperty name="contractBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <% goingBackward = false; %>
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="defectDetails" >
  <jsp:setProperty name="contractBean" property="action" value="" />
  <jsp:setProperty name="contractBean" property="all" value="clear" />
  <jsp:setProperty name="contractBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <% goingBackward = false; %>
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="faultLookup" >
  <jsp:setProperty name="contractBean" property="action" value="" />
  <jsp:setProperty name="contractBean" property="all" value="clear" />
  <jsp:setProperty name="contractBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <% goingBackward = false; %>
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="addDefect" >
  <jsp:setProperty name="contractBean" property="action" value="" />
  <jsp:setProperty name="contractBean" property="all" value="clear" />
  <jsp:setProperty name="contractBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <% goingBackward = false; %>
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="addFlyCapture" >
  <jsp:setProperty name="contractBean" property="action" value="" />
  <jsp:setProperty name="contractBean" property="all" value="clear" />
  <jsp:setProperty name="contractBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <% goingBackward = false; %>
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="compSampDetails" >
  <jsp:setProperty name="contractBean" property="action" value="" />
  <jsp:setProperty name="contractBean" property="all" value="clear" />
  <jsp:setProperty name="contractBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <% goingBackward = false; %>
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="flyCapUpdate" >
  <jsp:setProperty name="contractBean" property="action" value="" />
  <jsp:setProperty name="contractBean" property="all" value="clear" />
  <jsp:setProperty name="contractBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <% goingBackward = false; %>
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="flyCapDetails" >
  <jsp:setProperty name="contractBean" property="action" value="" />
  <jsp:setProperty name="contractBean" property="all" value="clear" />
  <jsp:setProperty name="contractBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <% goingBackward = false; %>
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="wasteTypes" >
  <jsp:setProperty name="contractBean" property="action" value="" />
  <jsp:setProperty name="contractBean" property="all" value="clear" />
  <jsp:setProperty name="contractBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <% goingBackward = false; %>
</sess:equalsAttribute>


<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>

<%-- Skip View Section --%>
<%-- Always skipping this form as should never need it, keeping it just incase multi contracts become --%>
<%-- available in contender. Meanwhile asuming only one contract found. --%>
<%-- only one record found then skip to the next page, by faking it so that it appears the user --%>
<%-- has just selected the one item and clicked the next page button. --%>
<%-- Do backwards skip first, as forward skip sets the 'input' session variable --%>
<if:IfTrue cond='<%= goingBackward %>' >
  <%-- Indicate which form we are coming from when we forward to another form --%>
  <sess:setAttribute name="previousForm">contract</sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form"><%= contractBean.getSavedPreviousForm() %></sess:setAttribute>
  <c:redirect url="${contractBean.savedPreviousForm}Script.jsp" />
</if:IfTrue>
<%-- Do forwards skip --%>
<if:IfTrue cond='<%= !goingBackward %>' >
  <%-- This section mimics the 'input' section at the top of the script --%>
  <%-- manually imitating a user interaction with the view, but without showing the view --%>

  <%-- Indicate which form we are in/just-come-from --%>
  <sess:setAttribute name="input">contract</sess:setAttribute>

  <%-- Setup the bean with the forms data manually --%>
  <jsp:setProperty name="contractBean" property="all" value="clear" />
  <jsp:setProperty name="contractBean" property="action" value="Next" />

  <jsp:setProperty name="recordBean" property="wo_contract_ref" param="wo_contract_ref" />
  <% recordBean.setWo_contract_ref(recordBean.getContract_ref()); %>
  <% contractBean.setWo_contract_ref(recordBean.getContract_ref()); %>
</if:IfTrue>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="contract" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= contractBean.getAction().equals("Next") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= contractBean.getWo_contract_ref() == null || contractBean.getWo_contract_ref().equals("") %>' >
      <jsp:setProperty name="contractBean" property="error"
        value="Please choose a contract." />
      <jsp:forward page="contractView.jsp" />
    </if:IfTrue>
    
    <%-- Valid entry --%>
    <%-- get the contract cycle no --%>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con">
      <sql:query>
        select cont_cycle_no
        from c_da
        where contract_ref = '<%= recordBean.getWo_contract_ref() %>'
        and period_start <= '<%= date %>'
        and period_finish >= '<%= date %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="cont_cycle_no" />
        <% recordBean.setCont_cycle_no((String) pageContext.getAttribute("cont_cycle_no")); %>
      </sql:resultSet>
    </sql:statement>
    <sql:closeConnection conn="con"/>
    
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">contract</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">suffix</sess:setAttribute>
    <c:redirect url="suffixScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= contractBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">contract</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= contractBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">contract</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= contractBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">contract</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= contractBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${contractBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="contractView.jsp" />
