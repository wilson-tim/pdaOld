<%@ page errorPage="error.jsp" %>
<%@ page import="com.db.DbUtils, com.vsb.helperBean, java.text.SimpleDateFormat, java.util.*" %>
<%@ page import="com.vsb.recordBean, com.vsb.compSampDetailsBean, com.vsb.loginBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>

<jsp:useBean id="DbUtils" scope="session" class="com.db.DbUtils" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="compSampDetailsBean" scope="session" class="com.vsb.compSampDetailsBean" />
<jsp:useBean id="loginBean" scope="session" class="com.vsb.loginBean" />

<%-- Only allow the use of this function if the form session variable --%>
<%-- has been correctly set --%>
<sess:equalsAttribute name="form" match="noFurtherActFunc" value="false">
  noFurtherActFunc - Permission Denied
</sess:equalsAttribute>
<sess:equalsAttribute name="form" match="noFurtherActFunc">
  <%-- COMPLAINT SET TO NO FURTHER ACTION --%>
  
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
    <%-- set up the comp.comp_code; --%>
    <%-- either use the current one from the comp table (No Further Action selected) --%>
    <%-- or use the user selected one picked from pickFault2 form and stored in recordBean (Not Checked selected) --%>
    <if:IfTrue cond='<%= compSampDetailsBean.getAction().equals("No Further Action") %>' >
      <sql:query>
        select comp_code
        from comp
        where complaint_no = '<%= recordBean.getComplaint_no() %>'
      </sql:query>
      <sql:resultSet id="rset">
        <sql:getColumn position="1" to="comp_code" />
        <sql:wasNull>
          <% recordBean.setFault_code(""); %>
        </sql:wasNull>
        <sql:wasNotNull>
          <% recordBean.setFault_code((String)pageContext.getAttribute("comp_code")); %>
        </sql:wasNotNull>
      </sql:resultSet>
    </if:IfTrue>
  
    <%-- The complaint update --%>
    <sql:query>
      update comp
      set action_flag = 'N',
        dest_ref = null,
        comp_code = '<%= recordBean.getFault_code() %>',
        date_closed = '<%= date %>',
        time_closed_h = '<%= time_h %>',
        time_closed_m = '<%= time_m %>'
      where complaint_no = '<%= recordBean.getComplaint_no() %>'
    </sql:query>
    <sql:execute />
  
    <%-- delete any occurance of the complaint from the inspection --%>
    <%-- list table, as it has been closed. --%>
    <sql:query>
      delete from insp_list
        where complaint_no = '<%= recordBean.getComplaint_no() %>'
    </sql:query>
    <sql:execute/>
  
    <%-- The complaint diry update --%>
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
  
    <sql:query>
      update diry
      set action_flag = 'C',
        dest_flag = 'C',
        dest_ref = null,
        dest_date = '<%= date %>',
        dest_time_h = '<%= time_h %>',
        dest_time_m = '<%= time_m %>',
        dest_user = '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
        date_due = null
      where diry_ref = '<%= ((String)pageContext.getAttribute("comp_diry_ref")).trim() %>'
    </sql:query>
    <sql:execute />
  
  </sql:statement>
  <sql:closeConnection conn="con1"/>
  
  <% recordBean.setUpdate_text("Y"); %>
</sess:equalsAttribute>
