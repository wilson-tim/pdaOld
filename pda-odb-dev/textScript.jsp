<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.textBean, com.vsb.recordBean, com.vsb.helperBean" %>

<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="textBean" scope="session" class="com.vsb.textBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="text" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="text" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>

    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="textBean" property="all" value="clear" />
    <jsp:setProperty name="textBean" property="*" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="textBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="addEnforcement" >
  <jsp:setProperty name="textBean" property="action" value="" />
  <jsp:setProperty name="textBean" property="all" value="clear" />
  <jsp:setProperty name="textBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="flyCapDetails" >
  <jsp:setProperty name="textBean" property="action" value="" />
  <jsp:setProperty name="textBean" property="all" value="clear" />
  <jsp:setProperty name="textBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="wasteTypes" >
  <jsp:setProperty name="textBean" property="action" value="" />
  <jsp:setProperty name="textBean" property="all" value="clear" />
  <jsp:setProperty name="textBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="details" >
  <jsp:setProperty name="textBean" property="action" value="" />
  <jsp:setProperty name="textBean" property="all" value="clear" />
  <jsp:setProperty name="textBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="enfAdditionalDetails" >
  <jsp:setProperty name="textBean" property="action" value="" />
  <jsp:setProperty name="textBean" property="all" value="clear" />
  <jsp:setProperty name="textBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="enfEvidence" >
  <jsp:setProperty name="textBean" property="action" value="" />
  <jsp:setProperty name="textBean" property="all" value="clear" />
  <jsp:setProperty name="textBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="enfSuspectText" >
  <jsp:setProperty name="textBean" property="action" value="" />
  <jsp:setProperty name="textBean" property="all" value="clear" />
  <jsp:setProperty name="textBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="enfSuspectMarketTrader" >
  <jsp:setProperty name="textBean" property="action" value="" />
  <jsp:setProperty name="textBean" property="all" value="clear" />
  <jsp:setProperty name="textBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="enfSuspectMarketTraders" >
  <jsp:setProperty name="textBean" property="action" value="" />
  <jsp:setProperty name="textBean" property="all" value="clear" />
  <jsp:setProperty name="textBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="woDetails" >
  <jsp:setProperty name="textBean" property="action" value="" />
  <jsp:setProperty name="textBean" property="all" value="clear" />
  <jsp:setProperty name="textBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="changeInspDate" >
  <jsp:setProperty name="textBean" property="action" value="" />
  <jsp:setProperty name="textBean" property="all" value="clear" />
  <jsp:setProperty name="textBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="text" >
  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= textBean.getAction().equals("Finish") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- The module is inspectors --%>
    <app:equalsInitParameter name="module" match="pda-in" >
      <%-- indicate the route which will be taken to get to defaultAdditional --%>
      <% recordBean.setDefault_route("text"); %>
      
      <%-- 02/09/2010  TW  Check for DART works order --%>
      <if:IfTrue cond='<%= recordBean.getCharge_flag().equals("Y") %>'>
        <% recordBean.setAction_flag("W"); %>
      </if:IfTrue>

      <%-- only add a complaint as user is adding a hold complaint --%>
      <if:IfTrue cond='<%= recordBean.getAction_flag().equals("H") || 
                           recordBean.getAction_flag().equals("I") ||
                           recordBean.getAction_flag().equals("N") ||
                           recordBean.getAction_flag().equals("W") %>' >
        <%-- add complaint, unless this is the enforcement service --%>
        <if:IfTrue cond='<%= !recordBean.getService_c().equals(recordBean.getEnf_service()) %>'>
          <sess:setAttribute name="form">addComplaintFunc</sess:setAttribute>
          <c:import url="addComplaintFunc.jsp" var="webPage" />
          <% helperBean.throwException("addComplaintFunc", (String)pageContext.getAttribute("webPage")); %>
        </if:IfTrue>

        <%-- Add an enforcement complaint if required --%>
        <if:IfTrue cond='<%= recordBean.getEnforce_flag().equals("Y") %>' >
          <sess:setAttribute name="form">addEnforceFunc</sess:setAttribute>
          <c:import url="addEnforceFunc.jsp" var="webPage" />
          <% helperBean.throwException("addEnforceFunc", (String)pageContext.getAttribute("webPage")); %>
           
          <%-- If this is NOT a standalone enforcement complaint, then we need to add the --%>
          <%-- complaint number to the record bean for the suspect to use and then set it back again after --%>
          <if:IfTrue cond='<%= ! recordBean.getService_c().equals(recordBean.getEnf_service()) %>'>
            <% recordBean.setComplaint_no( recordBean.getEnforce_complaint_no() ); %>
          </if:IfTrue>

          <%-- Add the suspect if required --%>
          <if:IfTrue cond='<%= recordBean.getSuspect_flag().equals("Y") %>' >
            <%-- 13/12/2010  TW  New conditional code for Markets module --%>
            <if:IfTrue cond='<%= recordBean.getComingFromMarketsList().equals("Y") %>' >
              <sess:setAttribute name="form">checkSuspectFunc</sess:setAttribute>
              <c:import url="checkSuspectFunc.jsp" var="webPage" />
              <% helperBean.throwException("checkSuspectFunc", (String)pageContext.getAttribute("webPage")); %>
            </if:IfTrue>
            <sess:setAttribute name="form">addUpdateSuspectFunc</sess:setAttribute>
            <c:import url="addUpdateSuspectFunc.jsp" var="webPage" />
            <% helperBean.throwException("addUpdateSuspectFunc", (String)pageContext.getAttribute("webPage")); %>
          </if:IfTrue>

          <%-- Add the evidence if required --%>
          <if:IfTrue cond='<%= ! recordBean.getEvidence().equals("") %>'>
            <sess:setAttribute name="form">updateEvidenceFunc</sess:setAttribute>
            <c:import url="updateEvidenceFunc.jsp" var="webPage" />
            <% helperBean.throwException("updateEvidenceFunc", (String)pageContext.getAttribute("webPage")); %>
          </if:IfTrue>

          <if:IfTrue cond='<%= ! recordBean.getService_c().equals(recordBean.getEnf_service()) %>'>
            <% recordBean.setComplaint_no( recordBean.getComplaint_complaint_no() ); %>
          </if:IfTrue>
        </if:IfTrue>

        <%-- Add a works order if required, charge_flag (Graff/Dart), AV and Defects --%>
        <if:IfTrue cond='<%= recordBean.getCharge_flag().equals("Y")    ||
                             recordBean.getAv_action_flag().equals("W") ||
                             recordBean.getAction_flag().equals("W") %>' >
          <sess:setAttribute name="form">addWorksOrderFunc</sess:setAttribute>
          <c:import url="addWorksOrderFunc.jsp" var="webPage" />
          <% helperBean.throwException("addWorksOrder", (String)pageContext.getAttribute("webPage")); %>
        </if:IfTrue>

        <%-- add complaint text --%>
        <sess:setAttribute name="form">addTextFunc</sess:setAttribute>
        <c:import url="addTextFunc.jsp" var="webPage" />
        <% helperBean.throwException("addTextFunc", (String)pageContext.getAttribute("webPage")); %>

        <%-- run the veolia link if required --%>
        <sess:setAttribute name="form">veoliaLinkFunc</sess:setAttribute>
        <c:import url="veoliaLinkFunc.jsp" var="webPage" />
        <% helperBean.throwException("veoliaLinkFunc", (String)pageContext.getAttribute("webPage")); %>

        <%-- If this is an Enforcement and suspect details have been added --%>
        <%-- re-route to the enfAction form to allow users to add an action and status FPN etc. --%>
        <%-- They are not allowed back to this screen, they must proceed forward. --%>
        <%-- The "Back" button will be disabled on the enfAction screen --%>
        <if:IfTrue cond='<%= recordBean.getEnforce_flag().equals("Y") && recordBean.getSuspect_flag().equals("Y") %>' >
          <%-- Populate the required fields for the Enf_list route --%>
          <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
          <sql:statement id="stmt" conn="con1">
            <%-- From enfList form --%>
            <sql:query>
              SELECT suspect_ref, action_seq
                FROM comp_enf
               WHERE complaint_no = '<%= recordBean.getComplaint_no() %>'
            </sql:query>
            <sql:resultSet id="rset">
              <sql:getColumn position="1" to="suspect_ref" />
              <% recordBean.setEnf_list_suspect_ref((String) pageContext.getAttribute("suspect_ref")); %>
              <sql:wasNull>
                <% recordBean.setEnf_list_suspect_ref(""); %>
              </sql:wasNull>
              <sql:getColumn position="2" to="action_seq" />
              <% recordBean.setEnf_list_action_seq((String) pageContext.getAttribute("action_seq")); %>
              <sql:wasNull>
                <% recordBean.setEnf_list_action_seq(""); %>
              </sql:wasNull>
            </sql:resultSet>
      
            <%-- Get the site_ref --%>
            <sql:query>
              SELECT site_ref 
                FROM comp 
               WHERE complaint_no = '<%= recordBean.getComplaint_no() %>'
            </sql:query>
            <sql:resultSet id="rset">
              <sql:getColumn position="1" to="site_ref" />
              <% recordBean.setSite_ref((String) pageContext.getAttribute("site_ref")); %>
            </sql:resultSet>
      
            <%-- Get the site_name_1 --%>
            <sql:query>
              SELECT site_name_1 
                FROM site
               WHERE site_ref = '<%= recordBean.getSite_ref() %>'
            </sql:query>
            <sql:resultSet id="rset">
              <sql:getColumn position="1" to="site_name_1" />
              <% recordBean.setSite_name_1((String) pageContext.getAttribute("site_name_1")); %>
            </sql:resultSet>
      
            <%-- From enfDetails form --%>
            <%-- only do if there is an action for this enforcement --%>
            <if:IfTrue cond='<%= ! recordBean.getEnf_list_action_seq().equals("") %>' >
              <% recordBean.setEnf_list_action_code(""); %>
              <% recordBean.setEnf_list_status_code(""); %>
              <sql:query>
                SELECT action_ref, enf_status
                  FROM enf_action 
                WHERE action_seq = '<%= recordBean.getEnf_list_action_seq() %>'
                AND complaint_no = '<%= recordBean.getComplaint_no() %>'
              </sql:query>
              <sql:resultSet id="rset">
                <sql:getColumn position="1" to="action_ref" />
                <sql:wasNotNull>
                  <% recordBean.setEnf_list_action_code(((String)pageContext.getAttribute("action_ref")).trim()); %>
                </sql:wasNotNull>
      
                <sql:getColumn position="2" to="enf_status" />
                <sql:wasNotNull>
                  <% recordBean.setEnf_list_status_code(((String)pageContext.getAttribute("enf_status")).trim()); %>
                </sql:wasNotNull>
              </sql:resultSet>
            </if:IfTrue>

          </sql:statement>
          <sql:closeConnection conn="con1"/>
           
          <%-- set enf_list_flag --%>
          <% recordBean.setEnf_list_flag("Y"); %>
          <%-- Clear the evidence text as it has already been put in when the enforcement --%>
          <%--  was created above. --%>
          <% recordBean.setEnf_list_evidence(""); %>
          <% recordBean.setEvidence(""); %>
          <%-- Don't do any suspect, stuff if there was any, as this has already been dealt with when --%>
          <%-- the enforcement was created above. --%>
          <% recordBean.setSuspect_flag("N"); %>
          <%-- Make sure that the enforcement action stuff is pointing at the enforcement, and not --%>
          <%-- the complaint if it was not a standalone enforcement. --%>
          <if:IfTrue cond='<%= ! recordBean.getService_c().equals(recordBean.getEnf_service()) %>'>
            <% recordBean.setComplaint_no( recordBean.getEnforce_complaint_no() ); %>
          </if:IfTrue>
          <%-- Indicate which form we are coming from when we forward to another form --%>
          <sess:setAttribute name="previousForm">text</sess:setAttribute>
          <%-- Indicate which form we are going to next --%>
          <sess:setAttribute name="form">enfAction</sess:setAttribute>
          <c:redirect url="enfActionScript.jsp" />
        </if:IfTrue>

        <%-- Indicate which form we are coming from when we forward to another form --%>
        <sess:setAttribute name="previousForm">text</sess:setAttribute>
        <%-- Indicate which form we are going to next --%>
        <sess:setAttribute name="form">updateStatus</sess:setAttribute>
        <c:redirect url="updateStatusScript.jsp" />
      </if:IfTrue>

      <%-- add a default as none of the above was triggered, so we must be a default now. --%>
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">text</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">streetLength</sess:setAttribute>
      <c:redirect url="streetLengthScript.jsp" />
    </app:equalsInitParameter>

    <%-- The module is town warden --%>
    <app:equalsInitParameter name="module" match="pda-tw" >
      <%-- indicate the route which will be taken to get to defaultAdditional --%>
      <% recordBean.setDefault_route("text"); %>

      <%-- add comp import --%>
      <sess:setAttribute name="form">addCompImportFunc</sess:setAttribute>
      <c:import url="addCompImportFunc.jsp" var="webPage" />
      <% helperBean.throwException("addCompImportFunc", (String)pageContext.getAttribute("webPage")); %>

      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">text</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">updateStatus</sess:setAttribute>
      <c:redirect url="updateStatusScript.jsp" />
    </app:equalsInitParameter>
  </if:IfTrue>

  <%-- Next view 2 --%>
  <if:IfTrue cond='<%= textBean.getAction().equals("Map") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Get the sites Easting and Northing values for the Map --%>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con">    
      <sql:query>
        SELECT easting,
               northing
          FROM site_detail
         WHERE site_ref = '<%= recordBean.getSite_ref() %>'
      </sql:query>
      <sql:resultSet id="rset5">
        <sql:getColumn position="1" to="easting" />
        <% recordBean.setMap_easting((String) pageContext.getAttribute("easting")); %>
        <sql:getColumn position="2" to="northing" />
        <% recordBean.setMap_northing((String) pageContext.getAttribute("northing")); %>
      </sql:resultSet>
    </sql:statement>
    <sql:closeConnection conn="con"/>    
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">text</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">map</sess:setAttribute>
    <c:redirect url="mapScript.jsp" />
  </if:IfTrue>
  
  <%-- Common Buttons --%>
  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= textBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">text</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= textBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">text</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= textBean.getAction().equals("Back") %>' >
    <% recordBean.setDefault_route(""); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">text</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= textBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${textBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="textView.jsp" />
