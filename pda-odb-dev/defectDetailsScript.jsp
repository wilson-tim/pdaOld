<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.defectDetailsBean, com.vsb.defectSizeBean" %>
<%@ page import="java.text.DecimalFormat, com.vsb.helperBean, com.vsb.recordBean" %>
<%@ page import="com.vsb.compSampDetailsBean, com.vsb.textBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags"      prefix="sql"  %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req"  %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags"   prefix="if"   %>
<%@ taglib uri="http://java.sun.com/jstl/core"                 prefix="c"    %>

<jsp:useBean id="defectDetailsBean"   scope="session" class="com.vsb.defectDetailsBean" />
<jsp:useBean id="defectSizeBean"      scope="session" class="com.vsb.defectSizeBean" />
<jsp:useBean id="compSampDetailsBean" scope="session" class="com.vsb.compSampDetailsBean" />
<jsp:useBean id="helperBean"          scope="session" class="com.vsb.helperBean" />
<jsp:useBean id="recordBean"          scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="textBean"            scope="session" class="com.vsb.textBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="defectDetails" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="defectDetails" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="defectDetailsBean" property="all" value="clear" />
    <jsp:setProperty name="defectDetailsBean" property="*" />

    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="defect_priority" param="priority" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="defectDetailsBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="defectSize" >
  <jsp:setProperty name="defectDetailsBean" property="action" value="" />
  <jsp:setProperty name="defectDetailsBean" property="all" value="clear" />
  <jsp:setProperty name="defectDetailsBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="defectDetails" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <%-- Code to run --%>
    <%-- Automatically calculate and set the area and linear values from the defectSizeBean X and Y values --%>
    <% DecimalFormat df = new DecimalFormat("0.00");     %>
    <% double x = new Double( defectSizeBean.getX() ).doubleValue();   %>
    <% double y = new Double( defectSizeBean.getY() ).doubleValue();   %>
    <% double linear = (x*2) + (y*2);                    %>
    <% double area   = x*y;                              %>
    <% defectDetailsBean.setLinear( df.format(linear) ); %>
    <% defectDetailsBean.setArea( df.format(area) );     %>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="defectDetails" >
  <%-- Invalid entry --%>
  <if:IfTrue cond='<%= defectDetailsBean.getLinear().equals("") || defectDetailsBean.getArea().equals("") %>' >
    <jsp:setProperty name="defectDetailsBean" property="error" value="Linear and Area must have a numeric value" />
    <jsp:forward page="defectDetailsView.jsp" />
  </if:IfTrue>

  <if:IfTrue cond='<%= !helperBean.isDouble( defectDetailsBean.getLinear() ) %>' >
    <jsp:setProperty name="defectDetailsBean" property="error" value="Linear must be a numeric value" />
    <jsp:forward page="defectDetailsView.jsp" />
  </if:IfTrue>

  <if:IfTrue cond='<%= !helperBean.isDouble( defectDetailsBean.getArea() ) %>' >
    <jsp:setProperty name="defectDetailsBean" property="error" value="Area must be a numeric value" />
    <jsp:forward page="defectDetailsView.jsp" />
  </if:IfTrue>

  <if:IfTrue cond='<%= defectDetailsBean.getPriority().equals("") %>' >
    <jsp:setProperty name="defectDetailsBean" property="error" value="Please enter priority value" />
    <jsp:forward page="defectDetailsView.jsp" />
  </if:IfTrue>

  <if:IfTrue cond='<%= defectDetailsBean.getArea().length() > 10 %>' >
    <jsp:setProperty name="defectDetailsBean" property="error" value="Area value exceeds maximum allowed limit" />
    <jsp:forward page="defectDetailsView.jsp" />
  </if:IfTrue>

  <if:IfTrue cond='<%= defectDetailsBean.getLinear().length() > 10 %>' >
    <jsp:setProperty name="defectDetailsBean" property="error" value="Linear value exceeds maximum allowed limit" />
    <jsp:forward page="defectDetailsView.jsp" />
  </if:IfTrue>    

  <%-- get rid of newline and carriage return chars --%>
  <%
    String tempTextIn = defectDetailsBean.getText();
    tempTextIn = tempTextIn.replace('\n',' ');
    tempTextIn = tempTextIn.replace('\r',' ');      
    defectDetailsBean.setText(tempTextIn);
  %>
    
  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= defectDetailsBean.getAction().equals("W/O") %>' >
    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">defectDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">contract</sess:setAttribute>
    <c:redirect url="contractScript.jsp" />
  </if:IfTrue>

  <%-- Next view 2 --%>
  <if:IfTrue cond='<%= defectDetailsBean.getAction().equals("Finish") %>' >
    <%-- Valid entry --%>
    <%-- update defect --%>
    <sess:setAttribute name="form">updateDefectFunc</sess:setAttribute>
    <c:import url="updateDefectFunc.jsp" var="webPage" />
    <% helperBean.throwException("updateDefectFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- Indicate that we are updateing the text only. --%>
    <% recordBean.setUpdate_text("Y"); %>

    <%-- add complaint text --%>
    <sess:setAttribute name="form">addTextFunc</sess:setAttribute>
    <c:import url="addTextFunc.jsp" var="webPage" />
    <% helperBean.throwException("addTextFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- run the veolia link if required --%>
    <sess:setAttribute name="form">veoliaLinkFunc</sess:setAttribute>
    <c:import url="veoliaLinkFunc.jsp" var="webPage" />
    <% helperBean.throwException("veoliaLinkFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">defectDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">updateStatus</sess:setAttribute>
    <c:redirect url="updateStatusScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= defectDetailsBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">defectDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= defectDetailsBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">defectDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= defectDetailsBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">defectDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= defectDetailsBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${defectDetailsBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="defectDetailsView.jsp" />
