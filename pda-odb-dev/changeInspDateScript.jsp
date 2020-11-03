<%@ page errorPage="error.jsp" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat" %>
<%@ page import="com.vsb.changeInspDateBean, com.vsb.recordBean, com.vsb.helperBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="changeInspDateBean" scope="session" class="com.vsb.changeInspDateBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="changeInspDate" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="changeInspDate" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="changeInspDateBean" property="all" value="clear" />
    <jsp:setProperty name="changeInspDateBean" property="*" />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="changeInspDateBean" property="error" value="" />

<%-- Initialise the forward_direction variable, used in the skip section --%>
<% String forward_direction = "N"; %>

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="changeFaultLookup" >
  <jsp:setProperty name="changeInspDateBean" property="action" value="" />
  <jsp:setProperty name="changeInspDateBean" property="all" value="clear" />
  <jsp:setProperty name="changeInspDateBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <% forward_direction = "Y"; %>
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="changeInspDate" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <%-- Code to run --%>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Skip View Section --%>
<%-- Don't skip if coming from the view --%>
<sess:equalsAttribute name="input" match="changeInspDate" value="false">
  <%-- Only skip if allowed. --%>
  <if:IfTrue cond='#SOME-SKIP-CHECK#' >
    <%-- skip to the next page, by faking it so that it appears the user --%>
    <%-- has just processd the page and clicked an action page button. --%>
    <%-- Do backwards skip first, as forward skip sets the 'input' session variable --%>
    <if:IfTrue cond='<%= forward_direction.equals("N") %>' >
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">changeInspDate</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form"><%= changeInspDateBean.getSavedPreviousForm() %></sess:setAttribute>
      <c:redirect url="${changeInspDateBean.savedPreviousForm}Script.jsp" />
    </if:IfTrue>
    <%-- Do forwards skip --%>
    <if:IfTrue cond='<%= forward_direction.equals("Y") %>' >
      <%-- This section mimics the 'input' section at the top of the script --%>
      <%-- manually imitating a user interaction with the view, but without showing the view --%>
  
      <%-- Indicate which form we are in/just-come-from --%>
      <sess:setAttribute name="input">changeInspDate</sess:setAttribute>
  
      <%-- Setup the bean with the forms data manually --%>
      <jsp:setProperty name="changeInspDateBean" property="all" value="clear" />
      <jsp:setProperty name="changeInspDateBean" property="action" value="#SOME-ACTION-BUTTON#" />
  
    </if:IfTrue>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="changeInspDate" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= changeInspDateBean.getAction().equals("Finish") %>' >
    <%
      // Re-Inspection date for recordBean update
      // Create string representation of forms date (yyyy-MM-dd)
      String re_inspect_date = changeInspDateBean.getYear() + "-" + 
                               changeInspDateBean.getMonth() + "-" + 
                               changeInspDateBean.getDay();
      // Create new simple date format (yyyy-MM-dd). This is not controlled by the context-param db_date_fmt
      // as it is just being used to turn a string date (re_inspect_date) into a real date.
      SimpleDateFormat formatStDate = new SimpleDateFormat("yyyy-MM-dd");
      // This simple date format does need to be controlled by the context-param db_date_fmt as it formats
      // the converted re_inspect_date back into a string but in the database format.
      SimpleDateFormat formatDbDate = new SimpleDateFormat(application.getInitParameter("db_date_fmt"));
      // Create completion date from string 
      Date tempDate = formatStDate.parse(re_inspect_date);
      re_inspect_date = formatDbDate.format(tempDate);
    
      // Data for validation checks
      GregorianCalendar check_date_due = new GregorianCalendar();
      int nday = check_date_due.get(check_date_due.DAY_OF_MONTH);
      int nmonth = check_date_due.get(check_date_due.MONTH) + 1;
      int nyear = check_date_due.get(check_date_due.YEAR);

      int day = Integer.parseInt(changeInspDateBean.getDay());
      int month = Integer.parseInt(changeInspDateBean.getMonth());
      int year = Integer.parseInt(changeInspDateBean.getYear());
    %>
    
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con">
      <% int complaint_no = Integer.parseInt(recordBean.getComplaint_no()); %>
      <% String diry_date_due = ""; %>
      <sql:query>
        select date_due
        from diry
        where source_flag = 'C'
        and   source_ref = '<%= complaint_no %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getDate position="1" to="date_due" format="<%= application.getInitParameter("db_date_fmt") %>" />
        <sql:wasNotNull>
          <% diry_date_due = ((String)pageContext.getAttribute("date_due")).trim(); %>
        </sql:wasNotNull>
      </sql:resultSet>
      <% boolean changed_date = false; %>
      <if:IfTrue cond='<%= ! re_inspect_date.equals(diry_date_due) %>' >
        <%
          changed_date = true;
        %>
      </if:IfTrue>

      <%-- Invalid entry --%>
      <if:IfTrue cond="<%= day > 30 && (month == 4 || month == 6 || month == 9 || month == 11) %>">
        <jsp:setProperty name="changeInspDateBean" property="error"
          value="You have entered an invalid date.<br/>Please try again" />
        <jsp:forward page="changeInspDateView.jsp" />
      </if:IfTrue>
    
      <if:IfTrue cond="<%= (check_date_due.isLeapYear(year) && month == 2 && day > 29) || (!check_date_due.isLeapYear(year) && month == 2 && day > 28) %>">
        <jsp:setProperty name="changeInspDateBean" property="error"
          value="You have entered an invalid date.<br/>Please try again" />
        <jsp:forward page="changeInspDateView.jsp" />
      </if:IfTrue>
      
      <if:IfTrue cond="<%= (year == nyear) && (month < nmonth) && (changed_date == true) %>">
        <jsp:setProperty name="changeInspDateBean" property="error"
          value="You cannot enter a date earlier than today's.<br/>Please try again" />
        <jsp:forward page="changeInspDateView.jsp" />
      </if:IfTrue>

      <if:IfTrue cond="<%= (year == nyear) && (month == nmonth) && (day < nday) && (changed_date == true) %>">
        <jsp:setProperty name="changeInspDateBean" property="error"
          value="You cannot enter a date earlier than today's.<br/>Please try again" />
        <jsp:forward page="changeInspDateView.jsp" />
      </if:IfTrue>

      <%-- Valid entry --%>
      <% recordBean.setChanged_date_due(re_inspect_date); %>
      
      <%-- Change item, fault and date due. This will also add text into the compSampDetailsBean 'Text' field. --%>
      <sess:setAttribute name="form">changeItemFaultDateFunc</sess:setAttribute>
      <c:import url="changeItemFaultDateFunc.jsp" var="webPage" />
      <% helperBean.throwException("changeItemFaultDateFunc", (String)pageContext.getAttribute("webPage")); %>

      <%-- We will be updateing the complaint text, with what we are changing so indicate to the --%>
      <%-- addTextFunc that we are updateing the text only. --%>
      <% recordBean.setUpdate_text("Y"); %>

      <%-- add complaint text --%>
      <sess:setAttribute name="form">addTextFunc</sess:setAttribute>
      <c:import url="addTextFunc.jsp" var="webPage" />
      <% helperBean.throwException("addTextFunc", (String)pageContext.getAttribute("webPage")); %>

      <%-- run the veolia link if required --%>
      <sess:setAttribute name="form">veoliaLinkFunc</sess:setAttribute>
      <c:import url="veoliaLinkFunc.jsp" var="webPage" />
      <% helperBean.throwException("veoliaLinkFunc", (String)pageContext.getAttribute("webPage")); %>

      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm">changeInspDate</sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">updateStatus</sess:setAttribute>
      <c:redirect url="updateStatusScript.jsp" />
    </sql:statement>
    <sql:closeConnection conn="con"/>
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= changeInspDateBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">changeInspDate</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= changeInspDateBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">changeInspDate</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= changeInspDateBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">changeInspDate</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= changeInspDateBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${changeInspDateBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="changeInspDateView.jsp" />
