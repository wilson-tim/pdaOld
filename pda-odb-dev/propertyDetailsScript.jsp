<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.propertyDetailsBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="propertyDetailsBean" scope="session" class="com.vsb.propertyDetailsBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="propertyDetails" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="propertyDetails" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="propertyDetailsBean" property="all" value="clear" />
    <jsp:setProperty name="propertyDetailsBean" property="*" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="propertyDetailsBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="locLookup" >
  <jsp:setProperty name="propertyDetailsBean" property="action" value="" />
  <jsp:setProperty name="propertyDetailsBean" property="all" value="clear" />
  <jsp:setProperty name="propertyDetailsBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="propertyDetails" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <%-- code to run --%>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="propertyDetails" >
  <%-- Show hide the various parts of the Details --%>
  <%-- Do none Action buttons before Action buttons, as the Action will be triggered otherwise --%>
  <%-- as it is not cleared from the Bean between submits. --%>
  <%-- Business Rates buttons --%>
  <if:IfTrue cond='<%= ! propertyDetailsBean.getBr_vo_descrip_action().equals("") %>' >
    <if:IfTrue cond='<%= propertyDetailsBean.getBr_vo_descrip().equals(propertyDetailsBean.getBr_vo_descrip_action()) %>' >
      <% propertyDetailsBean.setBr_vo_descrip(""); %>
      <jsp:forward page="propertyDetailsView.jsp">
        <jsp:param name="anchor" value="<%= propertyDetailsBean.getBr_vo_descrip_action() %>" />
      </jsp:forward>
    </if:IfTrue>
    <if:IfTrue cond='<%= ! propertyDetailsBean.getBr_vo_descrip().equals(propertyDetailsBean.getBr_vo_descrip_action()) %>' >
      <% propertyDetailsBean.setBr_vo_descrip(propertyDetailsBean.getBr_vo_descrip_action()); %>
      <jsp:forward page="propertyDetailsView.jsp">
        <jsp:param name="anchor" value="<%= propertyDetailsBean.getBr_vo_descrip_action() %>" />
      </jsp:forward>
    </if:IfTrue>
  </if:IfTrue>

  <if:IfTrue cond='<%= ! propertyDetailsBean.getBr_account_holder_action().equals("") %>' >
    <if:IfTrue cond='<%= propertyDetailsBean.getBr_account_holder().equals(propertyDetailsBean.getBr_account_holder_action()) %>' >
      <% propertyDetailsBean.setBr_account_holder(""); %>
      <jsp:forward page="propertyDetailsView.jsp">
        <jsp:param name="anchor" value="<%= propertyDetailsBean.getBr_account_holder_action() %>" />
      </jsp:forward>
    </if:IfTrue>
    <if:IfTrue cond='<%= ! propertyDetailsBean.getBr_account_holder().equals(propertyDetailsBean.getBr_account_holder_action()) %>' >
      <% propertyDetailsBean.setBr_account_holder(propertyDetailsBean.getBr_account_holder_action()); %>
      <jsp:forward page="propertyDetailsView.jsp">
        <jsp:param name="anchor" value="<%= propertyDetailsBean.getBr_account_holder_action() %>" />
      </jsp:forward>
    </if:IfTrue>
  </if:IfTrue>

  <%-- Private Contracts buttons --%>
  <if:IfTrue cond='<%= ! propertyDetailsBean.getPc_last_updated_action().equals("") %>' >
    <if:IfTrue cond='<%= propertyDetailsBean.getPc_last_updated().equals(propertyDetailsBean.getPc_last_updated_action()) %>' >
      <% propertyDetailsBean.setPc_last_updated(""); %>
      <jsp:forward page="propertyDetailsView.jsp">
        <jsp:param name="anchor" value="<%= propertyDetailsBean.getPc_last_updated_action() %>" />
      </jsp:forward>
    </if:IfTrue>
    <if:IfTrue cond='<%= ! propertyDetailsBean.getPc_last_updated().equals(propertyDetailsBean.getPc_last_updated_action()) %>' >
      <% propertyDetailsBean.setPc_last_updated(propertyDetailsBean.getPc_last_updated_action()); %>
      <jsp:forward page="propertyDetailsView.jsp">
        <jsp:param name="anchor" value="<%= propertyDetailsBean.getPc_last_updated_action() %>" />
      </jsp:forward>
    </if:IfTrue>
  </if:IfTrue>

  <if:IfTrue cond='<%= ! propertyDetailsBean.getPc_origin_action().equals("") %>' >
    <if:IfTrue cond='<%= propertyDetailsBean.getPc_origin().equals(propertyDetailsBean.getPc_origin_action()) %>' >
      <% propertyDetailsBean.setPc_origin(""); %>
      <jsp:forward page="propertyDetailsView.jsp">
        <jsp:param name="anchor" value="<%= propertyDetailsBean.getPc_origin_action() %>" />
      </jsp:forward>
    </if:IfTrue>
    <if:IfTrue cond='<%= ! propertyDetailsBean.getPc_origin().equals(propertyDetailsBean.getPc_origin_action()) %>' >
      <% propertyDetailsBean.setPc_origin(propertyDetailsBean.getPc_origin_action()); %>
      <jsp:forward page="propertyDetailsView.jsp">
        <jsp:param name="anchor" value="<%= propertyDetailsBean.getPc_origin_action() %>" />
      </jsp:forward>
    </if:IfTrue>
  </if:IfTrue>

  <if:IfTrue cond='<%= ! propertyDetailsBean.getPc_business_name_action().equals("") %>' >
    <if:IfTrue cond='<%= propertyDetailsBean.getPc_business_name().equals(propertyDetailsBean.getPc_business_name_action()) %>' >
      <% propertyDetailsBean.setPc_business_name(""); %>
      <jsp:forward page="propertyDetailsView.jsp">
        <jsp:param name="anchor" value="<%= propertyDetailsBean.getPc_business_name_action() %>" />
      </jsp:forward>
    </if:IfTrue>
    <if:IfTrue cond='<%= ! propertyDetailsBean.getPc_business_name().equals(propertyDetailsBean.getPc_business_name_action()) %>' >
      <% propertyDetailsBean.setPc_business_name(propertyDetailsBean.getPc_business_name_action()); %>
      <jsp:forward page="propertyDetailsView.jsp">
        <jsp:param name="anchor" value="<%= propertyDetailsBean.getPc_business_name_action() %>" />
      </jsp:forward>
    </if:IfTrue>
  </if:IfTrue>

  <%-- Existing Contracts buttons --%>
  <if:IfTrue cond='<%= ! propertyDetailsBean.getEc_start_date_action().equals("") %>' >
    <if:IfTrue cond='<%= propertyDetailsBean.getEc_start_date().equals(propertyDetailsBean.getEc_start_date_action()) %>' >
      <% propertyDetailsBean.setEc_start_date(""); %>
      <jsp:forward page="propertyDetailsView.jsp">
        <jsp:param name="anchor" value="<%= propertyDetailsBean.getEc_start_date_action() %>" />
      </jsp:forward>
    </if:IfTrue>
    <if:IfTrue cond='<%= ! propertyDetailsBean.getEc_start_date().equals(propertyDetailsBean.getEc_start_date_action()) %>' >
      <% propertyDetailsBean.setEc_start_date(propertyDetailsBean.getEc_start_date_action()); %>
      <jsp:forward page="propertyDetailsView.jsp">
        <jsp:param name="anchor" value="<%= propertyDetailsBean.getEc_start_date_action() %>" />
      </jsp:forward>
    </if:IfTrue>
  </if:IfTrue>

  <if:IfTrue cond='<%= ! propertyDetailsBean.getEc_origin_action().equals("") %>' >
    <if:IfTrue cond='<%= propertyDetailsBean.getEc_origin().equals(propertyDetailsBean.getEc_origin_action()) %>' >
      <% propertyDetailsBean.setEc_origin(""); %>
      <jsp:forward page="propertyDetailsView.jsp">
        <jsp:param name="anchor" value="<%= propertyDetailsBean.getEc_origin_action() %>" />
      </jsp:forward>
    </if:IfTrue>
    <if:IfTrue cond='<%= ! propertyDetailsBean.getEc_origin().equals(propertyDetailsBean.getEc_origin_action()) %>' >
      <% propertyDetailsBean.setEc_origin(propertyDetailsBean.getEc_origin_action()); %>
      <jsp:forward page="propertyDetailsView.jsp">
        <jsp:param name="anchor" value="<%= propertyDetailsBean.getEc_origin_action() %>" />
      </jsp:forward>
    </if:IfTrue>
  </if:IfTrue>

  <if:IfTrue cond='<%= ! propertyDetailsBean.getEc_business_name_action().equals("") %>' >
    <if:IfTrue cond='<%= propertyDetailsBean.getEc_business_name().equals(propertyDetailsBean.getEc_business_name_action()) %>' >
      <% propertyDetailsBean.setEc_business_name(""); %>
      <jsp:forward page="propertyDetailsView.jsp">
        <jsp:param name="anchor" value="<%= propertyDetailsBean.getEc_business_name_action() %>" />
      </jsp:forward>
    </if:IfTrue>
    <if:IfTrue cond='<%= ! propertyDetailsBean.getEc_business_name().equals(propertyDetailsBean.getEc_business_name_action()) %>' >
      <% propertyDetailsBean.setEc_business_name(propertyDetailsBean.getEc_business_name_action()); %>
      <jsp:forward page="propertyDetailsView.jsp">
        <jsp:param name="anchor" value="<%= propertyDetailsBean.getEc_business_name_action() %>" />
      </jsp:forward>
    </if:IfTrue>
  </if:IfTrue>

  <%-- Customer Care buttons --%>
  <if:IfTrue cond='<%= ! propertyDetailsBean.getCc_date_entered_action().equals("") %>' >
    <if:IfTrue cond='<%= propertyDetailsBean.getCc_date_entered().equals(propertyDetailsBean.getCc_date_entered_action()) %>' >
      <% propertyDetailsBean.setCc_date_entered(""); %>
      <jsp:forward page="propertyDetailsView.jsp">
        <jsp:param name="anchor" value="<%= propertyDetailsBean.getCc_date_entered_action() %>" />
      </jsp:forward>
    </if:IfTrue>
    <if:IfTrue cond='<%= ! propertyDetailsBean.getCc_date_entered().equals(propertyDetailsBean.getCc_date_entered_action()) %>' >
      <% propertyDetailsBean.setCc_date_entered(propertyDetailsBean.getCc_date_entered_action()); %>
      <jsp:forward page="propertyDetailsView.jsp">
        <jsp:param name="anchor" value="<%= propertyDetailsBean.getCc_date_entered_action() %>" />
      </jsp:forward>
    </if:IfTrue>
  </if:IfTrue>

  <if:IfTrue cond='<%= ! propertyDetailsBean.getCc_entered_by_action().equals("") %>' >
    <if:IfTrue cond='<%= propertyDetailsBean.getCc_entered_by().equals(propertyDetailsBean.getCc_entered_by_action()) %>' >
      <% propertyDetailsBean.setCc_entered_by(""); %>
      <jsp:forward page="propertyDetailsView.jsp">
        <jsp:param name="anchor" value="<%= propertyDetailsBean.getCc_entered_by_action() %>" />
      </jsp:forward>
    </if:IfTrue>
    <if:IfTrue cond='<%= ! propertyDetailsBean.getCc_entered_by().equals(propertyDetailsBean.getCc_entered_by_action()) %>' >
      <% propertyDetailsBean.setCc_entered_by(propertyDetailsBean.getCc_entered_by_action()); %>
      <jsp:forward page="propertyDetailsView.jsp">
        <jsp:param name="anchor" value="<%= propertyDetailsBean.getCc_entered_by_action() %>" />
      </jsp:forward>
    </if:IfTrue>
  </if:IfTrue>

  <if:IfTrue cond='<%= ! propertyDetailsBean.getCc_received_by_action().equals("") %>' >
    <if:IfTrue cond='<%= propertyDetailsBean.getCc_received_by().equals(propertyDetailsBean.getCc_received_by_action()) %>' >
      <% propertyDetailsBean.setCc_received_by(""); %>
      <jsp:forward page="propertyDetailsView.jsp">
        <jsp:param name="anchor" value="<%= propertyDetailsBean.getCc_received_by_action() %>" />
      </jsp:forward>
    </if:IfTrue>
    <if:IfTrue cond='<%= ! propertyDetailsBean.getCc_received_by().equals(propertyDetailsBean.getCc_received_by_action()) %>' >
      <% propertyDetailsBean.setCc_received_by(propertyDetailsBean.getCc_received_by_action()); %>
      <jsp:forward page="propertyDetailsView.jsp">
        <jsp:param name="anchor" value="<%= propertyDetailsBean.getCc_received_by_action() %>" />
      </jsp:forward>
    </if:IfTrue>
  </if:IfTrue>

  <if:IfTrue cond='<%= ! propertyDetailsBean.getCc_item_action().equals("") %>' >
    <if:IfTrue cond='<%= propertyDetailsBean.getCc_item().equals(propertyDetailsBean.getCc_item_action()) %>' >
      <% propertyDetailsBean.setCc_item(""); %>
      <jsp:forward page="propertyDetailsView.jsp">
        <jsp:param name="anchor" value="<%= propertyDetailsBean.getCc_item_action() %>" />
      </jsp:forward>
    </if:IfTrue>
    <if:IfTrue cond='<%= ! propertyDetailsBean.getCc_item().equals(propertyDetailsBean.getCc_item_action()) %>' >
      <% propertyDetailsBean.setCc_item(propertyDetailsBean.getCc_item_action()); %>
      <jsp:forward page="propertyDetailsView.jsp">
        <jsp:param name="anchor" value="<%= propertyDetailsBean.getCc_item_action() %>" />
      </jsp:forward>
    </if:IfTrue>
  </if:IfTrue>

  <if:IfTrue cond='<%= ! propertyDetailsBean.getCc_fault_action().equals("") %>' >
    <if:IfTrue cond='<%= propertyDetailsBean.getCc_fault().equals(propertyDetailsBean.getCc_fault_action()) %>' >
      <% propertyDetailsBean.setCc_fault(""); %>
      <jsp:forward page="propertyDetailsView.jsp">
        <jsp:param name="anchor" value="<%= propertyDetailsBean.getCc_fault_action() %>" />
      </jsp:forward>
    </if:IfTrue>
    <if:IfTrue cond='<%= ! propertyDetailsBean.getCc_fault().equals(propertyDetailsBean.getCc_fault_action()) %>' >
      <% propertyDetailsBean.setCc_fault(propertyDetailsBean.getCc_fault_action()); %>
      <jsp:forward page="propertyDetailsView.jsp">
        <jsp:param name="anchor" value="<%= propertyDetailsBean.getCc_fault_action() %>" />
      </jsp:forward>
    </if:IfTrue>
  </if:IfTrue>

  <%-- Main sections buttons --%>
  <if:IfTrue cond='<%= propertyDetailsBean.getAction().equals("Summary") %>' >
    <if:IfTrue cond='<%= propertyDetailsBean.getSummary().equals("show") %>' >
      <% propertyDetailsBean.setSummary(""); %>
      <jsp:forward page="propertyDetailsView.jsp">
        <jsp:param name="anchor" value="<%= propertyDetailsBean.getAction() %>" />
      </jsp:forward>
    </if:IfTrue>
    <if:IfTrue cond='<%= propertyDetailsBean.getSummary().equals("") %>' >
      <% propertyDetailsBean.setSummary("show"); %>
      <jsp:forward page="propertyDetailsView.jsp">
        <jsp:param name="anchor" value="<%= propertyDetailsBean.getAction() %>" />
      </jsp:forward>
    </if:IfTrue>
  </if:IfTrue>

  <if:IfTrue cond='<%= propertyDetailsBean.getAction().equals("Business Rates") %>' >
    <if:IfTrue cond='<%= propertyDetailsBean.getBusiness_rates().equals("show") %>' >
      <% propertyDetailsBean.setBusiness_rates(""); %>
      <jsp:forward page="propertyDetailsView.jsp">
        <jsp:param name="anchor" value="<%= propertyDetailsBean.getAction() %>" />
      </jsp:forward>
    </if:IfTrue>
    <if:IfTrue cond='<%= propertyDetailsBean.getBusiness_rates().equals("") %>' >
      <% propertyDetailsBean.setBusiness_rates("show"); %>
      <jsp:forward page="propertyDetailsView.jsp">
        <jsp:param name="anchor" value="<%= propertyDetailsBean.getAction() %>" />
      </jsp:forward>
    </if:IfTrue>
  </if:IfTrue>

  <if:IfTrue cond='<%= propertyDetailsBean.getAction().equals("Private Contracts") %>' >
    <if:IfTrue cond='<%= propertyDetailsBean.getPrivate_contracts().equals("show") %>' >
      <% propertyDetailsBean.setPrivate_contracts(""); %>
      <jsp:forward page="propertyDetailsView.jsp">
        <jsp:param name="anchor" value="<%= propertyDetailsBean.getAction() %>" />
      </jsp:forward>
    </if:IfTrue>
    <if:IfTrue cond='<%= propertyDetailsBean.getPrivate_contracts().equals("") %>' >
      <% propertyDetailsBean.setPrivate_contracts("show"); %>
      <jsp:forward page="propertyDetailsView.jsp">
        <jsp:param name="anchor" value="<%= propertyDetailsBean.getAction() %>" />
      </jsp:forward>
    </if:IfTrue>
  </if:IfTrue>

  <if:IfTrue cond='<%= propertyDetailsBean.getAction().equals("Existing Contracts") %>' >
    <if:IfTrue cond='<%= propertyDetailsBean.getExisting_contracts().equals("show") %>' >
      <% propertyDetailsBean.setExisting_contracts(""); %>
      <jsp:forward page="propertyDetailsView.jsp">
        <jsp:param name="anchor" value="<%= propertyDetailsBean.getAction() %>" />
      </jsp:forward>
    </if:IfTrue>
    <if:IfTrue cond='<%= propertyDetailsBean.getExisting_contracts().equals("") %>' >
      <% propertyDetailsBean.setExisting_contracts("show"); %>
      <jsp:forward page="propertyDetailsView.jsp">
        <jsp:param name="anchor" value="<%= propertyDetailsBean.getAction() %>" />
      </jsp:forward>
    </if:IfTrue>
  </if:IfTrue>

  <if:IfTrue cond='<%= propertyDetailsBean.getAction().equals("Customer Care") %>' >
    <if:IfTrue cond='<%= propertyDetailsBean.getCustomer_care().equals("show") %>' >
      <% propertyDetailsBean.setCustomer_care(""); %>
      <jsp:forward page="propertyDetailsView.jsp">
        <jsp:param name="anchor" value="<%= propertyDetailsBean.getAction() %>" />
      </jsp:forward>
    </if:IfTrue>
    <if:IfTrue cond='<%= propertyDetailsBean.getCustomer_care().equals("") %>' >
      <% propertyDetailsBean.setCustomer_care("show"); %>
      <jsp:forward page="propertyDetailsView.jsp">
        <jsp:param name="anchor" value="<%= propertyDetailsBean.getAction() %>" />
      </jsp:forward>
    </if:IfTrue>
  </if:IfTrue>

  <%-- Next view --%>
  <if:IfTrue cond='<%= propertyDetailsBean.getAction().equals("Priv. Con.") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='#SOME-ERROR-CHECK#' >
      <jsp:setProperty name="propertyDetailsBean" property="error" value="#SOME-ERROR-MESSAGE#" />
      <jsp:forward page="propertyDetailsView.jsp" />
    </if:IfTrue>
    
    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">propertyDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">addPrivateContract</sess:setAttribute>
    <c:redirect url="addPrivateContractScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= propertyDetailsBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">propertyDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= propertyDetailsBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">propertyDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= propertyDetailsBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">propertyDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= propertyDetailsBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${propertyDetailsBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="propertyDetailsView.jsp" />
