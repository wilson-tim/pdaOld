<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.dartDetailsBean, com.vsb.recordBean, com.vsb.helperBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="dartDetailsBean" scope="session" class="com.vsb.dartDetailsBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="dartDetails" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="dartDetails" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="dartDetailsBean" property="all" value="clear" />
    <jsp:setProperty name="dartDetailsBean" property="*" />

    <%-- make sure all the none ticked checkbox attributes are set to "N" --%>
    <if:IfTrue cond="<%= dartDetailsBean.getRefuse_pay().equals("") %>">
      <% dartDetailsBean.setRefuse_pay("N"); %>
    </if:IfTrue>
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="dartDetailsBean" property="error" value="" />

<%-- Flag to initialize Bean --%>
<% boolean init_bean = false; %>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="compSampDetails" >
  <jsp:setProperty name="dartDetailsBean" property="action" value="" />
  <jsp:setProperty name="dartDetailsBean" property="all" value="clear" />
  <jsp:setProperty name="dartDetailsBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <% init_bean = true; %>
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="addDartDetails" >
  <jsp:setProperty name="dartDetailsBean" property="action" value="" />
  <jsp:setProperty name="dartDetailsBean" property="all" value="clear" />
  <jsp:setProperty name="dartDetailsBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <% init_bean = true; %>
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="dartDetails" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <if:IfTrue cond='<%= init_bean == true %>' >    
      <%-- Initialise the form bean by populating the form bean with the values from the record --%>
      <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />    
      <sql:statement id="stmt" conn="con">
        <sql:query>
          select rep_needle_qty, rep_crack_pipe_qty, rep_condom_qty, 
            col_needle_qty, col_crack_pipe_qty, col_condom_qty,
            wo_est_cost, refuse_pay, est_duration_h, est_duration_m
          from comp_dart_header
          where complaint_no = '<%= recordBean.getComplaint_no() %>'
        </sql:query>
        <sql:resultSet id="rsetlist">
          <sql:getColumn position="1" to="rep_needle_qty" />
          <% dartDetailsBean.setRep_needle_qty((String)pageContext.getAttribute("rep_needle_qty")); %>
          <sql:wasNull>
            <% dartDetailsBean.setRep_needle_qty("0"); %>
          </sql:wasNull>
          
          <sql:getColumn position="2" to="rep_crack_pipe_qty" />
          <% dartDetailsBean.setRep_crack_pipe_qty((String)pageContext.getAttribute("rep_crack_pipe_qty")); %>
          <sql:wasNull>
            <% dartDetailsBean.setRep_crack_pipe_qty("0"); %>
          </sql:wasNull>
          
          <sql:getColumn position="3" to="rep_condom_qty" />
          <% dartDetailsBean.setRep_condom_qty((String)pageContext.getAttribute("rep_condom_qty")); %>
          <sql:wasNull>
            <% dartDetailsBean.setRep_condom_qty("0"); %>
          </sql:wasNull>
          
          <sql:getColumn position="4" to="col_needle_qty" />
          <% dartDetailsBean.setCol_needle_qty((String)pageContext.getAttribute("col_needle_qty")); %>
          <sql:wasNull>
            <% dartDetailsBean.setCol_needle_qty("0"); %>
          </sql:wasNull>
          
          <sql:getColumn position="5" to="col_crack_pipe_qty" />
          <% dartDetailsBean.setCol_crack_pipe_qty((String)pageContext.getAttribute("col_crack_pipe_qty")); %>
          <sql:wasNull>
            <% dartDetailsBean.setCol_crack_pipe_qty("0"); %>
          </sql:wasNull>
          
          <sql:getColumn position="6" to="col_condom_qty" />
          <% dartDetailsBean.setCol_condom_qty((String)pageContext.getAttribute("col_condom_qty")); %>
          <sql:wasNull>
            <% dartDetailsBean.setCol_condom_qty("0"); %>
          </sql:wasNull>
  
          <sql:getColumn position="7" to="wo_est_cost" />
          <% dartDetailsBean.setWo_est_cost((String)pageContext.getAttribute("wo_est_cost")); %>
          <sql:wasNull>
            <% dartDetailsBean.setWo_est_cost("0"); %>
          </sql:wasNull>
  
          <sql:getColumn position="8" to="refuse_pay" />
          <% dartDetailsBean.setRefuse_pay((String)pageContext.getAttribute("refuse_pay")); %>
          <sql:wasNull>
            <% dartDetailsBean.setRefuse_pay(""); %>
          </sql:wasNull>
  
          <sql:getColumn position="9" to="est_duration_h" />
          <% dartDetailsBean.setEst_duration_h((String)pageContext.getAttribute("est_duration_h")); %>
          <sql:wasNull>
            <% dartDetailsBean.setEst_duration_h(""); %>
          </sql:wasNull>
  
          <sql:getColumn position="10" to="est_duration_m" />
          <% dartDetailsBean.setEst_duration_m((String)pageContext.getAttribute("est_duration_m")); %>
          <sql:wasNull>
            <% dartDetailsBean.setEst_duration_m(""); %>
          </sql:wasNull>
        </sql:resultSet>
  
        <sql:wasEmpty>
          <% dartDetailsBean.setRep_needle_qty("0"); %>
          <% dartDetailsBean.setRep_crack_pipe_qty("0"); %>
          <% dartDetailsBean.setRep_condom_qty("0"); %>
          <% dartDetailsBean.setCol_needle_qty("0"); %>
          <% dartDetailsBean.setCol_crack_pipe_qty("0"); %>
          <% dartDetailsBean.setCol_condom_qty("0"); %>
          <% dartDetailsBean.setWo_est_cost("0"); %>
          <% dartDetailsBean.setRefuse_pay(""); %>
          <% dartDetailsBean.setEst_duration_h(""); %>
          <% dartDetailsBean.setEst_duration_m(""); %>
        </sql:wasEmpty>
  
        <% int i = 0; %>
        
        <%-- Reported Categories --%>
        <% String[] rep_cats = new String[50]; %>
        <% i = 0; %>
        <sql:query>
          select lookup_code
          from comp_dart_detail
          where lookup_func = 'DRTREP'
          and   complaint_no = '<%= recordBean.getComplaint_no() %>'
          order by lookup_code
        </sql:query>
        <sql:resultSet id="rsetlist">
          <sql:getColumn position="1" to="lookup_code" />
          <% rep_cats[i] = ((String)pageContext.getAttribute("lookup_code")).trim(); %>
          <% i = i + 1; %>
        </sql:resultSet>
        <sql:wasEmpty>
          <% rep_cats = null; %>
        </sql:wasEmpty>
        <% dartDetailsBean.setRep_cats(rep_cats); %>
  
        <%-- Drug Paraphernalia --%>
        <% String[] drug_para = new String[50]; %>
        <% i = 0; %>
        <sql:query>
          select lookup_code
          from comp_dart_detail
          where lookup_func = 'DRTPAR'
          and   complaint_no = '<%= recordBean.getComplaint_no() %>'
          order by lookup_code
        </sql:query>
        <sql:resultSet id="rsetlist">
          <sql:getColumn position="1" to="lookup_code" />
          <% drug_para[i] = ((String)pageContext.getAttribute("lookup_code")).trim(); %>
          <% i = i + 1; %>
        </sql:resultSet>
        <sql:wasEmpty>
          <% drug_para = null; %>
        </sql:wasEmpty>
        <% dartDetailsBean.setDrug_para(drug_para); %>
        
        <%-- Anti-social waste washdown --%>
        <% String[] asww_cats = new String[50]; %>
        <% i = 0; %>
        <sql:query>
          select lookup_code
          from comp_dart_detail
          where lookup_func = 'DRTASW'
          and   complaint_no = '<%= recordBean.getComplaint_no() %>'
          order by lookup_code
        </sql:query>
        <sql:resultSet id="rsetlist">
          <sql:getColumn position="1" to="lookup_code" />
          <% asww_cats[i] = ((String)pageContext.getAttribute("lookup_code")).trim(); %>
          <% i = i + 1; %>
        </sql:resultSet>
        <sql:wasEmpty>
          <% asww_cats = null; %>
        </sql:wasEmpty>
        <% dartDetailsBean.setAsww_cats(asww_cats); %>
  
        <%-- Abusive behaviour encountered --%>
        <% String[] abuse_cats = new String[50]; %>
        <% i = 0; %>
        <sql:query>
          select lookup_code
          from comp_dart_detail
          where lookup_func = 'ABUSE'
          and   complaint_no = '<%= recordBean.getComplaint_no() %>'
          order by lookup_code
        </sql:query>
        <sql:resultSet id="rsetlist">
          <sql:getColumn position="1" to="lookup_code" />
          <% abuse_cats[i] = ((String)pageContext.getAttribute("lookup_code")).trim(); %>
          <% i = i + 1; %>
        </sql:resultSet>
        <sql:wasEmpty>
          <% abuse_cats = null; %>
        </sql:wasEmpty>
        <% dartDetailsBean.setAbuse_cats(abuse_cats); %>
      </sql:statement>
      <sql:closeConnection conn="con"/>

    </if:IfTrue>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="dartDetails" >
  <%-- Only do validation if we are not trying to go back or jump --%>
  <if:IfTrue cond='<%= ! dartDetailsBean.getAction().equals("Back") && ! dartDetailsBean.getAction().equals("Inspect") && ! dartDetailsBean.getAction().equals("Sched/Comp") %>' >

    <%-- needle/crack pipe, condom quantity validation --%>
    <if:IfTrue cond='<%= dartDetailsBean.getRep_needle_qty() != null && !dartDetailsBean.getRep_needle_qty().equals("") && !helperBean.isStringInt(dartDetailsBean.getRep_needle_qty()) %>' >
      <jsp:setProperty name="dartDetailsBean" property="error"
        value="If supplying a reported needle quantity, it must be an integer." />
      <jsp:forward page="dartDetailsView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= dartDetailsBean.getRep_crack_pipe_qty() != null && !dartDetailsBean.getRep_crack_pipe_qty().equals("") && !helperBean.isStringInt(dartDetailsBean.getRep_crack_pipe_qty()) %>' >
      <jsp:setProperty name="dartDetailsBean" property="error"
        value="If supplying a reported crack pipe quantity, it must be an integer." />
      <jsp:forward page="dartDetailsView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= dartDetailsBean.getRep_condom_qty() != null && !dartDetailsBean.getRep_condom_qty().equals("") && !helperBean.isStringInt(dartDetailsBean.getRep_condom_qty()) %>' >
      <jsp:setProperty name="dartDetailsBean" property="error"
        value="If supplying a reported condom quantity, it must be an integer." />
      <jsp:forward page="dartDetailsView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= dartDetailsBean.getCol_needle_qty() != null && !dartDetailsBean.getCol_needle_qty().equals("") && !helperBean.isStringInt(dartDetailsBean.getCol_needle_qty()) %>' >
      <jsp:setProperty name="dartDetailsBean" property="error"
        value="If supplying a collected needle quantity, it must be an integer." />
      <jsp:forward page="dartDetailsView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= dartDetailsBean.getCol_crack_pipe_qty() != null && !dartDetailsBean.getCol_crack_pipe_qty().equals("") && !helperBean.isStringInt(dartDetailsBean.getCol_crack_pipe_qty()) %>' >
      <jsp:setProperty name="dartDetailsBean" property="error"
        value="If supplying a collected crack pipe quantity, it must be an integer." />
      <jsp:forward page="dartDetailsView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= dartDetailsBean.getCol_condom_qty() != null && !dartDetailsBean.getCol_condom_qty().equals("") && !helperBean.isStringInt(dartDetailsBean.getCol_condom_qty()) %>' >
      <jsp:setProperty name="dartDetailsBean" property="error"
        value="If supplying a collected condom quantity, it must be an integer." />
      <jsp:forward page="dartDetailsView.jsp" />
    </if:IfTrue>

    <%-- works order estimated cost validation --%>
    <if:IfTrue cond='<%= dartDetailsBean.getWo_est_cost() != null && !dartDetailsBean.getWo_est_cost().equals("") && !helperBean.isStringDouble(dartDetailsBean.getWo_est_cost()) %>' >
      <jsp:setProperty name="dartDetailsBean" property="error"
        value="If supplying an estimated cost, it must be a number." />
      <jsp:forward page="dartDetailsView.jsp" />
    </if:IfTrue>

    <%-- works order duration field (hrs) validation --%>
    <if:IfTrue cond='<%= dartDetailsBean.getEst_duration_h() != null && !dartDetailsBean.getEst_duration_h().equals("") && !helperBean.isStringInt(dartDetailsBean.getEst_duration_h()) %>' >
      <jsp:setProperty name="dartDetailsBean" property="error"
        value="If supplying a duration (hrs), it must be an integer." />
      <jsp:forward page="dartDetailsView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= dartDetailsBean.getEst_duration_h() != null && !dartDetailsBean.getEst_duration_h().equals("") && Integer.parseInt(dartDetailsBean.getEst_duration_h()) <= 0 %>' >
      <jsp:setProperty name="dartDetailsBean" property="error"
        value="If supplying a duration (hrs), it must be greater than zero." />
      <jsp:forward page="dartDetailsView.jsp" />
    </if:IfTrue>
    
    <%-- works order duration field (mins) validation --%>
    <if:IfTrue cond='<%= dartDetailsBean.getEst_duration_m() != null && !dartDetailsBean.getEst_duration_m().equals("") && !helperBean.isStringInt(dartDetailsBean.getEst_duration_m()) %>' >
      <jsp:setProperty name="dartDetailsBean" property="error"
        value="If supplying a duration (mins), it must be an integer." />
      <jsp:forward page="dartDetailsView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= dartDetailsBean.getEst_duration_m() != null && !dartDetailsBean.getEst_duration_m().equals("") && Integer.parseInt(dartDetailsBean.getEst_duration_m()) <= 0 %>' >
      <jsp:setProperty name="dartDetailsBean" property="error"
        value="If supplying a duration (mins), it must be greater than zero." />
      <jsp:forward page="dartDetailsView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond='<%= dartDetailsBean.getEst_duration_m() != null && !dartDetailsBean.getEst_duration_m().equals("") && Integer.parseInt(dartDetailsBean.getEst_duration_m()) >= 60 %>' >
      <jsp:setProperty name="dartDetailsBean" property="error"
        value="If supplying a duration (mins), it must be less than 60." />
      <jsp:forward page="dartDetailsView.jsp" />
    </if:IfTrue>
  </if:IfTrue>

  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= dartDetailsBean.getAction().equals("Finish") %>' >
    <%-- Invalid entry --%>
    <%-- Already done above --%>

    <%-- Valid entry --%>
    <%-- add dart details --%>
    <sess:setAttribute name="form">addDartGraffFunc</sess:setAttribute>
    <c:import url="addDartGraffFunc.jsp" var="webPage" />
    <% helperBean.throwException((String)pageContext.getAttribute("webPage")); %>

    <%-- add complaint text --%>
    <sess:setAttribute name="form">addTextFunc</sess:setAttribute>
    <c:import url="addTextFunc.jsp" var="webPage" />
    <% helperBean.throwException((String)pageContext.getAttribute("webPage")); %>

    <%-- run the veolia link if required --%>
    <sess:setAttribute name="form">veoliaLinkFunc</sess:setAttribute>
    <c:import url="veoliaLinkFunc.jsp" var="webPage" />
    <% helperBean.throwException("veoliaLinkFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">dartDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">updateStatus</sess:setAttribute>
    <c:redirect url="updateStatusScript.jsp" />
  </if:IfTrue>

  <%-- Next view 2 --%>
  <if:IfTrue cond='<%= dartDetailsBean.getAction().equals("Chargeable") %>' >
    <%-- Invalid entry --%>
    <%-- Already done above --%>

    <%-- Valid entry --%>
    <% recordBean.setCharge_flag("Y"); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">dartDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">contract</sess:setAttribute>
    <c:redirect url="contractScript.jsp" />
  </if:IfTrue>

  <%-- Next view 3 --%>
  <if:IfTrue cond='<%= dartDetailsBean.getAction().equals("Text") %>' >
    <%-- Invalid entry --%>
    <%-- Already done above --%>

    <%-- Valid entry --%>
    <% recordBean.setCharge_flag("N"); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">dartDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">addEnforcement</sess:setAttribute>
    <c:redirect url="addEnforcementScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= dartDetailsBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">dartDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= dartDetailsBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">dartDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= dartDetailsBean.getAction().equals("Back") %>' >
    <% recordBean.setCharge_flag("N"); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">dartDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= dartDetailsBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${dartDetailsBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="dartDetailsView.jsp" />
