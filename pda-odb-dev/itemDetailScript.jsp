<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.itemDetailBean, com.vsb.recordBean, com.vsb.helperBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="itemDetailBean" scope="session" class="com.vsb.itemDetailBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="itemDetail" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="itemDetail" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="itemDetailBean" property="all" value="clear" />
    <jsp:setProperty name="itemDetailBean" property="*" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="itemDetailBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="itemLookup" >
  <jsp:setProperty name="itemDetailBean" property="action" value="" />
  <jsp:setProperty name="itemDetailBean" property="all" value="clear" />
  <jsp:setProperty name="itemDetailBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="itemDetail" >
  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= itemDetailBean.getAction().equals("Add") %>' >
    <%-- Invalid entry --%>
    <%-- make sure the user has selected an action to be performed --%>
    <if:IfTrue cond='<%= itemDetailBean.getActionTaken() == null || itemDetailBean.getActionTaken().equals("") %>' >
      <jsp:setProperty name="itemDetailBean" property="error"
        value="Please select an action to perform." />
      <jsp:forward page="itemDetailView.jsp" />
    </if:IfTrue>

    <%-- Valid entry --%>
    <if:IfTrue cond='<%= itemDetailBean.getActionTaken().equals("Hold") %>' >
      <% recordBean.setAction_flag("H"); %>
    </if:IfTrue>

    <if:IfTrue cond='<%= itemDetailBean.getActionTaken().equals("Inspect") %>' >
      <% recordBean.setAction_flag("I"); %>
    </if:IfTrue>

    <if:IfTrue cond='<%= itemDetailBean.getActionTaken().equals(application.getInitParameter("def_name_noun")) %>' >
      <% recordBean.setAction_flag("D"); %>
    </if:IfTrue>

    <if:IfTrue cond='<%= itemDetailBean.getActionTaken().equals("Works Order") %>' >
      <% recordBean.setAction_flag("W"); %>
    </if:IfTrue>

    <if:IfTrue cond='<%= itemDetailBean.getActionTaken().equals("No Action") %>' >
      <% recordBean.setAction_flag("N"); %>
    </if:IfTrue>

    <if:IfTrue cond='<%= recordBean.getService_c().equals(recordBean.getGraffiti_service()) %>' >
      <%-- 14/07/2010  TW  Initialise last action flag (used by addGraffDetails) --%>
      <% recordBean.setLast_action_flag( recordBean.getAction_flag() ); %>
    </if:IfTrue>
    
    <if:IfTrue cond='<%= itemDetailBean.getActionTaken().equals("Inspect") %>' >
      <%-- 19/05/2010  TW  Display inspDate form --%>
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">itemDetail</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">inspDate</sess:setAttribute>
      <c:redirect url="inspDateScript.jsp" />
    </if:IfTrue>

    <%-- 24/05/2010  TW  New condition for Trees service and NFA --%>
    <if:IfTrue cond='<%= recordBean.getService_c().equals(recordBean.getTrees_service()) && recordBean.getAction_flag().equals("N") %>' >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">itemDetail</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">faultLookup</sess:setAttribute>
      <c:redirect url="faultLookupScript.jsp" />
    </if:IfTrue>

    <%-- Use the customer details section --%>
    <if:IfTrue cond='<%= ((String)application.getInitParameter("use_cust_dets")).trim().equals("Y") && !recordBean.getService_c().equals(recordBean.getTrees_service()) %>' >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">itemDetail</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">addCustDetails</sess:setAttribute>
      <c:redirect url="addCustDetailsScript.jsp" />
    </if:IfTrue>

    <%-- Don't use the customer details section --%>
    <if:IfTrue cond='<%= ((String)application.getInitParameter("use_cust_dets")).trim().equals("N") || recordBean.getService_c().equals(recordBean.getTrees_service()) %>' >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">itemDetail</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">faultLookup</sess:setAttribute>
      <c:redirect url="faultLookupScript.jsp" />
    </if:IfTrue>

  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= itemDetailBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">itemDetail</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= itemDetailBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">itemDetail</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= itemDetailBean.getAction().equals("Back") %>' >
    <% recordBean.setAction_flag(""); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">itemDetail</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= itemDetailBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${itemDetailBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="itemDetailView.jsp" />
