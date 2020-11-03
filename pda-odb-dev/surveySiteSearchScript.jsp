<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.surveySiteSearchBean" %>
<%@ page import="com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="surveySiteSearchBean" scope="session" class="com.vsb.surveySiteSearchBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="surveySiteSearch" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="surveySiteSearch" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>

    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="surveySiteSearchBean" property="all" value="clear" />
    <jsp:setProperty name="surveySiteSearchBean" property="*" />

    <%-- Clear the previous record --%>
    <jsp:setProperty name="recordBean" property="all" value="clear" />

  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="surveySiteSearchBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="mainMenu" >
  <jsp:setProperty name="surveySiteSearchBean" property="action" value="" />
  <jsp:setProperty name="surveySiteSearchBean" property="all" value="clear" />
  <jsp:setProperty name="surveySiteSearchBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>
<%-- If the user has used '*' in the input then make sure they see them as '*'s --%>
<%-- and not as '%'s symbols because of the change to '%' for matching using --%>
<%-- 'like' in the sql in locLookup, see later in the code. --%>
<%
  String tempText1 = "";
  tempText1 = surveySiteSearchBean.getSurveyPostCode();
  surveySiteSearchBean.setSurveyPostCode(tempText1.replace('%','*'));
  tempText1 = surveySiteSearchBean.getSurveyLocation();
  surveySiteSearchBean.setSurveyLocation(tempText1.replace('%','*'));
%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="surveySiteSearch" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= surveySiteSearchBean.getAction().equals("Search") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue
      cond='<%= (surveySiteSearchBean.getSurveyLocation() == null || surveySiteSearchBean.getSurveyLocation().equals("")) &&
        (surveySiteSearchBean.getSurveyPostCode() == null || surveySiteSearchBean.getSurveyPostCode().equals("")) %>' >
      <jsp:setProperty name="surveySiteSearchBean" property="error"
        value="Please supply postcode/street name search criteria." />
      <jsp:forward page="surveySiteSearchView.jsp" />
    </if:IfTrue>

    <if:IfTrue
      cond='<%= surveySiteSearchBean.getSurveyLocation() != null && !(surveySiteSearchBean.getSurveyLocation().equals("")) &&
        surveySiteSearchBean.getSurveyPostCode() != null && !(surveySiteSearchBean.getSurveyPostCode().equals("")) %>' >
      <jsp:setProperty name="surveySiteSearchBean" property="error"
        value="Please supply only postcode OR street name search criteria, NOT both." />
      <jsp:forward page="surveySiteSearchView.jsp" />
    </if:IfTrue>
    <%-- If the user has used '*' in the input then make sure they see them as '*'s --%>
    <%-- and not as '%'s symbols because of the change to '%' for matching using --%>
    <%-- 'like' in the sql in locLookup, see later in the code. --%>
    <%
      tempText1 = surveySiteSearchBean.getSurveyPostCode();
      surveySiteSearchBean.setSurveyPostCode(tempText1.replace('*','%'));
      tempText1 = surveySiteSearchBean.getSurveyLocation();
      surveySiteSearchBean.setSurveyLocation(tempText1.replace('*','%'));
    %>

    <%-- Indicate which form we are coming from when we forward to another form    --%>
    <sess:setAttribute name="previousForm">surveySiteSearch</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">surveySiteLookup</sess:setAttribute>
    <c:redirect url="surveySiteLookupScript.jsp" />
  </if:IfTrue>

  <%-- Menu view --%>
  <if:IfTrue cond='<%= surveySiteSearchBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">surveySiteSearch</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view --%>
  <if:IfTrue cond='<%= surveySiteSearchBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">surveySiteSearch</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= surveySiteSearchBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">surveySiteSearch</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= surveySiteSearchBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${surveySiteSearchBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="surveySiteSearchView.jsp" />
