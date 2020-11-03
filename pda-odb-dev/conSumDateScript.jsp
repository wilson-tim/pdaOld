<%@ page errorPage="error.jsp" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat" %>
<%@ page import="com.vsb.helperBean, com.vsb.conSumDateBean, com.vsb.recordBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="conSumDateBean" scope="session" class="com.vsb.conSumDateBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="conSumDate" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="conSumDate" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>

    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="conSumDateBean" property="all" value="clear" />
    <jsp:setProperty name="conSumDateBean" property="*" />

    <%-- The recordBean completion_date set in validation section --%>
    <jsp:setProperty name="recordBean" property="completion_time_h" param="hours" />
    <jsp:setProperty name="recordBean" property="completion_time_m" param="mins" />

  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="conSumDateBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="conSumDefaultDetails" >
  <jsp:setProperty name="conSumDateBean" property="action" value="" />
  <jsp:setProperty name="conSumDateBean" property="all" value="clear" />
  <jsp:setProperty name="conSumDateBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>
<sess:equalsAttribute name="input" match="conSumWODetails" >
  <jsp:setProperty name="conSumDateBean" property="action" value="" />
  <jsp:setProperty name="conSumDateBean" property="all" value="clear" />
  <jsp:setProperty name="conSumDateBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- , --%>
<%-- but only the first time through the SCRIPT. --%>
<%-- Also get/calculate the volume, points and value. --%>
<sess:equalsAttribute name="input" match="conSumDate" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals("conSumDefaultDetails")
                    || ((String)session.getAttribute("input")).equals("conSumWODetails") %>' >
    <%
    // Set the default time zone to where we are, as the time zone
    // returned from sco is GMT+00:00 which is fine but doesn't mention
    // BST. So the default timezone has to be set to "Europe/London".
    // Any objects which use the timezone (like SimpleDateFormat) will then
    // be using the correct timezone.
    TimeZone dtz = TimeZone.getTimeZone("Europe/London");
    TimeZone.setDefault(dtz);
    // Declare forms date variables
    String date;
    String day;
    String month;
    String year;
    String time;
    String time_h;
    String time_m;
    // Create simple date formats for date/time
    SimpleDateFormat formatDate   = new SimpleDateFormat(application.getInitParameter("db_date_fmt"));
    SimpleDateFormat formatDay   = new SimpleDateFormat("dd");
    SimpleDateFormat formatMonth   = new SimpleDateFormat("MM");
    SimpleDateFormat formatYear   = new SimpleDateFormat("yyyy");
    SimpleDateFormat formatTime   = new SimpleDateFormat("HH:mm");
    SimpleDateFormat formatTime_h = new SimpleDateFormat("HH");
    SimpleDateFormat formatTime_m = new SimpleDateFormat("mm");  
    // Get todays current date
    Date currentDate = new java.util.Date();    
    // Use simple date fromats to format current date
    date   = formatDate.format(currentDate);
    day   = formatDay.format(currentDate);
    month   = formatMonth.format(currentDate);
    year   = formatYear.format(currentDate);
    time   = formatTime.format(currentDate);
    time_h = formatTime_h.format(currentDate);
    time_m = formatTime_m.format(currentDate);
    // Set the date fields in the bean to todays date
    conSumDateBean.setDay(day);
    conSumDateBean.setMonth(month);
    conSumDateBean.setYear(year);
    conSumDateBean.setHours(time_h);
    conSumDateBean.setMins(time_m);
    // Set the completion time in the record bean
    // to todays date
    recordBean.setCompletion_date(date);
    recordBean.setCompletion_time_h(time_h);
    recordBean.setCompletion_time_m(time_m);
    %>  
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="conSumDate" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= conSumDateBean.getAction().equals("Finish") %>' >
    <%
      // Set the time zone
      TimeZone dtz = TimeZone.getTimeZone("Europe/London");
      TimeZone.setDefault(dtz);    
      // Get the forms integer date representation of day, month and year
      // These will be used to check if the user entry is valid, below.
      int day   = Integer.parseInt(conSumDateBean.getDay());
      int month = Integer.parseInt(conSumDateBean.getMonth());
      int year  = Integer.parseInt(conSumDateBean.getYear());
      // Get a gregorian calender to test for leap years when validating
      // user entry 
      GregorianCalendar gc = new GregorianCalendar();
      // Create string representation of forms date (yyyy-MM-dd)
      String string_date = conSumDateBean.getYear()  + "-" +
                           conSumDateBean.getMonth() + "-" +
                           conSumDateBean.getDay();
      // Create new simple date format (yyyy-MM-dd). This is not controlled by the context-param db_date_fmt
      // as it is just being used to turn a string date (string_date) into a real date.
      SimpleDateFormat formatStDate = new SimpleDateFormat("yyyy-MM-dd");
      // This simple date format does need to be controlled by the context-param db_date_fmt as it formats
      // the converted string_date back into a string but in the database format.
      SimpleDateFormat formatDbDate = new SimpleDateFormat(application.getInitParameter("db_date_fmt"));
      // Create completion date from string 
      Date completionDate = formatStDate.parse(string_date);
      // Set the record beans completion date
      recordBean.setCompletion_date(formatDbDate.format(completionDate));
      // Get the record beans start date
      Date startDate = formatDbDate.parse(recordBean.getStart_date());      
    %>
    
    <%-- Invalid entry --%>
    <%-- Check the days of the month that have 30 days --%>
    <if:IfTrue cond='<%= day > 30 && (month == 4 || month == 6 || month == 9 || month == 11) %>'>
      <jsp:setProperty name="conSumDateBean" property="error"
        value="You have entered an invalid date.<br/>Please try again" />
      <jsp:forward page="conSumDateView.jsp" />
    </if:IfTrue>
    <%-- Use the gregorian calender to check if the year is a leap year, --%>
    <%--   and that february has not got 29 days --%>
    <if:IfTrue cond='<%= (gc.isLeapYear(year) && month == 2 && day > 29) 
                     || (!gc.isLeapYear(year) && month == 2 && day > 28) %>'>
      <jsp:setProperty name="conSumDateBean" property="error"
        value="You have entered an invalid date.<br/>Please try again" />
      <jsp:forward page="conSumDateView.jsp" />
    </if:IfTrue>
    <%-- Check that the completion date is not before the start date--%>
    <if:IfTrue cond='<%= completionDate.compareTo( startDate ) < 0 %>'>
      <jsp:setProperty name="conSumDateBean" property="error"
        value="The completion date cannot be set to before the creation date.<br/>Please try again" />
      <jsp:forward page="conSumDateView.jsp" />
    </if:IfTrue>
    <%-- check that if the hours have been added then the mins should have been as well --%>
    <if:IfTrue cond="<%= conSumDateBean.getHours() != null && !conSumDateBean.getHours().equals("") &&
                        (conSumDateBean.getMins() == null || conSumDateBean.getMins().equals("")) %>">
      <jsp:setProperty name="conSumDateBean" property="error"
        value="If supplying a time, you must supply the hours AND mins." />
      <jsp:forward page="conSumDateView.jsp" />
    </if:IfTrue>
    <%-- checking that if the mins have been added then the hours should have been as well --%>
    <if:IfTrue cond="<%= conSumDateBean.getMins() != null && !conSumDateBean.getMins().equals("") &&
                        (conSumDateBean.getHours() == null || conSumDateBean.getHours().equals("")) %>">
      <jsp:setProperty name="conSumDateBean" property="error"
        value="If supplying a time, you must supply the hours AND mins." />
      <jsp:forward page="conSumDateView.jsp" />
    </if:IfTrue>
    <%-- rectify_time_h field (hrs) validation, check for integer values --%>
    <if:IfTrue cond="<%= conSumDateBean.getHours() != null && !conSumDateBean.getHours().equals("") &&
                         !helperBean.isStringInt(conSumDateBean.getHours()) %>">
      <jsp:setProperty name="conSumDateBean" property="error"
        value="If supplying a time (hrs), it must be an integer." />
      <jsp:forward page="conSumDateView.jsp" />
    </if:IfTrue>
    <%-- Check that no negative values have been entered as hours --%>
    <if:IfTrue cond="<%= conSumDateBean.getHours() != null && !conSumDateBean.getHours().equals("") &&
                         Integer.parseInt(conSumDateBean.getHours()) < 0 %>">
      <jsp:setProperty name="conSumDateBean" property="error"
        value="If supplying a time (hrs), it must NOT be less than zero." />
      <jsp:forward page="conSumDateView.jsp" />
    </if:IfTrue>
    <%-- Check that hours positive integer value is valid --%>
    <if:IfTrue cond="<%= conSumDateBean.getHours() != null && !conSumDateBean.getHours().equals("") &&
                         Integer.parseInt(conSumDateBean.getHours()) > 23 %>">
      <jsp:setProperty name="conSumDateBean" property="error"
        value="If supplying a time (hrs), it must NOT be greater than 23." />
      <jsp:forward page="conSumDateView.jsp" />
    </if:IfTrue>
    <%-- rectify_time_m field (mins) validation, check for integer values --%>
    <if:IfTrue cond="<%= conSumDateBean.getMins() != null && !conSumDateBean.getMins().equals("") &&
                         !helperBean.isStringInt(conSumDateBean.getMins()) %>">
      <jsp:setProperty name="conSumDateBean" property="error"
        value="If supplying a time (mins), it must be an integer." />
      <jsp:forward page="conSumDateView.jsp" />
    </if:IfTrue>
    <%-- Check that no negative values have been entered as minutes --%>
    <if:IfTrue cond="<%= conSumDateBean.getMins() != null && !conSumDateBean.getMins().equals("") &&
                         Integer.parseInt(conSumDateBean.getMins()) < 0 %>">
      <jsp:setProperty name="conSumDateBean" property="error"
        value="If supplying a time (mins), it must NOT be less than zero." />
      <jsp:forward page="conSumDateView.jsp" />
    </if:IfTrue>
    <%-- Check that minutes positive integer value is valid --%>
    <if:IfTrue cond="<%= conSumDateBean.getMins() != null && !conSumDateBean.getMins().equals("") &&
    Integer.parseInt(conSumDateBean.getMins()) >= 60 %>">
      <jsp:setProperty name="conSumDateBean" property="error"
        value="If supplying a time (mins), it must be less than 60." />
      <jsp:forward page="conSumDateView.jsp" />
    </if:IfTrue>
    <%-- Invalid date/time, the completion date must be older than the defaults start date/time value,
         if this is true and it is the same date, then check the completion time is after the start time --%>    
    <if:IfTrue cond='<%= completionDate.compareTo( startDate ) == 0 %>'>
      <if:IfTrue cond='<%= Integer.parseInt(conSumDateBean.getHours()) < Integer.parseInt(recordBean.getStart_time_h()) %>'>
        <jsp:setProperty name="conSumDateBean" property="error"
          value="The completion time cannot be set to before the creation time.<br/>Please try again" />
        <jsp:forward page="conSumDateView.jsp" />
      </if:IfTrue>      
      <if:IfTrue cond='<%= Integer.parseInt(conSumDateBean.getHours()) == Integer.parseInt(recordBean.getStart_time_h()) %>'>
        <if:IfTrue cond='<%= Integer.parseInt(conSumDateBean.getMins()) < Integer.parseInt(recordBean.getStart_time_m()) %>'>
          <jsp:setProperty name="conSumDateBean" property="error"
            value="The completion time cannot be set to before the creation time.<br/>Please try again" />
          <jsp:forward page="conSumDateView.jsp" />
        </if:IfTrue>
      </if:IfTrue>            
    </if:IfTrue>
        
    <%-- Valid entry --%>
    <%-- add the completion time/date to the record bean --%>
    <% recordBean.setCompletion_time_h( conSumDateBean.getHours() ); %>
    <% recordBean.setCompletion_time_m( conSumDateBean.getMins() ); %> 

    <%-- update default or worksOrder --%>
    <sess:setAttribute name="form">conSumFunc</sess:setAttribute>
    <c:import url="conSumFunc.jsp" var="webPage" />
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
    <sess:setAttribute name="previousForm">conSumDate</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">updateStatus</sess:setAttribute>
    <c:redirect url="updateStatusScript.jsp" />
  </if:IfTrue>
  
  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= conSumDateBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">conSumDate</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= conSumDateBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">conSumDate</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= conSumDateBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">conSumDate</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= conSumDateBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${conSumDateBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="conSumDateView.jsp" />
