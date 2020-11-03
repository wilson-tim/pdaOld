<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.inspQueryBean, com.vsb.recordBean" %>
<%@ page import="java.util.GregorianCalendar, java.util.Date,java.text.SimpleDateFormat" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="inspQueryBean" scope="session" class="com.vsb.inspQueryBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="inspQuery" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="inspQuery" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>

    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="inspQueryBean" property="all" value="clear" />
    <jsp:setProperty name="inspQueryBean" property="*" />

    <%-- Clear the previous record --%>
    <jsp:setProperty name="recordBean" property="all" value="clear" />

  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="inspQueryBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="mainMenu" >
  <jsp:setProperty name="inspQueryBean" property="action" value="" />
  <jsp:setProperty name="inspQueryBean" property="all" value="clear" />
  <jsp:setProperty name="inspQueryBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>

<%-- Assign pda_role for use in serviceView.jsp --%>
<sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />
<sql:statement id="stmt" conn="con">
  <%-- The module is inspectors --%>
  <app:equalsInitParameter name="module" match="pda-in" >
    <sql:query>
      select c_field
      from keys
      where service_c = 'ALL'
      and   keyname = 'PDA_INSPECTOR_ROLE'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="pda_role" />
      <% recordBean.setPda_role((String) pageContext.getAttribute("pda_role")); %>
    </sql:resultSet>
  </app:equalsInitParameter>

  <%-- The module is town warden --%>
  <app:equalsInitParameter name="module" match="pda-tw" >
    <sql:query>
      select c_field
      from keys
      where service_c = 'ALL'
      and   keyname = 'PDA_WARDEN_ROLE'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="pda_role" />
      <% recordBean.setPda_role((String) pageContext.getAttribute("pda_role")); %>
    </sql:resultSet>
  </app:equalsInitParameter>
</sql:statement>
<sql:closeConnection conn="con"/>

<%-- If the user has used '*' in the input then make sure they see them as '*'s --%>
<%-- and not as '%'s symbols because of the change to '%' for matching using --%>
<%-- 'like' in the sql in inspList, see later in the code. --%>
<%
  String tempText1 = "";
  tempText1 = inspQueryBean.getInsp_site();
  inspQueryBean.setInsp_site(tempText1.replace('%','*'));
  String tempText3 = "";
  tempText3 = inspQueryBean.getComplaint_no();
  inspQueryBean.setComplaint_no(tempText3.replace('%','*'));
%>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="inspQuery" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <%-- Code to run --%>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="inspQuery" >

  <%-- Check to see if the user is using the due date in the query --%>
  <%-- INSPECTION DUE DATE --%>
  <%
    // Check if any fields are blank
    inspQueryBean.setIs_due_date_completed( false );
    if( (!inspQueryBean.getInsp_due_day().equals(""))   &&
        (!inspQueryBean.getInsp_due_month().equals("")) && 
        (!inspQueryBean.getInsp_due_year().equals("")) ) {
      inspQueryBean.setIs_due_date_completed( true );
    }
    // Check if all the fields are blank
    boolean isDueDateBlank = false;
    if( (inspQueryBean.getInsp_due_day().equals(""))   && 
        (inspQueryBean.getInsp_due_month().equals("")) && 
        (inspQueryBean.getInsp_due_year().equals("")) ) {
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
    if( inspQueryBean.getIs_due_date_completed() ) {
      // Create due date from day, month and year.
      dueDay   = Integer.parseInt(inspQueryBean.getInsp_due_day());
      dueMonth = Integer.parseInt(inspQueryBean.getInsp_due_month());
      dueYear  = Integer.parseInt(inspQueryBean.getInsp_due_year());

      // Create string representation of forms date (yyyy-MM-dd)
      due_date_string = inspQueryBean.getInsp_due_year() + "-" + 
                        inspQueryBean.getInsp_due_month() + "-" + 
                        inspQueryBean.getInsp_due_day();
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

  <%-- Next view --%>
  <if:IfTrue cond='<%= inspQueryBean.getAction().equals("Submit") %>' >
    <%-- Invalid entry --%>
    
    <%-- DUE DATE VALIDATION --%>    
    <if:IfTrue cond="<%= inspQueryBean.getIs_due_date_completed() %>">    
      <if:IfTrue cond="<%= dueDay > 30 && (dueMonth == 4 || dueMonth == 6 || dueMonth == 9 || dueMonth == 11) %>">
        <jsp:setProperty name="inspQueryBean" property="error"
          value="You have entered an invalid date.<br/>Please try again" />
        <jsp:forward page="inspQueryView.jsp" />
      </if:IfTrue>
    
      <if:IfTrue cond="<%= (due_date.isLeapYear(dueYear) && dueMonth == 2 && dueDay > 29) || (!due_date.isLeapYear(dueYear) && dueMonth == 2 && dueDay > 28) %>">
        <jsp:setProperty name="inspQueryBean" property="error"
          value="You have entered an invalid date.<br/>Please try again" />
        <jsp:forward page="inspQueryView.jsp" />
      </if:IfTrue>
    </if:IfTrue>
    <if:IfTrue cond="<%= !inspQueryBean.getIs_due_date_completed() && !isDueDateBlank %>">
      <jsp:setProperty name="inspQueryBean" property="error"
        value="You have not entered a complete due date.<br/>Please try again" />
      <jsp:forward page="inspQueryView.jsp" />
    </if:IfTrue>
    
    <%-- Valid entry --%>
    <%-- If the user has used '*' in the input then change them to '%' for --%>
    <%-- matching using 'like' in the sql in inspList --%>
    <%
      String tempText2 = "";
      tempText2 = inspQueryBean.getInsp_site();
      inspQueryBean.setInsp_site(tempText2.replace('*','%'));
      String tempText4 = "";
      tempText4 = inspQueryBean.getComplaint_no();
      inspQueryBean.setComplaint_no(tempText4.replace('%','*'));
    %>
    <%-- Set the due date values in the inspQueryBean --%>
    <% inspQueryBean.setInsp_due_date(due_date_string);       %>    

    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">inspQuery</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= inspQueryBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">inspQuery</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= inspQueryBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">inspQuery</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= inspQueryBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">inspQuery</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= inspQueryBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${inspQueryBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="inspQueryView.jsp" />
