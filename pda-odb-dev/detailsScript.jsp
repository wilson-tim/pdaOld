<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.detailsBean, com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>

<jsp:useBean id="detailsBean" scope="session" class="com.vsb.detailsBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="details" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="details" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="detailsBean" property="all" value="clear" />
    <jsp:setProperty name="detailsBean" property="*" />
    
    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="model_desc" param="model_desc" />
    <jsp:setProperty name="recordBean" property="car_id" param="car_id" />
    <jsp:setProperty name="recordBean" property="colour_desc" param="colour_desc" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="detailsBean" property="error" value="" />

<%-- clear form fields if coming from previous form --%>
<sess:equalsAttribute name="input" match="make" >
  <jsp:setProperty name="detailsBean" property="action" value="" />
  <jsp:setProperty name="detailsBean" property="all" value="clear" />
  <jsp:setProperty name="detailsBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="details" >
  <%-- get rid of all spaces in the car_id --%>
  <%-- make part of a helper object eventually --%>
  <%
    String nextChar = "";
    String outputString = "";
    int textLength = recordBean.getCar_id().length();
    if (textLength > 0) {
      int i=0;
      int j=1;
      do {
        nextChar = recordBean.getCar_id().substring(i,j);
        if (!nextChar.equals(" ")) {
          outputString = outputString + nextChar;
        }
        i++;
        j++;
      } while (i < textLength);
    }
    recordBean.setCar_id(outputString);
  %>

  <%-- Next view --%>
  <if:IfTrue cond='<%= detailsBean.getAction().equals("Add Text") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= detailsBean.getCar_id() == null || detailsBean.getCar_id().trim().equals("") %>' >
      <jsp:setProperty name="detailsBean" property="error" value="Please enter a Car ID or <br/>'NO PLATES'." />
      <jsp:forward page="detailsView.jsp" />
    </if:IfTrue>
    
    <if:IfTrue cond='<%= detailsBean.getModel_desc() == null || detailsBean.getModel_desc().trim().equals("") %>' >
      <jsp:setProperty name="detailsBean" property="error" value="Please choose a model." />
      <jsp:forward page="detailsView.jsp" />
    </if:IfTrue>
    
    <if:IfTrue cond='<%= detailsBean.getColour_desc() == null || detailsBean.getColour_desc().trim().equals("") %>' >
      <jsp:setProperty name="detailsBean" property="error" value="Please choose a colour." />
      <jsp:forward page="detailsView.jsp" />
    </if:IfTrue>
    
    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">details</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">text</sess:setAttribute>
    <c:redirect url="textScript.jsp" />
  </if:IfTrue>
 
  <%-- Menu view --%>
  <if:IfTrue cond='<%= detailsBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">details</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>
 
  <%-- Previous view --%>
  <if:IfTrue cond='<%= detailsBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">details</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= detailsBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${detailsBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="detailsView.jsp" />
