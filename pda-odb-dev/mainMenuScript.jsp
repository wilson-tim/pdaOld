<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.mainMenuBean, com.vsb.loginBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app"  %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0"     prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0"     prefix="req"  %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags"       prefix="if"   %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags"          prefix="sql"  %>
<%@ taglib uri="http://java.sun.com/jstl/core"                     prefix="c"    %>

<jsp:useBean id="mainMenuBean" scope="session" class="com.vsb.mainMenuBean" />
<jsp:useBean id="loginBean"    scope="session" class="com.vsb.loginBean"    />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at beginning --%>
<sess:equalsAttribute name="form" match="mainMenu" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="mainMenu" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>

    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="mainMenuBean" property="all" value="clear" />
    <jsp:setProperty name="mainMenuBean" property="*" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="mainMenuBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="login" >
  <jsp:setProperty name="mainMenuBean" property="action" value="" />
  <jsp:setProperty name="mainMenuBean" property="all" value="clear" />
  <jsp:setProperty name="mainMenuBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="mainMenu" >
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
  <if:IfTrue cond='<%= mainMenuBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= absent %>' >
      <jsp:setProperty name="mainMenuBean" property="error"
        value="Action denied. The current user is flagged as absent.<br/>If you continue to experience difficulties please contact the site administrator." />
      <jsp:forward page="mainMenuView.jsp" />
    </if:IfTrue>

    <%-- Valid entry --%>
    <%-- Web.xml use_insp_manual_query controls which form we goto next --%>
    <app:equalsInitParameter name="use_insp_manual_query" match="N">
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">mainMenu</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">inspList</sess:setAttribute>
      <c:redirect url="inspListScript.jsp" />
    </app:equalsInitParameter>
    <app:equalsInitParameter name="use_insp_manual_query" match="Y">
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">mainMenu</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">inspQuery</sess:setAttribute>
      <c:redirect url="inspQueryScript.jsp" />
    </app:equalsInitParameter>
  </if:IfTrue>

  <%-- Next view 2--%>
  <if:IfTrue cond='<%= mainMenuBean.getAction().equals("Schedules / Complaints") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= absent %>' >
      <jsp:setProperty name="mainMenuBean" property="error"
        value="Action denied. The current user is flagged as absent.<br/>If you continue to experience difficulties please contact the site administrator." />
      <jsp:forward page="mainMenuView.jsp" />
    </if:IfTrue>

    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">mainMenu</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Next view 3--%>
  <if:IfTrue cond='<%= mainMenuBean.getAction().equals("Ad-Hoc Surveys") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">mainMenu</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">surveySiteSearch</sess:setAttribute>
    <c:redirect url="surveySiteSearchScript.jsp" />
  </if:IfTrue>

  <%-- Next view 6--%>
  <if:IfTrue cond='<%= mainMenuBean.getAction().equals("Contractor Schedules") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">mainMenu</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">conScheduleList</sess:setAttribute>
    <c:redirect url="conScheduleListScript.jsp" />
  </if:IfTrue>  

  <%-- Next view 4--%>
  <if:IfTrue cond='<%= mainMenuBean.getAction().equals("Officer Maintenance") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">mainMenu</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">officerMenu</sess:setAttribute>
    <c:redirect url="officerMenuScript.jsp" />
  </if:IfTrue>

  <%-- Next view 5--%>
  <if:IfTrue cond='<%= mainMenuBean.getAction().equals(application.getInitParameter("monitoring_title")) %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">mainMenu</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">recMonStreets</sess:setAttribute>
    <c:redirect url="recMonStreetsScript.jsp" />
  </if:IfTrue>

  <%-- Next view 6--%>
  <if:IfTrue cond='<%= mainMenuBean.getAction().equals("Contractor Summary") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= absent %>' >
      <jsp:setProperty name="mainMenuBean" property="error"
        value="Action denied. The current user is flagged as absent.<br/>If you continue to experience difficulties please contact the site administrator." />
      <jsp:forward page="mainMenuView.jsp" />
    </if:IfTrue>

    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">mainMenu</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">conSumList</sess:setAttribute>
    <c:redirect url="conSumListScript.jsp" />
  </if:IfTrue>

  <%-- Next view 7--%>
  <if:IfTrue cond='<%= mainMenuBean.getAction().equals("Enforcement List") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= absent %>' >
      <jsp:setProperty name="mainMenuBean" property="error"
        value="Action denied. The current user is flagged as absent.<br/>If you continue to experience difficulties please contact the site administrator." />
      <jsp:forward page="mainMenuView.jsp" />
    </if:IfTrue>

    <%-- Valid entry --%>
    <%-- Web.xml use_enf_manual_query controls which form we goto next --%>
    <app:equalsInitParameter name="use_enf_manual_query" match="N">
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">mainMenu</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">enfList</sess:setAttribute>
      <c:redirect url="enfListScript.jsp" />
    </app:equalsInitParameter>
    <app:equalsInitParameter name="use_enf_manual_query" match="Y">
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">mainMenu</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">enfQuery</sess:setAttribute>
      <c:redirect url="enfQueryScript.jsp" />
    </app:equalsInitParameter>
  </if:IfTrue>

  <%-- Next view 8--%>
  <if:IfTrue cond='<%= mainMenuBean.getAction().equals("Markets") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= absent %>' >
      <jsp:setProperty name="mainMenuBean" property="error"
        value="Action denied. The current user is flagged as absent.<br/>If you continue to experience difficulties please contact the site administrator." />
      <jsp:forward page="mainMenuView.jsp" />
    </if:IfTrue>

    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">mainMenu</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">marketsList</sess:setAttribute>
    <c:redirect url="marketsListScript.jsp" />
  </if:IfTrue>

  <%-- Next view 9--%>
  <if:IfTrue cond='<%= mainMenuBean.getAction().equals("Todo List") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= absent %>' >
      <jsp:setProperty name="mainMenuBean" property="error"
        value="Action denied. The current user is flagged as absent.<br/>If you continue to experience difficulties please contact the site administrator." />
      <jsp:forward page="mainMenuView.jsp" />
    </if:IfTrue>

    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">mainMenu</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">todoList</sess:setAttribute>
    <c:redirect url="todoListScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <%-- Start the application again as if the session had timed out. --%>
  <if:IfTrue cond='<%= mainMenuBean.getAction().equals("Logout") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">mainMenu</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">index</sess:setAttribute>
    <c:redirect url="index.jsp" />
  </if:IfTrue>  
  
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="mainMenuView.jsp" />
