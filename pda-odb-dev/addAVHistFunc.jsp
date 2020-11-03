<%@ page errorPage="error.jsp" %>
<%@ page import="com.db.DbUtils, com.vsb.helperBean, java.text.SimpleDateFormat, java.util.*" %>
<%@ page import="java.io.IOException, javax.naming.*" %>
<%@ page import="com.vsb.recordBean, com.vsb.loginBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags"   prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags"      prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jstl/core"                 prefix="c" %>

<jsp:useBean id="DbUtils"          scope="session" class="com.db.DbUtils" />
<jsp:useBean id="helperBean"       scope="session" class="com.vsb.helperBean" />
<jsp:useBean id="recordBean"       scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="loginBean"        scope="session" class="com.vsb.loginBean" />

<%-- Only allow the use of this function if the form session variable --%>
<%-- has been correctly set --%>
<sess:equalsAttribute name="form" match="addAVHistFunc" value="false">
  addAVHistFunc - Permission Denied
</sess:equalsAttribute>
<sess:equalsAttribute name="form" match="addAVHistFunc">
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

  <%-- Get the next sequence number for the comp_av_hist table --%>
  <%
    String seqString  = recordBean.getAv_last_seq();
    Integer    seqNo  = Integer.valueOf(seqString);
    int        seqInt = seqNo.intValue();
    seqInt++;
    String new_seq_no = String.valueOf(seqInt); 
  %>
  
  <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
  <sql:statement id="stmt" conn="con1">
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

    <%-- Get po_code --%>
    <sql:query>
      SELECT po_code
      FROM pda_user
      WHERE user_name = '<%= loginBean.getUser_name() %>'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="po_code" />
    </sql:resultSet>
  
    <%-- Add the Abandoned Vehicle History --%>
    <sql:query>
      INSERT INTO comp_av_hist (
        complaint_no,
        status_ref,
        seq,
        doa,
        toa_h,
        toa_m,
        username,
        status_date,
        status_time_h,
        status_time_m,
        vehicle_position,
        notes
      ) VALUES (
        <%= recordBean.getComplaint_no() %>,
        '<%= recordBean.getAv_status_ref() %>',
        <%= new_seq_no %>,
        '<%= recordBean.getAv_doa() %>',
        '<%= recordBean.getAv_toa_h() %>',
        '<%= recordBean.getAv_toa_m() %>',
        '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
        '<%= date %>',
        '<%= time_h %>',
        '<%= time_m %>',
        '<%= recordBean.getAv_position() %>',
        '<%= recordBean.getAv_notes() %>'
      )
    </sql:query>
    <sql:execute />
    
    <%-- Update the Abandoned Vehicles sequence number --%>
    <sql:query>
      UPDATE comp_av
      SET last_seq = <%= new_seq_no %>
      WHERE complaint_no = <%= recordBean.getComplaint_no() %>
    </sql:query>
    <sql:execute />
  
  </sql:statement>
  <sql:closeConnection conn="con1"/>
  
</sess:equalsAttribute>
