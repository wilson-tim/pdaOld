<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.enterCustDetailsBean, com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="enterCustDetailsBean" scope="session" class="com.vsb.enterCustDetailsBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="enterCustDetails" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="enterCustDetails" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="enterCustDetailsBean" property="all" value="clear" />
    <jsp:setProperty name="enterCustDetailsBean" property="*" />
    
    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="compl_init" param="compl_init" />
    <jsp:setProperty name="recordBean" property="compl_name" param="compl_name" />
    <jsp:setProperty name="recordBean" property="compl_surname" param="compl_surname" />
    <jsp:setProperty name="recordBean" property="compl_phone" param="compl_phone" />
    <jsp:setProperty name="recordBean" property="compl_email" param="compl_email" />
    <jsp:setProperty name="recordBean" property="int_ext_flag" param="int_ext_flag" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="enterCustDetailsBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="addCustDetails" >
  <jsp:setProperty name="enterCustDetailsBean" property="action" value="" />
  <jsp:setProperty name="enterCustDetailsBean" property="all" value="clear" />
  <jsp:setProperty name="enterCustDetailsBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<if:IfTrue cond='<%= enterCustDetailsBean.getInt_ext_flag().equals("") %>' >
  <% enterCustDetailsBean.setInt_ext_flag("E"); %>
</if:IfTrue>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="enterCustDetails" >
  <%-- Force the Int_ext_flag to uppercase --%>
  <% enterCustDetailsBean.setInt_ext_flag(enterCustDetailsBean.getInt_ext_flag().toUpperCase()); %>
  <% recordBean.setInt_ext_flag(recordBean.getInt_ext_flag().toUpperCase()); %>

  <%-- Next view --%>
  <if:IfTrue cond='<%= enterCustDetailsBean.getAction().equals("Continue") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue 
      cond='<%= !(enterCustDetailsBean.getInt_ext_flag().equals("I")) && !(enterCustDetailsBean.getInt_ext_flag().equals("E")) %>' >
      <jsp:setProperty name="enterCustDetailsBean" property="error"
        value="Only 'I' or 'E' allowed for int/ext." />
      <jsp:forward page="enterCustDetailsView.jsp" />
    </if:IfTrue>
    
    <if:IfTrue cond='<%= enterCustDetailsBean.getInt_ext_flag().trim().equals("E") %>' >
      <if:IfTrue 
        cond='<%= (enterCustDetailsBean.getCompl_name() == null || enterCustDetailsBean.getCompl_name().equals("")) &&
          (enterCustDetailsBean.getCompl_surname() == null || enterCustDetailsBean.getCompl_surname().equals("")) %>' >
        <jsp:setProperty name="enterCustDetailsBean" property="error"
          value="Please supply a minimum of name and/or surname." />
        <jsp:forward page="enterCustDetailsView.jsp" />
      </if:IfTrue>
    </if:IfTrue>
    
    <if:IfTrue cond='<%= enterCustDetailsBean.getInt_ext_flag().equals("E") && !(enterCustDetailsBean.getAddress_flag().equals("Yes")) %>' >
      <jsp:setProperty name="enterCustDetailsBean" property="error"
        value="An address must be added as an external customer has been selected." />
      <jsp:forward page="enterCustDetailsView.jsp" />
    </if:IfTrue>
    
    <%-- Valid entry --%>
    <%-- The the user wants to add an address --%>
    <if:IfTrue cond='<%= enterCustDetailsBean.getAddress_flag().equals("Yes") %>' >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">enterCustDetails</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">custLocSearch</sess:setAttribute>
      <c:redirect url="custLocSearchScript.jsp" />
    </if:IfTrue>
    
    <%-- The the user does not want to add an address --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enterCustDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">faultLookup</sess:setAttribute>
    <c:redirect url="faultLookupScript.jsp" />
  </if:IfTrue>
  
  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= enterCustDetailsBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enterCustDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= enterCustDetailsBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enterCustDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= enterCustDetailsBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enterCustDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= enterCustDetailsBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${enterCustDetailsBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="enterCustDetailsView.jsp" />
