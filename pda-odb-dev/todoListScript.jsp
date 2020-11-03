<%@ page errorPage="error.jsp" %>
<%@ page import="java.text.SimpleDateFormat, java.util.*" %>
<%@ page import="com.db.DbUtils, com.vsb.todoListLookupBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="DbUtils" scope="session" class="com.db.DbUtils" />
<jsp:useBean id="todoListLookupBean" scope="session" class="com.vsb.todoListLookupBean" />
  <%-- Set up the date variables --%>
  <%
    // Set the default time zone to where we are, as the time zone
    // returned from sco is GMT+00:00 which is fine but doesn't mentioned
    // BST. So the default timezone has to be set to "Europe/London".
    // Any objects which use the timezone (like SimpleDateFormat) will then
    // be using the correct timezone.
    TimeZone dtz = TimeZone.getTimeZone("Europe/London");
    TimeZone.setDefault(dtz);
  
    String date;
    String time;
    String time_h;
    String time_m;
    SimpleDateFormat formatDate = new SimpleDateFormat(application.getInitParameter("db_date_fmt"));
    SimpleDateFormat formatTime = new SimpleDateFormat("HH:mm");
    SimpleDateFormat formatTime_h = new SimpleDateFormat("HH");
    SimpleDateFormat formatTime_m = new SimpleDateFormat("mm");
  
    Date currentDate = new java.util.Date();
    date = formatDate.format(currentDate);
    time = formatTime.format(currentDate);
    time_h = formatTime_h.format(currentDate);
    time_m = formatTime_m.format(currentDate);
    session.setAttribute("currentDate ",date);
  %>

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="todoList" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Data has been submitted by the user --%>
<req:existsParameter name="input" >
  <if:IfParameterEquals name="input" value="todoList" >
    <%-- Indicate which form we are in/just-come-from --%>
    <sess:setAttribute name="input"><req:parameter name="input" /></sess:setAttribute>
    
    <%-- Setup the bean with the forms data --%>
    <jsp:setProperty name="todoListLookupBean" property="all" value="clear" />
    <jsp:setProperty name="todoListLookupBean" property="*" />

  </if:IfParameterEquals>
</req:existsParameter>

<%-- clear errors --%>
<jsp:setProperty name="todoListLookupBean" property="error" value="" />

<%-- clear form fields if coming from previous form and update savedPreviousForm --%>
<sess:equalsAttribute name="input" match="mainMenu" >
  <jsp:setProperty name="todoListLookupBean" property="action" value="" />
  <jsp:setProperty name="todoListLookupBean" property="all" value="clear" />
  <jsp:setProperty name="todoListLookupBean" property="savedPreviousForm"
    value='<%= session.getAttribute("previousForm") %>' />
</sess:equalsAttribute>

<%-- All tests are done on the <form>Bean as this page cannot rely on --%>
<%-- the browser resubmitting data when refreshing or moving back to a --%>
<%-- page. --%>

<%-- Do first time through SCRIPT --%>
<sess:equalsAttribute name="input" match="todoList" value="false">
  <if:IfTrue cond='<%= ((String)session.getAttribute("input")).equals((String)session.getAttribute("previousForm")) %>' >
    <%-- Code to run --%>
  </if:IfTrue>
</sess:equalsAttribute>

<%-- Validate user entry --%>
<sess:equalsAttribute name="input" match="todoList" >
  <%-- Next view --%>
  <if:IfTrue cond='<%= todoListLookupBean.getAction().equals("Submit") %>' >
    <%-- Invalid entry --%>
    <if:IfTrue cond='<%=false %>' >
      <jsp:setProperty name="todoListLookupBean" property="error" value="Please choose a job." />
      <jsp:forward page="todoListView.jsp" />
    </if:IfTrue>
    
    <%-- Valid entry --%>
    <%
    int row_count=Integer.parseInt((String)request.getParameter("row-count"));
    for(int i=1;i<=row_count;++i){
        String serial_no=(String)request.getParameter("serial_no"+Integer.toString(i));
        String todoStatus=DbUtils.cleanString((String)request.getParameter("todoStatus"+Integer.toString(i)));
        String todoReason=DbUtils.cleanString((String)request.getParameter("todoReason"+Integer.toString(i)));
        session.setAttribute("todo"+serial_no+"Status",todoStatus);
        session.setAttribute("todo"+serial_no+"Reason",todoReason);
        boolean FoundError=false;
        if(! todoStatus.equals("")){
            if(todoStatus.equals("Done (Txt)") || todoStatus.equals("Not Done")){
                if(todoReason.length()>255){
                    session.setAttribute("todo"+serial_no+"Error","Reason field must be 255 characters or less");
                    FoundError=true;
                }
                if(todoReason.length()==0){ 
                    session.setAttribute("todo"+serial_no+"Error","Reason must be given");
                    FoundError=true;
                }
            }
            if(!FoundError){
                session.removeAttribute("todo"+serial_no+"Status");
                session.removeAttribute("todo"+serial_no+"Reason");
                session.removeAttribute("todo"+serial_no+"Error");
%>
    <%-- Update the status of todo tasks --%>
    <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
    <sql:statement id="stmt" conn="con1">
    <sql:query>
      UPDATE todo_tasks
      SET status='<%=todoStatus %>', reason='<%=todoReason %>',
        reason_date='<%=date %>',
        reason_time_h='<%=time_h %>',reason_time_m='<%=time_m %>'
      WHERE serial_no = <%= serial_no %>
    </sql:query>
    <sql:execute />
  </sql:statement>
  <sql:closeConnection conn="con1"/>

<%
            }
        }else{
            session.removeAttribute("todo"+serial_no+"Status");
            session.removeAttribute("todo"+serial_no+"Reason");
            session.removeAttribute("todo"+serial_no+"Error");
        }
    }
    %>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">todoList</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">todoList</sess:setAttribute>
    <jsp:forward page="todoListView.jsp" />
  </if:IfTrue>

  <%-- Menu view 1 --%>
  <if:IfTrue cond='<%= todoListLookupBean.getAction().equals("Inspect") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">todoList</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">inspList</sess:setAttribute>
    <c:redirect url="inspListScript.jsp" />
  </if:IfTrue>

  <%-- Menu view 2 --%>
  <if:IfTrue cond='<%= todoListLookupBean.getAction().equals("Sched/Comp") %>' >
    <%-- Invalid entry --%>
    <%-- NON --%>

    <%-- Valid entry --%>
    <%-- Indicate we are doing a menu jump --%>
    <sess:setAttribute name="menuJump">yes</sess:setAttribute>
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">todoList</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form">schedOrComp</sess:setAttribute>
    <c:redirect url="schedOrCompScript.jsp" />
  </if:IfTrue>

  <%-- Previous view --%>
  <if:IfTrue cond='<%= todoListLookupBean.getAction().equals("Back") %>' >
    <%-- Indicate which form we are coming from when we forward to another form --%>
    <sess:setAttribute name="previousForm">todoList</sess:setAttribute>
    <%-- Indicate which form we are going to next --%>
    <sess:setAttribute name="form"><%= todoListLookupBean.getSavedPreviousForm() %></sess:setAttribute>
    <c:redirect url="${todoListLookupBean.savedPreviousForm}Script.jsp" />
  </if:IfTrue>
</sess:equalsAttribute>

<%-- If the user refreshes the view --%>
<jsp:forward page="todoListView.jsp" />
