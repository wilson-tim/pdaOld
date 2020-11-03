<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.loginBean, com.vsb.recordBean, com.vsb.helperBean, java.util.ArrayList" %>
<%@ page import="com.dbb.SNoBean, java.text.SimpleDateFormat, java.util.*" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>

<jsp:useBean id="loginBean" scope="session" class="com.vsb.loginBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<%-- Only allow the use of this function if the form session variable --%>
<%-- has been correctly set --%>
<sess:equalsAttribute name="form" match="addDefaultFunc" value="false">
  addDefaultFunc - Permission Denied
</sess:equalsAttribute>
<sess:equalsAttribute name="form" match="addDefaultFunc">
  <%-- Do a default --%>
  
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
  
  <%-- set up variables used inside and outside of the sql connection. --%>
  <% boolean clearDefault = false; %>
  
  <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
  <sql:statement id="stmt" conn="con1">
    <%-- CREATING A DEFAULT --%>

    <%-- get the default serial number --%>
    <%-- s_no.DEFREF is the value JUST USED and NOT the value to be used next, so need to increment the --%>
    <%-- the retreived value by one. The sNoBean takes care of adding one to the retrieved value before --%>
    <%-- putting it back into the database, so be don't have to worry about that. --%>
    <% SNoBean sNoBean  = new SNoBean( "java:comp/env", "jdbc/pda", "DEFREF" ); %>
    <% int cust_def_no = sNoBean.getSerial_no() + 1;     %>
    <% recordBean.setDefault_no(String.valueOf(cust_def_no)); %>
  
    <%-- Check to see if this is WBCHousing. WBCHousing only charges the first default on any given site --%>
    <%-- once per day. So we need to check if there are any defaults that have already been raised on    --%>
    <%-- this site that have been charged. If there is then we need to blank the value/points/volume of  --%>
    <%-- this default. --%>
    <% boolean isWBCHousing = false; %>
    <sql:query>
      SELECT c_field
        FROM keys
       WHERE keyname = 'WBC_ONE_MONETARY_DEF'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="wbchousing_defaults" />
      <sql:wasNotNull>
        <if:IfTrue cond='<%= ((String)pageContext.getAttribute("wbchousing_defaults")).trim().equals("Y") %>'>
          <% isWBCHousing = true; %>
        </if:IfTrue>
      </sql:wasNotNull>
    </sql:resultSet>
    <%-- If this is WBCHousing --%>
    <%-- Check for existing transaction on this site with a transaction value greater than 0 --%>
    <if:IfTrue cond='<%= isWBCHousing %>'>
      <% double default_trans_total = 0; %>
      <% double default_trans_value = 0; %>
      <sql:query>
        SELECT value
          FROM deft, defh
         WHERE trans_date = '<%= date %>'
           AND site_ref   = '<%= recordBean.getSite_ref() %>'
           AND value <> 0.00
           AND value IS NOT NULL
           AND defh.cust_def_no = deft.default_no
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="default_trans_value" />
        <% String default_trans_string = ((String)pageContext.getAttribute("default_trans_value")).trim(); %>
        <if:IfTrue cond='<%= helperBean.isStringDouble( default_trans_string )%>'>
          <% default_trans_value  = new Double( default_trans_string ).doubleValue(); %>
        </if:IfTrue>
        <if:IfTrue cond='<%= !helperBean.isStringDouble( default_trans_string )%>'>
          <% default_trans_value += 0; %>
        </if:IfTrue>
        <% default_trans_total += default_trans_value; %>
      </sql:resultSet>
      <%-- If the total value of all transactions is greater than 0, then there has already been --%>
      <%-- a transaction against this site, today. So we need to blank the value of this default transaction --%>
      <if:IfTrue cond='<%= default_trans_total > 0 %>'>
        <% recordBean.setValue("0.00"); %>
        <% recordBean.setPoints("0.00"); %>
      </if:IfTrue>
    </if:IfTrue>    
        
    <%-- get the defh.default_no from s_no table --%>
    <% sNoBean  = new SNoBean( "java:comp/env", "jdbc/pda", "defh" ); %>
    <% int default_key = sNoBean.getSerial_no();     %>
  
    <%-- Create the default header --%>
    <sql:query>
      insert into defh (
        default_no,
        cust_def_no,
        start_date,
        start_time_h,
        start_time_m,
        site_ref,
        contract_ref,
        cum_points,
        cum_value,
        default_status,
        clear_flag
      ) values (
        '<%= default_key %>',
        '<%= cust_def_no %>',
        '<%= date %>',
        '<%= time_h %>',
        '<%= time_m %>',
        '<%= recordBean.getSite_ref() %>',
        '<%= recordBean.getContract_ref()%>',
        '<%= recordBean.getPoints() %>',
        '<%= recordBean.getValue() %>',
        'Y',
        null
      )
    </sql:query>
    <sql:execute />
  
    <%-- Get next_action --%>
    <sql:query>
      select c_field
      from keys
      where service_c = 'ALL'
      and   keyname = 'WHAT_NEXT_ACTION'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="next_action" />
    </sql:resultSet>
    <% String next_action = "N"; %>
    <if:IfTrue cond='<%= ((String)pageContext.getAttribute("next_action")).trim().equals("Y") %>' >
      <% next_action = "I"; %>
    </if:IfTrue>
  
    <%-- Create the default item --%>
    <sql:query>
      insert into defi (
        default_no,
        item_ref,
        feature_ref,
        volume,
        default_reason,
        text_flag,
        cum_points,
        cum_value,
        next_action,
        next_date,
        item_status,
        clear_date,
        default_algorithm
      ) values (
        '<%= cust_def_no %>',
        '<%= recordBean.getItem_ref() %>',
        '<%= recordBean.getFeature_ref() %>',
        '<%= recordBean.getDef_volume() %>',
        <%-- If this is a doorstepping default, the fault code is different to that of the complaint! --%>
        <%-- 29/06/2010  TW  the doorstep fault code may be a comma delimited list of fault codes --%>
        <% ArrayList doorstep_fault_codes = helperBean.splitCommaList( recordBean.getDoorstep_fault_code() ); %>
        <if:IfTrue cond='<%= !doorstep_fault_codes.contains( recordBean.getFault_code() ) %>' >
          '<%= recordBean.getFault_code() %>',
        </if:IfTrue>
        <if:IfTrue cond='<%= doorstep_fault_codes.contains( recordBean.getFault_code() ) %>' >
          '<%= recordBean.getDefault_fault_code() %>',      
        </if:IfTrue>
        null,
        '<%= recordBean.getPoints() %>',
        '<%= recordBean.getValue() %>',
        '<%= next_action %>',
        '<%= recordBean.getDate_due()%>',
        'Y',
        null,
        '<%= recordBean.getAlgorithm()%>'
      )
    </sql:query>
    <sql:execute />
  
    <%-- Create the default item contractor action (blank) --%>
    <sql:query>
      insert into def_cont_i (
        cust_def_no,
        item_ref,
        feature_ref
      ) values (
        '<%= cust_def_no %>',
        '<%= recordBean.getItem_ref() %>',
        '<%= recordBean.getFeature_ref() %>'
      )
    </sql:query>
    <sql:execute />
  
    <%-- Create the default item transaction --%>
    <sql:query>
      insert into deft (
        default_no,
        item_ref,
        feature_ref,
        default_level,
        seq_no,
        action_flag,
        trans_date,
        notice_type,
        notice_ref,
        priority_flag,
        points,
        value,
        source_flag,
        source_ref,
        username,
        po_code,
        time_h,
        time_m,
        default_occ,
        default_sublevel
      ) values (
        '<%= cust_def_no %>',
        '<%= recordBean.getItem_ref() %>',
        '<%= recordBean.getFeature_ref() %>',
        '<%= recordBean.getDefault_level()%>',
        '1',
        'D',
        '<%= date %>',
        '<%= recordBean.getNotice_no() %>',
        '<%= cust_def_no %>',
        '<%= recordBean.getPriority() %>',
        '<%= recordBean.getPoints() %>',
        '<%= recordBean.getValue() %>',
        'C',
        '<%= recordBean.getComplaint_no() %>',
        '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
        null,
        '<%= time_h %>',
        '<%= time_m %>',
        '<%= recordBean.getDefault_occ() %>',
        null
      )
    </sql:query>
    <sql:execute />
  
    <%-- Create the default item rectify date --%>
    <%-- get the next defi_rect.rect_key from s_no table --%>
    <% sNoBean  = new SNoBean( "java:comp/env", "jdbc/pda", "defi_rect" ); %>
    <% int rect_key = sNoBean.getSerial_no();     %>
  
    <sql:query>
      insert into defi_rect (
        rect_key,
        default_no,
        seq_no,
        item_ref,
        feature_ref,
        rectify_date,
        rectify_time_h,
        rectify_time_m
      ) values (
        <%= rect_key %>,
        '<%= cust_def_no %>',
        '1',
        '<%= recordBean.getItem_ref() %>',
        '<%= recordBean.getFeature_ref() %>',
        '<%= recordBean.getRectify_date() %>',
        '<%= recordBean.getRectify_time_h() %>',
        '<%= recordBean.getRectify_time_m() %>'
      )
    </sql:query>
    <sql:execute />
  
    <%-- Get the diry_ref from the complaint diry record --%>
    <sql:query>
      select diry_ref
      from diry
      where source_flag = 'C'
      and   source_ref = '<%= recordBean.getComplaint_no() %>'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="comp_diry_ref" />
    </sql:resultSet>
  
    <%-- get the default diry ref --%>
    <%-- get the next diry.diry_ref from s_no table --%>
    <% sNoBean  = new SNoBean( "java:comp/env", "jdbc/pda", "diry" ); %>
    <% int def_diry_ref = sNoBean.getSerial_no();     %>
  
    <%-- Insert a new diry record for the default --%>
    <sql:query>
      insert into diry (
        diry_ref,
        prev_record,
        source_flag,
        source_ref,
        source_date,
        source_time_h,
        source_time_m,
        source_user,
        site_ref,
        item_ref,
        contract_ref,
        inspect_ref,
        inspect_seq,
        feature_ref,
        date_due,
        pa_area,
        action_flag
      ) values (
        '<%= def_diry_ref %>',
        '<%= ((String)pageContext.getAttribute("comp_diry_ref")).trim() %>',
        'D',
        '<%= cust_def_no %>',
        '<%= date %>',
        '<%= time_h %>',
        '<%= time_m %>',
        '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
        '<%= recordBean.getSite_ref() %>',
        '<%= recordBean.getItem_ref() %>',
        '<%= recordBean.getContract_ref() %>',
        null,
        null,
        '<%= recordBean.getFeature_ref() %>',
        '<%= recordBean.getDate_due()%>',
        '<%= recordBean.getPa_area() %>',
        'I'
      )
    </sql:query>
    <sql:execute />
  
    <%-- Update the complaint diry records next_record and dest_ref fields with the --%>
    <%-- default records info. also update the complaint record. This completes the --%>
    <%-- complaint record. --%>
    <%-- Also update the original diry record with the correct details --%>
  
    <%-- The complaint record update --%>
    <sql:query>
      update comp
      set dest_ref = '<%= cust_def_no %>',
        action_flag = 'D',
        comp_code = '<%= recordBean.getFault_code() %>'
      where complaint_no = '<%= recordBean.getComplaint_no() %>'
    </sql:query>
    <sql:execute />
  
    <%-- The complaint diry update --%>
    <sql:query>
      update diry
      set next_record = '<%= def_diry_ref %>',
        dest_ref = '<%= cust_def_no %>',
        action_flag = 'D',
        dest_flag = 'D',
        dest_date = '<%= date %>',
        dest_time_h = '<%= time_h %>',
        dest_time_m = '<%= time_m %>',
        dest_user = '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
        date_due = '<%= date %>'
      where diry_ref = '<%= ((String)pageContext.getAttribute("comp_diry_ref")).trim() %>'
    </sql:query>
    <sql:execute />
  
    <%-- If the default was added to a complaint from the inspection list --%>
    <%-- (insp_list) table, then flag that complaint as being processed. --%>
    <%-- I.e. if the default route is "text" then this is a new complaint --%>
    <%-- and default, otherwise the default is against an existing complaint. --%>
    <if:IfTrue cond='<%= !(recordBean.getDefault_route().equals("text")) && !(recordBean.getDefault_route().equals("surveyAddDefault")) %>' >
      <%-- update the active occurance of the complaint in the inspection --%>
      <%-- list table, to processed ('P'). --%>
      <sql:query>
        update insp_list set state = 'P'
          where complaint_no = '<%= recordBean.getComplaint_no() %>'
          and   state = 'A'
      </sql:query>
      <sql:execute/>
    </if:IfTrue>
  
    <%-- If the algorithm used for the above default says that the next --%>
    <%-- action on the first default level (default_level=1) is 'clear' then --%>
    <%-- the newly created default should be closed as well. --%>
  
    <%-- get the next action allowed --%>
    <sql:query>
      select next_action_id
      from defp1
      where algorithm = '<%= recordBean.getAlgorithm() %>'
      and   default_level = '1'
      and   item_type = '<%= recordBean.getItem_type() %>'
      and   contract_ref = '<%= recordBean.getContract_ref() %>'
      and   priority = '<%= recordBean.getPriority() %>'
    </sql:query>
    <sql:resultSet id="rset">
       <sql:getColumn position="1" to="next_action_id" />
    </sql:resultSet>
  
    <sql:query>
      select na_clear, and_clear
      from defp2
      where next_action_id = '<%= ((String) pageContext.getAttribute("next_action_id")).trim() %>'
    </sql:query>
    <sql:resultSet id="rset">
       <sql:getColumn position="1" to="na_clear" />
       <sql:getColumn position="2" to="and_clear" />
    </sql:resultSet>
    <%
      String na_clear = ((String) pageContext.getAttribute("na_clear")).trim();
      String and_clear = ((String) pageContext.getAttribute("and_clear")).trim();
    %>
  
    <%-- check to see if the default should be cleared --%>
    <if:IfTrue cond='<%= na_clear.equals("Y") || and_clear.equals("Y") %>' >
      <% clearDefault = true; %>
    </if:IfTrue>
  
  </sql:statement>
  <sql:closeConnection conn="con1"/>
  
  <%-- Redirect to the clearDefaultFunc form if the default is to be cleared. --%>
  <if:IfTrue cond='<%= clearDefault == true %>' >
    <%-- The default needs to be cleared so set the recordBean clearDefault --%>
    <%-- attribute to "Y", to indicate this fact. --%>
    <% recordBean.setClearDefault("Y"); %>
  </if:IfTrue>
</sess:equalsAttribute>
