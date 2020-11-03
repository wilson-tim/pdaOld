<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.avMakeBean, com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>

<jsp:useBean id="avMakeBean" scope="session" class="com.vsb.avMakeBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="avMake" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="avMake" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="avMakeBean" property="all" value="clear" />
    <jsp:setProperty name="avMakeBean" property="*" />
    
    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="av_make_ref" param="make_ref" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="avMakeBean" property="error" value="" />

<%-- clear form fields if coming from previous form --%>
<sess:equalsAttribute name="input" match="service" >
  <jsp:setProperty name="avMakeBean" property="action" value="" />
  <jsp:setProperty name="avMakeBean" property="all" value="clear" />
  <jsp:setProperty name="avMakeBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="avMake" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= avMakeBean.getAction().equals("Details") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= avMakeBean.getMake_ref() == null || avMakeBean.getMake_ref().trim().equals("") %>' >
      <jsp:setProperty name="avMakeBean" property="error"
        value="Please choose a Make." />
      <jsp:forward page="avMakeView.jsp" />
    </if:IfTrue>
    
    <%-- Valid entry --%>
    <%-- get the avMake description --%>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con">
      <sql:query>
        select make_desc
        from makes
        where make_ref = '<%= recordBean.getMake_ref() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="avMake_desc" />
        <% recordBean.setAv_make_desc((String) pageContext.getAttribute("avMake_desc")); %>
      </sql:resultSet>
    </sql:statement>
    <sql:closeConnection conn="con"/>
    
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">avMake</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">avAddDetails</sess:setAttribute>
    <c:redirect url="avAddDetailsScript.jsp" />
  </if:IfTrue>
 
  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= avMakeBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">avMake</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= avMakeBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">avMake</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>
 
  <%-- Previous view --%>
  <if:IfTrue cond='<%= avMakeBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">avMake</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= avMakeBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${avMakeBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="avMakeView.jsp" />
