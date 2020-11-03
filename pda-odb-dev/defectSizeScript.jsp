<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.defectSizeBean, com.vsb.helperBean, com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags"      prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags"   prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core"                 prefix="c" %>

<jsp:useBean id="defectSizeBean" scope="session" class="com.vsb.defectSizeBean" />
<jsp:useBean id="helperBean"     scope="session" class="com.vsb.helperBean" />
<jsp:useBean id="recordBean"     scope="session" class="com.vsb.recordBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="defectSize" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="defectSize" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="defectSizeBean" property="all" value="clear" />
    <jsp:setProperty name="defectSizeBean" property="*" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="defectSizeBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="addDefect" >
  <jsp:setProperty name="defectSizeBean" property="action" value="" />
  <jsp:setProperty name="defectSizeBean" property="all" value="clear" />
  <jsp:setProperty name="defectSizeBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="compSampDetails" >
  <jsp:setProperty name="defectSizeBean" property="action" value="" />
  <jsp:setProperty name="defectSizeBean" property="all" value="clear" />
  <jsp:setProperty name="defectSizeBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="defectSize" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <%-- Code to run --%>
    <%-- If user is updating the defect rather than adding it, then populate the screen fields --%>
    <if:IfTrue cond='<%= recordBean.getDefect_flag().equals("A") %>' >
      <% defectSizeBean.setX(recordBean.getDefect_view_x()); %>
      <% defectSizeBean.setY(recordBean.getDefect_view_y()); %>
    </if:IfTrue>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="defectSize" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= defectSizeBean.getAction().equals("Submit") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= defectSizeBean.getX().equals("") || defectSizeBean.getY().equals("") %>' >
      <jsp:setProperty name="defectSizeBean" property="error" value="X and Y must have numeric values" />
      <jsp:forward page="defectSizeView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= !helperBean.isDouble(defectSizeBean.getX()) %>' >
      <jsp:setProperty name="defectSizeBean" property="error" value="X must be a numeric value" />
      <jsp:forward page="defectSizeView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= !helperBean.isDouble(defectSizeBean.getY()) %>' >
      <jsp:setProperty name="defectSizeBean" property="error" value="Y must be a numeric value" />
      <jsp:forward page="defectSizeView.jsp" />
    </if:IfTrue>

    <%
      double sizeX  = (new Double(defectSizeBean.getX())).doubleValue();
      double sizeY  = (new Double(defectSizeBean.getY())).doubleValue();
    %>    
    <if:IfTrue cond='<%= sizeX < 0 || sizeY < 0 %>' >
      <jsp:setProperty name="defectSizeBean" property="error" value="X and Y must not be negative" />
      <jsp:forward page="defectSizeView.jsp" />
    </if:IfTrue>


    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">defectSize</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">defectDetails</sess:setAttribute>
    <c:redirect url="defectDetailsScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= defectSizeBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">defectSize</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= defectSizeBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">defectSize</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= defectSizeBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">defectSize</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= defectSizeBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${defectSizeBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="defectSizeView.jsp" />
