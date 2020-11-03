<%@ page errorPage="error.jsp" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat" %>
<%@ page import="com.vsb.woDetailsBean, com.vsb.woTaskBean, com.vsb.helperBean" %>
<%@ page import="com.vsb.recordBean, com.vsb.defectDetailsBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="woDetailsBean"     scope="session" class="com.vsb.woDetailsBean" />
<jsp:useBean id="woTaskBean"        scope="session" class="com.vsb.woTaskBean" />
<jsp:useBean id="helperBean"        scope="session" class="com.vsb.helperBean" />
<jsp:useBean id="recordBean"        scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="defectDetailsBean" scope="session" class="com.vsb.defectDetailsBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="woDetails" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="woDetails" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="woDetailsBean" property="all" value="clear" />
    <jsp:setProperty name="woDetailsBean" property="*" />

    <%-- Add the new values to the record --%>
    <% Iterator woi_task_refs = woTaskBean.iterator();       %>
    <% while( woi_task_refs.hasNext() ) {                    %>
    <%   String woi_task_ref = (String)woi_task_refs.next(); %>
    <%   String woi_task_rate = request.getParameter(woi_task_ref + "|wo_item_price"); %>
    <%   String woi_task_volume = request.getParameter(woi_task_ref + "|wo_volume");   %>
    <%   woDetailsBean.setWoi_task_rate( woi_task_ref, woi_task_rate );                %>
    <%   woDetailsBean.setWoi_task_volume( woi_task_ref, woi_task_volume );            %>
    <% } // END while loop woi_task_refs %>
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="woDetailsBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="woTask" >
  <jsp:setProperty name="woDetailsBean" property="action" value="" />
  <jsp:setProperty name="woDetailsBean" property="all" value="bean" />
  <jsp:setProperty name="woDetailsBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
  <%-- Clear the date held in the recordBean's wo_due_date, as it is used in the view. --%>
  <jsp:setProperty name="recordBean" property="wo_due_date" value="" />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="woDetails" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals("woTask") %>' >
    <%-- Code to run --%>
    <%-- Set up the date variables --%>
    <%
      // Set the default time zone to where we are, as the time zone
      // returned from sco is GMT+00:00 which is fine but doesn't mentioned
      // BST. So the default timezone has to be set to "Europe/London".
      // Any objects which use the timezone (like SimpleDateFormat) will then
      // be using the correct timezone.
      TimeZone dtz = TimeZone.getTimeZone("Europe/London");
      TimeZone.setDefault(dtz);

      SimpleDateFormat formatDate = new SimpleDateFormat(application.getInitParameter("db_date_fmt"));
      Date date;

      // todays date
      Date currentDate = new java.util.Date();
      String now_date = formatDate.format(currentDate);
 
      // set the correct date to use in the form
      if (recordBean.getWo_due_date().equals("")) {
        // set the date to todays date
        date = new java.util.Date();
      } else {
        // set the date to the stored date as it exists
        date = formatDate.parse(recordBean.getWo_due_date());
      }
  
      GregorianCalendar gregDate = new GregorianCalendar();
      gregDate.setTime(date);
    %>
    <%-- Set up the woDetails bean for each of the tasks in the woTaskBean --%>    
    <% Iterator woi_task_refs = woTaskBean.iterator(); %>
    <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con1">
    <% while( woi_task_refs.hasNext() ) { %>
      <% String[] taskDetails = new String[4];               %>
      <% String task_rate = "0.00";                          %>
      <% String task_vol  = "1.00";                          %>
      <% String task_desc = "";                              %>
      <% String woi_task_ref = (String)woi_task_refs.next(); %>
      <%-- Get the task description --%>
      <sql:query>
        SELECT task_desc
          FROM task
         WHERE task_ref = '<%= woi_task_ref %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="task_desc" />
        <sql:wasNotNull>
          <% task_desc = ((String)pageContext.getAttribute("task_desc")).trim(); %>
        </sql:wasNotNull>          
      </sql:resultSet>
      <%-- Get the tasks rate --%>
      <sql:query>
        SELECT task_rate
          FROM ta_r
         WHERE task_ref = '<%= woi_task_ref %>'
           AND contract_ref = '<%= recordBean.getWo_contract_ref() %>'
           AND rate_band_code = 'SELL'
           AND cont_cycle_no = '<%= recordBean.getCont_cycle_no() %>'
           AND start_date = (
               SELECT max(start_date)
                 FROM ta_r
                WHERE task_ref = '<%= woi_task_ref %>'
                  AND contract_ref = '<%= recordBean.getWo_contract_ref() %>'
                  AND rate_band_code = 'SELL'
                  AND cont_cycle_no = '<%= recordBean.getCont_cycle_no() %>'
                  AND start_date < '<%= now_date %>'
           )
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="task_rate" />
        <sql:wasNotNull>
          <% task_rate = ((String)pageContext.getAttribute("task_rate")).trim(); %>
        </sql:wasNotNull>          
      </sql:resultSet>
      <%-- If this is a defect works order we can set the area and linear volumes --%>
      <if:IfTrue cond='<%= !recordBean.getDefect_flag().equals("") && !recordBean.getDefect_flag().equals("N") %>'>
        <% String linear_or_area = ""; %>
        <%-- Check if the task is meant for the linear of area measurement --%>      
        <sql:query>
          SELECT linear_or_area
            FROM measurement_task
           WHERE task_ref  = '<%= woi_task_ref %>'
             AND wo_suffix = '<%= recordBean.getWo_suffix() %>'
             AND wo_type_f = '<%= recordBean.getWo_type_f() %>'
             AND priority  = '<%= recordBean.getDefect_priority() %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="linear_or_area" />
          <sql:wasNotNull>
            <% linear_or_area = ((String)pageContext.getAttribute("linear_or_area")).trim(); %>
            <if:IfTrue cond='<%= linear_or_area.equals("L") %>'>
              <% task_vol = defectDetailsBean.getLinear(); %>
            </if:IfTrue>
            <if:IfTrue cond='<%= linear_or_area.equals("A") %>'>
              <% task_vol = defectDetailsBean.getArea(); %>
            </if:IfTrue>
          </sql:wasNotNull>
        </sql:resultSet>
      </if:IfTrue>
      <%-- Create the new details for this task --%>
      <% taskDetails[0] = task_desc; %>
      <% taskDetails[1] = task_rate; %>
      <% taskDetails[2] = task_vol;  %>
      <%-- Add the new details to the woDetailsBean --%>
      <% woDetailsBean.add( woi_task_ref, taskDetails );  %>
    <% } // End While woi_task_refs %>
    </sql:statement>
    <sql:closeConnection conn="con1"/>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="woDetails" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= woDetailsBean.getAction().equals("Add Text") ||
                       woDetailsBean.getAction().equals("Submit") ||
                       woDetailsBean.getAction().equals("Finish") %>' >
    <%
      // Todays date and time
      String date;
      String time_h;
      String time_m;
      SimpleDateFormat formatDate = new SimpleDateFormat(application.getInitParameter("db_date_fmt"));
      SimpleDateFormat formatTime_h = new SimpleDateFormat("HH");
      SimpleDateFormat formatTime_m = new SimpleDateFormat("mm");
      Date currentDate = new java.util.Date();
      date = formatDate.format(currentDate);
      time_h = formatTime_h.format(currentDate);
      time_m = formatTime_m.format(currentDate);
    
      // due date
    	GregorianCalendar now_date = new GregorianCalendar();
    	int day = Integer.parseInt(woDetailsBean.getDay());
    	int month = Integer.parseInt(woDetailsBean.getMonth());
    	int year = Integer.parseInt(woDetailsBean.getYear());

      // Create string representation of forms date (yyyy-MM-dd)
    	String due_date = woDetailsBean.getYear() + "-" +
                        woDetailsBean.getMonth() + "-" + 
                        woDetailsBean.getDay();
      // Create new simple date format (yyyy-MM-dd). This is not controlled by the context-param db_date_fmt
      // as it is just being used to turn a string date (due_date) into a real date.
      SimpleDateFormat formatStDate = new SimpleDateFormat("yyyy-MM-dd");
      // This simple date format does need to be controlled by the context-param db_date_fmt as it formats
      // the converted due_date back into a string but in the database format.
      SimpleDateFormat formatDbDate = new SimpleDateFormat(application.getInitParameter("db_date_fmt"));
      // Create completion date from string 
      Date tempDate = formatStDate.parse(due_date);
      due_date = formatDbDate.format(tempDate);
        
    	int nday = now_date.get(now_date.DAY_OF_MONTH);
    	int nmonth = now_date.get(now_date.MONTH) + 1;
    	int nyear = now_date.get(now_date.YEAR);

      // set the works order due date
      recordBean.setWo_due_date(due_date);
    %>
    
    <%-- Invalid entry --%>
    <%-- Go through each task and check for validation --%>
    <% Iterator woi_task_refs = woTaskBean.iterator();       %>
    <% double wo_line_total = (double) 0.00;                 %>      
    <% while( woi_task_refs.hasNext() ) {                    %>
      <% double line_total = (double) 0.00;                    %>      
      <% String woi_task_ref = (String)woi_task_refs.next();   %>
      <if:IfTrue cond='<%=woDetailsBean.getWoi_task_rate( woi_task_ref ) == null || 
                          woDetailsBean.getWoi_task_rate( woi_task_ref ).equals("") %>' >
        <jsp:setProperty name="woDetailsBean" property="error"
          value="The unit price for <%= woi_task_ref %> must not be blank." />
        <jsp:forward page="woDetailsView.jsp" />
      </if:IfTrue>
  
      <if:IfTrue cond='<%= !helperBean.isStringDouble(woDetailsBean.getWoi_task_rate( woi_task_ref )) %>' >
        <jsp:setProperty name="woDetailsBean" property="error"
          value="The unit price for <%= woi_task_ref %> must be a number." />
        <jsp:forward page="woDetailsView.jsp" />
      </if:IfTrue>
  
      <if:IfTrue cond='<%=woDetailsBean.getWoi_task_volume( woi_task_ref ) == null || 
                          woDetailsBean.getWoi_task_volume( woi_task_ref ).equals("") %>' >
        <jsp:setProperty name="woDetailsBean" property="error"
          value="The quantity for <%= woi_task_ref %> must not be blank." />
        <jsp:forward page="woDetailsView.jsp" />
      </if:IfTrue>
  
      <if:IfTrue cond='<%= !helperBean.isStringDouble(woDetailsBean.getWoi_task_volume( woi_task_ref )) %>' >
        <jsp:setProperty name="woDetailsBean" property="error"
          value="The quantity for <%= woi_task_ref %> must be a number." />
        <jsp:forward page="woDetailsView.jsp" />
      </if:IfTrue>
    
      <% 
        double unit_of_measure = (double) 1.00;
        double vol = (double) 0.00;
        double item = (double) 0.00;
      %>
      <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
      <sql:statement id="stmt" conn="con1">
        <%-- Calculate the total value of all the lines, as we are only entering one line --%>
        <%-- this is the same as entering the line total --%>
        <sql:query>
          select unit_of_meas
          from task
          where task_ref = '<%= woi_task_ref %>'
        </sql:query>
        <sql:resultSet id="rset">
          <sql:getColumn position="1" to="unit_of_meas" />
          <if:IfTrue cond='<%= pageContext.getAttribute("unit_of_meas") != null && !((String)pageContext.getAttribute("unit_of_meas")).trim().equals("") %>' >
            <% unit_of_measure = (new Double((String)pageContext.getAttribute("unit_of_meas"))).doubleValue(); %>
          </if:IfTrue>
        </sql:resultSet>
        
        <% 
          vol  = (new Double(woDetailsBean.getWoi_task_volume( woi_task_ref ))).doubleValue();
          item = (new Double(woDetailsBean.getWoi_task_rate( woi_task_ref ))).doubleValue();
          line_total = vol * item / unit_of_measure;
          wo_line_total += line_total;
        %>
      </sql:statement>
      <sql:closeConnection conn="con1"/>
  
      <if:IfTrue cond='<%= item > 999.9999 %>' >
        <jsp:setProperty name="woDetailsBean" property="error"
          value="The unit price for <%= woi_task_ref %> must be less than 999.9999" />
      	<jsp:forward page="woDetailsView.jsp" />
      </if:IfTrue>
      
      <if:IfTrue cond='<%= line_total > 999999.99 %>' >
        <jsp:setProperty name="woDetailsBean" property="error"
          value="The line total for <%= woi_task_ref %> is more than 999999.99, please reduce the volume." />
      	<jsp:forward page="woDetailsView.jsp" />
      </if:IfTrue>

      <%-- Set the value of this lines total as it has passed validation --%>
      <% woDetailsBean.setLine_total( woi_task_ref, String.valueOf(line_total) ); %>
      
    <%-- End Woi task reference validation --%> 
    <% } // END while loop woi_task_ref %>

    
    <%-- Set the value of this works orders line total --%>
    <% recordBean.setWo_line_total( String.valueOf(wo_line_total) ); %>
    
    <if:IfTrue cond="<%= day > 30 && (month == 4 || month == 6 || month == 9 || month == 11) %>">
      <jsp:setProperty name="woDetailsBean" property="error"
        value="You have entered an invalid date.<br/>Please try again" />
    	<jsp:forward page="woDetailsView.jsp" />
    </if:IfTrue>
    
    <if:IfTrue cond="<%= (now_date.isLeapYear(year) && month == 2 && day > 29) || (!(now_date.isLeapYear(year)) && month == 2 && day > 28) %>">
      <jsp:setProperty name="woDetailsBean" property="error"
        value="You have entered an invalid date.<br/>Please try again" />
    	<jsp:forward page="woDetailsView.jsp" />
    </if:IfTrue>
    
    <if:IfTrue cond="<%= year == nyear && (month < nmonth) %>">
      <jsp:setProperty name="woDetailsBean" property="error"
        value="You cannot enter a date earlier than today's.<br/>Please try again" />
    	<jsp:forward page="woDetailsView.jsp" />
    </if:IfTrue>
    
    <if:IfTrue cond="<%= year == nyear && (month == nmonth && day < nday) %>">
      <jsp:setProperty name="woDetailsBean" property="error"
        value="You cannot enter a date earlier than today's.<br/>Please try again" />
    	<jsp:forward page="woDetailsView.jsp" />
    </if:IfTrue>
  </if:IfTrue>

  
  <%-- Valid entry --%>
  <%-- As the "Submit" button exists, we are in the CompOrSched route --%>
  <%-- But if the works order is a trees service, or the works order is a statutory item and the service is Hways --%>
  <%-- then process the works order and complaint here and then go to updateStatus form. --%>
  <if:IfTrue cond='<%= woDetailsBean.getAction().equals("Submit") %>' >
    <%-- add complaint --%>
    <sess:setAttribute name="form">addComplaintFunc</sess:setAttribute>
    <c:import url="addComplaintFunc.jsp" var="webPage" />
    <% helperBean.throwException("addComplaintFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- add works order --%>
    <sess:setAttribute name="form">addWorksOrderFunc</sess:setAttribute>
    <c:import url="addWorksOrderFunc.jsp" var="webPage" />
    <% helperBean.throwException("addWorksOrder", (String)pageContext.getAttribute("webPage")); %>

    <%-- add complaint text --%>
    <sess:setAttribute name="form">addTextFunc</sess:setAttribute>
    <c:import url="addTextFunc.jsp" var="webPage" />
    <% helperBean.throwException("addTextFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- run the veolia link if required --%>
    <sess:setAttribute name="form">veoliaLinkFunc</sess:setAttribute>
    <c:import url="veoliaLinkFunc.jsp" var="webPage" />
    <% helperBean.throwException("veoliaLinkFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">woDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">updateStatus</sess:setAttribute>
    <c:redirect url="updateStatusScript.jsp" />
  </if:IfTrue>
    
  <%-- As the "Add Text" button exists, we are in the CompOrSched route --%>
  <%-- so we will be creating a complaint therefore need the text form. --%>
  <if:IfTrue cond='<%= woDetailsBean.getAction().equals("Add Text") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">woDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <%-- As we are in the CompOrSched route and if this is a flyCapture then don't allow enforcements --%>
    <if:IfTrue cond='<%= recordBean.getFly_cap_flag().equals("Y") %>' >
      <sess:setAttribute name="form">text</sess:setAttribute>
      <c:redirect url="textScript.jsp" />
    </if:IfTrue>
    <if:IfTrue cond='<%= ! recordBean.getFly_cap_flag().equals("Y") %>' >
      <sess:setAttribute name="form">addEnforcement</sess:setAttribute>
      <c:redirect url="addEnforcementScript.jsp" />
    </if:IfTrue>
  </if:IfTrue>

  <%-- As the "Finish" button exists, we are in the compSampDetails route --%>
  <%-- so we are an AV and already have a complaint, a defect without a complaint --%>
  <%-- or are just a sample/inspect complaint. --%>
  <if:IfTrue cond='<%= woDetailsBean.getAction().equals("Finish") %>' >
    <%-- update Defect Complaint --%>
    <if:IfTrue cond='<%= recordBean.getDefect_flag().equals("A") %>'>
      <%-- update Defect --%>
      <sess:setAttribute name="form">updateDefectFunc</sess:setAttribute>
      <c:import url="updateDefectFunc.jsp" var="webPage" />
      <% helperBean.throwException("updateDefectFunc", (String)pageContext.getAttribute("webPage")); %>
    </if:IfTrue>
    
    <%-- Add AV Complaint and Works Order --%>
    <if:IfTrue cond='<%= recordBean.getService_c().equals(recordBean.getAv_service()) %>'>
      <sess:setAttribute name="form">addAVFunc</sess:setAttribute>
      <c:import url="addAVFunc.jsp" var="webPage" />
      <% helperBean.throwException((String)pageContext.getAttribute("webPage")); %>
      <%-- Check if the user wants to add a Works Order --%>
      <if:IfTrue cond='<%= recordBean.getAv_action_flag().equals("W") %>'>
        <sess:setAttribute name="form">addWorksOrderFunc</sess:setAttribute>
        <c:import url="addWorksOrderFunc.jsp" var="webPage" />
        <% helperBean.throwException((String)pageContext.getAttribute("webPage")); %>
      </if:IfTrue>
    </if:IfTrue>
    
    <%-- Add the additional stuff for graffiti and flyCapture Inspections --%>
    <%-- update flycapture --%>
    <if:IfTrue cond='<%= recordBean.getUser_triggered().equals("flyCapUpdate") %>' >
      <%-- Set the action flag to be 'H' for a Hold enquiry or 'N' for no further action --%>
      <app:equalsInitParameter name="fly_cap_h_or_n" match="H">
        <% recordBean.setAction_flag("H"); %>
      </app:equalsInitParameter>
      <app:equalsInitParameter name="fly_cap_h_or_n" match="N">
        <% recordBean.setAction_flag("N"); %>
      </app:equalsInitParameter>

      <%-- add/update Fly Capture Details details --%>
      <sess:setAttribute name="form">updateFlyCapFunc</sess:setAttribute>
      <c:import url="updateFlyCapFunc.jsp" var="webPage" />
      <% helperBean.throwException("updateFlyCapFunc", (String)pageContext.getAttribute("webPage")); %>
    </if:IfTrue>

    <%-- update graffiti --%>
    <if:IfTrue cond='<%= recordBean.getUser_triggered().equals("graffDetails") %>' >
      <%-- add graffiti details --%>
      <sess:setAttribute name="form">addDartGraffFunc</sess:setAttribute>
      <c:import url="addDartGraffFunc.jsp" var="webPage" />
      <% helperBean.throwException("addDartGraffFunc", (String)pageContext.getAttribute("webPage")); %>
    </if:IfTrue>

    <%-- Add a Works Order for a sample/inspect complaint --%>
    <if:IfTrue cond='<%= !recordBean.getService_c().equals(recordBean.getAv_service()) %>'>
      <sess:setAttribute name="form">addWorksOrderFunc</sess:setAttribute>
      <c:import url="addWorksOrderFunc.jsp" var="webPage" />
      <% helperBean.throwException("addWorksOrderFunc", (String)pageContext.getAttribute("webPage")); %>
    </if:IfTrue>

    <%-- add complaint text --%>
    <sess:setAttribute name="form">addTextFunc</sess:setAttribute>
    <c:import url="addTextFunc.jsp" var="webPage" />
    <% helperBean.throwException("addTextFunc", (String)pageContext.getAttribute("webPage")); %>
    
    <%-- run the veolia link if required --%>
    <sess:setAttribute name="form">veoliaLinkFunc</sess:setAttribute>
    <c:import url="veoliaLinkFunc.jsp" var="webPage" />
    <% helperBean.throwException("veoliaLinkFunc", (String)pageContext.getAttribute("webPage")); %>

    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">woDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">updateStatus</sess:setAttribute>
    <c:redirect url="updateStatusScript.jsp" />
  </if:IfTrue>
  
  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= woDetailsBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">woDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= woDetailsBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">woDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= woDetailsBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">woDetails</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= woDetailsBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${woDetailsBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="woDetailsView.jsp" />
