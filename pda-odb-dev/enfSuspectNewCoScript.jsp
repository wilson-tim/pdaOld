<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.enfSuspectNewCoBean, com.vsb.enfSuspectNewBean, com.vsb.recordBean" %>
<%@ page import="com.db.*, javax.sql.*, java.util.*" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="enfSuspectNewCoBean" scope="session" class="com.vsb.enfSuspectNewCoBean" />
<jsp:useBean id="enfSuspectNewBean" scope="session" class="com.vsb.enfSuspectNewBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="enfSuspectNewCo" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="enfSuspectNewCo" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>

    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="enfSuspectNewCoBean" property="all" value="clear" />
    <jsp:setProperty name="enfSuspectNewCoBean" property="*" />

    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="enfcompany" value='<%= enfSuspectNewCoBean.getEnfcompany() %>' />
    <jsp:setProperty name="recordBean" property="sus_newco" value='<%= enfSuspectNewCoBean.getSus_newco() %>' />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="enfSuspectNewCoBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="enfSuspectNew" >
  <jsp:setProperty name="enfSuspectNewCoBean" property="action" value="" />
  <jsp:setProperty name="enfSuspectNewCoBean" property="all" value="clear" />
  <jsp:setProperty name="enfSuspectNewCoBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="enfSuspectNewCo" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= enfSuspectNewCoBean.getAction().equals("Continue") %>' >
    <%-- Invalid entry --%>
    <%-- No company selected --%>
    <if:IfTrue cond='<%= enfSuspectNewCoBean.getEnfcompany() == null || enfSuspectNewCoBean.getEnfcompany().equals("") %>' >
      <jsp:setProperty name="enfSuspectNewCoBean" property="error"
        value="Please choose a company." />
      <jsp:forward page="enfSuspectNewCoView.jsp" />
    </if:IfTrue>
    
    <%-- The new company has been selected, but has been left blank. --%>
    <if:IfTrue cond='<%= enfSuspectNewCoBean.getEnfcompany().equals("new") && enfSuspectNewCoBean.getSus_newco().equals("") %>' >
      <jsp:setProperty name="enfSuspectNewCoBean" property="error"
        value="The new company name can not be blank." />
      <jsp:forward page="enfSuspectNewCoView.jsp" />
    </if:IfTrue>
    
    <%-- Check to see if the user has entered a new company name --%>
    <%-- and if they have then check to see if the name already --%>
    <%-- exists. --%>
    <if:IfTrue cond='<%= enfSuspectNewCoBean.getEnfcompany().equals("new") %>' >
      <% boolean company_exists = false; %>
      <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
      <sql:statement id="stmt" conn="con1">
        <sql:query>
          select company_name
          from enf_company
          where company_name = '<%= enfSuspectNewCoBean.getSus_newco().toUpperCase() %>'
        </sql:query>
        <sql:resultSet id="rset">
        </sql:resultSet>
        <sql:wasNotEmpty>
          <% company_exists = true; %>
        </sql:wasNotEmpty>
      </sql:statement>
      <sql:closeConnection conn="con1"/>
      
      <%-- The new company has been selected, but already exists. --%>
      <if:IfTrue cond='<%= company_exists %>' >
        <jsp:setProperty name="enfSuspectNewCoBean" property="error"
          value="The new company name already exists. Please go back a page and search for that company." />
        <jsp:forward page="enfSuspectNewCoView.jsp" />
      </if:IfTrue>
    </if:IfTrue>

    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfSuspectNewCo</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">enfSuspectText</sess:setAttribute>
    <c:redirect url="enfSuspectTextScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= enfSuspectNewCoBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfSuspectNewCo</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= enfSuspectNewCoBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfSuspectNewCo</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= enfSuspectNewCoBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfSuspectNewCo</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= enfSuspectNewCoBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${enfSuspectNewCoBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="enfSuspectNewCoView.jsp" />
