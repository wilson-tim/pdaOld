<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.surveyTransectMethodBean" %>
<%@ page import="com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="surveyTransectMethodBean" scope="session" class="com.vsb.surveyTransectMethodBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="surveyTransectMethod" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="surveyTransectMethod" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>

    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="surveyTransectMethodBean" property="all" value="clear" />
    <jsp:setProperty name="surveyTransectMethodBean" property="*" />

		<%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="bv_transect_method" value='<%=surveyTransectMethodBean.getTransectMethod()%>' />
    <jsp:setProperty name="recordBean" property="bv_transect" value='' />

  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="surveyTransectMethodBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="surveySiteLookup" >
  <jsp:setProperty name="surveyTransectMethodBean" property="action" value="" />
  <jsp:setProperty name="surveyTransectMethodBean" property="all" value="clear" />
  <jsp:setProperty name="surveyTransectMethodBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>
<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="surveyExisting" >
  <jsp:setProperty name="surveyTransectMethodBean" property="action" value="" />
  <jsp:setProperty name="surveyTransectMethodBean" property="all" value="clear" />
  <jsp:setProperty name="surveyTransectMethodBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>
<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="inspList" >
  <jsp:setProperty name="surveyTransectMethodBean" property="action" value="" />
  <jsp:setProperty name="surveyTransectMethodBean" property="all" value="clear" />
  <jsp:setProperty name="surveyTransectMethodBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="surveyTransectMethod" >
  <%-- Next view --%>
	<if:IfTrue cond='<%= surveyTransectMethodBean.getAction().equals("Continue") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= surveyTransectMethodBean.getTransectMethod().equals("") || surveyTransectMethodBean.getTransectMethod() == null %>' >
    	<jsp:setProperty name="surveyTransectMethodBean" property="error"
        value="Please choose a transect measurement method." />
      <jsp:forward page="surveyTransectMethodView.jsp" />
    </if:IfTrue>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">surveyTransectMethod</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">surveyTransectMeasure</sess:setAttribute>
    <c:redirect url="surveyTransectMeasureScript.jsp" />
  </if:IfTrue>

  <%-- Menu view --%>
  <if:IfTrue cond='<%= surveyTransectMethodBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">surveyTransectMethod</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>
  
  <%-- Menu view --%>
  <if:IfTrue cond='<%= surveyTransectMethodBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">surveyTransectMethod</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= surveyTransectMethodBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">surveyTransectMethod</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= surveyTransectMethodBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${surveyTransectMethodBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="surveyTransectMethodView.jsp" />
