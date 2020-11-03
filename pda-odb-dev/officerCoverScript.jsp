<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.officerCoverBean, com.vsb.pickAbsentOfficerBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>

<jsp:useBean id="officerCoverBean" scope="session" class="com.vsb.officerCoverBean" />
<jsp:useBean id="pickAbsentOfficerBean" scope="session" class="com.vsb.pickAbsentOfficerBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="officerCover" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="officerCover" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="officerCoverBean" property="all" value="clear" />
    <jsp:setProperty name="officerCoverBean" property="*" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="officerCoverBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="pickAbsentOfficer" >
  <jsp:setProperty name="officerCoverBean" property="action" value="" />
  <jsp:setProperty name="officerCoverBean" property="all" value="clear" />
  <jsp:setProperty name="officerCoverBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="officerCover" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <%-- Code to run --%>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="officerCover" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= officerCoverBean.getAction().equals("Finish") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%=officerCoverBean.getCover_name() == null || officerCoverBean.getCover_name().trim().equals("") %>' >
      <jsp:setProperty name="officerCoverBean" property="error"
        value="Please choose an officer." />
      <jsp:forward page="officerCoverView.jsp" />
    </if:IfTrue>

    <%-- Valid entry --%>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />    
    <sql:statement id="stmt" conn="con">
      <sql:query>
        update pda_cover_list
        set covered_by = '<%= officerCoverBean.getCover_name() %>'
        where user_name = '<%= pickAbsentOfficerBean.getUser_name() %>'
      </sql:query>
      <sql:execute />
    </sql:statement>
    <sql:closeConnection conn="con"/>

    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">officerCover</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">officerMenu</sess:setAttribute>
    <c:redirect url="officerMenuScript.jsp" />
  </if:IfTrue>
  
  <%-- Previous view --%>
  <if:IfTrue cond='<%= officerCoverBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">officerCover</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= officerCoverBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${officerCoverBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="officerCoverView.jsp" />
