<%@ page errorPage="error.jsp" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat" %>
<%@ page import="com.vsb.helperBean, com.vsb.defaultDateBean, com.vsb.recordBean" %>
<%@ page import="com.dbb.DefaultAlgBean, com.db.DbQueryHandler" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="defaultDateBean" scope="session" class="com.vsb.defaultDateBean" />
<jsp:useBean id="defaultAlgBean"  scope="session" class="com.dbb.DefaultAlgBean" />
<jsp:useBean id="recordBean"      scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean"      scope="session" class="com.vsb.helperBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="defaultDate" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="defaultDate" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>

    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="defaultDateBean" property="all" value="clear" />
    <jsp:setProperty name="defaultDateBean" property="*" />
    
    <%-- Add the new values to the record --%>
    <jsp:setProperty name="recordBean" property="rectify_time_h" value='<%= defaultDateBean.getHours() %>' />
    <jsp:setProperty name="recordBean" property="rectify_time_m" value='<%= defaultDateBean.getMins() %>' />
  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="defaultDateBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="streetLength" >
  <jsp:setProperty name="defaultDateBean" property="action" value="" />
  <jsp:setProperty name="defaultDateBean" property="all" value="clear" />
  <jsp:setProperty name="defaultDateBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<sess:equalsAttribute name="input" match="defaultDetails" >
  <jsp:setProperty name="defaultDateBean" property="action" value="" />
  <jsp:setProperty name="defaultDateBean" property="all" value="clear" />
  <jsp:setProperty name="defaultDateBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refresshing or moving back to a --%>
<%-- page. --%>

<%-- Check to see if we should show the VIEW or go to the next SCRIPT, --%>
<%-- but only the first time through the SCRIPT. --%>
<%-- Also get/calculate the volume, points and value. --%>
<sess:equalsAttribute name="input" match="defaultDate" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals("streetLength") || ((String)session.getAttribute("input")).equals("defaultDetails") %>' >
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />    
    <sql:statement id="stmt" conn="con">
      <% recordBean.setShow_view("N"); %>
      <%-- check to see what allowed to edit --%>
      <sql:query>
        select prompt_for_rectify
        from defa
        where item_type = '<%= recordBean.getItem_type() %>'
        and   notice_rep_no = '<%= recordBean.getNotice_no() %>'
        and   default_algorithm = '<%= recordBean.getAlgorithm() %>'
       </sql:query>
      <sql:resultSet id="rset">
         <sql:getColumn position="1" to="edit_date" />
         <sql:wasNotNull>
           <% recordBean.setShow_view(((String) pageContext.getAttribute("edit_date")).trim()); %>
         </sql:wasNotNull>
         <sql:wasNull>
           <% recordBean.setShow_view("Y"); %>
         </sql:wasNull>
      </sql:resultSet>
      <sql:wasEmpty>
        <% recordBean.setShow_view("Y"); %>
      </sql:wasEmpty>
      
      <%-- retrieve the defp4 record via the defp1.cb_time_id --%>
      <sql:query>
        select time_delay, report_by_hrs1, report_by_mins1, report_by_hrs2,
           report_by_mins2, report_by_hrs3, report_by_mins3, correct_by_hrs1,
           correct_by_mins1, correct_by_hrs2, correct_by_mins2, correct_by_hrs3,
           correct_by_mins3, working_week, clock_start_hrs, clock_start_mins,
           clock_stop_hrs, clock_stop_mins, cut_off_hrs, cut_off_mins
        from defp4
        where cb_time_id = (
          select cb_time_id
          from defp1
          where algorithm = '<%= recordBean.getAlgorithm() %>'
          and   default_level = '<%= recordBean.getDefault_level() %>'
          and   item_type = '<%= recordBean.getItem_type() %>'
          and   contract_ref = '<%= recordBean.getContract_ref() %>'
          and   priority = '<%= recordBean.getPriority() %>'
        )
       </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="defp4_time_delay" />
        <sql:wasNull>
          <% pageContext.setAttribute("defp4_time_delay",""); %>
        </sql:wasNull>
    
        <sql:getColumn position="2" to="defp4_report_by_hrs1" />
        <sql:wasNull>
          <% pageContext.setAttribute("defp4_report_by_hrs1",""); %>
        </sql:wasNull>
    
        <sql:getColumn position="3" to="defp4_report_by_mins1" />
        <sql:wasNull>
          <% pageContext.setAttribute("defp4_report_by_mins1",""); %>
        </sql:wasNull>
    
        <sql:getColumn position="4" to="defp4_report_by_hrs2" />
        <sql:wasNull>
          <% pageContext.setAttribute("defp4_report_by_hrs2",""); %>
        </sql:wasNull>
    
        <sql:getColumn position="5" to="defp4_report_by_mins2" />
        <sql:wasNull>
          <% pageContext.setAttribute("defp4_report_by_mins2",""); %>
        </sql:wasNull>
    
        <sql:getColumn position="6" to="defp4_report_by_hrs3" />
        <sql:wasNull>
          <% pageContext.setAttribute("defp4_report_by_hrs3",""); %>
        </sql:wasNull>
    
        <sql:getColumn position="7" to="defp4_report_by_mins3" />
        <sql:wasNull>
          <% pageContext.setAttribute("defp4_report_by_mins3",""); %>
        </sql:wasNull>
    
        <sql:getColumn position="8" to="defp4_correct_by_hrs1" />
        <sql:wasNull>
          <% pageContext.setAttribute("defp4_correct_by_hrs1",""); %>
        </sql:wasNull>
    
        <sql:getColumn position="9" to="defp4_correct_by_mins1" />
        <sql:wasNull>
          <% pageContext.setAttribute("defp4_correct_by_mins1",""); %>
        </sql:wasNull>
    
        <sql:getColumn position="10" to="defp4_correct_by_hrs2" />
        <sql:wasNull>
          <% pageContext.setAttribute("defp4_correct_by_hrs2",""); %>
        </sql:wasNull>
    
        <sql:getColumn position="11" to="defp4_correct_by_mins2" />
        <sql:wasNull>
          <% pageContext.setAttribute("defp4_correct_by_mins2",""); %>
        </sql:wasNull>
    
        <sql:getColumn position="12" to="defp4_correct_by_hrs3" />
        <sql:wasNull>
          <% pageContext.setAttribute("defp4_correct_by_hrs3",""); %>
        </sql:wasNull>
    
        <sql:getColumn position="13" to="defp4_correct_by_mins3" />
        <sql:wasNull>
          <% pageContext.setAttribute("defp4_correct_by_mins3",""); %>
        </sql:wasNull>
    
        <sql:getColumn position="14" to="defp4_working_week" />
        <sql:wasNull>
          <% pageContext.setAttribute("defp4_working_week",""); %>
        </sql:wasNull>
    
        <sql:getColumn position="15" to="defp4_clock_start_hrs" />
        <sql:wasNull>
          <% pageContext.setAttribute("defp4_clock_start_hrs",""); %>
        </sql:wasNull>
    
        <sql:getColumn position="16" to="defp4_clock_start_mins" />
        <sql:wasNull>
          <% pageContext.setAttribute("defp4_clock_start_mins",""); %>
        </sql:wasNull>
    
        <sql:getColumn position="17" to="defp4_clock_stop_hrs" />
        <sql:wasNull>
          <% pageContext.setAttribute("defp4_clock_stop_hrs",""); %>
        </sql:wasNull>
    
        <sql:getColumn position="18" to="defp4_clock_stop_mins" />
        <sql:wasNull>
          <% pageContext.setAttribute("defp4_clock_stop_mins",""); %>
        </sql:wasNull>
    
        <sql:getColumn position="19" to="defp4_cut_off_hrs" />
        <sql:wasNull>
          <% pageContext.setAttribute("defp4_cut_off_hrs",""); %>
        </sql:wasNull>
    
        <sql:getColumn position="20" to="defp4_cut_off_mins" />
        <sql:wasNull>
          <% pageContext.setAttribute("defp4_cut_off_mins",""); %>
        </sql:wasNull>
      </sql:resultSet>
      <sql:wasEmpty>
        <% 
          pageContext.setAttribute("defp4_time_delay","");
          pageContext.setAttribute("defp4_report_by_hrs1","");
          pageContext.setAttribute("defp4_report_by_mins1","");
          pageContext.setAttribute("defp4_report_by_hrs2","");
          pageContext.setAttribute("defp4_report_by_mins2","");
          pageContext.setAttribute("defp4_report_by_hrs3","");
          pageContext.setAttribute("defp4_report_by_mins3","");
          pageContext.setAttribute("defp4_correct_by_hrs1","");
          pageContext.setAttribute("defp4_correct_by_mins1","");
          pageContext.setAttribute("defp4_correct_by_hrs2","");
          pageContext.setAttribute("defp4_correct_by_mins2","");
          pageContext.setAttribute("defp4_correct_by_hrs3","");
          pageContext.setAttribute("defp4_correct_by_mins3","");
          pageContext.setAttribute("defp4_working_week","");
          pageContext.setAttribute("defp4_clock_start_hrs","");
          pageContext.setAttribute("defp4_clock_start_mins","");
          pageContext.setAttribute("defp4_clock_stop_hrs","");
          pageContext.setAttribute("defp4_clock_stop_mins","");
          pageContext.setAttribute("defp4_cut_off_hrs","");
          pageContext.setAttribute("defp4_cut_off_mins","");
        %>
      </sql:wasEmpty>
      
      <%-- Calculate the rectify date for the default --%>
      <%
        // Set the default time zone to where we are, as the time zone
        // returned from sco is GMT+00:00 which is fine but doesn't mentioned
        // BST. So the default timezone has to be set to "Europe/London".
        // Any objects which use the timezone (like SimpleDateFormat) will then
        // be using the correct timezone.
        TimeZone dtz = TimeZone.getTimeZone("Europe/London");
        TimeZone.setDefault(dtz);
      
        SimpleDateFormat formatDate = new SimpleDateFormat(application.getInitParameter("db_date_fmt"));
        SimpleDateFormat formatTime_h = new SimpleDateFormat("HH");
        SimpleDateFormat formatTime_m = new SimpleDateFormat("mm");
        
        // Create a new database handle
        DbQueryHandler dbHandle = new DbQueryHandler();        
        dbHandle.connect("java:comp/env", "jdbc/pda");        
        
        GregorianCalendar rectify_date = defaultAlgBean.get_correct_by_dates(
          ((String)pageContext.getAttribute("defp4_time_delay")).trim(),
          ((String)pageContext.getAttribute("defp4_report_by_hrs1")).trim(),
          ((String)pageContext.getAttribute("defp4_report_by_mins1")).trim(),
          ((String)pageContext.getAttribute("defp4_report_by_hrs2")).trim(),
          ((String)pageContext.getAttribute("defp4_report_by_mins2")).trim(),
          ((String)pageContext.getAttribute("defp4_report_by_hrs3")).trim(),
          ((String)pageContext.getAttribute("defp4_report_by_mins3")).trim(),
          ((String)pageContext.getAttribute("defp4_correct_by_hrs1")).trim(),
          ((String)pageContext.getAttribute("defp4_correct_by_mins1")).trim(),
          ((String)pageContext.getAttribute("defp4_correct_by_hrs2")).trim(),
          ((String)pageContext.getAttribute("defp4_correct_by_mins2")).trim(),
          ((String)pageContext.getAttribute("defp4_correct_by_hrs3")).trim(),
          ((String)pageContext.getAttribute("defp4_correct_by_mins3")).trim(),
          ((String)pageContext.getAttribute("defp4_working_week")).trim(),
          ((String)pageContext.getAttribute("defp4_clock_start_hrs")).trim(),
          ((String)pageContext.getAttribute("defp4_clock_start_mins")).trim(),
          ((String)pageContext.getAttribute("defp4_clock_stop_hrs")).trim(),
          ((String)pageContext.getAttribute("defp4_clock_stop_mins")).trim(),
          ((String)pageContext.getAttribute("defp4_cut_off_hrs")).trim(),
          ((String)pageContext.getAttribute("defp4_cut_off_mins")).trim(),
          application.getInitParameter("db_date_fmt"),
          dbHandle          
           );
          
        dbHandle.disconnect();
           
        recordBean.setRectify_date(formatDate.format(rectify_date.getTime()));
        recordBean.setRectify_time_h(formatTime_h.format(rectify_date.getTime()));
        recordBean.setRectify_time_m(formatTime_m.format(rectify_date.getTime()));
        
      %>

    </sql:statement>
    <sql:closeConnection conn="con"/>

    <if:IfTrue cond='<%= recordBean.getShow_view().equals("N") %>' >
      <%-- nothing to do in this form so move to the next --%>
      <%-- Indicate that the input section has been passed through --%>
      <sess:setAttribute name="input">defaultDate</sess:setAttribute>
      <%-- Indicate which form we are coming from when we forward to another form --%>
      <sess:setAttribute name="previousForm"><%= defaultDateBean.getSavedPreviousForm() %></sess:setAttribute>
      <%-- Indicate which form we are going to next --%>
      <sess:setAttribute name="form">defaultAdditional</sess:setAttribute>
      <c:redirect url="defaultAdditionalScript.jsp" />
    </if:IfTrue>
    
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="defaultDate" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= defaultDateBean.getAction().equals("Finish") %>' >
    <%
      // Re-Inspection date
      GregorianCalendar re_date = new GregorianCalendar();
      int day = Integer.parseInt(defaultDateBean.getDay());
      int month = Integer.parseInt(defaultDateBean.getMonth());
      int year = Integer.parseInt(defaultDateBean.getYear());
      
      // Create string representation of forms date (yyyy-MM-dd)
      String re_inspect_date = defaultDateBean.getYear() + "-" + 
                               defaultDateBean.getMonth() + "-" + 
                               defaultDateBean.getDay();
      // Create new simple date format (yyyy-MM-dd). This is not controlled by the context-param db_date_fmt
      // as it is just being used to turn a string date (re_inspect_date) into a real date.
      SimpleDateFormat formatStDate = new SimpleDateFormat("yyyy-MM-dd");
      // This simple date format does need to be controlled by the context-param db_date_fmt as it formats
      // the converted re_inspect_date back into a string but in the database format.
      SimpleDateFormat formatDbDate = new SimpleDateFormat(application.getInitParameter("db_date_fmt"));
      // Create completion date from string 
      Date tempDate = formatStDate.parse(re_inspect_date);
      re_inspect_date = formatDbDate.format(tempDate);
      
      int nday = re_date.get(re_date.DAY_OF_MONTH);
      int nmonth = re_date.get(re_date.MONTH) + 1;
      int nyear = re_date.get(re_date.YEAR);
    %>
   
    <%-- Check that the date the user entered is not excluded in the whiteboard dates --%>
    <% boolean isValidDate = false; %>
    <% String exclusion_yn = "N";   %>
    <sql:connection id="con" jndiName="java:comp/env/jdbc/pda" />    
    <sql:statement id="stmt" conn="con">
      <sql:query>
        SELECT exclusion_yn
          FROM whiteboard_dtl
         WHERE calendar_date = '<%= recordBean.getRectify_date() %>'
      </sql:query>
      <sql:resultSet id="rset">          
        <sql:getColumn position="1" to="exclusion_yn" />
        <sql:wasNull>
          <% pageContext.setAttribute("exclusion_yn","N"); %>
        </sql:wasNull>
      </sql:resultSet>
      <sql:wasEmpty>
        <% pageContext.setAttribute("exclusion_yn","N"); %>
      </sql:wasEmpty>
      <% exclusion_yn = ((String)pageContext.getAttribute("exclusion_yn")).trim(); %>      
    </sql:statement>
    <sql:closeConnection conn="con"/>
    
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%= exclusion_yn.equals("Y") || exclusion_yn.equals("y") %>'>
      <jsp:setProperty name="defaultDateBean" property="error"
        value="You have entered an excluded date.<br/>Please try again" />
      <jsp:forward page="defaultDateView.jsp" />
    </if:IfTrue>
    
    <if:IfTrue cond="<%= day > 30 && (month == 4 || month == 6 || month == 9 || month == 11) %>">
      <jsp:setProperty name="defaultDateBean" property="error"
        value="You have entered an invalid date.<br/>Please try again" />
      <jsp:forward page="defaultDateView.jsp" />
    </if:IfTrue>
    
    <if:IfTrue cond="<%= (re_date.isLeapYear(year) && month == 2 && day > 29) || (!re_date.isLeapYear(year) && month == 2 && day > 28) %>">
      <jsp:setProperty name="defaultDateBean" property="error"
        value="You have entered an invalid date.<br/>Please try again" />
      <jsp:forward page="defaultDateView.jsp" />
    </if:IfTrue>
    
    <if:IfTrue cond="<%= year == nyear && (month < nmonth) %>">
      <jsp:setProperty name="defaultDateBean" property="error"
        value="You cannot enter a date earlier than today's.<br/>Please try again" />
      <jsp:forward page="defaultDateView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond="<%= year == nyear && (month == nmonth && day < nday) %>">
      <jsp:setProperty name="defaultDateBean" property="error"
        value="You cannot enter a date earlier than today's.<br/>Please try again" />
      <jsp:forward page="defaultDateView.jsp" />
    </if:IfTrue>

    <%-- checking that if the hours have been added then the mins should have been as well --%>
    <if:IfTrue cond="<%= defaultDateBean.getHours() != null && !defaultDateBean.getHours().equals("") && (defaultDateBean.getMins() == null || defaultDateBean.getMins().equals("")) %>">
      <jsp:setProperty name="defaultDateBean" property="error"
        value="If supplying a time, you must supply the hours AND mins." />
      <jsp:forward page="defaultDateView.jsp" />
    </if:IfTrue>

    <%-- checking that if the mins have been added then the hours should have been as well --%>
    <if:IfTrue cond="<%= defaultDateBean.getMins() != null && !defaultDateBean.getMins().equals("") && (defaultDateBean.getHours() == null || defaultDateBean.getHours().equals("")) %>">
      <jsp:setProperty name="defaultDateBean" property="error"
        value="If supplying a time, you must supply the hours AND mins." />
      <jsp:forward page="defaultDateView.jsp" />
    </if:IfTrue>
    
    <%-- rectify_time_h field (hrs) validation --%>
    <if:IfTrue cond="<%= defaultDateBean.getHours() != null && !defaultDateBean.getHours().equals("") && !helperBean.isStringInt(defaultDateBean.getHours()) %>">
      <jsp:setProperty name="defaultDateBean" property="error"
        value="If supplying a time (hrs), it must be an integer." />
      <jsp:forward page="defaultDateView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond="<%= defaultDateBean.getHours() != null && !defaultDateBean.getHours().equals("") && Integer.parseInt(defaultDateBean.getHours()) < 0 %>">
      <jsp:setProperty name="defaultDateBean" property="error"
        value="If supplying a time (hrs), it must NOT be less than zero." />
      <jsp:forward page="defaultDateView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond="<%= defaultDateBean.getHours() != null && !defaultDateBean.getHours().equals("") && Integer.parseInt(defaultDateBean.getHours()) > 23 %>">
      <jsp:setProperty name="defaultDateBean" property="error"
        value="If supplying a time (hrs), it must NOT be greater than 23." />
      <jsp:forward page="defaultDateView.jsp" />
    </if:IfTrue>

    <%-- rectify_time_m field (mins) validation --%>
    <if:IfTrue cond="<%= defaultDateBean.getMins() != null && !defaultDateBean.getMins().equals("") && !helperBean.isStringInt(defaultDateBean.getMins()) %>">
      <jsp:setProperty name="defaultDateBean" property="error"
        value="If supplying a time (mins), it must be an integer." />
      <jsp:forward page="defaultDateView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond="<%= defaultDateBean.getMins() != null && !defaultDateBean.getMins().equals("") && Integer.parseInt(defaultDateBean.getMins()) < 0 %>">
      <jsp:setProperty name="defaultDateBean" property="error"
        value="If supplying a time (mins), it must NOT be less than zero." />
      <jsp:forward page="defaultDateView.jsp" />
    </if:IfTrue>

    <if:IfTrue cond="<%= defaultDateBean.getMins() != null && !defaultDateBean.getMins().equals("") && Integer.parseInt(defaultDateBean.getMins()) >= 60 %>">
      <jsp:setProperty name="defaultDateBean" property="error"
        value="If supplying a time (mins), it must be less than 60." />
      <jsp:forward page="defaultDateView.jsp" />
    </if:IfTrue>

    <%-- Valid entry --%>
    <%-- add the rectify date to the record bean --%>
    <% recordBean.setRectify_date(re_inspect_date); %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">defaultDate</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">defaultAdditional</sess:setAttribute>
    <c:redirect url="defaultAdditionalScript.jsp" />
  </if:IfTrue>
  
  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= defaultDateBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">defaultDate</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= defaultDateBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>
    
    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">defaultDate</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= defaultDateBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">defaultDate</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= defaultDateBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${defaultDateBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="defaultDateView.jsp" />
