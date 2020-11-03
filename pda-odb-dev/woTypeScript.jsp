<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.woTypeBean, com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="woTypeBean" scope="session" class="com.vsb.woTypeBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="woType" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="woType" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="woTypeBean" property="all" value="clear" />
    <jsp:setProperty name="woTypeBean" property="*" />
    
    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="wo_type_f" param="wo_type_f" />
    <jsp:setProperty name="recordBean" property="del_contact" param="del_contact" />
    <jsp:setProperty name="recordBean" property="del_phone" param="del_phone" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="woTypeBean" property="error" value="" />

<%-- Initialise the forward_direction variable, used in the skip section --%>
<% String forward_direction = "N"; %>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="suffix" >
  <jsp:setProperty name="woTypeBean" property="action" value="" />
  <jsp:setProperty name="woTypeBean" property="all" value="clear" />
  <jsp:setProperty name="woTypeBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <% forward_direction = "Y"; %>
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="woType" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <%-- Code to run --%>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Skip View Section --%>
<%-- Don't skip if coming from the view or skippin has not been turned on --%>
<sess:equalsAttribute name="input" match="woType" value="false">
  <app:equalsInitParameter name="use_wo_type_skip" match="Y">
    <%-- Set up variables --%>
    <% String defect_wo_type = ""; %>
    <% String wo_type_count = ""; %>
    <% String wo_type_f = ""; %>
   
    <%-- Get the count of wo_type records --%>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con">
      <sql:query>
        <app:equalsInitParameter name="limit_wo_type_by_suffix" match="Y">
          select count(distinct wo_type.wo_type_f)
          from wo_type, wo_s
          where wo_type.contract_ref = '<%= recordBean.getWo_contract_ref() %>'
          and wo_s.wo_suffix = '<%= recordBean.getWo_suffix() %>'
          and wo_type.contract_ref = wo_s.contract_ref
          and wo_type.wo_type_f = wo_s.wo_type_f
        </app:equalsInitParameter>
        <app:equalsInitParameter name="limit_wo_type_by_suffix" match="Y" value="false">
          select count(distinct wo_type.wo_type_f)
          from wo_type
          where wo_type.contract_ref = '<%= recordBean.getWo_contract_ref() %>'
        </app:equalsInitParameter>
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="wo_type_count" />
        <% wo_type_count = ((String) pageContext.getAttribute("wo_type_count")).trim(); %>
      </sql:resultSet>
  
      <sql:query>
        <app:equalsInitParameter name="limit_wo_type_by_suffix" match="Y">
          select distinct wo_type.wo_type_f
          from wo_type, wo_s
          where wo_type.contract_ref = '<%= recordBean.getWo_contract_ref() %>'
          and wo_s.wo_suffix = '<%= recordBean.getWo_suffix() %>'
          and wo_type.contract_ref = wo_s.contract_ref
          and wo_type.wo_type_f = wo_s.wo_type_f
        </app:equalsInitParameter>
        <app:equalsInitParameter name="limit_wo_type_by_suffix" match="Y" value="false">
          select distinct wo_type.wo_type_f
          from wo_type
          where wo_type.contract_ref = '<%= recordBean.getWo_contract_ref() %>'
        </app:equalsInitParameter>
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="wo_type_f" />
        <sql:wasNotNull>
          <% wo_type_f = ((String) pageContext.getAttribute("wo_type_f")).trim(); %>
        </sql:wasNotNull>
      </sql:resultSet>

      <sql:query>
        select distinct wo_type_f
        from measurement_task
        where priority = '<%= recordBean.getDefect_priority() %>'
        and   contract_ref = '<%= recordBean.getWo_contract_ref() %>'
        and   item_ref = '<%= recordBean.getItem_ref() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="wo_type_f" />
        <sql:wasNotNull>
          <% defect_wo_type = ((String) pageContext.getAttribute("wo_type_f")).trim(); %>
        </sql:wasNotNull>
      </sql:resultSet>
    </sql:statement>
    <sql:closeConnection conn="con"/>
 
    <%-- Set up a variable to to show if defects are being used --%>
    <%
      boolean defect_flag = false;
      if(recordBean.getDefect_flag().equals("Y") || recordBean.getDefect_flag().equals("A") || recordBean.getDefect_flag().equals("I")) {
       defect_flag = true;
      };
    %>

    <%-- Only skip if allowed. --%>
    <if:IfTrue cond='<%= (!defect_flag && wo_type_count.equals("1")) || (defect_flag && !defect_wo_type.equals("")) %>' >
      <%-- skip to the next page, by faking it so that it appears the user --%>
      <%-- has just processd the page and clicked an action page button. --%>
      <%-- Do backwards skip first, as forward skip sets the 'input' session variable --%>
      <if:IfTrue cond='<%= forward_direction.equals("N") %>' >
        <%-- Indicate which form we are coming from when we forward to another form --%>
        <sess:setAttribute name="previousForm">woType</sess:setAttribute>
        <%-- Indicate which form we are going to next --%>
        <sess:setAttribute name="form"><%= woTypeBean.getSavedPreviousForm() %></sess:setAttribute>
        <c:redirect url="${woTypeBean.savedPreviousForm}Script.jsp" />
      </if:IfTrue>
      <%-- Do forwards skip --%>
      <if:IfTrue cond='<%= forward_direction.equals("Y") %>' >
        <%-- This section mimics the 'input' section at the top of the script --%>
        <%-- manually imitating a user interaction with the view, but without showing the view --%>
  
        <%-- Indicate which form we are in/just-come-from --%>
        <sess:setAttribute name="input">woType</sess:setAttribute>
  
        <%-- Setup the bean with the forms data manually --%>
        <jsp:setProperty name="woTypeBean" property="all" value="clear" />
        <jsp:setProperty name="woTypeBean" property="action" value="Next" />

        <if:IfTrue cond='<%= !defect_flag && wo_type_count.equals("1") %>' >
          <% woTypeBean.setWo_type_f(wo_type_f); %>
  
          <%-- Add the new values to the record --%>
          <% recordBean.setWo_type_f(wo_type_f); %>
          <% recordBean.setDel_contact(""); %>
          <% recordBean.setDel_phone(""); %>
        </if:IfTrue>
        <if:IfTrue cond='<%= defect_flag && !defect_wo_type.equals("") %>' >
          <% woTypeBean.setWo_type_f(defect_wo_type); %>
          <% recordBean.setWo_type_f(defect_wo_type); %>
          <% recordBean.setDel_contact(""); %>
          <% recordBean.setDel_phone(""); %>
        </if:IfTrue>

      </if:IfTrue>
    </if:IfTrue>
  </app:equalsInitParameter>
</sess:equalsAttribute>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="woType" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= woTypeBean.getAction().equals("Next") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= woTypeBean.getWo_type_f() == null || woTypeBean.getWo_type_f().equals("") %>' >
      <jsp:setProperty name="woTypeBean" property="error"
        value="Please choose a type." />
      <jsp:forward page="woTypeView.jsp" />
    </if:IfTrue>
    
    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">woType</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">woTask</sess:setAttribute>
    <c:redirect url="woTaskScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= woTypeBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">woType</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= woTypeBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">woType</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= woTypeBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">woType</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= woTypeBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${woTypeBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="woTypeView.jsp" />
