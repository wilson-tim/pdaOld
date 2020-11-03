<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.faultLookupBean, com.vsb.recordBean, com.vsb.helperBean, java.util.ArrayList" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>

<jsp:useBean id="faultLookupBean" scope="session" class="com.vsb.faultLookupBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="faultLookup" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- fly capture flags --%>
<% boolean fc_installed = false; %>
<% boolean enhanced_fc = false; %>
<% boolean matched_fault = false; %>
<%-- comp_action_link check --%>
<% boolean invalid_comp_action_flag = false; %>  
<% boolean no_action_flag = false; %>  

<%-- 08/09/2010  TW  If using comp_action_link clear of recordBean Action_flag --%>
<%--                 to ensure correct selection of fault codes by faultLookupView.jsp --%>
<if:IfTrue cond='<%= application.getInitParameter("use_comp_action_link").equals("Y") %>' >
  <% recordBean.setAction_flag(""); %>
</if:IfTrue>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="faultLookup" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="faultLookupBean" property="all" value="clear" />
    <jsp:setProperty name="faultLookupBean" property="*" />

    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="fault_code" value='<%= faultLookupBean.getLookup_code() %>' />

    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />    
    <sql:statement id="stmt" conn="con">
      <%-- Check to see if use_comp_action_link is Y and if it is then retrieve the new action_flag --%>
      <if:IfTrue cond='<%= application.getInitParameter("use_comp_action_link").equals("Y") %>' >
        <% String user_action_flag = ""; %>
        <if:IfTrue cond='<%= faultLookupBean.getActionTaken().equals("Hold") %>' >
          <% user_action_flag = "H"; %>
        </if:IfTrue>
    
        <if:IfTrue cond='<%= faultLookupBean.getActionTaken().equals("Inspect") %>' >
          <% user_action_flag = "I"; %>
        </if:IfTrue>
    
        <if:IfTrue cond='<%= faultLookupBean.getActionTaken().equals(application.getInitParameter("def_name_noun")) %>' >
          <% user_action_flag = "D"; %>
        </if:IfTrue>
    
        <if:IfTrue cond='<%= faultLookupBean.getActionTaken().equals("Works Order") %>' >
          <% user_action_flag = "W"; %>
        </if:IfTrue>
    
        <if:IfTrue cond='<%= faultLookupBean.getActionTaken().equals("No Action") %>' >
          <% user_action_flag = "N"; %>
        </if:IfTrue>

        <% String comp_action_flag = ""; %>
        <sql:query>
          select action_flag
          from comp_action
          where comp_code = '<%= recordBean.getFault_code() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="action_flag" />
          <sql:wasNotNull>
            <% comp_action_flag = ((String) pageContext.getAttribute("action_flag")).trim(); %>
          </sql:wasNotNull>
        </sql:resultSet>
        
        <if:IfTrue cond='<%= ! user_action_flag.equals("") %>' >
          <% recordBean.setAction_flag(user_action_flag); %>
        </if:IfTrue>
        <if:IfTrue cond='<%= ! comp_action_flag.equals("") && user_action_flag.equals("") %>' >
          <if:IfTrue cond='<%= comp_action_flag.equals("H") ||
                               comp_action_flag.equals("I") ||
                               comp_action_flag.equals("W") ||
                               comp_action_flag.equals("D") ||
                               comp_action_flag.equals("N") %>' >
            <% recordBean.setAction_flag(comp_action_flag); %>
          </if:IfTrue>
          <if:IfTrue cond='<%= ! comp_action_flag.equals("H") &&
                               ! comp_action_flag.equals("I") &&
                               ! comp_action_flag.equals("W") &&
                               ! comp_action_flag.equals("D") &&
                               ! comp_action_flag.equals("N") %>' >
            <% invalid_comp_action_flag = true; %>  
          </if:IfTrue>
        </if:IfTrue>
        <if:IfTrue cond='<%= comp_action_flag.equals("") && user_action_flag.equals("") %>' >
          <% no_action_flag = true; %>  
        </if:IfTrue>

        <%-- 14/07/2010  TW  Initialise last action flag (used by addGraffDetails) --%>
        <% recordBean.setLast_action_flag( recordBean.getAction_flag() ); %>

      </if:IfTrue>

      <%-- make sure we pick the default or complaint fault code description --%>
      <% String defrnOrCompla = ""; %>
      <if:IfTrue cond='<%= recordBean.getAction_flag().equals("H") || 
                           recordBean.getAction_flag().equals("I") || 
                           recordBean.getAction_flag().equals("W") || 
                           recordBean.getAction_flag().equals("N") %>' > 
        <% defrnOrCompla = "COMPLA"; %>
      </if:IfTrue>
      <if:IfTrue cond='<%= recordBean.getAction_flag().equals("D") %>' > 
        <% defrnOrCompla = "DEFRN"; %>
      </if:IfTrue>
     
      <sql:query>
        select lookup_text, lookup_num
        from allk
        where lookup_func = '<%= defrnOrCompla %>'
        and   lookup_code = '<%= recordBean.getFault_code() %>'
      </sql:query>
      <sql:resultSet id="rset">
         <sql:getColumn position="1" to="lookup_text" />
         <% recordBean.setFault_desc((String) pageContext.getAttribute("lookup_text")); %>
         <sql:getColumn position="2" to="lookup_num" />
         <% recordBean.setNotice_no((String) pageContext.getAttribute("lookup_num")); %>
      </sql:resultSet>

      <%-- check if the fault code matched the fly capture fault code list --%>
      <sql:query>
        select count(*)
        from allk
        where lookup_func = 'FCCOMP'
        and   lookup_code = '<%= recordBean.getFault_code() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="count" />
        <if:IfTrue cond='<%= Integer.parseInt(((String) pageContext.getAttribute("count")).trim()) > 0 %>' >
          <% matched_fault = true; %>
        </if:IfTrue>
      </sql:resultSet>

      <%-- check if the fault code matched the doorstepping fault code --%>
      <sql:query>
        SELECT c_field
        FROM keys
        WHERE keyname = 'DOORSTOP_FAULT'
        AND service_c = 'ALL'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="doorstep_fault_code" />
        <% recordBean.setDoorstep_fault_code( ((String) pageContext.getAttribute("doorstep_fault_code")).trim() ); %>
      </sql:resultSet>

      <%-- check if we're using fly capture. --%>
      <sql:query>
        select c_field
        from keys
        where keyname = 'FC_INSTALLATION'
        and   service_c = 'ALL'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="c_field" />
        <if:IfTrue cond='<%= ((String) pageContext.getAttribute("c_field")).trim().equals("Y") %>' >
          <% fc_installed = true; %>
        </if:IfTrue>
      </sql:resultSet>

      <%-- check if we're using enhanced fly capture. Enhanced fly capture --%>
      <%-- only allows fly capture info to be added for specific fault codes, the --%>
      <%-- matched_fault flag above indicates if the fault matched. --%>
      <sql:query>
        select c_field
        from keys
        where keyname = 'FC_ENHANCED'
        and   service_c = 'ALL'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="c_field" />
        <if:IfTrue cond='<%= ((String) pageContext.getAttribute("c_field")).trim().equals("Y") %>' >
          <% enhanced_fc = true; %>
        </if:IfTrue>
      </sql:resultSet>
    </sql:statement>
    <sql:closeConnection conn="con"/>
      
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="faultLookupBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="addCustDetails" >
  <jsp:setProperty name="faultLookupBean" property="action" value="" />
  <jsp:setProperty name="faultLookupBean" property="all" value="clear" />
  <jsp:setProperty name="faultLookupBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="custLocLookup" >
  <jsp:setProperty name="faultLookupBean" property="action" value="" />
  <jsp:setProperty name="faultLookupBean" property="all" value="clear" />
  <jsp:setProperty name="faultLookupBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="enterCustDetails" >
  <jsp:setProperty name="faultLookupBean" property="action" value="" />
  <jsp:setProperty name="faultLookupBean" property="all" value="clear" />
  <jsp:setProperty name="faultLookupBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="itemLookup" >
  <jsp:setProperty name="faultLookupBean" property="action" value="" />
  <jsp:setProperty name="faultLookupBean" property="all" value="clear" />
  <jsp:setProperty name="faultLookupBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="itemDetail" >
  <jsp:setProperty name="faultLookupBean" property="action" value="" />
  <jsp:setProperty name="faultLookupBean" property="all" value="clear" />
  <jsp:setProperty name="faultLookupBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="inspDate" >
  <jsp:setProperty name="faultLookupBean" property="action" value="" />
  <jsp:setProperty name="faultLookupBean" property="all" value="clear" />
  <jsp:setProperty name="faultLookupBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="taskAgreement" >
  <jsp:setProperty name="faultLookupBean" property="action" value="" />
  <jsp:setProperty name="faultLookupBean" property="all" value="clear" />
  <jsp:setProperty name="faultLookupBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="faultLookup" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= faultLookupBean.getAction().equals("Continue") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%=faultLookupBean.getLookup_code() == null || faultLookupBean.getLookup_code().equals("") %>' >
      <jsp:setProperty name="faultLookupBean" property="error"
        value="Please choose a fault." />
      <jsp:forward page="faultLookupView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= invalid_comp_action_flag == true %>' >
      <% faultLookupBean.setComp_action_error("Y"); %>
      <jsp:setProperty name="faultLookupBean" property="error"
        value="The automatic action associated with this fault is not recognised by the application. Please choose an action from the dropdown." />
      <jsp:forward page="faultLookupView.jsp" />
    </if:IfTrue>
    
    <if:IfTrue cond='<%= no_action_flag == true %>' >
      <% faultLookupBean.setComp_action_error("Y"); %>
      <jsp:setProperty name="faultLookupBean" property="error"
        value="There is no automatic action is associated with this fault. Please choose an action from the dropdown." />
      <jsp:forward page="faultLookupView.jsp" />
    </if:IfTrue>
    
    <%-- Valid entry --%>
    <if:IfTrue cond='<%= ((String)application.getInitParameter("module")).trim().equals("pda-in") %>' >

      <%-- check to see if the code selected is for Doorstepping. --%>
      <%-- If so ignore the flytipping / Dart / Graffiti stuff    --%>
      <%-- 29/06/2010  TW  the doorstep fault code may be a comma delimited list of fault codes --%>
      <% ArrayList doorstep_fault_codes = helperBean.splitCommaList( recordBean.getDoorstep_fault_code() ); %>
      <if:IfTrue cond='<%= doorstep_fault_codes.contains( faultLookupBean.getLookup_code() )  %>' >
        <%-- Indicate which form we are coming from when we forward to another form --%>
        <sess:setAttribute name="previousForm">faultLookup</sess:setAttribute>
        <%-- Indicate which form we are going to next --%>
        <sess:setAttribute name="form">doorstepSurvey</sess:setAttribute>
        <c:redirect url="doorstepSurveyScript.jsp" />
      </if:IfTrue>      
      
      <%-- Check to see if this is a Highways Complaint, and if so send the user to --%>
      <%-- the addDefect screen --%>
      <if:IfTrue cond='<%= recordBean.getService_c().equals(recordBean.getHway_service()) %>' >
        <%-- Indicate which form we are coming from when we forward to another form --%>
        <sess:setAttribute name="previousForm">faultLookup</sess:setAttribute>
        <%-- Indicate which form we are going to next --%>
        <sess:setAttribute name="form">addDefect</sess:setAttribute>
        <c:redirect url="addDefectScript.jsp" />
      </if:IfTrue>
      
      <%-- Checking for Dart service, if found ignore the fly capture stuff --%>
      <%-- and go straight to the add Dart details screen --%>
      <if:IfTrue cond='<%= recordBean.getService_c().equals(recordBean.getDart_service()) %>' >
        <%-- Indicate which form we are coming from when we forward to another form --%>
        <sess:setAttribute name="previousForm">faultLookup</sess:setAttribute>
        <%-- Indicate which form we are going to next --%>
        <sess:setAttribute name="form">addDartDetails</sess:setAttribute>
        <c:redirect url="addDartDetailsScript.jsp" />
      </if:IfTrue>
 
      <%-- Checking for Graffiti service, if found ignore the fly capture stuff --%>
      <%-- and go straight to the add Graffiti details screen --%>
      <if:IfTrue cond='<%= recordBean.getService_c().equals(recordBean.getGraffiti_service()) %>' >
        <%-- Indicate which form we are coming from when we forward to another form --%>
        <sess:setAttribute name="previousForm">faultLookup</sess:setAttribute>
        <%-- Indicate which form we are going to next --%>
        <sess:setAttribute name="form">addGraffDetails</sess:setAttribute>
        <c:redirect url="addGraffDetailsScript.jsp" />
      </if:IfTrue>
    
      <%-- 24/05/2010  TW  New condition for Trees service and NFA --%>
      <%-- Checking for Trees service and NFA, if found go straight to updateStatus form --%>
      <if:IfTrue cond='<%= recordBean.getService_c().equals(recordBean.getTrees_service()) && recordBean.getAction_flag().equals("N") %>' >
        <%-- add complaint --%>
        <sess:setAttribute name="form">addComplaintFunc</sess:setAttribute>
        <c:import url="addComplaintFunc.jsp" var="webPage" />
        <% helperBean.throwException("addComplaintFunc", (String)pageContext.getAttribute("webPage")); %>
    
        <%-- add complaint text --%>
        <sess:setAttribute name="form">addTextFunc</sess:setAttribute>
        <c:import url="addTextFunc.jsp" var="webPage" />
        <% helperBean.throwException("addTextFunc", (String)pageContext.getAttribute("webPage")); %>
    
        <%-- run the veolia link if required --%>
        <sess:setAttribute name="form">veoliaLinkFunc</sess:setAttribute>
        <c:import url="veoliaLinkFunc.jsp" var="webPage" />
        <% helperBean.throwException("veoliaLinkFunc", (String)pageContext.getAttribute("webPage")); %>
    
        <%-- Indicate which form we are coming from when we forward to another form --%>
        <sess:setAttribute name="previousForm">faultLookup</sess:setAttribute>
        <%-- Indicate which form we are going to next --%>
        <sess:setAttribute name="form">updateStatus</sess:setAttribute>
        <c:redirect url="updateStatusScript.jsp" />
      </if:IfTrue>

      <if:IfTrue cond='<%= fc_installed == true %>' >
        <if:IfTrue cond='<%= enhanced_fc == true %>' >
          <if:IfTrue cond='<%= matched_fault == true %>' >
            <% recordBean.setFly_cap_flag("Y"); %>
            <%-- Indicate which form we are coming from when we forward to another form --%>
            <sess:setAttribute name="previousForm">faultLookup</sess:setAttribute>
            <%-- Indicate which form we are going to next --%>
            <sess:setAttribute name="form">flyCapDetails</sess:setAttribute>
            <c:redirect url="flyCapDetailsScript.jsp" />
          </if:IfTrue>
  
          <%-- the fault code didn't match, so cannot add a fly capture. --%>
          <%-- Action_flag is not "W" (works order) so go to the addEnforcement form. --%>
          <if:IfTrue cond='<%= ! recordBean.getAction_flag().equals("W") %>' >
            <% recordBean.setFly_cap_flag("N"); %>
            <%-- Indicate which form we are coming from when we forward to another form --%>
            <sess:setAttribute name="previousForm">faultLookup</sess:setAttribute>
            <%-- Indicate which form we are going to next --%>
            <sess:setAttribute name="form">addEnforcement</sess:setAttribute>
            <c:redirect url="addEnforcementScript.jsp" />
          </if:IfTrue>
          <%-- Action_flag is "W" (works order) so go to add a works order first. --%>
          <if:IfTrue cond='<%= recordBean.getAction_flag().equals("W") %>' >
            <% recordBean.setFly_cap_flag("N"); %>
            <%-- Indicate which form we are coming from when we forward to another form --%>
            <sess:setAttribute name="previousForm">faultLookup</sess:setAttribute>
            <%-- Indicate which form we are going to next --%>
            <sess:setAttribute name="form">contract</sess:setAttribute>
            <c:redirect url="contractScript.jsp" />
          </if:IfTrue>
        </if:IfTrue>
  
        <%-- Not using enhanced fly capture, so any old fault code can have --%>
        <%-- fly capture added to it. --%>
        <%-- Indicate which form we are coming from when we forward to another form --%>
        <sess:setAttribute name="previousForm">faultLookup</sess:setAttribute>
        <%-- Indicate which form we are going to next --%>
        <sess:setAttribute name="form">addFlyCapture</sess:setAttribute>
        <c:redirect url="addFlyCaptureScript.jsp" />
      </if:IfTrue>
      <if:IfTrue cond='<%= fc_installed == false %>' >
        <%-- Not using fly capture so cannot add a fly capture. --%>  
        <%-- Action_flag is not "W" (works order) so go to the addEnforcement form. --%>
        <if:IfTrue cond='<%= ! recordBean.getAction_flag().equals("W") %>' >
          <% recordBean.setFly_cap_flag("N"); %>
          <%-- Indicate which form we are coming from when we forward to another form --%>
          <sess:setAttribute name="previousForm">faultLookup</sess:setAttribute>
          <%-- Indicate which form we are going to next --%>
          <sess:setAttribute name="form">addEnforcement</sess:setAttribute>
          <c:redirect url="addEnforcementScript.jsp" />
        </if:IfTrue>
        <%-- Action_flag is "W" (works order) so go to add a works order first. --%>
        <if:IfTrue cond='<%= recordBean.getAction_flag().equals("W") %>' >
          <% recordBean.setFly_cap_flag("N"); %>
          <%-- Indicate which form we are coming from when we forward to another form --%>
          <sess:setAttribute name="previousForm">faultLookup</sess:setAttribute>
          <%-- Indicate which form we are going to next --%>
          <sess:setAttribute name="form">contract</sess:setAttribute>
          <c:redirect url="contractScript.jsp" />
        </if:IfTrue>
      </if:IfTrue>

    </if:IfTrue>

    <%-- This is the Town Warden (pda-tw) app so no fly capture allowed. --%>
    <% recordBean.setFly_cap_flag("N"); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">faultLookup</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">text</sess:setAttribute>
    <c:redirect url="textScript.jsp" />
  </if:IfTrue>
  
  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= faultLookupBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">faultLookup</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= faultLookupBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">faultLookup</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= faultLookupBean.getAction().equals("Back") %>' >
    <% recordBean.setFly_cap_flag("N"); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">faultLookup</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= faultLookupBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${faultLookupBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="faultLookupView.jsp" />
