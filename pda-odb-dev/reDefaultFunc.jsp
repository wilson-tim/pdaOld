<%@ page errorPage="error.jsp" %>
<%@ page import="com.vsb.loginBean, com.vsb.recordBean, com.vsb.helperBean" %> 
<%@ page import="java.text.SimpleDateFormat, java.util.*" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>

<jsp:useBean id="loginBean" scope="session" class="com.vsb.loginBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<%-- Make sure this is the form we are supposed to be on and also --%>
<%-- check if session has expired, if it has start at begining --%>
<sess:equalsAttribute name="form" match="reDefaultFunc" value="false">
  <%-- Blank the previousForm session --%>
  <sess:setAttribute name="previousForm"></sess:setAttribute>
  <%-- Indicate which form we are going to next --%>
  <sess:setAttribute name="form">index</sess:setAttribute>
  <jsp:forward page="index.jsp" />
</sess:equalsAttribute>

<%-- Only allow the use of this function if the form session variable --%>
<%-- has been correctly set --%>
<sess:equalsAttribute name="form" match="reDefaultFunc" value="false">
  reDefaultFunc - Permission Denied
</sess:equalsAttribute>
<sess:equalsAttribute name="form" match="reDefaultFunc">
  <%-- Do a re-default --%>
  
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
          <% default_trans_value = 0; %>
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
  
    <%-- Add a new default line to the already created default header. --%>
    
    <%-- get the max seq_no of the defaults transactions --%>
    <sql:query>
      select max(seq_no)
      from deft
      where default_no = '<%= recordBean.getDefault_no()%>'
     </sql:query>
    <sql:resultSet id="rset">
       <sql:getColumn position="1" to="max_seq_no" />
    </sql:resultSet>
    <% int max_seq_no = Integer.parseInt((String)pageContext.getAttribute("max_seq_no")); %>
    
    <%-- assign the seq_no at which to add the clear transaction at --%>
    <% int add_seq_no = max_seq_no + 1; %>
    
    <sql:query>
      select notice_type
      from deft
      where seq_no = '<%= max_seq_no %>'
      and   default_no = '<%= recordBean.getDefault_no()%>'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="deft_notice_type" />
    </sql:resultSet>
    
    <%-- adding deft record --%>
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
        credit_date,
        username,
        po_code,
        time_h,
        time_m,
        default_occ,
        default_sublevel,
        user_initials,
        credit_reason
      ) values (
        '<%= recordBean.getDefault_no() %>',
        '<%= recordBean.getItem_ref() %>',
        '<%= recordBean.getFeature_ref() %>',
        '<%= recordBean.getDefault_level() %>',
        <%= add_seq_no %>,
        'R',
        '<%= date %>',
        '<%= ((String)pageContext.getAttribute("deft_notice_type")).trim() %>',
        '<%= recordBean.getDefault_no()%>',
        '<%= recordBean.getPriority() %>',
        '<%= recordBean.getPoints() %>',
        '<%= recordBean.getValue() %>',
        'D',
        '<%= recordBean.getDefault_no()%>',
        null,
        '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
        null,
        '<%= time_h %>',
        '<%= time_m %>',
        '<%= recordBean.getDefault_occ() %>',
        null,
        null,
        null 
      )
    </sql:query>
    <sql:execute />
    
    <%-- adding defi_rect record --%>
    <sql:query>
      select max(seq_no)
      from defi_rect
      where default_no = '<%= recordBean.getDefault_no()%>'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="rect_seq_no" />
    </sql:resultSet>
    <% int rect_seq_no = Integer.parseInt((String)pageContext.getAttribute("rect_seq_no")) + 1; %>
    
    <%-- get the next defi_rect.rect_key from s_no table --%>
    <sql:query>
      select serial_no 
      from s_no
      where sn_func = 'defi_rect'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="rect_key" />
    </sql:resultSet>
    <% int rect_key = Integer.parseInt((String)pageContext.getAttribute("rect_key")); %>
  
    <%-- update the s_no table with the next defi_rect.rect_key --%>
    <sql:query>
      update s_no
      set serial_no = <%= rect_key %> + 1
      where sn_func = 'defi_rect'
    </sql:query>
    <sql:execute />
    
    <%-- Create the default item rectify date --%>
    <sql:query>
      insert into defi_rect (
        default_no,
        seq_no,
        rect_key,
        item_ref,
        feature_ref,
        rectify_date,
        rectify_time_h,
        rectify_time_m
      ) values (
        '<%= recordBean.getDefault_no()%>',
        <%= rect_seq_no %>,
        <%= rect_key %>,
        '<%= recordBean.getItem_ref() %>',
        '<%= recordBean.getFeature_ref() %>',
        '<%= recordBean.getRectify_date() %>',
        '<%= recordBean.getRectify_time_h() %>',
        '<%= recordBean.getRectify_time_m() %>'
      )
    </sql:query>
    <sql:execute />
  
    <%-- update the def_cont_i table by removing the contractor information --%>
    <sql:query>
      update def_cont_i
      set action = null,
        compl_by = null,
        printed = null,
        clear_credit = null,
        date_actioned = null,
        time_actioned_h = null,
        time_actioned_m = null,
        completion_date = null,
        completion_time_h = null,
        completion_time_m = null 
      where cust_def_no = '<%= recordBean.getDefault_no()%>'
    </sql:query>
    <sql:execute />
    
    <%-- update the points --%>
    <if:IfTrue cond='<%= (new Float(recordBean.getPoints())).floatValue() > 0.00 %>' >
      <sql:query>
        update defh
        set cum_points = cum_points + <%= recordBean.getPoints() %>
        where cust_def_no = '<%= recordBean.getDefault_no()%>'
      </sql:query>
      <sql:execute />
      
      <sql:query>
        update defi
        set cum_points = cum_points + <%= recordBean.getPoints() %>
        where default_no = '<%= recordBean.getDefault_no()%>'
      </sql:query>
      <sql:execute />
    </if:IfTrue>
    
    <%-- update the value --%>
    <if:IfTrue cond='<%= (new Float(recordBean.getValue())).floatValue() > 0.00 %>' >
      <sql:query>
        update defh
        set cum_value = cum_value + <%= recordBean.getValue() %>
        where cust_def_no = '<%= recordBean.getDefault_no()%>'
      </sql:query>
      <sql:execute />
      
      <sql:query>
        update defi
        set cum_value = cum_value + <%= recordBean.getValue() %>
        where default_no = '<%= recordBean.getDefault_no()%>'
      </sql:query>
      <sql:execute />
    </if:IfTrue>
  
    <%-- update the active occurance of the complaint in the inspection --%>
    <%-- list table, to processed ('P'). --%>
    <sql:query>
      update insp_list set state = 'P'
        where complaint_no = '<%= recordBean.getComplaint_no() %>'
        and   state = 'A'
    </sql:query>
    <sql:execute/>
    
  </sql:statement>
  <sql:closeConnection conn="con1"/>    
</sess:equalsAttribute>
