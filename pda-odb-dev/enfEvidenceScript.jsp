<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.enfEvidenceBean, com.vsb.recordBean, com.vsb.helperBean, com.vsb.systemKeysBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="systemKeysBean" scope="session" class="com.vsb.systemKeysBean" />
<jsp:useBean id="enfEvidenceBean" scope="session" class="com.vsb.enfEvidenceBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="enfEvidence" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="enfEvidence" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>

    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="enfEvidenceBean" property="all" value="clear" />
    <jsp:setProperty name="enfEvidenceBean" property="*" />

    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="evidence" value='<%= enfEvidenceBean.getEvidence() %>' />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="enfEvidenceBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="enfAdditionalDetails" >
  <jsp:setProperty name="enfEvidenceBean" property="action" value="" />
  <jsp:setProperty name="enfEvidenceBean" property="all" value="clear" />
  <jsp:setProperty name="enfEvidenceBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="enfDetails" >
  <jsp:setProperty name="enfEvidenceBean" property="action" value="" />
  <jsp:setProperty name="enfEvidenceBean" property="all" value="clear" />
  <jsp:setProperty name="enfEvidenceBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <%-- Set the evidence to the enfList enforcements evidence, so the --%>
  <%-- user can update it. --%>
  <%-- 10/05/2010  TW  Read contender_version from systemKeysBean --%>
  <% String contender_version = systemKeysBean.getContender_version(); %>
  <if:IfTrue cond='<%= contender_version.equals("v7") || contender_version.equals("") %>'>
    <% enfEvidenceBean.setEvidence(recordBean.getEnf_list_evidence()); %>
    <% enfEvidenceBean.setPreviousEvidence(""); %>
  </if:IfTrue>
  <if:IfTrue cond='<%= contender_version.equals("v8") %>'>
    <% enfEvidenceBean.setEvidence(""); %>
    <% enfEvidenceBean.setPreviousEvidence(recordBean.getEnf_list_evidence()); %>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="enfEvidence" >
  <%-- 10/05/2010  TW  Read contender_version from systemKeysBean --%>
  <% String contender_version = systemKeysBean.getContender_version(); %>

  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= enfEvidenceBean.getAction().equals("Suspect") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= contender_version.equals("v7") || contender_version.equals("") %>'>
      <if:IfTrue cond='<%= enfEvidenceBean.getEvidence().length() > 255 %>' >
        <% 
          int n = enfEvidenceBean.getEvidence().length() - 255;
          String error = "Evidence text is limited to 255 characters. Please delete " + n + " characters."; 
        %>
        <jsp:setProperty name="enfEvidenceBean" property="error" value='<%= error %>' />
        <jsp:forward page="enfEvidenceView.jsp" />
      </if:IfTrue>
    </if:IfTrue>

    <%-- Valid entry --%>
    <% recordBean.setSuspect_flag("Y"); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfEvidence</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <if:IfTrue cond='<%= recordBean.getComingFromMarketsList().equals("Y") %>' >
      <if:IfTrue cond='<%= recordBean.getTrader_ref() != null && !recordBean.getTrader_ref().equals("") %>' >
        <%-- Working with a particular market trader, this needs to be confirmed/changed by the user --%>
        <sess:setAttribute name="form">enfSuspectMarketTrader</sess:setAttribute>
        <c:redirect url="enfSuspectMarketTraderScript.jsp" />
      </if:IfTrue>
      <if:IfTrue cond='<%= !(recordBean.getTrader_ref() != null && !recordBean.getTrader_ref().equals("")) %>' >
        <%-- The user needs to select a market trader --%>
        <sess:setAttribute name="form">enfSuspectMarketTraders</sess:setAttribute>
        <c:redirect url="enfSuspectMarketTradersScript.jsp" />
      </if:IfTrue>
    </if:IfTrue>
    <if:IfTrue cond='<%= ! recordBean.getComingFromMarketsList().equals("Y") %>' >
      <sess:setAttribute name="form">enfSuspectMain</sess:setAttribute>
      <c:redirect url="enfSuspectMainScript.jsp" />
    </if:IfTrue>
  </if:IfTrue>

  <%-- Next view 2 --%>
  <if:IfTrue cond='<%= enfEvidenceBean.getAction().equals("Add Text") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= contender_version.equals("v7") || contender_version.equals("") %>'>
      <if:IfTrue cond='<%= enfEvidenceBean.getEvidence().length() > 255 %>' >
        <% 
          int n = enfEvidenceBean.getEvidence().length() - 255;
          String error = "Evidence text is limited to 255 characters. Please delete " + n + " characters."; 
        %>
        <jsp:setProperty name="enfEvidenceBean" property="error" value='<%= error %>' />
        <jsp:forward page="enfEvidenceView.jsp" />
      </if:IfTrue>
    </if:IfTrue>

    <%-- Valid entry --%>
    <% recordBean.setSuspect_flag("N"); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfEvidence</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">text</sess:setAttribute>
    <c:redirect url="textScript.jsp" />
  </if:IfTrue>

  <%-- Next view 3 --%>
  <if:IfTrue cond='<%= enfEvidenceBean.getAction().equals("Update") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= contender_version.equals("v7") || contender_version.equals("") %>'>
      <if:IfTrue cond='<%= enfEvidenceBean.getEvidence().length() > 255 %>' >
        <% 
          int n = enfEvidenceBean.getEvidence().length() - 255;
          String error = "Evidence text is limited to 255 characters. Please delete " + n + " characters."; 
        %>
        <jsp:setProperty name="enfEvidenceBean" property="error" value='<%= error %>' />
        <jsp:forward page="enfEvidenceView.jsp" />
      </if:IfTrue>
    </if:IfTrue>

    <if:IfTrue cond='<%= enfEvidenceBean.getEvidence().trim().equals("") %>' >
      <jsp:setProperty name="enfEvidenceBean" property="error" 
        value="No new evidence supplied." />
      <jsp:forward page="enfEvidenceView.jsp" />
    </if:IfTrue>

    <%-- Valid entry --%>
    <% recordBean.setSuspect_flag("N"); %>

    <%-- update evidence --%>
    <sess:setAttribute name="form">updateEvidenceFunc</sess:setAttribute>
    <c:import url="updateEvidenceFunc.jsp" var="webPage" />
    <% helperBean.throwException("updateEvidenceFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfEvidence</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">updateStatus</sess:setAttribute>
    <c:redirect url="updateStatusScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= enfEvidenceBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfEvidence</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= enfEvidenceBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfEvidence</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

   <%-- Previous view --%>
  <if:IfTrue cond='<%= enfEvidenceBean.getAction().equals("Back") %>' >
    <% recordBean.setSuspect_flag("N"); %>
    <% recordBean.setEvidence(""); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfEvidence</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= enfEvidenceBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${enfEvidenceBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="enfEvidenceView.jsp" />
