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
<sess:equalsAttribute name="form" match="changeItemFaultDateFunc" value="false">
  changeItemFaultDateFunc - Permission Denied
</sess:equalsAttribute>
<sess:equalsAttribute name="form" match="changeItemFaultDateFunc">
  <%-- UPDATE ITEM FAULT CODES --%>
  
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

    SimpleDateFormat formatStDate = new SimpleDateFormat("yyyy-MM-dd");
    SimpleDateFormat formatDbDate = new SimpleDateFormat(application.getInitParameter("db_date_fmt"));
  %>
  
  <sql:connection id="con1" jndiName="java:comp/env/jdbc/pda" />
  <sql:statement id="stmt" conn="con1">
    <%-- Set up the text --%>
    <% boolean changedItem = false; %>
    <% boolean changedFault = false; %>
    <% boolean changedDate = false; %>
    <% int complaint_no = Integer.parseInt(recordBean.getComplaint_no()); %>
    <% String diry_date_due = ""; %>
    <sql:query>
      select date_due
      from diry
      where source_flag = 'C'
      and   source_ref = '<%= complaint_no %>'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getDate position="1" to="date_due" format="<%= application.getInitParameter("db_date_fmt") %>" />
      <sql:wasNotNull>
        <% diry_date_due = ((String)pageContext.getAttribute("date_due")).trim(); %>
      </sql:wasNotNull>
    </sql:resultSet>

    <if:IfTrue cond='<%= ! recordBean.getChanged_item_ref().equals(recordBean.getItem_ref()) %>' >
      <% changedItem = true; %>
    </if:IfTrue>
    <if:IfTrue cond='<%= ! recordBean.getChanged_comp_code().equals(recordBean.getComp_code()) %>' >
      <% changedFault = true; %>
    </if:IfTrue>
    <if:IfTrue cond='<%= ! recordBean.getChanged_date_due().equals(diry_date_due) && ! recordBean.getChanged_date_due().equals("") %>' >
      <% changedDate = true; %>
    </if:IfTrue>
   
    <% String notificationText = compSampDetailsBean.getText(); %>
    <if:IfTrue cond='<%= changedItem == true %>' >
      <% 
        notificationText = notificationText + " Item changed from " + recordBean.getItem_ref() + 
                           " to " + recordBean.getChanged_item_ref() + ".";
      %>
    </if:IfTrue>
    <if:IfTrue cond='<%= changedFault == true %>' >
      <% 
        notificationText = notificationText + " Fault changed from " + recordBean.getComp_code() + 
                           " to " + recordBean.getChanged_comp_code() + ".";
      %>
    </if:IfTrue>
    <if:IfTrue cond='<%= changedDate == true %>' >
      <%
        notificationText = notificationText + 
          " Inspection date changed from " + 
          helperBean.dispDate(diry_date_due, application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) + 
          " to " + 
          helperBean.dispDate(recordBean.getChanged_date_due(), application.getInitParameter("db_date_fmt"), application.getInitParameter("view_date_fmt")) + ".";
      %>
    </if:IfTrue>
    <if:IfTrue cond='<%= changedItem == true || changedFault == true || changedDate == true %>' >
      <% compSampDetailsBean.setText(notificationText); %>
    </if:IfTrue>
 
    <%-- The complaint update --%>
    <if:IfTrue cond='<%= changedItem == true %>' >
      <%-- Update the COMP record --%>
      <sql:query>
        update comp
        set item_ref     = '<%= recordBean.getChanged_item_ref() %>',
            feature_ref  = '<%= recordBean.getChanged_feature_ref() %>',
            contract_ref = '<%= recordBean.getChanged_contract_ref() %>',
            occur_day    = '<%= recordBean.getChanged_occur_day() %>',
            round_c      = '<%= recordBean.getChanged_round_c() %>',
            pa_area      = '<%= recordBean.getChanged_pa_area() %>'
        where complaint_no = '<%= recordBean.getComplaint_no() %>'
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

      <%-- Update the DIRY record --%>
      <sql:query>
        update diry
        set item_ref     = '<%= recordBean.getChanged_item_ref() %>',
            feature_ref  = '<%= recordBean.getChanged_feature_ref() %>',
            contract_ref = '<%= recordBean.getChanged_contract_ref() %>',
            pa_area      = '<%= recordBean.getChanged_pa_area() %>'
        where diry_ref = '<%= ((String)pageContext.getAttribute("comp_diry_ref")).trim() %>'
      </sql:query>
      <sql:execute />
    </if:IfTrue>
    <if:IfTrue cond='<%= changedFault == true %>' >
      <sql:query>
        update comp
        set comp_code = '<%= recordBean.getChanged_comp_code() %>'
        where complaint_no = '<%= recordBean.getComplaint_no() %>'
      </sql:query>
      <sql:execute />
    </if:IfTrue>
    <if:IfTrue cond='<%= changedDate == true %>' >
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
      <%-- Update the DIRY record --%>
      <sql:query>
        update diry
        set date_due = '<%= recordBean.getChanged_date_due() %>'
        where diry_ref = '<%= ((String)pageContext.getAttribute("comp_diry_ref")).trim() %>'
      </sql:query>
      <sql:execute />
    </if:IfTrue>

    <%-- If this has become a flycapture complaint then add a blank comp_flycap record --%>
    <%-- Data has been submitted by the user --%>
    <%-- fly capture flags --%>
    <% boolean fc_installed = false; %>
    <% boolean enhanced_fc = false; %>
    <% boolean matched_fault = false; %>
    <% boolean add_fly_cap = false; %>

    <%-- check if the fault code matched the fly capture fault code list --%>
    <sql:query>
      select count(*)
      from allk
      where lookup_func = 'FCCOMP'
       and   lookup_code = '<%= recordBean.getChanged_comp_code() %>'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="count" />
      <if:IfTrue cond='<%= Integer.parseInt(((String) pageContext.getAttribute("count")).trim()) > 0 %>' >
        <% matched_fault = true; %>
      </if:IfTrue>
    </sql:resultSet>

    <%-- check if we're using fly capture. --%>
    <sql:query>
      select c_field
      from keys
      where keyname = 'FC_INSTALLATION'
      and   service_c = 'ALL'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="c_field" />
      <if:IfTrue cond='<%= ((String) pageContext.getAttribute("c_field")).trim().equals("Y") %>' >
        <% fc_installed = true; %>
      </if:IfTrue>
    </sql:resultSet>

    <%-- check if we're using enhanced fly capture. Enhanced fly capture --%>
    <%-- only allows fly capture info to be added for specific fault codes, the --%>
    <%-- matched_fault flag above indicates if the fault matched. --%>
    <sql:query>
      select c_field
      from keys
      where keyname = 'FC_ENHANCED'
      and   service_c = 'ALL'
    </sql:query>
    <sql:resultSet id="rset">
      <sql:getColumn position="1" to="c_field" />
      <if:IfTrue cond='<%= ((String) pageContext.getAttribute("c_field")).trim().equals("Y") %>' >
        <% enhanced_fc = true; %>
      </if:IfTrue>
    </sql:resultSet>

    <if:IfTrue cond='<%= fc_installed == true %>' >
      <if:IfTrue cond='<%= enhanced_fc == true %>' >
        <if:IfTrue cond='<%= matched_fault == true %>' >
          <% add_fly_cap = true; %>
        </if:IfTrue>
        <if:IfTrue cond='<%= matched_fault == false %>' >
          <% add_fly_cap = false; %>
        </if:IfTrue>
      </if:IfTrue>
      <if:IfTrue cond='<%= enhanced_fc == false %>' >
        <% add_fly_cap = false; %>
      </if:IfTrue>
    </if:IfTrue>
    <if:IfTrue cond='<%= fc_installed == false %>' >
      <% add_fly_cap = false; %>
    </if:IfTrue>

    <%-- Check if a Flycapture complaint is already present --%>
    <%-- 20/05/2010  TW  Already declared above--%>
    <%-- int complaint_no = Integer.parseInt(recordBean.getComplaint_no()); --%>
    <sql:query>
      SELECT complaint_no
        FROM comp_flycap
       WHERE complaint_no = <%= complaint_no %>
    </sql:query>
    <sql:resultSet id="rset">
      <%-- do nothing --%>
    </sql:resultSet>
    <sql:wasNotEmpty>
      <% add_fly_cap = false; %>
    </sql:wasNotEmpty>

    <if:IfTrue cond='<%= add_fly_cap == true %>' >
      <%-- do the table insert --%>
      <sql:query>
        insert into comp_flycap (
          complaint_no
        ) values (
          '<%= recordBean.getComplaint_no() %>'
        )
      </sql:query>
      <sql:execute/>
    </if:IfTrue>
  
    <%-- delete any occurrence of the complaint from the inspection --%>
    <%-- list table, as it has been updated. --%>
    <sql:query>
      delete from insp_list
        where complaint_no = '<%= recordBean.getComplaint_no() %>'
    </sql:query>
    <sql:execute/>
  
  </sql:statement>
  <sql:closeConnection conn="con1"/>
  
  <% recordBean.setUpdate_text("Y"); %>
</sess:equalsAttribute>
