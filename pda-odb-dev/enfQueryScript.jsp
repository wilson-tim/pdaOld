<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.enfQueryBean, com.vsb.loginBean" %>
<%@ page import="java.util.GregorianCalendar, java.util.Date,java.text.SimpleDateFormat" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="enfQueryBean" scope="session" class="com.vsb.enfQueryBean" />
<jsp:useBean id="loginBean" scope="session" class="com.vsb.loginBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="enfQuery" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="enfQuery" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>

    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="enfQueryBean" property="all" value="clear" />
    <jsp:setProperty name="enfQueryBean" property="*" />

    <%-- Clear the previous record --%>
    <jsp:setProperty name="recordBean" property="all" value="clear" />

  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="enfQueryBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="mainMenu" >
  <jsp:setProperty name="enfQueryBean" property="action" value="" />
  <jsp:setProperty name="enfQueryBean" property="all" value="clear" />
  <jsp:setProperty name="enfQueryBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <%-- reset the officer --%>
  <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
  <sql:statement id="stmt" conn="con">
    <sql:query>
      select po_code
      from pda_user
      where user_name = '<%= loginBean.getUser_name() %>'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="po_code" />
      <sql:wasNotNull>
        <% enfQueryBean.setEnf_officer(((String)pageContext.getAttribute("po_code")).trim().toUpperCase()); %>
      </sql:wasNotNull>
      <sql:wasNull>
        <% enfQueryBean.setEnf_officer(""); %>
      </sql:wasNull>
    </sql:resultSet>
    <sql:wasEmpty>
      <% enfQueryBean.setEnf_officer(""); %>
    </sql:wasEmpty>
  </sql:statement>
  <sql:closeConnection conn="con"/>
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>
<%-- If the user has used '*' in the input then make sure they see them as '*'s --%>
<%-- and not as '%'s symbols because of the change to '%' for matching using --%>
<%-- 'like' in the sql in enfList, see later in the code. --%>
<%
  String tempText1 = "";
  tempText1 = enfQueryBean.getEnf_site();
  enfQueryBean.setEnf_site(tempText1.replace('%','*'));
%>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="enfQuery" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <%-- Code to run --%>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="enfQuery" >

  <%-- Check to see if the user is using the due date in the query --%>
  <%-- ENFORCEMENT DUE DATE --%>
  <%
    // Check if any fields are blank
    enfQueryBean.setIs_due_date_completed( false );
    if( (!enfQueryBean.getEnf_due_day().equals(""))   &&
        (!enfQueryBean.getEnf_due_month().equals("")) && 
        (!enfQueryBean.getEnf_due_year().equals("")) ) {
      enfQueryBean.setIs_due_date_completed( true );
    }
    // Check if all the fields are blank
    boolean isDueDateBlank = false;
    if( (enfQueryBean.getEnf_due_day().equals(""))   && 
        (enfQueryBean.getEnf_due_month().equals("")) && 
        (enfQueryBean.getEnf_due_year().equals("")) ) {
      isDueDateBlank = true;
    }
  %>
  <%
    int dueDay   = 0;
    int dueMonth = 0;
    int dueYear  = 0;
    String due_date_string = "";
    GregorianCalendar due_date = new GregorianCalendar();
    // Check to see if the due date is complete before attempting to convert to gregorian date
    if( enfQueryBean.getIs_due_date_completed() ) {
      // Create due date from day, month and year.
      dueDay   = Integer.parseInt(enfQueryBean.getEnf_due_day());
      dueMonth = Integer.parseInt(enfQueryBean.getEnf_due_month());
      dueYear  = Integer.parseInt(enfQueryBean.getEnf_due_year());

      // Create string representation of forms date (yyyy-MM-dd)
      due_date_string = enfQueryBean.getEnf_due_year() + "-" + 
                        enfQueryBean.getEnf_due_month() + "-" + 
                        enfQueryBean.getEnf_due_day();
      // Create new simple date format (yyyy-MM-dd). This is not controlled by the context-param db_date_fmt
      // as it is just being used to turn a string date (re_inspect_date) into a real date.
      SimpleDateFormat formatStDate = new SimpleDateFormat("yyyy-MM-dd");
      // This simple date format does need to be controlled by the context-param db_date_fmt as it formats
      // the converted re_inspect_date back into a string but in the database format.
      SimpleDateFormat formatDbDate = new SimpleDateFormat(application.getInitParameter("db_date_fmt"));
      // Create completion date from string 
      Date tempDate = formatStDate.parse(due_date_string);
      due_date_string = formatDbDate.format(tempDate);
    }
  %>
  <%-- ENFORCEMENT ACTION DATE --%>
  <%
    // Check if any fields are blank
    enfQueryBean.setIs_action_date_completed(false);
    boolean isActionDateCompleted = false;
    if( (!enfQueryBean.getEnf_action_day().equals(""))   &&
        (!enfQueryBean.getEnf_action_month().equals("")) && 
        (!enfQueryBean.getEnf_action_year().equals("")) ) {
      enfQueryBean.setIs_action_date_completed(true);
    }
    // Check if all the fields are blank
    boolean isActionDateBlank = false;
    if( (enfQueryBean.getEnf_action_day().equals(""))   && 
        (enfQueryBean.getEnf_action_month().equals("")) && 
        (enfQueryBean.getEnf_action_year().equals("")) ) {
      isActionDateBlank = true;
    }
  %>
  <%
    int actionDay   = 0;
    int actionMonth = 0;
    int actionYear  = 0;
    String action_date_string = ""; 
    GregorianCalendar action_date = new GregorianCalendar();    
    // Check to see if the due date is complete before attempting to convert to gregorian date
    if( enfQueryBean.getIs_action_date_completed() ) {
      // Create action date from day, month and year.
      actionDay   = Integer.parseInt(enfQueryBean.getEnf_action_day());
      actionMonth = Integer.parseInt(enfQueryBean.getEnf_action_month());
      actionYear  = Integer.parseInt(enfQueryBean.getEnf_action_year());

      // Create string representation of forms date (yyyy-MM-dd)
      action_date_string = enfQueryBean.getEnf_action_year() + "-" + 
                           enfQueryBean.getEnf_action_month() + "-" + 
                           enfQueryBean.getEnf_action_day();
      // Create new simple date format (yyyy-MM-dd). This is not controlled by the context-param db_date_fmt
      // as it is just being used to turn a string date (re_inspect_date) into a real date.
      SimpleDateFormat formatStDate = new SimpleDateFormat("yyyy-MM-dd");
      // This simple date format does need to be controlled by the context-param db_date_fmt as it formats
      // the converted re_inspect_date back into a string but in the database format.
      SimpleDateFormat formatDbDate = new SimpleDateFormat(application.getInitParameter("db_date_fmt"));
      // Create completion date from string 
      Date tempDate = formatStDate.parse(action_date_string);
      action_date_string = formatDbDate.format(tempDate);
    }
  %>

  <%-- Next view --%>
  <if:IfTrue cond='<%= enfQueryBean.getAction().equals("Submit") %>' >
    <%-- Invalid entry --%>
    
    <%-- DUE DATE VALIDATION --%>    
    <if:IfTrue cond="<%= enfQueryBean.getIs_due_date_completed() %>">    
      <if:IfTrue cond="<%= dueDay > 30 && (dueMonth == 4 || dueMonth == 6 || dueMonth == 9 || dueMonth == 11) %>">
        <jsp:setProperty name="enfQueryBean" property="error"
          value="You have entered an invalid date.<br/>Please try again" />
        <jsp:forward page="enfQueryView.jsp" />
      </if:IfTrue>
    
      <if:IfTrue cond="<%= (due_date.isLeapYear(dueYear) && dueMonth == 2 && dueDay > 29) || (!due_date.isLeapYear(dueYear) && dueMonth == 2 && dueDay > 28) %>">
        <jsp:setProperty name="enfQueryBean" property="error"
          value="You have entered an invalid date.<br/>Please try again" />
        <jsp:forward page="enfQueryView.jsp" />
      </if:IfTrue>
    </if:IfTrue>
    <if:IfTrue cond="<%= !enfQueryBean.getIs_due_date_completed() && !isDueDateBlank %>">
      <jsp:setProperty name="enfQueryBean" property="error"
        value="You have not entered a complete due date.<br/>Please try again" />
      <jsp:forward page="enfQueryView.jsp" />
    </if:IfTrue>
    
    <%-- ACTION DATE VALIDATION --%>
    <if:IfTrue cond="<%= enfQueryBean.getIs_action_date_completed() %>">    
      <if:IfTrue cond="<%= actionDay > 30 && (actionMonth == 4 || actionMonth == 6 || actionMonth == 9 || actionMonth == 11) %>">
        <jsp:setProperty name="enfQueryBean" property="error"
          value="You have entered an invalid date.<br/>Please try again" />
        <jsp:forward page="enfQueryView.jsp" />
      </if:IfTrue>
    
      <if:IfTrue cond="<%= (action_date.isLeapYear(actionYear) && actionMonth == 2 && actionDay > 29) || (!action_date.isLeapYear(actionYear) && actionMonth == 2 && actionDay > 28) %>">
        <jsp:setProperty name="enfQueryBean" property="error"
          value="You have entered an invalid date.<br/>Please try again" />
        <jsp:forward page="enfQueryView.jsp" />
      </if:IfTrue>
    </if:IfTrue>    
    <if:IfTrue cond="<%= !enfQueryBean.getIs_action_date_completed() && !isActionDateBlank %>">
      <jsp:setProperty name="enfQueryBean" property="error"
        value="You have not entered a complete action date.<br/>Please try again" />
      <jsp:forward page="enfQueryView.jsp" />
    </if:IfTrue>
    
    <%-- Valid entry --%>
    <%-- If the user has used '*' in the input then change them to '%' for --%>
    <%-- matching using 'like' in the sql in enfList --%>
    <%
      String tempText2 = "";
      tempText2 = enfQueryBean.getEnf_site();
      enfQueryBean.setEnf_site(tempText2.replace('*','%'));
    %>
    <%-- Set the action and due date values in the enfQueryBean --%>
    <% enfQueryBean.setEnf_due_date(due_date_string);       %>    
    <% enfQueryBean.setEnf_action_date(action_date_string); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfQuery</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">enfList</sess:setAttribute>
    <c:redirect url="enfListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= enfQueryBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfQuery</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= enfQueryBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfQuery</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= enfQueryBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfQuery</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= enfQueryBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${enfQueryBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="enfQueryView.jsp" />
