<%@ page errorPage="error.jsp" %>
<%@ page import="com.db.DbUtils, java.text.SimpleDateFormat, java.util.*" %>
<%@ page import="com.dbb.SNoBean, com.utils.date.vsbCalendar" %>
<%@ page import="com.vsb.recordBean, com.vsb.helperBean" %>
<%@ page import="com.vsb.loginBean, com.vsb.enfActionBean, com.vsb.enfStatusBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>

<jsp:useBean id="DbUtils" scope="session" class="com.db.DbUtils" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="loginBean" scope="session" class="com.vsb.loginBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />
<jsp:useBean id="enfActionBean" scope="session" class="com.vsb.enfActionBean" />
<jsp:useBean id="enfStatusBean" scope="session" class="com.vsb.enfStatusBean" />

<%-- Only allow the use of this function if the form session variable --%>
<%-- has been correctly set --%>
<sess:equalsAttribute name="form" match="addUpdateActionStatusFunc" value="false">
  addUpdateActionStatusFunc - Permission Denied
</sess:equalsAttribute>
<sess:equalsAttribute name="form" match="addUpdateActionStatusFunc">
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
  
  <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
  <sql:statement id="stmt" conn="con1">
    <%-- Create the complaint_no to use --%>
    <% int complaint_no = Integer.parseInt(recordBean.getComplaint_no()); %>

    <%-- we need to add the new action (enf_action) record --%>
    <%-- then update the comp_enf with the new number of actions (comp_enf.actions) --%>
    <%-- and action sequence number (comp_enf.action_seq) --%>
 
    <%-- Get the suspect_ref from the comp_enf table --%>
    <% String suspect_ref = ""; %>
    <sql:query>
      SELECT suspect_ref
        FROM comp_enf
       WHERE complaint_no = '<%= recordBean.getComplaint_no() %>'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="suspect_ref" />
      <sql:wasNotNull>
        <% suspect_ref = ((String) pageContext.getAttribute("suspect_ref")).trim(); %>
      </sql:wasNotNull>
      <sql:wasNull>
        <% suspect_ref = ""; %>
      </sql:wasNull>
    </sql:resultSet>

    <%-- create enf_action record --%>
    <%-- get the previous action date if the comp_enf field has an action_seq --%>
    <% String prev_action_date = ""; %>
    <if:IfTrue cond='<%= ! recordBean.getEnf_list_action_seq().equals("") %>'>
      <sql:query>
        select action_date 
        from enf_action
        where complaint_no = <%= complaint_no %>
        and   action_seq = (
          select max(action_seq)
          from enf_action
          where complaint_no = <%= complaint_no %>
        )
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getDate position="1" to="action_date" format="<%= application.getInitParameter("db_date_fmt") %>" />
        <sql:wasNotNull>
          <% prev_action_date = ((String)pageContext.getAttribute("action_date")).trim(); %>
        </sql:wasNotNull>
      </sql:resultSet>
    </if:IfTrue>
   
    <%-- get the next action_seq number --%>
    <% SNoBean sNoBean  = new SNoBean( "java:comp/env", "jdbc/pda", "enf_action" ); %>
    <% String action_serial_no = sNoBean.getSerial_noAsString(); %> 

    <%-- Insert a new enf_action record the user picked a new action --%>
    <%-- NEEDS THE text_flag/enf_act_text ADDED - FROM THE enfStatus SCREEN. --%>
    <if:IfTrue cond='<%= ! enfActionBean.getAction_code().equals("") %>'>

      <%-- Is there any text to add --%>
      <% String action_text_flag = "N"; %>
      <if:IfTrue cond='<%= !recordBean.getEnf_action_txt().equals("") %>'>
        <% action_text_flag = "Y"; %>
      </if:IfTrue>
    
      <%-- get the delay if it exists --%>
      <% int delay = 0; %>
      <sql:query>
        select delay
        from enf_act
        where action_code = '<%= enfActionBean.getAction_code() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="delay" />
        <sql:wasNotNull>
          <if:IfTrue cond='<%= ! (((String)pageContext.getAttribute("delay")).trim()).equals("") %>'>
            <% delay = Integer.parseInt(((String)pageContext.getAttribute("delay")).trim()); %>
          </if:IfTrue>
        </sql:wasNotNull>
      </sql:resultSet>

      <%-- Now if the delay is > 0 then add the delay to todays date to get the due_date --%>
      <%-- If the delay is 0 then the due date will be null. --%>
      <% String due_date = ""; %>
      <if:IfTrue cond='<%= delay != 0 %>'>
        <% 
          vsbCalendar due_date_cal = new vsbCalendar( application.getInitParameter("db_date_fmt"));
          due_date_cal.addDays(delay);
          due_date = due_date_cal.getDateString(); 
        %>
      </if:IfTrue>     

      <sql:query>
        insert into enf_action (
          action_seq,
          complaint_no,
          action_ref,
          action_date,
          action_time_h,
          action_time_m,
          due_date,
          suspect_ref,
          aut_officer,
          enf_status,
          date_entered,
          entered_by,
          ent_time_h,
          ent_time_m,
          text_flag,
          fpcn,
          prev_action_date         
        ) values (
          <%= action_serial_no %>,
          <%= complaint_no %>,
          '<%= enfActionBean.getAction_code() %>',
          '<%= recordBean.getAction_date() %>',
          <if:IfTrue cond='<%= ! recordBean.getAction_time_h().equals("") %>'>
            '<%= recordBean.getAction_time_h() %>',
          </if:IfTrue>
          <if:IfTrue cond='<%= recordBean.getAction_time_h().equals("") %>'>
            null,
          </if:IfTrue>
          <if:IfTrue cond='<%= ! recordBean.getAction_time_m().equals("") %>'>
            '<%= recordBean.getAction_time_m() %>',
          </if:IfTrue>
          <if:IfTrue cond='<%= recordBean.getAction_time_m().equals("") %>'>
            null,
          </if:IfTrue>
          <if:IfTrue cond='<%= delay != 0 %>'>
            '<%= due_date %>',
          </if:IfTrue>
          <if:IfTrue cond='<%= delay == 0 %>'>
            null,
          </if:IfTrue>
          '<%= suspect_ref %>', 
          '<%= enfActionBean.getAutOff() %>',
          '<%= enfStatusBean.getStatus_code() %>',
          '<%= date %>',
          '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
          '<%= time_h %>',
          '<%= time_m %>',
          '<%= action_text_flag %>',
          '<%= recordBean.getEnf_fpn_ref() %>',
          <if:IfTrue cond='<%= ! prev_action_date.equals("") %>'>
            '<%= prev_action_date %>' 
          </if:IfTrue>
          <if:IfTrue cond='<%= prev_action_date.equals("") %>'>
            null
          </if:IfTrue>
        )
      </sql:query>
      <sql:execute />

      <%-- Add text to the action --%>
      <if:IfTrue cond='<%= action_text_flag.equals("Y") %>'>
        <% int enf_act_text_seq = 1; %>
        <%
          String tempTextIn = "";
  
          //get rid of newline and carriage return chars
          tempTextIn = recordBean.getEnf_action_txt();
          tempTextIn = tempTextIn.replace('\n',' ');
          tempTextIn = tempTextIn.replace('\r',' ');
        %>
  
        <%-- The text should be split into 60 char lines, and there should be a --%>
        <%-- single record for each line. --%>
        <%
          String allText = tempTextIn.trim();
          String line;
          int lineIndex;
          boolean flag = true;
          do {
            if (allText.length() <= 60) {
              line = allText;
              flag = false;
            } else {
              lineIndex = allText.lastIndexOf(" ", 60);
              // Space not found so use the whole 60
              if (lineIndex == -1) {
                lineIndex = 60;
              } else {
                lineIndex = lineIndex + 1;
              }
              line = allText.substring(0,lineIndex);
              allText = allText.substring(lineIndex);
            }
        %>
            <sql:query>
              insert into enf_act_text (
                complaint_no,
                action_seq,
                action_ref,
                action_date,
                seq,
                username,
                Doa,
                time_entered_h,
                time_entered_m,
                txt
              ) values (
                <%= complaint_no %>,
                <%= action_serial_no %>,
                '<%= enfActionBean.getAction_code() %>',
                '<%= recordBean.getAction_date() %>',
                <%= enf_act_text_seq %>,
                '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',                  
                '<%= date %>',
                '<%= time_h %>',
                '<%= time_m %>',
                '<%= DbUtils.cleanString(line) %>'
              )
            </sql:query>
            <sql:execute />
        <%
            enf_act_text_seq = enf_act_text_seq + 1;
          } while (flag == true);
        %>        
      </if:IfTrue>
     
      <%-- get count of actions for this enforcement, not including 'No Evidence' (NOT DONE YET) --%>
      <% String action_count = "0"; %>
      <sql:query>
        select count(*)
        from enf_action
        where complaint_no = <%= complaint_no %>
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="action_count" />
        <sql:wasNotNull>
          <% action_count = ((String)pageContext.getAttribute("action_count")).trim(); %>
        </sql:wasNotNull>
      </sql:resultSet>
 
      <sql:query>
        update comp_enf
        set actions = '<%= action_count %>',
          action_seq = '<%= action_serial_no %>',
          enf_status = '<%= enfStatusBean.getStatus_code() %>'
        where complaint_no = '<%= complaint_no %>'
      </sql:query>
      <sql:execute/>

    </if:IfTrue>

    <%-- update the current enf_action record if the user just changed the status --%>
    <if:IfTrue cond='<%= enfActionBean.getAction_code().equals("") %>'>
      <sql:query>
        Update enf_action
        set enf_status = '<%= enfStatusBean.getStatus_code() %>'
        where action_seq = '<%= recordBean.getEnf_list_action_seq() %>'
        and   complaint_no = '<%= complaint_no %>'
      </sql:query>
      <sql:execute />

      <sql:query>
        Update comp_enf
        set enf_status = '<%= enfStatusBean.getStatus_code() %>'
        where complaint_no = '<%= complaint_no %>'
      </sql:query>
      <sql:execute />

    </if:IfTrue>

    <%-- If the user selected the ENF_COMPLETED status, then close the enforcement --%>
    <% boolean completed = false; %>
    <% String enf_completed = ""; %>
    <sql:query>
      select c_field
      from keys
      where service_c = 'ALL'
      and   keyname = 'ENF_COMPLETED'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="enf_completed" />
      <sql:wasNotNull>
        <% enf_completed = ((String)pageContext.getAttribute("enf_completed")).trim(); %>
      </sql:wasNotNull>
    </sql:resultSet>
    <if:IfTrue cond='<%= (! enf_completed.equals("")) && enf_completed.equals(enfStatusBean.getStatus_code()) %>'>
     <% completed = true; %>
    </if:IfTrue>

    <%-- update the active occurance of the enforcement in the enforcement --%>
    <%-- list table, to processed ('P') or deleted it if completed. --%>
    <if:IfTrue cond='<%= completed == true %>'>
      <sql:query>
        UPDATE comp
           SET date_closed   = '<%= date %>',
               time_closed_h = '<%= time_h %>',
               time_closed_m = '<%= time_m %>'
         WHERE complaint_no  = '<%= complaint_no %>'
      </sql:query>
      <sql:execute />

      <%-- Close the enforcement diry record --%>
      <sql:query>
        UPDATE diry
           SET action_flag = 'C',
               dest_date = '<%= date %>',
               dest_time_h = '<%= time_h %>',
               dest_time_m = '<%= time_m %>',
               dest_user = '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>'
         WHERE source_ref = '<%= complaint_no %>'
      </sql:query>
      <sql:execute />

      <%-- delete any occurance of the enforcement from the enforcement --%>
      <%-- list table, as it has been closed. --%>
      <sql:query>
        delete from enf_list
        where complaint_no = '<%= complaint_no %>'
      </sql:query>
      <sql:execute/>
    </if:IfTrue>
    <if:IfTrue cond='<%= completed == false %>'>
      <sql:query>
        update enf_list set state = 'P'
          where complaint_no = '<%= complaint_no %>'
          and   state = 'A'
      </sql:query>
      <sql:execute/>
    </if:IfTrue>
 
  </sql:statement>
  <sql:closeConnection conn="con1"/>

  <%-- ensure that the printing error status is set to "ok" as no printing occured. --%>
  <% recordBean.setPrinting_error("ok"); %>
</sess:equalsAttribute>
