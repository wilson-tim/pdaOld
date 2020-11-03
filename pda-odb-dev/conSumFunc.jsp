<%@ page errorPage="error.jsp" %>
<%@ page import="com.db.DbUtils, com.vsb.helperBean" %>
<%@ page import="java.text.SimpleDateFormat, java.util.*, java.io.IOException" %>
<%@ page import="java.io.IOException, javax.naming.*" %>
<%@ page import="com.vsb.conSumDefaultDetailsBean" %>
<%@ page import="com.vsb.conSumWODetailsBean" %>
<%@ page import="com.vsb.recordBean, com.vsb.loginBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<jsp:useBean id="DbUtils" scope="session" class="com.db.DbUtils" />
<jsp:useBean id="conSumDefaultDetailsBean" scope="session" class="com.vsb.conSumDefaultDetailsBean" />
<jsp:useBean id="conSumWODetailsBean" scope="session" class="com.vsb.conSumWODetailsBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />
<jsp:useBean id="loginBean" scope="session" class="com.vsb.loginBean" />

<%-- Only allow the use of this function if the form session variable --%>
<%-- has been correctly set --%>
<sess:equalsAttribute name="form" match="conSumFunc" value="false">
  conSumFunc - Permission Denied
</sess:equalsAttribute>
<sess:equalsAttribute name="form" match="conSumFunc">
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
  %>
  
  <sql:connection id="con2" jndiName="java:comp/env/jdbc/pda" />
  <sql:statement id="stmt2" conn="con2">
  
  <%-- DEFAULTS SECTION--%>
  <if:IfTrue cond='<%= recordBean.getComp_action_flag().equals("D") %>' >
  
    <%-- Update the def_cont_i action to the new action --%>
    <sql:query>
      UPDATE def_cont_i
      SET action = '<%= conSumDefaultDetailsBean.getActionTaken() %>',
      date_actioned = '<%= date %>',
      time_actioned_h = '<%= time_h %>',
      time_actioned_m = '<%= time_m %>'
      WHERE cust_def_no = <%= recordBean.getDefault_no() %>
    </sql:query>
    <sql:execute />
    <%-- Get the maximum sequence number --%>
    <sql:query>
      SELECT MAX(seq_no)
      FROM def_act_hist
      WHERE cust_def_no = <%= recordBean.getDefault_no() %>
    </sql:query>
    <sql:resultSet id="rs2">
      <sql:getColumn position="1" to="max_def_seq_no" />
      <sql:wasNull>
        <% pageContext.setAttribute("max_def_seq_no", "0"); %>
      </sql:wasNull>
    </sql:resultSet>
    <sql:wasEmpty>
      <% pageContext.setAttribute("max_def_seq_no", "0"); %>
    </sql:wasEmpty>
          
    <%-- Create the next serial number --%>
    <% int hist_seq_no = Integer.parseInt((String)pageContext.getAttribute("max_def_seq_no")) + 1; %>
        
    <%-- Add new def_act_hist row --%>
    <sql:query>
      INSERT INTO def_act_hist
      VALUES (
      '<%= recordBean.getDefault_no() %>',
      <%= hist_seq_no %>,
      '<%= conSumDefaultDetailsBean.getActionTaken() %>',
      '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
      '<%= date %>',
      '<%= time_h %>',
      '<%= time_m %>')         
    </sql:query>
    <sql:execute />
    
    <%-- Add the completion date/time if the default has been 'Actioned' --%>
    <if:IfTrue cond='<%= conSumDefaultDetailsBean.getActionTaken().equals("A") %>' >
      <sql:query>
        UPDATE def_cont_i
        SET completion_date = '<%= recordBean.getCompletion_date() %>',
            completion_time_h ='<%= recordBean.getCompletion_time_h() %>',
            completion_time_m = '<%= recordBean.getCompletion_time_m() %>'
        WHERE cust_def_no = '<%= recordBean.getDefault_no() %>'
      </sql:query>
      <sql:execute />
    </if:IfTrue>
  
    <%-- Set the status of the complaint to PENDING in the con_sum_list --%>
    <sql:query>
      UPDATE con_sum_list
      SET state = 'P'
      WHERE complaint_no = '<%= recordBean.getComplaint_no() %>'
    </sql:query>
    <sql:execute />
  </if:IfTrue>
  
  <%-- WORKS ORDERS SECTION--%>
  <if:IfTrue cond='<%= recordBean.getComp_action_flag().equals("W") %>' >
    <%-- Retrieve which wo_h_stat was selected --%>
    <% pageContext.setAttribute("works_order_action", ""); %>  
    <sql:query>
      SELECT wo_h_stat
        FROM wo_stat
       WHERE wo_stat_desc = '<%= conSumWODetailsBean.getActionTaken() %>'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="works_order_action" />
      <sql:wasNull>
        <% pageContext.setAttribute("works_order_action", "Are you in here?"); %>    
      </sql:wasNull>
    </sql:resultSet>
    <%-- Change the status of the wo_h_stat --%>
    <sql:query>
      UPDATE wo_h
      SET wo_h_stat = '<%= ((String)pageContext.getAttribute("works_order_action")).trim() %>'
      WHERE wo_ref  = '<%= recordBean.getWo_ref() %>'
      AND wo_suffix = '<%= recordBean.getWo_suffix() %>'            
    </sql:query>
    <sql:execute />    
  
    <%-- Insert new entry into the wo_stat_hist table --%>
    <sql:query>
      SELECT MAX(seq_no)
        FROM wo_stat_hist
       WHERE wo_ref  = '<%= recordBean.getWo_ref() %>'
       AND wo_suffix = '<%= recordBean.getWo_suffix() %>'        
    </sql:query>
    <sql:resultSet id="rs3">
      <sql:getColumn position="1" to="max_wo_seq_no" />
      <sql:wasNull>
        <% pageContext.setAttribute("max_wo_seq_no", "0"); %>
      </sql:wasNull>
    </sql:resultSet>
    <sql:wasEmpty>
      <% pageContext.setAttribute("max_wo_seq_no", "0"); %>
    </sql:wasEmpty>  
    <%-- Create the next serial number --%>
    <% int wo_hist_seq_no = Integer.parseInt((String)pageContext.getAttribute("max_wo_seq_no")) + 1; %>
    <sql:query>
      INSERT INTO wo_stat_hist
      VALUES(
        '<%= recordBean.getWo_ref() %>',
        '<%= recordBean.getWo_suffix() %>',
         <%= wo_hist_seq_no %>,
        '<%= recordBean.getWo_h_stat() %>',
        '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
        '<%= date %>',
        '<%= time_h %>',
        '<%= time_m %>')
    </sql:query>
    <sql:execute />  
    
    <%-- Update the contractors text reminders --%>
    <sql:query>
      UPDATE wo_cont_h
      SET cont_rem1 = '<%=conSumWODetailsBean.getCont_rem1() %>',
          cont_rem2 = '<%=conSumWODetailsBean.getCont_rem2() %>'
      WHERE wo_ref  = '<%= recordBean.getWo_ref() %>'
      AND wo_suffix = '<%= recordBean.getWo_suffix() %>'    
    </sql:query>
    <sql:execute />  
    
    <%-- Update cont_canc if the Works Order has been cancelled --%>  
    <if:IfTrue cond='<%= conSumWODetailsBean.getActionTaken().equals("CANCELLED") %>' >
      <sql:query>  
        UPDATE wo_cont_h
        SET cont_canc = 'Y'
        WHERE wo_ref  = '<%= recordBean.getWo_ref() %>'
        AND wo_suffix = '<%= recordBean.getWo_suffix() %>'    
      </sql:query>
      <sql:execute />

      <%-- Set the complaints date/time closed fields --%>
      <sql:query>  
        UPDATE comp
        SET date_closed    = '<%= date %>',
            time_closed_h  = '<%= time_h %>',
            time_closed_m  = '<%= time_m %>'
        WHERE complaint_no = '<%= recordBean.getComplaint_no() %>'
      </sql:query>
      <sql:execute />

      <%-- Delete this works order from con_sum_list--%>
      <sql:query>  
        DELETE FROM con_sum_list
        WHERE complaint_no  = '<%= recordBean.getComplaint_no() %>'
      </sql:query>
      <sql:execute />

      <%-- getting the information for the notify_customer service call --%>
      <% String notify_customer = "N"; %>
      <sql:query>
        select c_field
        from keys
        where service_c = 'ALL'
        and   keyname = 'NOTIFY_CUSTOMER'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="notify_customer" />
        <sql:wasNotNull>
          <% notify_customer = ((String)pageContext.getAttribute("notify_customer")).trim(); %>
        </sql:wasNotNull>
      </sql:resultSet>

      <%-- Make the notify_customer web service call --%>
      <if:IfTrue cond='<%= notify_customer.equals("Y") %>'>
        <%
          // notify_customer client environmental variables from the java:comp/env
          // JNDI resource.
          // The output of the printing client is the string 'ok' if no errors occur.
          // alternatelly an error message or java exception are returned as strings.
          
          // obtain the initial context, which holds the server/web.xml environment variables.
          Context initCtx = new InitialContext();
          Context envCtx = (Context) initCtx.lookup("java:comp/env");
         
          // Put all values that are going to be used in the <c:import ...> call, into the pageContext
          // So that the <c:import ...> tag can access them. 
          pageContext.setAttribute("notify_service", (String)envCtx.lookup("notify_service"));
          pageContext.setAttribute("contender_home", (String)envCtx.lookup("contender_home"));
          pageContext.setAttribute("system_path", (String)envCtx.lookup("system_path"));
          pageContext.setAttribute("cdev_db", (String)envCtx.lookup("cdev_db"));
          pageContext.setAttribute("COMPLAINT_NO", recordBean.getComplaint_no());
        %>
  
        <%-- Make the web service call, the returned value is stored in the --%>
        <%-- pageContext variable "webPage" --%> 
        <%-- Need to catch the web service call, just incase the service is inaccesible --%>
        <c:catch var="caughtError"> 
          <c:import url="${notify_service}" var="webPage" >
            <c:param name="contender_home" value="${contender_home}" />
            <c:param name="system_path" value="${system_path}" />
            <c:param name="cdev_db" value="${cdev_db}" />
            <c:param name="complaint_no" value="${COMPLAINT_NO}" />
          </c:import>
        </c:catch>
          
        <%
          String returnedValue = "";
          Exception caughtError = (Exception)pageContext.getAttribute("caughtError");
          if (caughtError == null) {
            // No caught error so use value returned from web service. This will be "ok" if
            // everything went ok.
            returnedValue = ((String)pageContext.getAttribute("webPage")).trim();
          } else {
            // There is a caught error so use that value 
            returnedValue = caughtError.toString().trim();
          }
        %>
  
        <%-- Only output an error message --%> 
        <if:IfTrue cond='<%= ! returnedValue.equals("ok") %>'>
          <%
            // Set the output value into the page scope
            pageContext.setAttribute("output", returnedValue);
          %>
          <c:out value="${output}" escapeXml="false" />
        </if:IfTrue>
      </if:IfTrue>

    </if:IfTrue>
    
    <%-- Add the completion date/time if the works order has been 'CLEARED' --%>
    <if:IfTrue cond='<%= conSumWODetailsBean.getActionTaken().equals("CLEARED") %>' >
      <sql:query>
        UPDATE wo_cont_h
        SET completion_date = '<%= recordBean.getCompletion_date() %>',
            completion_time_h ='<%= recordBean.getCompletion_time_h() %>',
            completion_time_m = '<%= recordBean.getCompletion_time_m() %>'
        WHERE wo_ref  = '<%= recordBean.getWo_ref() %>'
        AND wo_suffix = '<%= recordBean.getWo_suffix() %>'
      </sql:query>
      <sql:execute />
      <%-- Set the status of the complaint to PENDING in con_sum_list --%>
      <sql:query>
        UPDATE con_sum_list
        SET state = 'P'
        WHERE complaint_no  = '<%= recordBean.getComplaint_no() %>'
      </sql:query>
      <sql:execute />
    </if:IfTrue>
  </if:IfTrue>
  
  </sql:statement>
  <sql:closeConnection conn="con2"/>  
</sess:equalsAttribute>
