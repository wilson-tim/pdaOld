<%@ page errorPage="error.jsp" %>
<%@ page import="com.db.DbUtils, java.text.SimpleDateFormat, java.util.*" %>
<%@ page import="com.dbb.SNoBean, com.utils.date.vsbCalendar" %>
<%@ page import="com.vsb.recordBean" %>
<%@ page import="com.vsb.loginBean" %>
<%@ page import="com.vsb.helperBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/application-1.0" prefix="app" %>

<jsp:useBean id="DbUtils" scope="session" class="com.db.DbUtils" />
<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="loginBean" scope="session" class="com.vsb.loginBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />

<%-- Only allow the use of this function if the form session variable --%>
<%-- has been correctly set --%>
<sess:equalsAttribute name="form" match="updateFlyCapFunc" value="false">
  updateFlyCapFunc - Permission Denied
</sess:equalsAttribute>
<sess:equalsAttribute name="form" match="updateFlyCapFunc">
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
    <%-- As this is a fly capture there will already be a comp_flycap record --%>
    <%-- so update it with the new values --%>
    <% int complaint_no = Integer.parseInt(recordBean.getComplaint_no()); %>
    <% double load_qty = (new Float(recordBean.getLoad_qty())).floatValue(); %>
    <% double unit_cost = (new Float(recordBean.getLoad_unit_cost())).floatValue(); %>
    <% double load_est_cost = helperBean.roundDouble(load_qty * unit_cost, 2); %>
    <sql:query>
      update comp_flycap
      set landtype_ref = '<%= recordBean.getLand_type() %>',
          dominant_waste_ref = '<%= recordBean.getDom_waste_type() %>',
          dominant_waste_qty = <%= recordBean.getDom_waste_qty() %>,
          load_ref = '<%= recordBean.getLoad_ref() %>',
          load_unit_cost = <%= recordBean.getLoad_unit_cost() %>,
          load_qty = <%= recordBean.getLoad_qty() %>,
          load_est_cost = <%= load_est_cost %>
      where complaint_no = <%= complaint_no %>
    </sql:query>
    <sql:execute />

    <%-- Set complaint to Hold enquiry or no further action --%>
    <app:equalsInitParameter name="fly_cap_h_or_n" match="H">
      <%-- set complaint to HOLD --%>
      <sql:query>
        update comp
        set action_flag = 'H',
          dest_ref = null
        where complaint_no = <%= complaint_no %>
      </sql:query>
      <sql:execute />
    </app:equalsInitParameter>
    <app:equalsInitParameter name="fly_cap_h_or_n" match="N">
      <%-- set complaint to NO FURTHER ACTION --%>
      <sql:query>
        update comp
        set action_flag = 'N',
          dest_ref = null,
          date_closed = '<%= date %>',
          time_closed_h = '<%= time_h %>',
          time_closed_m = '<%= time_m %>'
        where complaint_no = <%= complaint_no %>
      </sql:query>
      <sql:execute />

      <%-- The complaint diry update --%>
      <%-- Get the diry_ref from the complaint diry record --%>
      <sql:query>
        select diry_ref
        from diry
        where source_flag = 'C'
        and   source_ref = <%= complaint_no %>
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
        where diry_ref = <%= ((String)pageContext.getAttribute("comp_diry_ref")).trim() %>
      </sql:query>
      <sql:execute />
    </app:equalsInitParameter>

    <%-- delete any occurance of the complaint from the inspection --%>
    <%-- list table, as it should no longer be accessed. --%>
    <sql:query>
      delete from insp_list
        where complaint_no = '<%= complaint_no %>'
    </sql:query>
    <sql:execute/>
 
  </sql:statement>
  <sql:closeConnection conn="con1"/>

  <%-- ensure that the printing error status is set to "ok" as no printing occured. --%>
  <% recordBean.setPrinting_error("ok"); %>
</sess:equalsAttribute>
