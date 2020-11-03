<%@ page errorPage="error.jsp" %>
<%@ page import="java.text.SimpleDateFormat, java.util.*" %>
<%@ page import="com.dbb.SNoBean" %>
<%@ page import="com.vsb.recordBean" %>
<%@ page import="com.vsb.loginBean" %>
<%@ page import="com.vsb.helperBean" %>
<%@ page import="com.vsb.propertyDetailsBean" %>
<%@ page import="com.vsb.addPrivateContractBean" %>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/session-1.0" prefix="sess" %>
<%@ taglib uri="http://www.servletsuite.com/servlets/iftags" prefix="if" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/dbtags" prefix="sql" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>

<jsp:useBean id="recordBean" scope="session" class="com.vsb.recordBean" />
<jsp:useBean id="loginBean" scope="session" class="com.vsb.loginBean" />
<jsp:useBean id="helperBean" scope="session" class="com.vsb.helperBean" />
<jsp:useBean id="propertyDetailsBean" scope="session" class="com.vsb.propertyDetailsBean" />
<jsp:useBean id="addPrivateContractBean" scope="session" class="com.vsb.addPrivateContractBean" />

<%-- Only allow the use of this function if the form session variable --%>
<%-- has been correctly set --%>
<sess:equalsAttribute name="form" match="addUpdatePrivateContractFunc" value="false">
  addPrivateContractFunc - Permission Denied
</sess:equalsAttribute>
<sess:equalsAttribute name="form" match="addUpdatePrivateContractFunc">
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


    // Create new simple date format (yyyy-MM-dd). This is not controlled by the context-param db_date_fmt
    // as it is just being used to turn a string date into a real date.
    SimpleDateFormat formatStDate = new SimpleDateFormat("yyyy-MM-dd");
    // This simple date format does need to be controlled by the context-param db_date_fmt as it formats
    // the converted real date back into a string but in the database format.
    SimpleDateFormat formatDbDate = new SimpleDateFormat(application.getInitParameter("db_date_fmt"));
  %>
 
  <%-- Set up the CWTN Start and End dates if they exist --%>
  <%
    String cwtn_start_date = ""; 
    String cwtn_end_date = ""; 
  %> 
  <%-- We know the dates either have valid data or they are all blank --%>
  <%-- so only try to create a string date if the date is not blank --%>
  <if:IfTrue cond='<%= !addPrivateContractBean.getCwtn_start_day().equals("") %>'>
    <%
      // Create the new date from the CWTN Start day, month and year
      cwtn_start_date  = addPrivateContractBean.getCwtn_start_year() + "-" + 
                                addPrivateContractBean.getCwtn_start_month() + "-" + 
                                addPrivateContractBean.getCwtn_start_day();
      Date tempCwtnStartDate = formatStDate.parse(cwtn_start_date);
      cwtn_start_date = formatDbDate.format(tempCwtnStartDate);
    %>
  </if:IfTrue>
  <%-- We know the dates either have valid data or they are all blank --%>
  <%-- so only try to create a string date if the date is not blank --%>
  <if:IfTrue cond='<%= !addPrivateContractBean.getCwtn_end_day().equals("") %>'>
    <%
      // Create the new date from the CWTN End day, month and year
      cwtn_end_date  = addPrivateContractBean.getCwtn_end_year() + "-" + 
                              addPrivateContractBean.getCwtn_end_month() + "-" + 
                              addPrivateContractBean.getCwtn_end_day();
      Date tempCwtnEndDate = formatStDate.parse(cwtn_end_date);
      cwtn_end_date = formatDbDate.format(tempCwtnEndDate);
    %>
  </if:IfTrue>
  
  <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
  <sql:statement id="stmt" conn="con1">
    <%-- Is there any text to add --%>
    <% String text_flag = "Y"; %>

    <%-- Is there any text to add --%>
    <if:IfTrue cond='<%= addPrivateContractBean.getNotes() == null || addPrivateContractBean.getNotes().equals("") %>' >
      <% text_flag = "N"; %>
    </if:IfTrue>

    <% String tempTextIn = ""; %>
    <%-- get rid of newline and carriage return chars --%>
    <%
      tempTextIn = addPrivateContractBean.getNotes();
      tempTextIn = tempTextIn.replace('\n',' ');
      String notes = tempTextIn.replace('\r',' ');
    %>

    <%-- Add a new private contract (trading organisation) --%>
   
    <%-- Update or Insert depending on whether a user picked a private contract --%>
    <%-- on the propertyDetails form to update. --%>
    <% int trader_ref = 0; %>
    <if:IfTrue cond='<%= propertyDetailsBean.getTrader_ref().equals("") %>' >
      <%-- get the next trader_ref --%>
      <% SNoBean sNoBean  = new SNoBean( "java:comp/env", "jdbc/pda", "trading_org" ); %>
      <% trader_ref = sNoBean.getSerial_no(); %>

      <%-- Add the trading_org record --%>
      <sql:query>
        insert into trading_org (
          trader_ref,
          site_ref,
          origin,
          last_updated,
          business_name,
          ta_name,
          contact_name,
          contact_title,
          contact_email,
          contact_tel,
          contact_mobile,
          contract_size,
          bus_category,
          status_ref,
          notes,
          disposal_method,
          exact_locn,
          cwtn_start,
          cwtn_end,
          disposer_ref,
          waste_type,
          pa_area,
          recvd_by,
          text_flag
        ) values (
          <%= trader_ref %>,
          '<%= recordBean.getSite_ref() %>',
          '<%= addPrivateContractBean.getOrigin() %>',
          '<%= date %>',
          '<%= addPrivateContractBean.getBusiness_name() %>',
          '<%= addPrivateContractBean.getTa_name() %>',
          '<%= addPrivateContractBean.getContact_name() %>',
          '<%= addPrivateContractBean.getContact_title() %>',
          '<%= addPrivateContractBean.getContact_email() %>',
          '<%= addPrivateContractBean.getContact_tel() %>',
          '<%= addPrivateContractBean.getContact_mobile() %>',
          '<%= addPrivateContractBean.getContract_size() %>',
          '<%= addPrivateContractBean.getBusiness_cat() %>',
          '<%= addPrivateContractBean.getStatus() %>',
          '<%= notes %>',
          '<%= addPrivateContractBean.getDisposal_method() %>',
          '<%= addPrivateContractBean.getExact_location() %>',
          <if:IfTrue cond = '<%= addPrivateContractBean.getCwtn_start_day().trim().equals("") %>'>
            null,
          </if:IfTrue>
          <if:IfTrue cond = '<%= !addPrivateContractBean.getCwtn_start_day().trim().equals("") %>'>
            '<%= cwtn_start_date %>',
          </if:IfTrue>
          <if:IfTrue cond = '<%= addPrivateContractBean.getCwtn_end_day().trim().equals("") %>'>
            null,
          </if:IfTrue>
          <if:IfTrue cond = '<%= !addPrivateContractBean.getCwtn_end_day().trim().equals("") %>'>
            '<%= cwtn_end_date %>',
          </if:IfTrue>
          '<%= addPrivateContractBean.getDisposer_ref() %>',
          '<%= addPrivateContractBean.getWaste_type() %>',
          '<%= addPrivateContractBean.getPa_area() %>',
          '<%= addPrivateContractBean.getRecvd_by() %>',
          '<%= text_flag %>'
        )
      </sql:query>
      <sql:execute />
    </if:IfTrue>
    <if:IfTrue cond='<%= ! propertyDetailsBean.getTrader_ref().equals("") %>' >
      <% trader_ref = Integer.parseInt(propertyDetailsBean.getTrader_ref()); %>

      <%-- update the trading_org record --%>
      <sql:query>
        update trading_org
        set origin = '<%= addPrivateContractBean.getOrigin() %>',
          last_updated = '<%= date %>',
          business_name = '<%= addPrivateContractBean.getBusiness_name() %>',
          ta_name = '<%= addPrivateContractBean.getTa_name() %>',
          contact_name = '<%= addPrivateContractBean.getContact_name() %>',
          contact_title = '<%= addPrivateContractBean.getContact_title() %>',
          contact_email = '<%= addPrivateContractBean.getContact_email() %>',
          contact_tel = '<%= addPrivateContractBean.getContact_tel() %>',
          contact_mobile = '<%= addPrivateContractBean.getContact_mobile() %>',
          contract_size = '<%= addPrivateContractBean.getContract_size() %>',
          bus_category = '<%= addPrivateContractBean.getBusiness_cat() %>',
          status_ref = '<%= addPrivateContractBean.getStatus() %>',
          notes = '<%= notes %>',
          disposal_method = '<%= addPrivateContractBean.getDisposal_method() %>',
          exact_locn = '<%= addPrivateContractBean.getExact_location() %>',
          <if:IfTrue cond = '<%= addPrivateContractBean.getCwtn_start_day().trim().equals("") %>'>
            cwtn_start = null,
          </if:IfTrue>
          <if:IfTrue cond = '<%= !addPrivateContractBean.getCwtn_start_day().trim().equals("") %>'>
            cwtn_start = '<%= cwtn_start_date %>',
          </if:IfTrue>
          <if:IfTrue cond = '<%= addPrivateContractBean.getCwtn_end_day().trim().equals("") %>'>
            cwtn_end = null,
          </if:IfTrue>
          <if:IfTrue cond = '<%= !addPrivateContractBean.getCwtn_end_day().trim().equals("") %>'>
            cwtn_end = '<%= cwtn_end_date %>',
          </if:IfTrue>
          disposer_ref = '<%= addPrivateContractBean.getDisposer_ref() %>',
          waste_type = '<%= addPrivateContractBean.getWaste_type() %>',
          pa_area = '<%= addPrivateContractBean.getPa_area() %>',
          recvd_by = '<%= addPrivateContractBean.getRecvd_by() %>',
          text_flag = '<%= text_flag %>'
        where trader_ref = <%= trader_ref %> 
      </sql:query>
      <sql:execute />
    </if:IfTrue>

    <%-- Add the trading_org_log record --%>
    <%-- If there already is a record then the seq_no gets set to the next one --%>
    <%-- otherwise it defaults to 1. --%>
    <%-- set the seq_no number value --%>
    <% pageContext.setAttribute("max_seq_no", "0"); %>
    <sql:query>
      select max(seq_no)
      from trading_org_log
      where trader_ref = <%= trader_ref %>
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="max_seq_no" />
      <sql:wasNull>
        <% pageContext.setAttribute("max_seq_no", "0"); %>
      </sql:wasNull>
    </sql:resultSet>
    <% int seq_no = Integer.parseInt((String)pageContext.getAttribute("max_seq_no")) + 1; %>

    <sql:query>
      insert into trading_org_log (
        seq_no,
        trans_date,
        trans_time_h,
        trans_time_m,
        trans_user,
        trader_ref,
        site_ref,
        origin,
        last_updated,
        business_name,
        ta_name,
        contact_name,
        contact_title,
        contact_email,
        contact_tel,
        contact_mobile,
        contract_size,
        bus_category,
        status_ref,
        notes,
        disposal_method,
        exact_locn,
        cwtn_start,
        cwtn_end,
        disposer_ref,
        waste_type,
        pa_area,
        recvd_by,
        text_flag
      ) values (
        <%= seq_no %>,
        '<%= date %>',
        '<%= time_h %>',
        '<%= time_m %>',
        '<%= helperBean.restrict(loginBean.getUser_name(), 8) %>',
        <%= trader_ref %>,
        '<%= recordBean.getSite_ref() %>',
        '<%= addPrivateContractBean.getOrigin() %>',
        '<%= date %>',
        '<%= addPrivateContractBean.getBusiness_name() %>',
        '<%= addPrivateContractBean.getTa_name() %>',
        '<%= addPrivateContractBean.getContact_name() %>',
        '<%= addPrivateContractBean.getContact_title() %>',
        '<%= addPrivateContractBean.getContact_email() %>',
        '<%= addPrivateContractBean.getContact_tel() %>',
        '<%= addPrivateContractBean.getContact_mobile() %>',
        '<%= addPrivateContractBean.getContract_size() %>',
        '<%= addPrivateContractBean.getBusiness_cat() %>',
        '<%= addPrivateContractBean.getStatus() %>',
        '<%= notes %>',
        '<%= addPrivateContractBean.getDisposal_method() %>',
        '<%= addPrivateContractBean.getExact_location() %>',
        <if:IfTrue cond = '<%= addPrivateContractBean.getCwtn_start_day().trim().equals("") %>'>
          null,
        </if:IfTrue>
        <if:IfTrue cond = '<%= !addPrivateContractBean.getCwtn_start_day().trim().equals("") %>'>
          '<%= cwtn_start_date %>',
        </if:IfTrue>
        <if:IfTrue cond = '<%= addPrivateContractBean.getCwtn_end_day().trim().equals("") %>'>
          null,
        </if:IfTrue>
        <if:IfTrue cond = '<%= !addPrivateContractBean.getCwtn_end_day().trim().equals("") %>'>
          '<%= cwtn_end_date %>',
        </if:IfTrue>
        '<%= addPrivateContractBean.getDisposer_ref() %>',
        '<%= addPrivateContractBean.getWaste_type() %>',
        '<%= addPrivateContractBean.getPa_area() %>',
        '<%= addPrivateContractBean.getRecvd_by() %>',
        '<%= text_flag %>'
      )
    </sql:query>
    <sql:execute />

  </sql:statement>
  <sql:closeConnection conn="con1"/>

  <%-- ensure that the printing error status is set to "ok" as no printing occured. --%>
  <% recordBean.setPrinting_error("ok"); %>
</sess:equalsAttribute>
