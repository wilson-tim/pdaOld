<%@ page errorPage="error.jsp" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat" %>
<%@ page import="com.vsb.enfActionBean, com.vsb.recordBean, com.vsb.loginBean" %>
<%@ page import="com.vsb.helperBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="enfActionBean" scope="session" class="com.vsb.enfActionBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="loginBean" scope="session" class="com.vsb.loginBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="enfAction" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="enfAction" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="enfActionBean" property="all" value="clear" />
    <jsp:setProperty name="enfActionBean" property="*" />

    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="enf_action_txt" param="action_text" />
   
    <%-- Set the just picked action_code too the enf_list_action_code if the action_code --%>
    <%-- has a header_flag equal to 'Y', and go to the view again --%>
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="enfActionBean" property="error" value="" />

<%-- set up a variable to indicate if we have come from a previous form --%>
<% boolean fromPreviousForm = false; %>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="enfDetails" >
  <jsp:setProperty name="enfActionBean" property="action" value="" />
  <jsp:setProperty name="enfActionBean" property="all" value="clear" />
  <jsp:setProperty name="enfActionBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <%-- Clear the date held in the recordBean's action_date, as it is used in the view. --%>
  <% fromPreviousForm = true; %>
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="enfSuspectText" >
  <jsp:setProperty name="enfActionBean" property="action" value="" />
  <jsp:setProperty name="enfActionBean" property="all" value="clear" />
  <jsp:setProperty name="enfActionBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <%-- Clear the date held in the recordBean's action_date, as it is used in the view. --%>
  <% fromPreviousForm = true; %>
</sess:equalsAttribute>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="text" >
  <jsp:setProperty name="enfActionBean" property="action" value="" />
  <jsp:setProperty name="enfActionBean" property="all" value="clear" />
  <jsp:setProperty name="enfActionBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <%-- Clear the date held in the recordBean's action_date, as it is used in the view. --%>
  <% fromPreviousForm = true; %>
</sess:equalsAttribute>

<if:IfTrue cond='<%= fromPreviousForm == true %>' >
  <jsp:setProperty name="recordBean" property="action_date" value="" />
  <jsp:setProperty name="recordBean" property="action_time_h" value="" />
  <jsp:setProperty name="recordBean" property="action_time_m" value="" />
  <%-- reset the aut officers --%>
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
        <% enfActionBean.setAutOff(((String)pageContext.getAttribute("po_code")).trim().toUpperCase()); %>
      </sql:wasNotNull>
      <sql:wasNull>
        <% enfActionBean.setAutOff(""); %>
      </sql:wasNull>
    </sql:resultSet>
    <sql:wasEmpty>
      <% enfActionBean.setAutOff(""); %>
    </sql:wasEmpty>
  </sql:statement>
  <sql:closeConnection conn="con"/>

  <%-- Assign the recordBean enf_list_action_code to the forms enf_list_action_code --%>
  <%-- as that's the one that is used in the view to retreive the next actions. --%>
  <%-- It is done this way so that header_flag field in the enf_act table can be utilised. --%>
  <% enfActionBean.setEnf_list_action_code(recordBean.getEnf_list_action_code()); %>
</if:IfTrue>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>

<%-- If we got to the Action page but the recordBean enf_list_action_code variable is  --%>
<%-- blank, then this is the first action for this enforcement, and we can assume that --%>
<%-- the first action is 'NONE' as it is in contender.                                 --%>
<if:IfTrue cond='<%= recordBean.getEnf_list_action_code().equals("") %>' >
  <% recordBean.setEnf_list_action_code("NONE"); %>
  <%-- Assign the recordBean enf_list_action_code to the forms enf_list_action_code --%>
  <%-- as that's the one that is used in the view to retreive the next actions. --%>
  <%-- It is done this way so that header_flag field in the enf_act table can be utilised. --%>
  <% enfActionBean.setEnf_list_action_code(recordBean.getEnf_list_action_code()); %>
</if:IfTrue>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="enfAction" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <%-- Code to run --%>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="enfAction" >
  <%-- get the offence date --%>
  <% String offence_date = ""; %>
  <% String header_flag = "N"; %>
  <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
  <sql:statement id="stmt" conn="con">
      <sql:query>
        SELECT offence_date
          FROM comp_enf
         WHERE complaint_no = '<%= recordBean.getComplaint_no() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getDate position="1" to="offence_date" format="<%= application.getInitParameter("db_date_fmt") %>" />
        <sql:wasNotNull>
          <% offence_date = ((String) pageContext.getAttribute("offence_date")).trim(); %>
        </sql:wasNotNull>
      </sql:resultSet>

      <if:IfTrue cond='<%= offence_date.equals("") %>' >
        <sql:query>
          SELECT inv_period_start
            FROM comp_enf
           WHERE complaint_no = '<%= recordBean.getComplaint_no() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getDate position="1" to="offence_date" format="<%= application.getInitParameter("db_date_fmt") %>" />
          <sql:wasNotNull>
            <% offence_date = ((String) pageContext.getAttribute("offence_date")).trim(); %>
          </sql:wasNotNull>
        </sql:resultSet>
      </if:IfTrue>

      <sql:query>
        select header_flag
        from enf_act
        where action_code = '<%= enfActionBean.getAction_code() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="header_flag" />
        <sql:wasNotNull>
          <% header_flag = ((String) pageContext.getAttribute("header_flag")).trim(); %>
        </sql:wasNotNull>
      </sql:resultSet>
      
  </sql:statement>
  <sql:closeConnection conn="con"/>

  <%
    // Set the default time zone to where we are, as the time zone
    // returned from sco is GMT+00:00 which is fine but doesn't mentioned
    // BST. So the default timezone has to be set to "Europe/London".
    // Any objects which use the timezone (like SimpleDateFormat) will then
    // be using the correct timezone.
    TimeZone dtz = TimeZone.getTimeZone("Europe/London");
    TimeZone.setDefault(dtz);

    // Action date
    GregorianCalendar act_date = new GregorianCalendar();
    int day = Integer.parseInt(enfActionBean.getAction_day());
    int month = Integer.parseInt(enfActionBean.getAction_month());
    int year = Integer.parseInt(enfActionBean.getAction_year());

    // Create string representation of forms date (yyyy-MM-dd)
    String action_date = enfActionBean.getAction_year() + "-" +
                         enfActionBean.getAction_month() + "-" +
                         enfActionBean.getAction_day();

    // Create new simple date format (yyyy-MM-dd). This is not controlled by the context-param db_date_fmt
    // as it is just being used to turn a string date (offence_date) into a real date.
    SimpleDateFormat formatDate = new SimpleDateFormat("yyyy-MM-dd");
    // This simple date format does need to be controlled by the context-param db_date_fmt as it formats
    // the converted offence_date back into a string but in the database format.
    SimpleDateFormat formatDbDate = new SimpleDateFormat(application.getInitParameter("db_date_fmt"));

    // set the date to todays date
    Date todayDate = new java.util.Date();
    // Create offence date from string
    Date offenceDate = formatDbDate.parse(offence_date);
    // Create action date from string 
    Date actionDate = formatDate.parse(action_date);
    // Then turn the action date into a string able to be inserted into the database
    action_date = formatDbDate.format(actionDate);

    // Add the action date to the record bean
    recordBean.setAction_date(action_date); 

    // Add action_time_X to the record bean
    recordBean.setAction_time_h(enfActionBean.getAction_time_h());
    recordBean.setAction_time_m(enfActionBean.getAction_time_m());
  %>
  
  <%-- Next view --%>
  <if:IfTrue cond='<%= enfActionBean.getAction().equals("Status") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= enfActionBean.getAction_code() == null || enfActionBean.getAction_code().equals("") %>' >
      <jsp:setProperty name="enfActionBean" property="error"
        value="Please choose an action." />
      <jsp:forward page="enfActionView.jsp" />
    </if:IfTrue>

    <%-- Set the enf_list_action_code to the just picked action_action if the action_code --%>
    <%-- has a header_flag equal to 'Y', and then go back to the view to  --%>
    <%-- list the new set of action codes. --%>
    <if:IfTrue cond='<%= header_flag.equals("Y") %>' >
      <% enfActionBean.setEnf_list_action_code(enfActionBean.getAction_code()); %>
      <jsp:setProperty name="enfActionBean" property="error"
        value="Please choose a new action from the new set of action codes, as the last action selected represents this new group of actions and not a single action." />
      <jsp:forward page="enfActionView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond="<%= day > 30 && (month == 4 || month == 6 || month == 9 || month == 11) %>">
      <jsp:setProperty name="enfActionBean" property="error"
        value="You have entered an invalid date.<br/>Please try again" />
      <jsp:forward page="enfActionView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond="<%= (act_date.isLeapYear(year) && month == 2 && day > 29) || (!(act_date.isLeapYear(year))&& month == 2 && day > 28) %>">
      <jsp:setProperty name="enfActionBean" property="error"
        value="You have entered an invalid date.<br/>Please try again" />
      <jsp:forward page="enfActionView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond="<%= actionDate.after(todayDate) %>">
      <jsp:setProperty name="enfActionBean" property="error"
        value="The action date cannot be in the future.<br/>Please try again" />
      <jsp:forward page="enfActionView.jsp" />
    </if:IfTrue>
    
    <if:IfTrue cond="<%= actionDate.before(offenceDate) %>">
      <jsp:setProperty name="enfActionBean" property="error"
        value="The action date cannot be before the offence date or period.<br/>Please try again" />
      <jsp:forward page="enfActionView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond="<%= enfActionBean.getAutOff() == null || enfActionBean.getAutOff().trim().equals("") %>">
      <jsp:setProperty name="enfActionBean" property="error"
        value="You must enter an authorising officer." />
      <jsp:forward page="enfActionView.jsp" />
    </if:IfTrue>

    <%-- Validating the time --%>
    <%-- checking that if the hours have been added then the mins should have been as well and vice versa --%>
    <if:IfTrue cond="<%= enfActionBean.getAction_time_h() != null &&
                         !enfActionBean.getAction_time_h().equals("") &&
                         (enfActionBean.getAction_time_m() == null ||
                          enfActionBean.getAction_time_m().equals("")) %>">
      <jsp:setProperty name="enfActionBean" property="error"
        value="If supplying a time, you must supply the hours AND mins." />
      <jsp:forward page="enfActionView.jsp" />
    </if:IfTrue>

    <%-- checking that if the mins have been added then the hours should have been as well --%>
    <if:IfTrue cond="<%= enfActionBean.getAction_time_m() != null &&
                         !enfActionBean.getAction_time_m().equals("") &&
                         (enfActionBean.getAction_time_h() == null ||
                          enfActionBean.getAction_time_h().equals("")) %>">
      <jsp:setProperty name="enfActionBean" property="error"
        value="If supplying a time, you must supply the hours AND mins." />
      <jsp:forward page="enfActionView.jsp" />
    </if:IfTrue>

    <%-- Validating the hours --%>
    <if:IfTrue cond="<%= enfActionBean.getAction_time_h() != null &&
                        !enfActionBean.getAction_time_h().equals("") &&
                        !helperBean.isStringInt(enfActionBean.getAction_time_h()) %>">
      <jsp:setProperty name="enfActionBean" property="error"
        value="If supplying a time (hrs), it must be an integer." />
      <jsp:forward page="enfActionView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond="<%= enfActionBean.getAction_time_h() != null &&
                        !enfActionBean.getAction_time_h().equals("") &&
                        Integer.parseInt(enfActionBean.getAction_time_h()) < 0 %>">
      <jsp:setProperty name="enfActionBean" property="error"
        value="If supplying a time (hrs), it must NOT be less than zero." />
      <jsp:forward page="enfActionView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond="<%= enfActionBean.getAction_time_h() != null &&
                        !enfActionBean.getAction_time_h().equals("") &&
                        Integer.parseInt(enfActionBean.getAction_time_h()) > 23 %>">
      <jsp:setProperty name="enfActionBean" property="error"
        value="If supplying a time (hrs), it must NOT be greater than 23." />
      <jsp:forward page="enfActionView.jsp" />
    </if:IfTrue>

    <%-- Validating the minutes --%>
    <if:IfTrue cond="<%= enfActionBean.getAction_time_m() != null &&
                        !enfActionBean.getAction_time_m().equals("") &&
                        !helperBean.isStringInt(enfActionBean.getAction_time_m()) %>">
      <jsp:setProperty name="enfActionBean" property="error"
        value="If supplying a time (mins), it must be an integer." />
      <jsp:forward page="enfActionView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond="<%= enfActionBean.getAction_time_m() != null &&
                        !enfActionBean.getAction_time_m().equals("") &&
                        Integer.parseInt(enfActionBean.getAction_time_m()) < 0 %>">
      <jsp:setProperty name="enfActionBean" property="error"
        value="If supplying a time (mins), it must NOT be less than zero." />
      <jsp:forward page="enfActionView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond="<%= enfActionBean.getAction_time_m() != null &&
                        !enfActionBean.getAction_time_m().equals("") &&
                        Integer.parseInt(enfActionBean.getAction_time_m()) > 59 %>">
      <jsp:setProperty name="enfActionBean" property="error"
        value="If supplying a time (mins), it must less than 60." />
      <jsp:forward page="enfActionView.jsp" />
    </if:IfTrue>

    
    <%-- Valid entry --%>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfAction</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">enfStatus</sess:setAttribute>
    <c:redirect url="enfStatusScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= enfActionBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfAction</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= enfActionBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfAction</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= enfActionBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">enfAction</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= enfActionBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${enfActionBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="enfActionView.jsp" />
