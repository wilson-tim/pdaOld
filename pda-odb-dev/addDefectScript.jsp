<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.addDefectBean, com.vsb.recordBean, com.vsb.helperBean, java.util.ArrayList" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags"          prefix="sql"  %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app"  %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0"     prefix="req"  %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0"     prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags"       prefix="if"   %>
<%@ taglib uri="http://java.sun.com/jstl/core"                     prefix="c"    %>

<jsp:useBean id="addDefectBean" scope="session" class="com.vsb.addDefectBean" />
<jsp:useBean id="recordBean"    scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean"    scope="session" class="com.vsb.helperBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="addDefect" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="addDefect" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="addDefectBean" property="all" value="clear" />
    <jsp:setProperty name="addDefectBean" property="*" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="addDefectBean" property="error" value="" />

<%-- Initialise the forward_direction variable, used in the skip section --%>
<% String forward_direction = "N"; %>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="faultLookup" >
  <jsp:setProperty name="addDefectBean" property="action" value="" />
  <jsp:setProperty name="addDefectBean" property="all" value="clear" />
  <jsp:setProperty name="addDefectBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <% forward_direction = "Y"; %>
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Do first time through SCRIPT --%>
<%-- We need to check if the selected fault code is allowed to have a --%>
<%-- defect attached to it before we show the user the add defect screen --%>
<%-- We also need to check if the item is a statutory item, as we will --%>
<%-- skip the view straight to the defectSize form if it is and has a --%>
<%-- valid defect fault code. --%>
<% boolean isValidFaultCode = false; %>
<sess:equalsAttribute name="input" match="addDefect" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <%-- Code to run --%>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con">
      <% String defect_fault_codes_string = ""; %>
      <%-- Get the fault codes that are allowed to have defects applied to them --%>
      <sql:query>
        SELECT c_field
          FROM keys
         WHERE keyname = 'MS_FAULT_CODES'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="c_field" />
        <sql:wasNotNull>
          <% defect_fault_codes_string = ((String)pageContext.getAttribute("c_field")).trim(); %>
        </sql:wasNotNull>
      </sql:resultSet>
      <%-- Create an arraylist of individual fault codes from the comma separated list --%>
      <% ArrayList defect_fault_codes = helperBean.splitCommaList( defect_fault_codes_string ); %>
      <if:IfTrue cond='<%= !defect_fault_codes.contains( recordBean.getFault_code() ) %>'>
        <%-- Set the valid fault code field to false as the current fault code is not in the list --%>
        <% addDefectBean.setIsValidFaultCode( false ); %>
      </if:IfTrue>
    </sql:statement>
    <sql:closeConnection conn="con"/>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Skip View Section --%>
<%-- Don't skip if coming from the view --%>
<sess:equalsAttribute name="input" match="addDefect" value="false">
  <%-- Only allow skip if allowed i.e. use_defect does not equal "Y" and --%>
  <app:equalsInitParameter name="use_defect" match="Y" value="false">
    <%-- skip to the next page, by faking it so that it appears the user --%>
    <%-- has just selected "No" and clicked the next page button. --%>
    <%-- Do backwards skip first, as forward skip sets the 'input' session variable --%>
    <if:IfTrue cond='<%= forward_direction.equals("N") %>' >
      <if:IfTrue cond='<%= !recordBean.getLast_action_flag().equals("") %>'>
        <% recordBean.setAction_flag( recordBean.getLast_action_flag() ); %>
        <%-- Clear the last action flag --%>
        <% recordBean.setLast_action_flag(""); %>
      </if:IfTrue>
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">addDefect</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form"><%= addDefectBean.getSavedPreviousForm() %></sess:setAttribute>
      <c:redirect url="${addDefectBean.savedPreviousForm}Script.jsp" />
    </if:IfTrue>
    <%-- Do forwards skip --%>
    <if:IfTrue cond='<%= forward_direction.equals("Y") %>' >
      <%-- This section mimics the 'input' section at the top of the script --%>
      <%-- manually imitating a user interaction with the view, but without showing the view --%>

      <%-- save the fault code status --%>
      <% isValidFaultCode = addDefectBean.getIsValidFaultCode(); %>

      <%-- Indicate which form we are in/just-come-from --%>
      <sess:setAttribute name="input">addDefect</sess:setAttribute>
  
      <%-- Setup the bean with the forms data manually --%>
      <jsp:setProperty name="addDefectBean" property="all" value="clear" />
      <jsp:setProperty name="addDefectBean" property="action" value="Continue" />
      <jsp:setProperty name="addDefectBean" property="confirm" value="No" />
  
      <% addDefectBean.setIsValidFaultCode(isValidFaultCode); %>

      <% recordBean.setDefect_flag("N"); %>
    </if:IfTrue>
  </app:equalsInitParameter>
</sess:equalsAttribute>

<%-- Skip View Section If the fault code is not valid --%>
<if:IfTrue cond='<%= !addDefectBean.getIsValidFaultCode() %>'>
  <%-- skip to the next page, by faking it so that it appears the user --%>
  <%-- has just selected "No" and clicked the next page button. --%>
  <%-- Do backwards skip first, as forward skip sets the 'input' session variable --%>
  <if:IfTrue cond='<%= forward_direction.equals("N") %>' >
    <if:IfTrue cond='<%= !recordBean.getLast_action_flag().equals("") %>'>
      <% recordBean.setAction_flag( recordBean.getLast_action_flag() ); %>
      <%-- Clear the last action flag --%>
      <% recordBean.setLast_action_flag(""); %>
    </if:IfTrue>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">addDefect</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= addDefectBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${addDefectBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
  <%-- Do forwards skip --%>
  <if:IfTrue cond='<%= forward_direction.equals("Y") %>' >
    <%-- This section mimics the 'input' section at the top of the script --%>
    <%-- manually imitating a user interaction with the view, but without showing the view --%>

    <%-- save the fault code status --%>
    <% isValidFaultCode = addDefectBean.getIsValidFaultCode(); %>

    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input">addDefect</sess:setAttribute>

    <%-- Setup the bean with the forms data manually --%>
    <jsp:setProperty name="addDefectBean" property="all" value="clear" />
    <jsp:setProperty name="addDefectBean" property="action" value="Continue" />
    <jsp:setProperty name="addDefectBean" property="confirm" value="No" />

    <% addDefectBean.setIsValidFaultCode(isValidFaultCode); %>

    <% recordBean.setDefect_flag("N"); %>
  </if:IfTrue>
</if:IfTrue>

<%-- Skip View Section If the fault code is valid and this is a statutory item --%>
<if:IfTrue cond='<%= addDefectBean.getIsValidFaultCode() && recordBean.getInsp_item_flag().equals("Y") %>'>
  <%-- skip to the next page, by faking it so that it appears the user --%>
  <%-- has just selected "Yes" and clicked the next page button. --%>
  <%-- Do backwards skip first, as forward skip sets the 'input' session variable --%>
  <if:IfTrue cond='<%= forward_direction.equals("N") %>' >
    <if:IfTrue cond='<%= !recordBean.getLast_action_flag().equals("") %>'>
      <% recordBean.setAction_flag( recordBean.getLast_action_flag() ); %>
      <%-- Clear the last action flag --%>
      <% recordBean.setLast_action_flag(""); %>
    </if:IfTrue>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">addDefect</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= addDefectBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${addDefectBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
  <%-- Do forwards skip --%>
  <if:IfTrue cond='<%= forward_direction.equals("Y") %>' >
    <%-- This section mimics the 'input' section at the top of the script --%>
    <%-- manually imitating a user interaction with the view, but without showing the view --%>

    <%-- save the fault code status --%>
    <% isValidFaultCode = addDefectBean.getIsValidFaultCode(); %>

    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input">addDefect</sess:setAttribute>

    <%-- Setup the bean with the forms data manually --%>
    <jsp:setProperty name="addDefectBean" property="all" value="clear" />
    <jsp:setProperty name="addDefectBean" property="action" value="Continue" />
    <jsp:setProperty name="addDefectBean" property="confirm" value="Yes" />

    <% addDefectBean.setIsValidFaultCode(isValidFaultCode); %>

    <% recordBean.setDefect_flag("N"); %>
  </if:IfTrue>
</if:IfTrue>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="addDefect" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= addDefectBean.getAction().equals("Continue") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>
    
    <%-- Valid entry --%>
    <if:IfTrue cond='<%= addDefectBean.getConfirm().equals("Yes") %>' >
      <% recordBean.setDefect_flag("Y"); %>
      <%-- Store the last action_flag incase the user changes their mind or has made a mistake --%>
      <% recordBean.setLast_action_flag( recordBean.getAction_flag() ); %>
      <%-- Set the action flag to be 'W' for a Works Order --%>
      <% recordBean.setAction_flag("W"); %>
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">addDefect</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">defectSize</sess:setAttribute>
      <c:redirect url="defectSizeScript.jsp" />
    </if:IfTrue>
    
    <if:IfTrue cond='<%= addDefectBean.getConfirm().equals("No") %>' >
      <% recordBean.setDefect_flag("N"); %>
      <%-- Check to see if the last action flag was set, and if so revert back to that value --%>
      <if:IfTrue cond='<%= !recordBean.getLast_action_flag().equals("") %>'>
        <% recordBean.setAction_flag( recordBean.getLast_action_flag() ); %>
        <%-- Clear the last action flag --%>
        <% recordBean.setLast_action_flag(""); %>
      </if:IfTrue>
      <%-- if the action was works order but user NOT adding a defect then set action to hold --%>
      <if:IfTrue cond='<%= recordBean.getAction_flag().equals("W") %>'>
        <%-- If the fault code WAS NOT a valid defect fault code allow the user to add a works order --%>
        <if:IfTrue cond='<%= !addDefectBean.getIsValidFaultCode() %>'>
          <% recordBean.setAction_flag("W"); %>
        </if:IfTrue>
        <%-- If the fault code WAS a valid defect fault code do not allow the user to add a works order --%>
        <if:IfTrue cond='<%= addDefectBean.getIsValidFaultCode() %>'>
          <% recordBean.setAction_flag("H"); %>
        </if:IfTrue>
      </if:IfTrue>

      <%-- We are allowed to add a Works order --%>
      <if:IfTrue cond='<%= recordBean.getAction_flag().equals("W") %>'>
        <%-- Indicate which form we are coming from when we forward to another form --%>
        <sess:setAttribute name="previousForm">addDefect</sess:setAttribute>
        <%-- Indicate which form we are going to next --%>
        <sess:setAttribute name="form">contract</sess:setAttribute>
        <c:redirect url="contractScript.jsp" />
      </if:IfTrue>

      <%-- We are NOT allowed to add a Works order --%>
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">addDefect</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">addEnforcement</sess:setAttribute>
      <c:redirect url="addEnforcementScript.jsp" />
    </if:IfTrue>
  </if:IfTrue>
  
  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= addDefectBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">addDefect</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= addDefectBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">addDefect</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= addDefectBean.getAction().equals("Back") %>' >
    <% recordBean.setEnforce_flag("N"); %>
    <if:IfTrue cond='<%= !recordBean.getLast_action_flag().equals("") %>'>
      <% recordBean.setAction_flag( recordBean.getLast_action_flag() ); %>
      <%-- Clear the last action flag --%>
      <% recordBean.setLast_action_flag(""); %>
    </if:IfTrue>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">addDefect</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= addDefectBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${addDefectBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="addDefectView.jsp" />
