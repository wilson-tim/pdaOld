<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.recMonMissedBean, com.vsb.recMonStreetsBean, com.vsb.loginBean" %>
<%@ page import="com.vsb.recordBean, com.vsb.helperBean, com.utils.date.dateBean" %>
<%@ page import="java.util.*" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="recMonMissedBean" scope="session" class="com.vsb.recMonMissedBean" />
<jsp:useBean id="recMonStreetsBean" scope="session" class="com.vsb.recMonStreetsBean" />
<jsp:useBean id="loginBean" scope="session" class="com.vsb.loginBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="recMonMissed" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Make sure this is the form we are supposed to be on --%>
<sess:equalsAttribute name="form" match="recMonMissed" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="recMonMissed" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="recMonMissedBean" property="all" value="clear" />
    <jsp:setProperty name="recMonMissedBean" property="*" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="recMonMissedBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="recMonStreets" >
  <jsp:setProperty name="recMonMissedBean" property="action" value="" />
  <jsp:setProperty name="recMonMissedBean" property="all" value="clear" />
  <jsp:setProperty name="recMonMissedBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="recMonMissed" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= recMonMissedBean.getAction().equals("Continue") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>
    
    <%-- Valid entry --%>
    <if:IfTrue cond='<%= recMonMissedBean.getConfirm().equals("Yes") %>' >
      <%-- Set up the dateBean for todays date --%>
      <% dateBean dateBean = new dateBean( application.getInitParameter("db_date_fmt") ); %>

      <%-- Create an array to store the complaint_nos --%>
      <% ArrayList complaint_nos = new ArrayList();     %>

      <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
      <sql:statement id="stmt" conn="con">
        <% String missedStreetFault = ""; %>
        <sql:query>
          select c_field
          from keys
          where service_c = 'ALL'
          and   keyname = 'MONITOR_FAULT_MISS'
        </sql:query>
        <sql:resultSet id="rset1">
          <sql:getColumn position="1" to="c_field" />
          <sql:wasNotNull>
            <% missedStreetFault = ((String) pageContext.getAttribute("c_field")).trim(); %>
          </sql:wasNotNull>
        </sql:resultSet>

        <%-- get all the complaint nos for this street for this user --%>
        <sql:query>
          SELECT complaint_no
            FROM mon_list
           WHERE location_c = '<%= recMonStreetsBean.getLocation_c() %>'
             AND (state = 'A' OR state = 'P')
             AND action_flag = 'P'
             AND user_name in (
                 SELECT user_name
                 FROM pda_cover_list
                 WHERE covered_by = '<%= loginBean.getUser_name() %>'
             )
             AND recvd_by = '<%= recMonStreetsBean.getMonitor_source() %>'
        </sql:query>
        <sql:resultSet id="rset1">
          <sql:getColumn position="1" to="complaint_no" />
          <% complaint_nos.add( ((String)pageContext.getAttribute("complaint_no")).trim() );%>
        </sql:resultSet>

        <%-- If we have results in the array, then close them all --%>
        <if:IfTrue cond='<%= complaint_nos.size() > 0 %>'>
          <% Iterator complaintIterator = complaint_nos.iterator(); %>
          <% while( complaintIterator.hasNext() ){ %>
            <% String complaint_no = (String)complaintIterator.next(); %> 

            <%-- Remove the survey from the inspection list --%>
            <sql:query>
              DELETE FROM mon_list
              WHERE complaint_no = <%= complaint_no %>
            </sql:query>
            <sql:execute />
      
            <%-- Get the diry_ref from the complaint_no --%>
            <sql:query>
              SELECT diry_ref
                FROM diry
               WHERE source_ref = '<%= complaint_no %>'
            </sql:query>
            <sql:resultSet id="rset">
              <sql:getColumn position="1" to="diry_ref" />
            </sql:resultSet>
      
            <%-- Close the default diry record --%>
            <sql:query>
              UPDATE diry
                 SET action_flag = 'C',
                     dest_date = '<%= dateBean.getDate() %>',
                     dest_time_h = '<%= dateBean.getTime_h() %>',
                     dest_time_m = '<%= dateBean.getTime_m() %>',
                     dest_user = '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>'
               WHERE diry_ref = '<%= ((String)pageContext.getAttribute("diry_ref")).trim() %>'
            </sql:query>
            <sql:execute />
      
            <%-- close the complaint --%>
            <sql:query>
              UPDATE comp
                 SET comp_code = '<%= missedStreetFault %>',
                     date_closed = '<%= dateBean.getDate() %>',
                     time_closed_h = '<%= dateBean.getTime_h() %>',
                     time_closed_m = '<%= dateBean.getTime_m() %>'
               WHERE complaint_no = '<%= complaint_no %>'
            </sql:query>
            <sql:execute />
          <% } %>
        </if:IfTrue>
      </sql:statement>
      <sql:closeConnection conn="con"/>

      <%-- If we have results in the array, then do the veolia link for them all if required --%>
      <if:IfTrue cond='<%= complaint_nos.size() > 0 %>' >
        <% Iterator complaintIterator = complaint_nos.iterator(); %>
        <% while( complaintIterator.hasNext() ){ %>
          <% recordBean.setComplaint_no( (String)complaintIterator.next() ); %> 

          <%-- run the veolia link --%>
          <sess:setAttribute name="form">veoliaLinkFunc</sess:setAttribute>
          <c:import url="veoliaLinkFunc.jsp" var="webPage" />
          <% helperBean.throwException("veoliaLinkFunc", (String)pageContext.getAttribute("webPage")); %>

        <% } %>
      </if:IfTrue>

      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">recMonMissed</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">recMonStreets</sess:setAttribute>
      <c:redirect url="recMonStreetsScript.jsp" />
    </if:IfTrue>
    
    <if:IfTrue cond='<%= recMonMissedBean.getConfirm().equals("No") %>' >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">recMonMissed</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">recMonStreets</sess:setAttribute>
      <c:redirect url="recMonStreetsScript.jsp" />
    </if:IfTrue>
  </if:IfTrue>
  
  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= recMonMissedBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">recMonMissed</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= recMonMissedBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">recMonMissed</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= recMonMissedBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">recMonMissed</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= recMonMissedBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${recMonMissedBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="recMonMissedView.jsp" />
