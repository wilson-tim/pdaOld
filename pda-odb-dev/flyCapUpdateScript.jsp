<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.flyCapUpdateBean, com.vsb.recordBean, com.vsb.helperBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="flyCapUpdateBean" scope="session" class="com.vsb.flyCapUpdateBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="flyCapUpdate" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="flyCapUpdate" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="flyCapUpdateBean" property="all" value="clear" />
    <jsp:setProperty name="flyCapUpdateBean" property="*" />

    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="land_type" value='<%= flyCapUpdateBean.getLand_type() %>' />
    <jsp:setProperty name="recordBean" property="dom_waste_type" value='<%= flyCapUpdateBean.getDom_waste_type() %>' />
    <jsp:setProperty name="recordBean" property="dom_waste_qty" value='<%= flyCapUpdateBean.getDom_waste_qty() %>' />
    <jsp:setProperty name="recordBean" property="load_ref" value='<%= flyCapUpdateBean.getLoad_size() %>' />
    <jsp:setProperty name="recordBean" property="load_qty" value='<%= flyCapUpdateBean.getLoad_qty().trim() %>' />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="flyCapUpdateBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="compSampDetails" >
  <jsp:setProperty name="flyCapUpdateBean" property="action" value="" />
  <jsp:setProperty name="flyCapUpdateBean" property="all" value="clear" />
  <jsp:setProperty name="flyCapUpdateBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="flyCapUpdate" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <%-- Code to run --%>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con">
      <sql:query>
        select landtype_ref, dominant_waste_ref, dominant_waste_qty, load_ref, load_qty
        from comp_flycap
        where complaint_no = '<%= recordBean.getComplaint_no() %>'
      </sql:query>
      <sql:resultSet id="rset">
         <sql:getColumn position="1" to="landtype_ref" />
         <sql:wasNotNull>
           <% flyCapUpdateBean.setLand_type(((String) pageContext.getAttribute("landtype_ref")).trim()); %>
         </sql:wasNotNull>
         <sql:getColumn position="2" to="dominant_waste_ref" />
         <sql:wasNotNull>
           <% flyCapUpdateBean.setDom_waste_type(((String) pageContext.getAttribute("dominant_waste_ref")).trim()); %>
         </sql:wasNotNull>
         <sql:getColumn position="3" to="dominant_waste_qty" />
         <sql:wasNotNull>
           <% flyCapUpdateBean.setDom_waste_qty(((String) pageContext.getAttribute("dominant_waste_qty")).trim()); %>
         </sql:wasNotNull>
         <sql:getColumn position="4" to="load_ref" />
         <sql:wasNotNull>
           <% flyCapUpdateBean.setLoad_size(((String) pageContext.getAttribute("load_ref")).trim()); %>
         </sql:wasNotNull>
         <sql:getColumn position="5" to="load_qty" />
         <sql:wasNotNull>
           <% flyCapUpdateBean.setLoad_qty(((String) pageContext.getAttribute("load_qty")).trim()); %>
         </sql:wasNotNull>
      </sql:resultSet>
    </sql:statement>
    <sql:closeConnection conn="con"/>

  </if:IfTrue>
</sess:equalsAttribute>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="flyCapUpdate" >
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
  <if:IfTrue cond='<%= flyCapUpdateBean.getLoad_qty() == null || flyCapUpdateBean.getLoad_qty().equals("") %>' >
    <% recordBean.setLoad_qty(String.valueOf(default_qty)); %>
  </if:IfTrue>

  <%-- check if any data has been entered --%>
  <% boolean dataEntered = false; %> 
  <if:IfTrue cond='<%= flyCapUpdateBean.getLand_type() != null && ! flyCapUpdateBean.getLand_type().equals("") %>' >
    <% dataEntered = true; %> 
  </if:IfTrue>
  <if:IfTrue cond='<%= flyCapUpdateBean.getLoad_size() != null && ! flyCapUpdateBean.getLoad_size().equals("") %>' >
    <% dataEntered = true; %> 
  </if:IfTrue>
  <if:IfTrue cond='<%= flyCapUpdateBean.getLoad_qty() != null && ! flyCapUpdateBean.getLoad_qty().equals("") %>' >
    <% dataEntered = true; %> 
  </if:IfTrue>
  <if:IfTrue cond='<%= flyCapUpdateBean.getDom_waste_type() != null && ! flyCapUpdateBean.getDom_waste_type().equals("") %>' >
    <% dataEntered = true; %> 
  </if:IfTrue>
  <if:IfTrue cond='<%= flyCapUpdateBean.getDom_waste_qty() != null && ! flyCapUpdateBean.getDom_waste_qty().equals("") %>' >
    <% dataEntered = true; %> 
  </if:IfTrue>

  <%-- Invalid entry --%>
  <%-- Do validation if there is any data entered, but if no data is entered then --%>
  <%-- only do validation if we are not trying to go back, works order, default or jump --%>
  <if:IfTrue cond='<%= ! flyCapUpdateBean.getAction().equals("Back") && ! flyCapUpdateBean.getAction().equals("Inspect") && ! flyCapUpdateBean.getAction().equals("Sched/Comp") %>' >
    <if:IfTrue cond='<%= (! flyCapUpdateBean.getAction().equals("W/O") && ! flyCapUpdateBean.getAction().equals(application.getInitParameter("def_name_verb")) && dataEntered == false) || (dataEntered == true) %>' >
      <%-- land type validation --%>
      <if:IfTrue cond='<%= flyCapUpdateBean.getLand_type() == null || flyCapUpdateBean.getLand_type().equals("") %>' >
        <jsp:setProperty name="flyCapUpdateBean" property="error" 
          value="Please choose a land type." />
        <jsp:forward page="flyCapUpdateView.jsp" />
      </if:IfTrue>
    
      <%-- load size validation --%>
      <if:IfTrue cond='<%= flyCapUpdateBean.getLoad_size() == null || flyCapUpdateBean.getLoad_size().equals("") %>' >
        <jsp:setProperty name="flyCapUpdateBean" property="error"
          value="Please choose a load size." />
        <jsp:forward page="flyCapUpdateView.jsp" />
      </if:IfTrue>
        
      <if:IfTrue cond='<%= flyCapUpdateBean.getLoad_qty() != null && ! (flyCapUpdateBean.getLoad_qty().equals("")) %>' >
        <if:IfTrue cond='<%= ! helperBean.isStringInt(flyCapUpdateBean.getLoad_qty()) %>' >
          <jsp:setProperty name="flyCapUpdateBean" property="error"
            value="The load size quantity must be an integer." />
          <jsp:forward page="flyCapUpdateView.jsp" />
        </if:IfTrue>
      </if:IfTrue>
  
      <if:IfTrue cond='<%= flyCapUpdateBean.getLoad_qty() != null && ! (flyCapUpdateBean.getLoad_qty().equals("")) %>' >
        <if:IfTrue cond='<%= default_qty == 1 && Integer.parseInt(flyCapUpdateBean.getLoad_qty()) > 1 %>' >
          <jsp:setProperty name="flyCapUpdateBean" property="error" 
            value="The load size quantity must equal one or be left blank to use the default quantity." />
          <jsp:forward page="flyCapUpdateView.jsp" />
        </if:IfTrue>
      </if:IfTrue>
        
      <if:IfTrue cond='<%= flyCapUpdateBean.getLoad_qty() != null && ! (flyCapUpdateBean.getLoad_qty().equals("")) %>' >
        <if:IfTrue cond='<%= default_qty > 1 && Integer.parseInt(flyCapUpdateBean.getLoad_qty()) == 1 %>' >
          <jsp:setProperty name="flyCapUpdateBean" property="error" 
            value="The load size quantity must be greater than one or left blank to use the default quantity." />
          <jsp:forward page="flyCapUpdateView.jsp" />
        </if:IfTrue>
      </if:IfTrue>
        
      <if:IfTrue cond='<%= flyCapUpdateBean.getLoad_qty() != null && ! (flyCapUpdateBean.getLoad_qty().equals("")) %>' >
        <if:IfTrue cond='<%= Integer.parseInt(flyCapUpdateBean.getLoad_qty()) < 1 %>' >
          <jsp:setProperty name="flyCapUpdateBean" property="error" 
            value="The quantity must be greater than zero or left blank to use the default quantity." />
          <jsp:forward page="flyCapUpdateView.jsp" />
        </if:IfTrue>
      </if:IfTrue>
  
      <%-- dom waste type validation --%>
      <if:IfTrue cond='<%= flyCapUpdateBean.getDom_waste_type() == null || flyCapUpdateBean.getDom_waste_type().equals("") %>' >
        <jsp:setProperty name="flyCapUpdateBean" property="error" 
          value="Please choose a waste type." />
        <jsp:forward page="flyCapUpdateView.jsp" />
      </if:IfTrue>
        
      <if:IfTrue cond='<%= flyCapUpdateBean.getDom_waste_qty() == null || flyCapUpdateBean.getDom_waste_qty().equals("") %>' >
        <jsp:setProperty name="flyCapUpdateBean" property="error" 
          value="Please supply a quantity for the waste type." />
        <jsp:forward page="flyCapUpdateView.jsp" />
      </if:IfTrue>
        
      <if:IfTrue cond='<%= ! helperBean.isStringInt(flyCapUpdateBean.getDom_waste_qty()) %>' >
        <jsp:setProperty name="flyCapUpdateBean" property="error"
          value="The waste type quantity must be an integer." />
        <jsp:forward page="flyCapUpdateView.jsp" />
      </if:IfTrue>
        
      <if:IfTrue cond='<%= Integer.parseInt(flyCapUpdateBean.getDom_waste_qty()) <= 0 %>' >
        <jsp:setProperty name="flyCapUpdateBean" property="error" 
          value="The waste type quantity must be greater than zero." />
        <jsp:forward page="flyCapUpdateView.jsp" />
      </if:IfTrue>
    </if:IfTrue>
  </if:IfTrue>

  <if:IfTrue cond='<%= flyCapUpdateBean.getAction().equals("W/O") %>' >
    <%-- Invalid entry --%>
    <%-- Already done above --%>

    <%-- Indicate what triggered the user action i.e. not triggered by the 'Action' button --%>
    <% recordBean.setUser_triggered("flyCapUpdate"); %>    
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">flyCapUpdate</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">contract</sess:setAttribute>
    <c:redirect url="contractScript.jsp" />
  </if:IfTrue>

  <if:IfTrue cond='<%= flyCapUpdateBean.getAction().equals(application.getInitParameter("def_name_verb")) %>' >
    <%-- Invalid entry --%>
    <%-- Already done above --%>

    <%-- Indicate what triggered the user action i.e. not triggered by the 'Action' button --%>
    <% recordBean.setUser_triggered("flyCapUpdate"); %>    
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">flyCapUpdate</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">streetLength</sess:setAttribute>
    <c:redirect url="streetLengthScript.jsp" />
  </if:IfTrue>

  <if:IfTrue cond='<%= flyCapUpdateBean.getAction().equals("Finish") %>' >
    <%-- Invalid entry --%>
    <%-- Already done above --%>
    
    <%-- Valid entry --%>
    <%-- Set the action flag to be 'H' for a Hold enquiry or 'N' for no further action --%>
    <app:equalsInitParameter name="fly_cap_h_or_n" match="H">
      <% recordBean.setAction_flag("H"); %>
    </app:equalsInitParameter>
    <app:equalsInitParameter name="fly_cap_h_or_n" match="N">
      <% recordBean.setAction_flag("N"); %>
    </app:equalsInitParameter>

    <%-- add/update Fly Capture Details details --%>
    <sess:setAttribute name="form">updateFlyCapFunc</sess:setAttribute>
    <c:import url="updateFlyCapFunc.jsp" var="webPage" />
    <% helperBean.throwException("updateFlyCapFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- add complaint text --%>
    <sess:setAttribute name="form">addTextFunc</sess:setAttribute>
    <c:import url="addTextFunc.jsp" var="webPage" />
    <% helperBean.throwException("addTextFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- run the veolia link if required --%>
    <sess:setAttribute name="form">veoliaLinkFunc</sess:setAttribute>
    <c:import url="veoliaLinkFunc.jsp" var="webPage" />
    <% helperBean.throwException("veoliaLinkFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">flyCapUpdate</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">updateStatus</sess:setAttribute>
    <c:redirect url="updateStatusScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= flyCapUpdateBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">flyCapUpdate</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= flyCapUpdateBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">flyCapUpdate</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= flyCapUpdateBean.getAction().equals("Back") %>' >
    <% recordBean.setUser_triggered(""); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">flyCapUpdate</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= flyCapUpdateBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${flyCapUpdateBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="flyCapUpdateView.jsp" />
