<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.makeBean, com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>

<jsp:useBean id="makeBean" scope="session" class="com.vsb.makeBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="make" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="make" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="makeBean" property="all" value="clear" />
    <jsp:setProperty name="makeBean" property="*" />
    
    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="make_ref" param="make_ref" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="makeBean" property="error" value="" />

<%-- clear form fields if coming from previous form --%>
<sess:equalsAttribute name="input" match="service" >
  <jsp:setProperty name="makeBean" property="action" value="" />
  <jsp:setProperty name="makeBean" property="all" value="clear" />
  <jsp:setProperty name="makeBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="make" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= makeBean.getAction().equals("Details") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= makeBean.getMake_ref() == null || makeBean.getMake_ref().trim().equals("") %>' >
      <jsp:setProperty name="makeBean" property="error"
        value="Please choose a make." />
      <jsp:forward page="makeView.jsp" />
    </if:IfTrue>
    
    <%-- Valid entry --%>
    <%-- get the make description --%>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con">
      <sql:query>
        select make_desc
        from makes
        where make_ref = '<%= recordBean.getMake_ref() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="make_desc" />
        <% recordBean.setMake_desc((String) pageContext.getAttribute("make_desc")); %>
      </sql:resultSet>
    </sql:statement>
    <sql:closeConnection conn="con"/>
    
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">make</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">details</sess:setAttribute>
    <c:redirect url="detailsScript.jsp" />
  </if:IfTrue>
 
  <%-- Menu view --%>
  <if:IfTrue cond='<%= makeBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">make</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>
 
  <%-- Previous view --%>
  <if:IfTrue cond='<%= makeBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">make</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= makeBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${makeBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="makeView.jsp" />
