<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.marketsMenuBean, com.vsb.loginBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app"  %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0"     prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0"     prefix="req"  %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags"       prefix="if"   %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags"          prefix="sql"  %>
<%@ taglib uri="http://java.sun.com/jstl/core"                     prefix="c"    %>

<jsp:useBean id="marketsMenuBean" scope="session" class="com.vsb.marketsMenuBean" />
<jsp:useBean id="loginBean"    scope="session" class="com.vsb.loginBean"    />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at beginning --%>
<sess:equalsAttribute name="form" match="marketsMenu" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="marketsMenu" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>

    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="marketsMenuBean" property="all" value="clear" />
    <jsp:setProperty name="marketsMenuBean" property="*" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="marketsMenuBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="login" >
  <jsp:setProperty name="marketsMenuBean" property="action" value="" />
  <jsp:setProperty name="marketsMenuBean" property="all" value="clear" />
  <jsp:setProperty name="marketsMenuBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="marketsMenu" >
  <% boolean absent = false; %>

  <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
  <sql:statement id="stmt" conn="con">
    <%-- Check to see if the user is absent --%>
    <sql:query>
      select user_name
      from pda_cover_list
      where user_name = '<%= loginBean.getUser_name().toLowerCase() %>'
      and   absent = 'Y'
    </sql:query>
    <sql:resultSet id="rset">
    </sql:resultSet>
    <sql:wasEmpty>
      <% absent = false; %>
    </sql:wasEmpty>
    <sql:wasNotEmpty>
      <% absent = true; %>
    </sql:wasNotEmpty>
  </sql:statement>
  <sql:closeConnection conn="con"/>

  <%-- Next view 1--%>
  <if:IfTrue cond='<%= marketsMenuBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= absent %>' >
      <jsp:setProperty name="marketsMenuBean" property="error"
        value="Action denied. The current user is flagged as absent.<br/>If you continue to experience difficulties please contact the site administrator." />
      <jsp:forward page="marketsMenuView.jsp" />
    </if:IfTrue>

    <%-- Valid entry --%>
    <%-- Web.xml use_insp_manual_query controls which form we goto next --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">marketsMenu</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">marketsList</sess:setAttribute>
    <c:redirect url="marketsListScript.jsp" />
  </if:IfTrue>

  <%-- Next view 2--%>
  <if:IfTrue cond='<%= marketsMenuBean.getAction().equals("Schedules / Complaints") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= absent %>' >
      <jsp:setProperty name="marketsMenuBean" property="error"
        value="Action denied. The current user is flagged as absent.<br/>If you continue to experience difficulties please contact the site administrator." />
      <jsp:forward page="marketsMenuView.jsp" />
    </if:IfTrue>

    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">marketsMenu</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">marketsSchedOrComp</sess:setAttribute>
    <c:redirect url="marketsSchedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <%-- Start the application again as if the session had timed out. --%>
  <if:IfTrue cond='<%= marketsMenuBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">marketsMenu</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">mainMenu</sess:setAttribute>
    <c:redirect url="mainMenuScript.jsp" />
  </if:IfTrue>  
  
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="marketsMenuView.jsp" />
