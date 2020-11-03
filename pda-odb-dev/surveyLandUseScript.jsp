<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.surveyLandUseBean" %>
<%@ page import="com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>

<jsp:useBean id="surveyLandUseBean" scope="session" class="com.vsb.surveyLandUseBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="surveyLandUse" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="surveyLandUse" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>

    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="surveyLandUseBean" property="all" value="clear" />
    <jsp:setProperty name="surveyLandUseBean" property="*" />

		<%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="bv_land_use" value='<%=surveyLandUseBean.getLanduse()%>' />
    <if:IfTrue cond='<%= surveyLandUseBean.getLowdensity().equals("Yes") %>' >
      <jsp:setProperty name="recordBean" property="bv_lowdensity_flag" value="Y" />
    </if:IfTrue>
    <if:IfTrue cond='<%= ! surveyLandUseBean.getLowdensity().equals("Yes") %>' >
      <jsp:setProperty name="recordBean" property="bv_lowdensity_flag" value="N" />
    </if:IfTrue>
    <if:IfTrue cond='<%= surveyLandUseBean.getWard().equals("Yes") %>' >
      <jsp:setProperty name="recordBean" property="bv_ward_flag" value="Y" />
    </if:IfTrue>
    <if:IfTrue cond='<%= ! surveyLandUseBean.getWard().equals("Yes") %>' >
      <jsp:setProperty name="recordBean" property="bv_ward_flag" value="N" />
    </if:IfTrue>

  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="surveyLandUseBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="surveyTransectMeasure" >
  <jsp:setProperty name="surveyLandUseBean" property="action" value="" />
  <jsp:setProperty name="surveyLandUseBean" property="all" value="clear" />
  <jsp:setProperty name="surveyLandUseBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="surveyLandUse" >
  <%-- Next view --%>
	<if:IfTrue cond='<%= surveyLandUseBean.getAction().equals("Continue") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%=  surveyLandUseBean.getLanduse() == null || surveyLandUseBean.getLanduse().equals("") %>' >
      <jsp:setProperty name="surveyLandUseBean" property="error"
        value="Please choose a land use." />
      <jsp:forward page="surveyLandUseView.jsp" />
    </if:IfTrue>
    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">surveyLandUse</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">surveyGrading</sess:setAttribute>
    <c:redirect url="surveyGradingScript.jsp" />
  </if:IfTrue>

  <%-- Menu view --%>
  <if:IfTrue cond='<%= surveyLandUseBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">surveyLandUse</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>
  
  <%-- Menu view --%>
  <if:IfTrue cond='<%= surveyLandUseBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">surveyLandUse</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= surveyLandUseBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">surveyLandUse</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= surveyLandUseBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${surveyLandUseBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="surveyLandUseView.jsp" />
