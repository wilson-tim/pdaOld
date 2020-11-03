<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.flyCapDetailsBean, com.vsb.recordBean, com.vsb.helperBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="flyCapDetailsBean" scope="session" class="com.vsb.flyCapDetailsBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="flyCapDetails" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="flyCapDetails" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="flyCapDetailsBean" property="all" value="clear" />
    <jsp:setProperty name="flyCapDetailsBean" property="*" />

    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="land_type" value='<%= flyCapDetailsBean.getLand_type() %>' />
    <jsp:setProperty name="recordBean" property="dom_waste_type" value='<%= flyCapDetailsBean.getDom_waste_type() %>' />
    <jsp:setProperty name="recordBean" property="dom_waste_qty" value='<%= flyCapDetailsBean.getDom_waste_qty() %>' />
    <jsp:setProperty name="recordBean" property="load_ref" value='<%= flyCapDetailsBean.getLoad_size() %>' />
    <jsp:setProperty name="recordBean" property="load_qty" value='<%= flyCapDetailsBean.getLoad_qty().trim() %>' />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="flyCapDetailsBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="addFlyCapture" >
  <jsp:setProperty name="flyCapDetailsBean" property="action" value="" />
  <jsp:setProperty name="flyCapDetailsBean" property="all" value="clear" />
  <jsp:setProperty name="flyCapDetailsBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="faultLookup" >
  <jsp:setProperty name="flyCapDetailsBean" property="action" value="" />
  <jsp:setProperty name="flyCapDetailsBean" property="all" value="clear" />
  <jsp:setProperty name="flyCapDetailsBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="flyCapDetails" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <%-- Code to run --%>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="flyCapDetails" >
  <%-- Get the default quantity and the unit_cost for the selected load_ref --%>
  <% int default_qty = 1; %>
  <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
  <sql:statement id="stmt" conn="con">
    <sql:query>
      select default_qty, unit_cost
      from fly_loads
      where load_ref = '<%= recordBean.getLoad_ref() %>'
    </sql:query>
    <sql:resultSet id="rset">
       <sql:getColumn position="1" to="default_qty" />
       <% default_qty = Integer.parseInt(((String) pageContext.getAttribute("default_qty")).trim()); %>
       <sql:getColumn position="2" to="unit_cost" />
       <% recordBean.setLoad_unit_cost(((String) pageContext.getAttribute("unit_cost")).trim()); %>
    </sql:resultSet>
  </sql:statement>
  <sql:closeConnection conn="con"/>

  <%-- If the loadSizeBean's load_qty is blank then the recordBean's load_qty --%>
  <%-- must be the default_qty for the selected load_ref --%>
  <if:IfTrue cond='<%= flyCapDetailsBean.getLoad_qty() == null || flyCapDetailsBean.getLoad_qty().equals("") %>' >
    <% recordBean.setLoad_qty(String.valueOf(default_qty)); %>
  </if:IfTrue>

  <%-- Invalid entry --%>
  <%-- Only do validation if we are not trying to go back or jump --%>
  <if:IfTrue cond='<%= ! flyCapDetailsBean.getAction().equals("Back") && ! flyCapDetailsBean.getAction().equals("Inspect") && ! flyCapDetailsBean.getAction().equals("Sched/Comp") %>' >
    <%-- land type validation --%>
    <if:IfTrue cond='<%= flyCapDetailsBean.getLand_type() == null || flyCapDetailsBean.getLand_type().equals("") %>' >
      <jsp:setProperty name="flyCapDetailsBean" property="error" 
        value="Please choose a land type." />
      <jsp:forward page="flyCapDetailsView.jsp" />
    </if:IfTrue>
  
    <%-- load size validation --%>
    <if:IfTrue cond='<%= flyCapDetailsBean.getLoad_size() == null || flyCapDetailsBean.getLoad_size().equals("") %>' >
      <jsp:setProperty name="flyCapDetailsBean" property="error"
        value="Please choose a load size." />
      <jsp:forward page="flyCapDetailsView.jsp" />
    </if:IfTrue>
      
    <if:IfTrue cond='<%= flyCapDetailsBean.getLoad_qty() != null && ! (flyCapDetailsBean.getLoad_qty().equals("")) %>' >
      <if:IfTrue cond='<%= ! helperBean.isStringInt(flyCapDetailsBean.getLoad_qty()) %>' >
        <jsp:setProperty name="flyCapDetailsBean" property="error"
          value="The load size quantity must be an integer." />
        <jsp:forward page="flyCapDetailsView.jsp" />
      </if:IfTrue>
    </if:IfTrue>

    <if:IfTrue cond='<%= flyCapDetailsBean.getLoad_qty() != null && ! (flyCapDetailsBean.getLoad_qty().equals("")) %>' >
      <if:IfTrue cond='<%= default_qty == 1 && Integer.parseInt(flyCapDetailsBean.getLoad_qty()) > 1 %>' >
        <jsp:setProperty name="flyCapDetailsBean" property="error" 
          value="The load size quantity must equal one or be left blank to use the default quantity." />
        <jsp:forward page="flyCapDetailsView.jsp" />
      </if:IfTrue>
    </if:IfTrue>
      
    <if:IfTrue cond='<%= flyCapDetailsBean.getLoad_qty() != null && ! (flyCapDetailsBean.getLoad_qty().equals("")) %>' >
      <if:IfTrue cond='<%= default_qty > 1 && Integer.parseInt(flyCapDetailsBean.getLoad_qty()) == 1 %>' >
        <jsp:setProperty name="flyCapDetailsBean" property="error" 
          value="The load size quantity must be greater than one or left blank to use the default quantity." />
        <jsp:forward page="flyCapDetailsView.jsp" />
      </if:IfTrue>
    </if:IfTrue>
      
    <if:IfTrue cond='<%= flyCapDetailsBean.getLoad_qty() != null && ! (flyCapDetailsBean.getLoad_qty().equals("")) %>' >
      <if:IfTrue cond='<%= Integer.parseInt(flyCapDetailsBean.getLoad_qty()) < 1 %>' >
        <jsp:setProperty name="flyCapDetailsBean" property="error" 
          value="The quantity must be greater than zero or left blank to use the default quantity." />
        <jsp:forward page="flyCapDetailsView.jsp" />
      </if:IfTrue>
    </if:IfTrue>

    <%-- dom waste type validation --%>
    <if:IfTrue cond='<%= flyCapDetailsBean.getDom_waste_type() == null || flyCapDetailsBean.getDom_waste_type().equals("") %>' >
      <jsp:setProperty name="flyCapDetailsBean" property="error" 
        value="Please choose a waste type." />
      <jsp:forward page="flyCapDetailsView.jsp" />
    </if:IfTrue>
      
    <if:IfTrue cond='<%= flyCapDetailsBean.getDom_waste_qty() == null || flyCapDetailsBean.getDom_waste_qty().equals("") %>' >
      <jsp:setProperty name="flyCapDetailsBean" property="error" 
        value="Please supply a quantity for the waste type." />
      <jsp:forward page="flyCapDetailsView.jsp" />
    </if:IfTrue>
      
    <if:IfTrue cond='<%= ! helperBean.isStringInt(flyCapDetailsBean.getDom_waste_qty()) %>' >
      <jsp:setProperty name="flyCapDetailsBean" property="error"
        value="The waste type quantity must be an integer." />
      <jsp:forward page="flyCapDetailsView.jsp" />
    </if:IfTrue>
      
    <if:IfTrue cond='<%= Integer.parseInt(flyCapDetailsBean.getDom_waste_qty()) <= 0 %>' >
      <jsp:setProperty name="flyCapDetailsBean" property="error" 
        value="The waste type quantity must be greater than zero." />
      <jsp:forward page="flyCapDetailsView.jsp" />
    </if:IfTrue>
  </if:IfTrue>

  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= flyCapDetailsBean.getAction().equals("Waste") %>' >
    <%-- Invalid entry --%>
    <%-- Already done above --%>

    <%-- Valid entry --%>
    <% recordBean.setEnforce_flag("N"); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">flyCapDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">wasteTypes</sess:setAttribute>
    <c:redirect url="wasteTypesScript.jsp" />
  </if:IfTrue>

  <%-- Next view 2 --%>
  <if:IfTrue cond='<%= flyCapDetailsBean.getAction().equals("W/O") %>' >
    <%-- Invalid entry --%>
    <%-- Already done above --%>

    <%-- Valid entry --%>
    <% recordBean.setEnforce_flag("N"); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">flyCapDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">contract</sess:setAttribute>
    <c:redirect url="contractScript.jsp" />
  </if:IfTrue>

  <%-- Next view 3 --%>
  <if:IfTrue cond='<%= flyCapDetailsBean.getAction().equals("Enf") %>' >
    <%-- Invalid entry --%>
    <%-- Already done above --%>
    
    <%-- Valid entry --%>
    <% recordBean.setEnforce_flag("Y"); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">flyCapDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">law</sess:setAttribute>
    <c:redirect url="lawScript.jsp" />
  </if:IfTrue>

  <%-- Next view 4 --%>
  <if:IfTrue cond='<%= flyCapDetailsBean.getAction().equals("Text") %>' >
    <%-- Invalid entry --%>
    <%-- Already done above --%>
    
    <%-- Valid entry --%>
    <% recordBean.setEnforce_flag("N"); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">flyCapDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">text</sess:setAttribute>
    <c:redirect url="textScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= flyCapDetailsBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">flyCapDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= flyCapDetailsBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">flyCapDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= flyCapDetailsBean.getAction().equals("Back") %>' >
    <% recordBean.setEnforce_flag("N"); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">flyCapDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= flyCapDetailsBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${flyCapDetailsBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="flyCapDetailsView.jsp" />
