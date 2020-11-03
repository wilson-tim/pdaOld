<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.page3Bean" %>
<%@ page import="com.vsb.recordBean" %>
<%@ page import="com.vsb.helperBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="page3Bean" scope="session" class="com.vsb.page3Bean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="page3" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="page3" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="page3Bean" property="all" value="clear" />
    <jsp:setProperty name="page3Bean" property="*" />

    <%-- Now update recordBean with radio button selection --%>
    <% recordBean.setComplaint_no_sel(page3Bean.getComplaint_no()); %>
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="page3Bean" property="error" value="" />

<%-- Initialise the forward_direction variable, used in the skip section --%>
<% String forward_direction = "N"; %>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="page2" >
  <jsp:setProperty name="page3Bean" property="action" value="" />
  <jsp:setProperty name="page3Bean" property="all" value="clear" />
  <jsp:setProperty name="page3Bean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <% forward_direction = "Y"; %>
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="page3" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <%-- Code to run --%>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Skip View Section --%>
<%-- Don't skip if coming from the view --%>
<sess:equalsAttribute name="input" match="page3" value="false">
  <%-- Only skip if allowed. --%>
  <if:IfTrue cond='#SOME-SKIP-CHECK#' >
    <%-- skip to the next page, by faking it so that it appears the user --%>
    <%-- has just processd the page and clicked an action page button. --%>
    <%-- Do backwards skip first, as forward skip sets the 'input' session variable --%>
    <if:IfTrue cond='<%= forward_direction.equals("N") %>' >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">page3</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form"><%= page3Bean.getSavedPreviousForm() %></sess:setAttribute>
      <c:redirect url="${page3Bean.savedPreviousForm}Script.jsp" />
    </if:IfTrue>
    <%-- Do forwards skip --%>
    <if:IfTrue cond='<%= forward_direction.equals("Y") %>' >
      <%-- This section mimics the 'input' section at the top of the script --%>
      <%-- manually imitating a user interaction with the view, but without showing the view --%>
  
      <%-- Indicate which form we are in/just-come-from --%>
      <sess:setAttribute name="input">page3</sess:setAttribute>
  
      <%-- Setup the bean with the forms data manually --%>
      <jsp:setProperty name="page3Bean" property="all" value="clear" />
      <jsp:setProperty name="page3Bean" property="action" value="#SOME-ACTION-BUTTON#" />
  
    </if:IfTrue>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="page3" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= page3Bean.getAction().equals("Details") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= helperBean.isNotValid(page3Bean.getComplaint_no()) %>' >
      <jsp:setProperty name="page3Bean" property="error" 
        value="Please select a complaint" />
      <jsp:forward page="page3View.jsp" />
    </if:IfTrue>
    
    <%-- Valid entry --%>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />    
    <sql:statement id="stmt" conn="con">
      <sql:query>
        select site_ref
        from comp
        where complaint_no = <%= recordBean.getComplaint_no_sel() %>
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="site_ref" />
        <sql:wasNotNull>
          <% recordBean.setSite_ref((String) pageContext.getAttribute("site_ref")); %>
        </sql:wasNotNull>
      </sql:resultSet>

      <sql:query>
        select site_name_1, area_c
        from site
        where site_ref = '<%= recordBean.getSite_ref() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="site_name" />
        <sql:wasNotNull>
          <% recordBean.setSite_name_1((String) pageContext.getAttribute("site_name")); %>
        </sql:wasNotNull>

        <sql:getColumn position="2" to="area_c" />
        <sql:wasNotNull>
          <% recordBean.setArea_c((String) pageContext.getAttribute("area_c")); %>
        </sql:wasNotNull>
      </sql:resultSet>

    </sql:statement>
    <sql:closeConnection conn="con"/>

    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">page3</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">page4</sess:setAttribute>
    <c:redirect url="page4Script.jsp" />
  </if:IfTrue>

  <%-- Next view --%>
  <if:IfTrue cond='<%= page3Bean.getAction().equals("Update") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= helperBean.isNotValid(page3Bean.getComplaint_no()) %>' >
      <jsp:setProperty name="page3Bean" property="error" 
        value="Please select a complaint" />
      <jsp:forward page="page3View.jsp" />
    </if:IfTrue>
    
    <%-- Valid entry --%>
    <%-- Update remarks --%>
    <sess:setAttribute name="form">updateRemarksFunc</sess:setAttribute>
    <c:import url="updateRemarksFunc.jsp" var="webPage" />
    <% helperBean.throwException("updateRemarksFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">page3</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">updateStatus</sess:setAttribute>
    <c:redirect url="updateStatusScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= page3Bean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">page3</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= page3Bean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${page3Bean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="page3View.jsp" />
