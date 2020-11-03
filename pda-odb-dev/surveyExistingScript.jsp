<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.surveyExistingBean" %>
<%@ page import="com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>

<jsp:useBean id="surveyExistingBean" scope="session" class="com.vsb.surveyExistingBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="surveyExisting" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="surveyExisting" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>

    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="surveyExistingBean" property="all" value="clear" />
    <jsp:setProperty name="surveyExistingBean" property="*" />

    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="bv_transect" value='<%=surveyExistingBean.getTransect()%>' />

  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="surveyExistingBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="surveySiteLookup" >
  <jsp:setProperty name="surveyExistingBean" property="action" value="" />
  <jsp:setProperty name="surveyExistingBean" property="all" value="clear" />
  <jsp:setProperty name="surveyExistingBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>
<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="inspList" >
  <jsp:setProperty name="surveyExistingBean" property="action" value="" />
  <jsp:setProperty name="surveyExistingBean" property="all" value="clear" />
  <jsp:setProperty name="surveyExistingBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="surveyExisting" >

  <%-- Next view --%>
  <if:IfTrue cond='<%= surveyExistingBean.getAction().equals("New") %>' >
    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">surveyExisting</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">surveyTransectMethod</sess:setAttribute>
    <c:redirect url="surveyTransectMethodScript.jsp" />
  </if:IfTrue>

  <%-- Next view --%>
  <if:IfTrue cond='<%= surveyExistingBean.getAction().equals("Continue") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%=  surveyExistingBean.getTransect() == null || surveyExistingBean.getTransect().equals("") %>' >
      <jsp:setProperty name="surveyExistingBean" property="error"
        value="Please choose a transect to use, or click New to define a new transect." />
      <jsp:forward page="surveyExistingView.jsp" />
    </if:IfTrue>

    <%-- get the transect details --%>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con">
      <sql:query>
        select
              measure_method,
              land_use,
              start_ref,
              end_ref,
              lowdensity_flag,
              ward_flag,
              description
        from
              bv_transect
        where
              transect_ref = '<%= recordBean.getBv_transect() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="measure_method" />
        <% recordBean.setBv_transect_method((String) pageContext.getAttribute("measure_method")); %>
        <sql:getColumn position="2" to="land_use" />
        <% recordBean.setBv_land_use((String) pageContext.getAttribute("land_use")); %>
        <sql:getColumn position="3" to="start_ref" />
        <% recordBean.setBv_start_post((String) pageContext.getAttribute("start_ref")); %>
        <% recordBean.setBv_start_house((String) pageContext.getAttribute("start_ref")); %>
        <sql:getColumn position="4" to="end_ref" />
        <% recordBean.setBv_stop_post((String) pageContext.getAttribute("end_ref")); %>
        <% recordBean.setBv_stop_house((String) pageContext.getAttribute("end_ref")); %>
        <sql:getColumn position="5" to="lowdensity_flag" />
        <% recordBean.setBv_lowdensity_flag((String) pageContext.getAttribute("lowdensity_flag")); %>
        <sql:getColumn position="6" to="ward_flag" />
        <% recordBean.setBv_ward_flag((String) pageContext.getAttribute("ward_flag")); %>
        <sql:getColumn position="7" to="description" />
        <% recordBean.setBv_transect_desc((String) pageContext.getAttribute("description")); %>
      </sql:resultSet>
    </sql:statement>
    <sql:closeConnection conn="con"/>
    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">surveyExisting</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">surveyGrading</sess:setAttribute>
    <c:redirect url="surveyGradingScript.jsp" />
  </if:IfTrue>

<%-- Menu view --%>
  <if:IfTrue cond='<%= surveyExistingBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">surveyExisting</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>
<%-- Menu view --%>
  <if:IfTrue cond='<%= surveyExistingBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">surveyExisting</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>
  <%-- Previous view --%>
  <if:IfTrue cond='<%= surveyExistingBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">surveyExisting</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= surveyExistingBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${surveyExistingBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="surveyExistingView.jsp" />
