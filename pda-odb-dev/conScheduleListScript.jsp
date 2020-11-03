<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.conScheduleListBean, com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="conScheduleListBean" scope="session" class="com.vsb.conScheduleListBean" />


<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="conScheduleList" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="conScheduleList" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>

    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="conScheduleListBean" property="all" value="clear" />
    <jsp:setProperty name="conScheduleListBean" property="*" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="conScheduleListBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="mainMenu" >
  <jsp:setProperty name="conScheduleListBean" property="action" value="" />
  <jsp:setProperty name="conScheduleListBean" property="all" value="clear" />
  <jsp:setProperty name="conScheduleListBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="conScheduleList" >

  <%-- Next view 1 --%>
  <if:IfTrue cond='<%= conScheduleListBean.getAction().equals("Details") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%=conScheduleListBean.getWo_key() == null || conScheduleListBean.getWo_key().equals("") %>' >
      <jsp:setProperty name="conScheduleListBean" property="error"
        value="Please choose an item." />
      <jsp:forward page="conScheduleListView.jsp" />
    </if:IfTrue>

    <%-- Valid entry --%>    
    <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con1">
      <%-- get the W/O complaint link to ensure the bean is   --%>
      <%-- populated the same way for the conSumWODetailsView --%>      
      <sql:query>
        SELECT wo_h.wo_ref,
               wo_h.wo_suffix,
               work_schedule.quantity
          FROM wo_h,
               work_schedule
         WHERE wo_h.wo_key = '<%= conScheduleListBean.getWo_key() %>'
           AND work_schedule.wo_key = '<%= conScheduleListBean.getWo_key() %>'
      </sql:query>
      <sql:resultSet id="rset0">
        <sql:getColumn position="1" to="wo_ref" />
        <sql:wasNull>
          <% pageContext.setAttribute("wo_ref", ""); %>
        </sql:wasNull>        
        <% recordBean.setWo_ref((String) pageContext.getAttribute("wo_ref")); %>          
        <sql:getColumn position="2" to="wo_suffix" />
        <sql:wasNull>
          <% pageContext.setAttribute("wo_suffix", ""); %>
        </sql:wasNull>        
        <% recordBean.setWo_suffix((String) pageContext.getAttribute("wo_suffix")); %>
        <sql:getColumn position="3" to="work_sched_vol" />
        <sql:wasNull>
          <% pageContext.setAttribute("work_sched_vol", ""); %>
        </sql:wasNull>        
        <% recordBean.setWo_volume((String) pageContext.getAttribute("work_sched_vol")); %>                  
      </sql:resultSet>
    
      <%-- get the action_flag of the currently selected item --%>
      <sql:query>
        SELECT action_flag,
               recvd_by,
               exact_location,
               site_ref,
               service_c,
               complaint_no
          FROM comp
         WHERE dest_ref = <%= recordBean.getWo_ref() %>
           AND dest_suffix = '<%= recordBean.getWo_suffix() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="comp_action_flag" />
        <% recordBean.setComp_action_flag((String) pageContext.getAttribute("comp_action_flag")); %>
        <sql:getColumn position="2" to="comp_recvd_by" />
        <% recordBean.setSource_code((String) pageContext.getAttribute("comp_recvd_by")); %>
        <sql:getColumn position="3" to="comp_exact_location" />
        <% recordBean.setExact_location((String) pageContext.getAttribute("comp_exact_location")); %>                
        <sql:getColumn position="4" to="comp_site_ref" />
        <% recordBean.setSite_ref((String) pageContext.getAttribute("comp_site_ref")); %>
        <sql:getColumn position="5" to="service_c" />
        <% recordBean.setService_c((String) pageContext.getAttribute("service_c")); %>
        <sql:getColumn position="6" to="complaint_no" />
        <% recordBean.setComplaint_no((String) pageContext.getAttribute("complaint_no")); %>
      </sql:resultSet>

      <%-- Get the W/O information --%>
        <sql:query>
          SELECT service_c,
                 date_raised,
                 time_raised_h,
                 time_raised_m,
                 wo_h_stat,
                 wo_date_due,
	               contract_ref	 
           FROM wo_h
          WHERE wo_ref    = <%= recordBean.getWo_ref() %>
	          AND wo_suffix = '<%= recordBean.getWo_suffix() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="service_c" />
          <sql:wasNull>
            <% pageContext.setAttribute("service_c", ""); %>
          </sql:wasNull>
          <% recordBean.setComp_desc((String) pageContext.getAttribute("service_c")); %>
          <sql:getDate position="2" to="date_raised" format="<%= application.getInitParameter("db_date_fmt") %>" />
          <sql:wasNull>
            <% pageContext.setAttribute("date_raised", ""); %>
          </sql:wasNull>
          <% recordBean.setStart_date((String) pageContext.getAttribute("date_raised")); %>
          <sql:getColumn position="3" to="time_raised_h" />
          <sql:wasNull>
            <% pageContext.setAttribute("time_raised_h", ""); %>
          </sql:wasNull>
          <% recordBean.setStart_time_h((String) pageContext.getAttribute("time_raised_h")); %>
          <sql:getColumn position="4" to="time_raised_m" />
          <sql:wasNull>
            <% pageContext.setAttribute("time_raised_m", ""); %>
          </sql:wasNull>
          <% recordBean.setStart_time_m((String) pageContext.getAttribute("time_raised_m")); %>
          <sql:getColumn position="5" to="wo_h_stat" />
          <sql:wasNull>
            <% pageContext.setAttribute("wo_h_stat", ""); %>
          </sql:wasNull>	  
          <% recordBean.setWo_h_stat((String) pageContext.getAttribute("wo_h_stat")); %>
          <sql:getDate position="6" to="wo_date_due" format="<%= application.getInitParameter("db_date_fmt") %>" />
          <sql:wasNull>
            <% pageContext.setAttribute("wo_date_due", ""); %>
          </sql:wasNull>
          <% recordBean.setWo_date_due((String) pageContext.getAttribute("wo_date_due")); %>
          <sql:getColumn position="7" to="wo_contract_ref" />
          <sql:wasNull>
            <% pageContext.setAttribute("wo_contract_ref", ""); %>
          </sql:wasNull>
          <% recordBean.setWo_contract_ref((String) pageContext.getAttribute("wo_contract_ref")); %>	  
        </sql:resultSet>      

        <sql:query>
          SELECT compl_by,
                 cont_canc,
                 cont_rem1,
                 cont_rem2,
                 completion_date,
                 completion_time_h,
                 completion_time_m	 
          FROM wo_cont_h
          WHERE wo_ref    = '<%= recordBean.getWo_ref() %>'
	          AND wo_suffix = '<%= recordBean.getWo_suffix() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="compl_by" />
          <sql:wasNull>
            <% pageContext.setAttribute("compl_by", ""); %>
          </sql:wasNull>
          <% recordBean.setCompl_by((String) pageContext.getAttribute("compl_by")); %>
          <sql:getColumn position="2" to="cont_canc" />
          <sql:wasNull>
            <% pageContext.setAttribute("cont_canc", ""); %>
          </sql:wasNull>
          <% recordBean.setCont_canc((String) pageContext.getAttribute("cont_canc")); %>
          <sql:getColumn position="3" to="cont_rem1" />
          <sql:wasNull>
            <% pageContext.setAttribute("cont_rem1", ""); %>
          </sql:wasNull>
          <% recordBean.setCont_rem1((String) pageContext.getAttribute("cont_rem1")); %>
          <sql:getColumn position="4" to="cont_rem2" />
          <sql:wasNull>
            <% pageContext.setAttribute("cont_rem2", ""); %>
          </sql:wasNull>
          <% recordBean.setCont_rem2((String) pageContext.getAttribute("cont_rem2")); %>
          <sql:getDate position="5" to="completion_date" format="<%= application.getInitParameter("db_date_fmt") %>" />
          <sql:wasNull>
            <% pageContext.setAttribute("completion_date", ""); %>
          </sql:wasNull>	  
          <% recordBean.setCompletion_date((String) pageContext.getAttribute("completion_date")); %>
          <sql:getColumn position="6" to="completion_time_h" />
          <sql:wasNull>
            <% pageContext.setAttribute("completion_time_h", ""); %>
          </sql:wasNull>
          <% recordBean.setCompletion_time_h((String) pageContext.getAttribute("completion_time_h")); %>
          <sql:getColumn position="7" to="completion_time_m" />
          <sql:wasNull>
            <% pageContext.setAttribute("completion_time_m", ""); %>
          </sql:wasNull>
          <% recordBean.setCompletion_time_m((String) pageContext.getAttribute("completion_time_m")); %>	  
        </sql:resultSet>

        <sql:query>
          SELECT site_name_1, ward_code
          FROM site
          WHERE site_ref = '<%= recordBean.getSite_ref() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="site_name_1" />
          <% recordBean.setSite_name_1((String) pageContext.getAttribute("site_name_1")); %>
          <sql:getColumn position="2" to="ward_code" />
          <% recordBean.setWard_code((String) pageContext.getAttribute("ward_code")); %>
        </sql:resultSet>

        <sql:query>
          SELECT wo_stat_desc
          FROM wo_stat
          WHERE wo_h_stat  = '<%= recordBean.getWo_h_stat() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="wo_stat_desc" />
          <% recordBean.setWo_stat_desc((String) pageContext.getAttribute("wo_stat_desc")); %>
        </sql:resultSet>

    </sql:statement>
    <sql:closeConnection conn="con1"/>
    <%-- Redirect to conSumWODetails screen --%>
    <if:IfTrue cond='<%= recordBean.getComp_action_flag().equals("W") %>' >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">conScheduleList</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">conSumWODetails</sess:setAttribute>
      <c:redirect url="conSumWODetailsScript.jsp" />
    </if:IfTrue>
    
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= conScheduleListBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">conScheduleList</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= conScheduleListBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">conScheduleList</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= conScheduleListBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">conScheduleList</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= conScheduleListBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${conScheduleListBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="conScheduleListView.jsp" />
