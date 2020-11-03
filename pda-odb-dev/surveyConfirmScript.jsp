<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.*" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="surveyConfirmBean" scope="session" class="com.vsb.surveyConfirmBean" />
<jsp:useBean id="surveyGradingBean" scope="session" class="com.vsb.surveyGradingBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="surveyConfirm" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="surveyConfirm" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>

    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="surveyConfirmBean" property="all" value="clear" />
    <jsp:setProperty name="surveyConfirmBean" property="*" />

		<%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="bv_additional_text" value='<%=surveyConfirmBean.getSurvey_text()%>' />

  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="surveyConfirmBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="surveyGrading" >
  <jsp:setProperty name="surveyConfirmBean" property="action" value="" />
  <jsp:setProperty name="surveyConfirmBean" property="all" value="clear" />
  <jsp:setProperty name="surveyConfirmBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm to be surveyGrading --%>
<sess:equalsAttribute name="input" match="surveyAddDefault" >
  <jsp:setProperty name="surveyConfirmBean" property="action" value="" />
  <jsp:setProperty name="surveyConfirmBean" property="all" value="clear" />
  <jsp:setProperty name="surveyConfirmBean" property="savedPreviousForm"
    value='surveyGrading' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>


<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="surveyConfirm" >
  <%-- Next view --%>
	<if:IfTrue cond='<%= surveyConfirmBean.getAction().equals("Submit") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>
    
    <%-- Valid entry --%>
    <%-- repopulate the recordBean complaint_no and comp_action_flag properties, as if any --%>
    <%-- defaults were created then they will have overwritten them. --%>
    <% recordBean.setComplaint_no(recordBean.getBv_complaint_no_save()); %>
    <% recordBean.setComp_action_flag(recordBean.getBv_comp_action_flag_save()); %>
    <%-- Add the survey --%>
    <sess:setAttribute name="form">addSurveyFunc</sess:setAttribute>
    <c:import url="addSurveyFunc.jsp" var="webPage" />
    <% helperBean.throwException((String)pageContext.getAttribute("webPage")); %>

    <%-- run the veolia link if required --%>
    <sess:setAttribute name="form">veoliaLinkFunc</sess:setAttribute>
    <c:import url="veoliaLinkFunc.jsp" var="webPage" />
    <% helperBean.throwException("veoliaLinkFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- Indicate which form we are coming from when we forward to another form  --%>
    <sess:setAttribute name="previousForm">surveyConfirm</sess:setAttribute>
    <%-- Indicate which form we are going to next  --%>
    <sess:setAttribute name="form">updateStatus</sess:setAttribute>
    <c:redirect url="updateStatusScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= surveyConfirmBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- non --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">surveyConfirm</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= surveyConfirmBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">surveyConfirm</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= surveyConfirmBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">surveyConfirm</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= surveyConfirmBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${surveyConfirmBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="surveyConfirmView.jsp" />
