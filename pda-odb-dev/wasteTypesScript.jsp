<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.wasteTypesBean, com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="wasteTypesBean" scope="session" class="com.vsb.wasteTypesBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="wasteTypes" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="wasteTypes" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="wasteTypesBean" property="all" value="clear" />
    <jsp:setProperty name="wasteTypesBean" property="*" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="wasteTypesBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="flyCapDetails" >
  <jsp:setProperty name="wasteTypesBean" property="action" value="" />
  <jsp:setProperty name="wasteTypesBean" property="all" value="clear" />
  <jsp:setProperty name="wasteTypesBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="wasteTypes" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <%-- Code to run --%>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="wasteTypes" >
  <%-- As the submit will only have placed the checked types into --%>
  <%-- the waste_types array, the waste_types array has to be recreated --%>
  <%-- with as many elements as there were waste types. The elements --%>
  <%-- associated with an unselected waste types will have a blank string --%>
  <%-- added. E.g. a selected waste type will have an element with the --%>
  <%-- selected types name, but an unselected one will have "". --%>
  <%-- the waste_qtys array is fine as all the elements are 0 by default --%>
  <%-- but a check will have to be made to make sure that a user has not --%>
  <%-- blanked one of the quantities. --%>
  <% String[] waste_types = wasteTypesBean.getWaste_types(); %>
  <% String[] waste_qtys = wasteTypesBean.getWaste_qtys(); %>
  <% String[] waste_type_list = wasteTypesBean.getWaste_type_list(); %>
  <% boolean clear_waste_type = true; %>
  <% boolean error_no_qty = false; %>
  <% boolean error_neg_qty = false; %>
  <%-- Check the selected waste types --%>
  <%
    if (waste_types != null) {
      // do a check?
    }
  %>
 
  <%-- looping through the quantities to check for errors --%>
  <%
    if (waste_qtys != null) {
      error_no_qty = false;
      error_neg_qty = false;
      for(int i=0; i < waste_qtys.length; i++) {
        // check for a blank quantity
        if (waste_qtys[i].trim().equals("")) {
          error_no_qty = true;
        }
        // check for a negative quantity
        if ((! waste_qtys[i].trim().equals("")) && Integer.parseInt(waste_qtys[i].trim()) < 0) {
          error_neg_qty = true;
        }
      }
    }
  %>
 
  <%-- rebuilding the selected waste_type array so that it has the same number --%>
  <%-- of elements as the waste_type_list array, with the unselected elements --%>
  <%-- as blank strings. --%>
  <%
    if (waste_type_list != null) {
      for(int i=0; i < waste_type_list.length; i++) {
        clear_waste_type = true;
        // loop through the selected list of waste types to
        // see if any of them match.
        if (waste_types != null) {
          for(int j=0; j < waste_types.length; j++) {
            // found a match so don't clear this element from
            // the waste_type_list array.
            if (waste_type_list[i].equals(waste_types[j])) {
              clear_waste_type = false;
              break;
            }
          }
          // No match found, so this element was not selected, so 
          // blank the element.
          if (clear_waste_type == true) {
            waste_type_list[i] = "";
          }
        }
      }
      
      // if both the selected waste_types array and the waste_type_list
      // array exist then replace the wasteTypeBean's waste_types array.
      if (waste_types != null && waste_type_list != null) {
        wasteTypesBean.setWaste_types(waste_type_list);
      }
    }
  %>

  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= wasteTypesBean.getAction().equals("Enforce") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= error_no_qty == true %>' >
      <jsp:setProperty name="wasteTypesBean" property="error"
        value="Please supply a quantity for ALL the waste types." />
      <jsp:forward page="wasteTypesView.jsp" />
    </if:IfTrue>
    
    <if:IfTrue cond='<%= error_neg_qty == true %>' >
      <jsp:setProperty name="wasteTypesBean" property="error"
        value="Quantities must not be negative." />
      <jsp:forward page="wasteTypesView.jsp" />
    </if:IfTrue>
    
    <%-- Valid entry --%>
    <% recordBean.setEnforce_flag("Y"); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">wasteTypes</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">law</sess:setAttribute>
    <c:redirect url="lawScript.jsp" />
  </if:IfTrue>

  <%-- Next view 2 --%>
  <if:IfTrue cond='<%= wasteTypesBean.getAction().equals("W/O") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= error_no_qty == true %>' >
      <jsp:setProperty name="wasteTypesBean" property="error"
        value="Please supply a quantity for ALL the waste types." />
      <jsp:forward page="wasteTypesView.jsp" />
    </if:IfTrue>
    
    <if:IfTrue cond='<%= error_neg_qty == true %>' >
      <jsp:setProperty name="wasteTypesBean" property="error"
        value="Quantities must not be negative." />
      <jsp:forward page="wasteTypesView.jsp" />
    </if:IfTrue>
    
    <%-- Valid entry --%>
    <% recordBean.setEnforce_flag("N"); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">wasteTypes</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">contract</sess:setAttribute>
    <c:redirect url="contractScript.jsp" />
  </if:IfTrue>

  <%-- Next view 3 --%>
  <if:IfTrue cond='<%= wasteTypesBean.getAction().equals("Add Text") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= error_no_qty == true %>' >
      <jsp:setProperty name="wasteTypesBean" property="error"
        value="Please supply a quantity for ALL the waste types." />
      <jsp:forward page="wasteTypesView.jsp" />
    </if:IfTrue>
    
    <if:IfTrue cond='<%= error_neg_qty == true %>' >
      <jsp:setProperty name="wasteTypesBean" property="error"
        value="Quantities must not be negative." />
      <jsp:forward page="wasteTypesView.jsp" />
    </if:IfTrue>
    
    <%-- Valid entry --%>
    <% recordBean.setEnforce_flag("N"); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">wasteTypes</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">text</sess:setAttribute>
    <c:redirect url="textScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= wasteTypesBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">wasteTypes</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= wasteTypesBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">wasteTypes</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= wasteTypesBean.getAction().equals("Back") %>' >
    <% recordBean.setEnforce_flag("N"); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">wasteTypes</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= wasteTypesBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${wasteTypesBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="wasteTypesView.jsp" />
